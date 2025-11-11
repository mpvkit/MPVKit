import Foundation
import AppKit

class MPVViewController: NSViewController {
    var glView : MPVOGLView!
    var playDelegate: MPVPlayerDelegate?
    var playUrl: URL?
    var hdrAvailable : Bool {
        let maxEDRRange = NSScreen.main?.maximumPotentialExtendedDynamicRangeColorComponentValue ?? 1.0
        let sigPeak = glView.getDouble(MPVProperty.videoParamsSigPeak)
        // display screen support HDR and current playing HDR video
        return maxEDRRange > 1.0 && sigPeak > 1.0
    }
    var hdrEnabled = false
    
    override func loadView() {
        self.view = NSView(frame: .init(x: 0, y: 0, width: NSScreen.main!.frame.width, height: NSScreen.main!.frame.height))
        self.glView = MPVOGLView(frame: self.view.bounds)
        self.glView.wantsLayer = true
        self.glView.playDelegate = self.playDelegate
        
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
    
    func loadFile(_ url: URL) {
        self.glView.loadFile(url)
    }
    
    func play() {
        self.glView.setFlag("pause", false)
    }
    
    func pause() {
        self.glView.setFlag("pause", true)
    }
    
    func seek(relative time: TimeInterval) {
        self.glView.seek(relative: time)
    }
}
