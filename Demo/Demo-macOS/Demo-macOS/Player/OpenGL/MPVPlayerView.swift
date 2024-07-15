import Foundation
import SwiftUI

struct MPVPlayerView: NSViewControllerRepresentable {
    let playUrl : URL?
    let coordinator = Coordinator()
    
    func makeNSViewController(context: Context) -> some NSViewController {
        let mpv =  MPVViewController()
        mpv.playUrl = playUrl
        
        context.coordinator.player = mpv
        return mpv
    }
    
    func updateNSViewController(_ nsViewController: NSViewControllerType, context: Context) {
        
    }
    
    public func makeCoordinator() -> Coordinator {
        coordinator
    }
 
    public final class Coordinator: ObservableObject {
        weak var player: MPVViewController?
        
        func play(_ url: URL) {
            player?.play(url)
        }
    }
}

