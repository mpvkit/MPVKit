import AppKit
import OpenGL.GL
import OpenGL.GL3
import Libmpv

final class MPVOGLView: NSOpenGLView {
    var mpv: OpaquePointer!
    var mpvGL: OpaquePointer!
    var queue = DispatchQueue(label: "mpv", qos: .userInteractive)
    private var defaultFBO: GLint = -1
    
    override class func defaultPixelFormat() -> NSOpenGLPixelFormat {
        let attributes: [NSOpenGLPixelFormatAttribute] = [
            // Must specify the 3.2 Core Profile to use OpenGL 3.2
            //            NSOpenGLPixelFormatAttribute(NSOpenGLPFAOpenGLProfile), NSOpenGLPixelFormatAttribute(NSOpenGLProfileVersion3_2Core),
            
            NSOpenGLPixelFormatAttribute(NSOpenGLPFADoubleBuffer),
            
            NSOpenGLPixelFormatAttribute(NSOpenGLPFAColorSize), NSOpenGLPixelFormatAttribute(32),
            NSOpenGLPixelFormatAttribute(NSOpenGLPFADepthSize), NSOpenGLPixelFormatAttribute(24),
            NSOpenGLPixelFormatAttribute(NSOpenGLPFAStencilSize), NSOpenGLPixelFormatAttribute(8),
            
            NSOpenGLPixelFormatAttribute(NSOpenGLPFAMultisample),
            NSOpenGLPixelFormatAttribute(NSOpenGLPFASampleBuffers), NSOpenGLPixelFormatAttribute(1),
            NSOpenGLPixelFormatAttribute(NSOpenGLPFASamples), NSOpenGLPixelFormatAttribute(4),
            NSOpenGLPixelFormatAttribute(0)
        ]
        
        return NSOpenGLPixelFormat(attributes: attributes)!
    }

    
    func setupContext() {
        self.autoresizingMask = [.width, .height]
        self.openGLContext!.makeCurrentContext()
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
        checkError(mpv_set_option_string(mpv, "hwdec", "auto-safe"))
        checkError(mpv_set_option_string(mpv, "vo", "libmpv"))
        
        checkError(mpv_initialize(mpv))
        
        let api = UnsafeMutableRawPointer(mutating: (MPV_RENDER_API_TYPE_OPENGL as NSString).utf8String)
        var initParams = mpv_opengl_init_params(
            get_proc_address: {
                (ctx, name) in
                return MPVOGLView.getProcAddress(ctx, name)
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
                UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())
            )
        
        }
        
        mpv_set_wakeup_callback(self.mpv, mpvWakeUp, UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque()))
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
    

    
    override func draw(_ dirtyRect: NSRect) {
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
        
        self.openGLContext!.flushBuffer()
    }
    
    
    private static func getProcAddress(_: UnsafeMutableRawPointer?, _ name: UnsafePointer<Int8>?) -> UnsafeMutableRawPointer? {
        let symbolName = CFStringCreateWithCString(kCFAllocatorDefault, name, CFStringBuiltInEncodings.ASCII.rawValue)
        let identifier = CFBundleGetBundleWithIdentifier("com.apple.opengl" as CFString)
        
        return CFBundleGetFunctionPointerForName(identifier, symbolName)
    }

}



func mpvGLUpdate(_ ctx: UnsafeMutableRawPointer?) {
    let glView = unsafeBitCast(ctx, to: MPVOGLView.self)
    
    DispatchQueue.main.async {
        glView.display()
    }
}


func mpvWakeUp(_ ctx: UnsafeMutableRawPointer?) {
    let glView = unsafeBitCast(ctx, to: MPVOGLView.self)
    glView.readEvents()
}
