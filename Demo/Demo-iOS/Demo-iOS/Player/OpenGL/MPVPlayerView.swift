import Foundation
import SwiftUI

struct MPVPlayerView: UIViewControllerRepresentable {
    let playUrl : URL?
    let coordinator = Coordinator()
    
    func makeUIViewController(context: Context) -> some UIViewController {
        let mpv =  MPVViewController()
        mpv.playUrl = playUrl
        
        context.coordinator.player = mpv
        return mpv
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
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
