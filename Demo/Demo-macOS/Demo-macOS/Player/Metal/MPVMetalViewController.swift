import Foundation
import AppKit
import CoreMedia
import Libmpv

// warning: metal API validation has been disabled to ignore crash when playing HDR videos.
// Edit Scheme -> Run -> Diagnostics -> Metal API Validation -> Turn it off
// https://github.com/KhronosGroup/MoltenVK/issues/2226
final class MPVMetalViewController: NSViewController {
    var metalLayer = MetalLayer()
    var mpv: OpaquePointer!
    var playDelegate: MPVPlayerDelegate?
    var edrRange: CGFloat?
    lazy var queue = DispatchQueue(label: "mpv", qos: .userInitiated)
    
    var playUrl: URL?
    var hdrAvailable : Bool = false
    var hdrEnabled = false {
        didSet {
            // FIXME: target-colorspace-hint does not support being changed at runtime.
            // this option should be set when mpv init otherwise can cause player slow and hangs.
            // not recommended to use this way.
            if hdrEnabled {
                checkError(mpv_set_option_string(mpv, "target-colorspace-hint", "yes"))
            } else {
                checkError(mpv_set_option_string(mpv, "target-colorspace-hint", "no"))
            }
        }
    }
    
    override func loadView() {
        self.view = NSView(frame: .init(x: 0, y: 0, width: NSScreen.main!.frame.width, height: NSScreen.main!.frame.height))
        self.view.wantsLayer = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        metalLayer.frame = view.frame
        metalLayer.contentsScale = NSScreen.main!.backingScaleFactor
        metalLayer.framebufferOnly = true
        metalLayer.backgroundColor = NSColor.black.cgColor
        view.layer = metalLayer
        view.wantsLayer = true
        
        setupMpv()
        
        if let url = playUrl {
            loadFile(url)
        }
        
        // observer EDR range value change
        NotificationCenter.default.addObserver(
            forName: NSApplication.didChangeScreenParametersNotification,
            object: nil,
            queue: .main
        ) { [weak self] value in
            guard let self = self else { return }
            
            if let screen = NSScreen.screens.first {
                let maxRange = screen.maximumExtendedDynamicRangeColorComponentValue
                DispatchQueue.main.async {
                    self.playDelegate?.propertyChange(mpv: self.mpv, propertyName: "edr", data: maxRange)
                }
            }
        }
        
    }
    
    override func viewDidLayout() {
        super.viewDidLayout()
        
        if let window = view.window {
            let scale = window.screen!.backingScaleFactor
            let layerSize = view.bounds.size
            
            metalLayer.frame = CGRect(x: 0, y: 0, width: layerSize.width, height: layerSize.height)
            metalLayer.drawableSize = CGSize(width: layerSize.width * scale, height: layerSize.height * scale)
        }
    }
    
    func setupMpv(hdrPass : Bool = false) {
        mpv = mpv_create()
        if mpv == nil {
            print("failed creating context\n")
            exit(1)
        }
        
        // https://mpv.io/manual/stable/#options
#if DEBUG
        checkError(mpv_request_log_messages(mpv, "debug"))
#else
        checkError(mpv_request_log_messages(mpv, "no"))
#endif
#if os(macOS)
        checkError(mpv_set_option_string(mpv, "input-media-keys", "yes"))
#endif
        checkError(mpv_set_option(mpv, "wid", MPV_FORMAT_INT64, &metalLayer))
        checkError(mpv_set_option_string(mpv, "subs-match-os-language", "yes"))
        checkError(mpv_set_option_string(mpv, "subs-fallback", "yes"))
        checkError(mpv_set_option_string(mpv, "vo", "gpu-next"))
        checkError(mpv_set_option_string(mpv, "gpu-api", "vulkan"))
        checkError(mpv_set_option_string(mpv, "gpu-context", "moltenvk"))
        checkError(mpv_set_option_string(mpv, "hwdec", "videotoolbox"))
        checkError(mpv_set_option_string(mpv, "ytdl", "no"))
        //        checkError(mpv_set_option_string(mpv, "target-colorspace-hint", "yes")) // HDR passthrough
        //        checkError(mpv_set_option_string(mpv, "tone-mapping-visualize", "yes"))  // only for debugging purposes
        //        checkError(mpv_set_option_string(mpv, "profile", "fast"))   // can fix frame drop in poor device when play 4k
        
        
        checkError(mpv_initialize(mpv))
        
        mpv_observe_property(mpv, 0, MPVProperty.videoParamsSigPeak, MPV_FORMAT_DOUBLE)
        mpv_observe_property(mpv, 0, MPVProperty.videoParamsColormatrix, MPV_FORMAT_STRING)
        mpv_observe_property(mpv, 0, MPVProperty.pausedForCache, MPV_FORMAT_FLAG)
        mpv_set_wakeup_callback(self.mpv, { (ctx) in
            guard let client = ctx else { return }
            let viewController = Unmanaged<MPVMetalViewController>.fromOpaque(client).takeUnretainedValue()
            viewController.readEvents()
        }, Unmanaged.passRetained(self).toOpaque())
    }
    
    func loadFile(
        _ url: URL,
        time: Double? = nil
    ) {
        var args = [url.absoluteString]
        var options = [String]()
        
        args.append("replace")
        args.append("-1")
        
        if let time, time > 0 {
            options.append("start=\(Int(time))")
        }
        
        if !options.isEmpty {
            args.append(options.joined(separator: ","))
        }
        
        command("loadfile", args: args)
    }
    
    func play() {
        setFlag("pause", false)
    }
    
    func pause() {
        setFlag("pause", true)
    }
    
    func seek(relative time: TimeInterval) {
        command("seek", args: [String(time), "relative"])
    }
    
    private func getDouble(_ name: String) -> Double {
        guard mpv != nil else { return 0.0 }
        var data = Double()
        mpv_get_property(mpv, name, MPV_FORMAT_DOUBLE, &data)
        return data
    }
    
    private func getString(_ name: String) -> String? {
        guard mpv != nil else { return nil }
        let cstr = mpv_get_property_string(mpv, name)
        let str: String? = cstr == nil ? nil : String(cString: cstr!)
        mpv_free(cstr)
        return str
    }
    
    func setFlag(_ name: String, _ flag: Bool) {
        guard mpv != nil else { return }
        var data: Int = flag ? 1 : 0
        mpv_set_property(mpv, name, MPV_FORMAT_FLAG, &data)
    }
    
    func command(
        _ command: String,
        args: [String?] = [],
        checkForErrors: Bool = true,
        returnValueCallback: ((Int32) -> Void)? = nil
    ) {
        guard mpv != nil else {
            return
        }
        var cargs = makeCArgs(command, args).map { $0.flatMap { UnsafePointer<CChar>(strdup($0)) } }
        defer {
            for ptr in cargs where ptr != nil {
                free(UnsafeMutablePointer(mutating: ptr!))
            }
        }
        //print("\(command) -- \(args)")
        let returnValue = mpv_command(mpv, &cargs)
        if checkForErrors {
            checkError(returnValue)
        }
        if let cb = returnValueCallback {
            cb(returnValue)
        }
    }
    
    
    
    private func makeCArgs(_ command: String, _ args: [String?]) -> [String?] {
        if !args.isEmpty, args.last == nil {
            fatalError("Command do not need a nil suffix")
        }
        
        var strArgs = args
        strArgs.insert(command, at: 0)
        strArgs.append(nil)
        
        return strArgs
    }
    
    func readEvents() {
        queue.async { [weak self] in
            guard let self else { return }

            while self.mpv != nil {
                let event = mpv_wait_event(self.mpv, 0)
                if event?.pointee.event_id == MPV_EVENT_NONE {
                    break
                }
                
                switch event!.pointee.event_id {
                case MPV_EVENT_PROPERTY_CHANGE:
                    let dataOpaquePtr = OpaquePointer(event!.pointee.data)
                    if let property = UnsafePointer<mpv_event_property>(dataOpaquePtr)?.pointee {
                        let propertyName = String(cString: property.name)
                        switch propertyName {
                        case MPVProperty.videoParamsSigPeak:
                            if let sigPeak = UnsafePointer<Double>(OpaquePointer(property.data))?.pointee {
                                DispatchQueue.main.async {
                                    let maxEDRRange = NSScreen.main?.maximumPotentialExtendedDynamicRangeColorComponentValue ?? 1.0
                                    // display screen support HDR and current playing HDR video
                                    self.hdrAvailable = maxEDRRange > 1.0 && sigPeak > 1.0
                                    self.playDelegate?.propertyChange(mpv: self.mpv, propertyName: propertyName, data: sigPeak)
                                }
                            }
                        case MPVProperty.pausedForCache:
                            let buffering = UnsafePointer<Bool>(OpaquePointer(property.data))?.pointee ?? true
                            DispatchQueue.main.async {
                                self.playDelegate?.propertyChange(mpv: self.mpv, propertyName: propertyName, data: buffering)
                            }
                        default: break
                        }
                    }
                case MPV_EVENT_SHUTDOWN:
                    print("event: shutdown\n");
                    mpv_terminate_destroy(mpv);
                    mpv = nil;
                    break;
                case MPV_EVENT_LOG_MESSAGE:
                    let msg = UnsafeMutablePointer<mpv_event_log_message>(OpaquePointer(event!.pointee.data))
                    print("[\(String(cString: (msg!.pointee.prefix)!))] \(String(cString: (msg!.pointee.level)!)): \(String(cString: (msg!.pointee.text)!))", terminator: "")
                default:
                    let eventName = mpv_event_name(event!.pointee.event_id )
                    print("event: \(String(cString: (eventName)!))");
                }
                
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        
        if mpv != nil {
            mpv_set_wakeup_callback(mpv, nil, nil)
            
            // Wait for any pending queue operations to complete
            queue.sync {
                if self.mpv != nil {
                    mpv_terminate_destroy(self.mpv)
                    self.mpv = nil
                }
            }
            
            // Release the retained self from wakeup callback
            Unmanaged.passUnretained(self).release()
        }
    }
    
    private func checkError(_ status: CInt) {
        if status < 0 {
            print("MPV API error: \(String(cString: mpv_error_string(status)))\n")
        }
    }
    
}
