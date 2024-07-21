import Foundation
import GLKit
import Libmpv

class MPVViewController: GLKViewController {
    var mpv: OpaquePointer!
    var mpvGL: OpaquePointer!
    var playDelegate: MPVPlayerDelegate?
    var queue: DispatchQueue = DispatchQueue(label: "mpv", qos: .userInteractive)
    private var defaultFBO: GLint = -1
    var playUrl: URL?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupContext()
        self.setupMpv()
      
        if let url = playUrl {
            self.loadFile(url)
        }
    }
    
    func setupContext() {
        let context = EAGLContext(api: .openGLES2)!
        if context == nil {
            print("create context fail ...")
            return
        }
        let isSuccess = EAGLContext.setCurrent(context)
        if !isSuccess {
            print("setup context fail")
        }
        
        let glkView = self.view as! GLKView
        glkView.context = context
    }
    
    func setupMpv() {
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
        checkError(mpv_set_option_string(mpv, "subs-match-os-language", "yes"))
        checkError(mpv_set_option_string(mpv, "subs-fallback", "yes"))
        checkError(mpv_set_option_string(mpv, "hwdec", machine == "x86_64" ? "no" : "auto-safe"))
        checkError(mpv_set_option_string(mpv, "vo", "libmpv"))
        
        checkError(mpv_initialize(mpv))
        
        let api = UnsafeMutableRawPointer(mutating: (MPV_RENDER_API_TYPE_OPENGL as NSString).utf8String)
        var initParams = mpv_opengl_init_params(
            get_proc_address: {
                (ctx, name) in
                return MPVViewController.getProcAddress(ctx, name)
            },
            get_proc_address_ctx: nil
        )
        
        withUnsafeMutablePointer(to: &initParams) { initParams in
            var params = [
                mpv_render_param(type: MPV_RENDER_PARAM_API_TYPE, data: api),
                mpv_render_param(type: MPV_RENDER_PARAM_OPENGL_INIT_PARAMS, data: initParams),
                mpv_render_param()
            ]
            
            if mpv_render_context_create(&mpvGL, mpv, &params) < 0 {
                puts("failed to initialize mpv GL context")
                exit(1)
            }
            
            mpv_render_context_set_update_callback(
                mpvGL,
                mpvGLUpdate,
                UnsafeMutableRawPointer(Unmanaged.passUnretained(self.view).toOpaque())
            )
            
        }
        
        mpv_observe_property(mpv, 0, MPVProperty.videoParamsSigPeak, MPV_FORMAT_DOUBLE)
        mpv_observe_property(mpv, 0, MPVProperty.pausedForCache, MPV_FORMAT_FLAG)
        mpv_set_wakeup_callback(self.mpv, { (ctx) in
            let client = unsafeBitCast(ctx, to: MPVViewController.self)
            client.readEvents()
        }, UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque()))
    }
    
    
    func loadFile(
        _ url: URL
    ) {
        var args = [url.absoluteString]
        var options = [String]()
        
        args.append("replace")
        
        if !options.isEmpty {
            args.append(options.joined(separator: ","))
        }
        
        command("loadfile", args: args)
    }
    
    func togglePause() {
        getFlag(MPVProperty.pause) ? play() : pause()
    }
    
    func play() {
        setFlag(MPVProperty.pause, false)
    }
    
    func pause() {
        setFlag(MPVProperty.pause, true)
    }
    
    private func getFlag(_ name: String) -> Bool {
        var data = Int64()
        mpv_get_property(mpv, name, MPV_FORMAT_FLAG, &data)
        return data > 0
    }
    
    private func setFlag(_ name: String, _ flag: Bool) {
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
        queue.async { [self] in
            while self.mpv != nil {
                let event = mpv_wait_event(self.mpv, 0)
                if event!.pointee.event_id == MPV_EVENT_NONE {
                    break
                }
                switch event!.pointee.event_id {
                case MPV_EVENT_PROPERTY_CHANGE:
                    let dataOpaquePtr = OpaquePointer(event!.pointee.data)
                    if let property = UnsafePointer<mpv_event_property>(dataOpaquePtr)?.pointee {
                        let propertyName = String(cString: property.name)
                        switch propertyName {
                        case MPVProperty.pausedForCache:
                            let buffering = UnsafePointer<Bool>(OpaquePointer(property.data))?.pointee ?? true
                            DispatchQueue.main.async {
                                self.playDelegate?.propertyChange(mpv: self.mpv, propertyName: propertyName, data: buffering)
                            }
                        default: break
                        }
                    }
                case MPV_EVENT_SHUTDOWN:
                    mpv_render_context_free(mpvGL);
                    mpv_terminate_destroy(mpv);
                    mpv = nil;
                    print("event: shutdown\n");
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
    
    
    private func checkError(_ status: CInt) {
        if status < 0 {
            print("MPV API error: \(String(cString: mpv_error_string(status)))\n")
        }
    }
    
    
    private var machine: String {
        var systeminfo = utsname()
        uname(&systeminfo)
        return withUnsafeBytes(of: &systeminfo.machine) { bufPtr -> String in
            let data = Data(bufPtr)
            if let lastIndex = data.lastIndex(where: { $0 != 0 }) {
                return String(data: data[0 ... lastIndex], encoding: .isoLatin1)!
            } else {
                return String(data: data, encoding: .isoLatin1)!
            }
        }
    }
    
    
    override func glkView(_ view: GLKView, drawIn rect: CGRect) {
        guard let mpvGL else {
            return
        }
        
        // fill black background
        glClearColor(0, 0, 0, 0)
        glClear(UInt32(GL_COLOR_BUFFER_BIT))
        
        glGetIntegerv(UInt32(GL_FRAMEBUFFER_BINDING), &defaultFBO)
        
        var dims: [GLint] = [0, 0, 0, 0]
        glGetIntegerv(GLenum(GL_VIEWPORT), &dims)
        
        var data = mpv_opengl_fbo(
            fbo: Int32(defaultFBO),
            w: Int32(dims[2]),
            h: Int32(dims[3]),
            internal_format: 0
        )
        
        var flip: CInt = 1
        withUnsafeMutablePointer(to: &flip) { flip in
            withUnsafeMutablePointer(to: &data) { data in
                var params = [
                    mpv_render_param(type: MPV_RENDER_PARAM_OPENGL_FBO, data: data),
                    mpv_render_param(type: MPV_RENDER_PARAM_FLIP_Y, data: flip),
                    mpv_render_param()
                ]
                mpv_render_context_render(mpvGL, &params)
            }
        }
        
    }
    
    
    private static func getProcAddress(_: UnsafeMutableRawPointer?, _ name: UnsafePointer<Int8>?) -> UnsafeMutableRawPointer? {
        let symbolName = CFStringCreateWithCString(kCFAllocatorDefault, name, CFStringBuiltInEncodings.ASCII.rawValue)
        let identifier = CFBundleGetBundleWithIdentifier("com.apple.opengles" as CFString)
        
        return CFBundleGetFunctionPointerForName(identifier, symbolName)
    }
    
}



private func mpvGLUpdate(_ ctx: UnsafeMutableRawPointer?) {
    let glView = unsafeBitCast(ctx, to: GLKView.self)
    
    DispatchQueue.main.async {
        glView.display()
    }
}
