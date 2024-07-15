import Foundation
import AppKit

class MPVViewController: NSViewController {
    var glView : MPVOGLView!
    var playUrl: URL?
    
    override func loadView() {
        self.view = NSView(frame: .init(x: 0, y: 0, width: NSScreen.main!.frame.width, height: NSScreen.main!.frame.height))
        self.glView = MPVOGLView(frame: self.view.bounds)
        self.glView.wantsLayer = true
        
        self.view.addSubview(glView)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.glView.setupContext()
        self.glView.setupMpv()
     
        if let url = playUrl {
            self.glView.loadFile(url)
        }
    }
    
    func play(_ url: URL) {
        self.glView.loadFile(url)
    }
}
