import Foundation
import GLKit
import Libmpv

class MPVViewController: UIViewController {
    var glView : MPVOGLView!
    var playUrl: URL?
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(enterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(enterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        
        self.glView = MPVOGLView(frame: self.view.frame)
        self.glView.setupContext()
        self.glView.setupMpv()
        
        self.view.addSubview(self.glView)
        self.glView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.glView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.glView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.glView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            self.glView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
        ])
      
        if let url = playUrl {
            self.glView.loadFile(url)
        }
    }
    
    func play(_ url: URL) {
        self.glView.loadFile(url)
    }
    
    @objc private func enterBackground() {
        self.glView.command("stop")
    }
    
    @objc private func enterForeground() {
        self.glView.command("stop")
        self.glView.setFlag("pause", false)
    }
}
