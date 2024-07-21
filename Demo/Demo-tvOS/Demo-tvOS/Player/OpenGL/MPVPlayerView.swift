import Foundation
import SwiftUI

struct MPVPlayerView: UIViewControllerRepresentable {
    @ObservedObject var coordinator: Coordinator
    
    func makeUIViewController(context: Context) -> some UIViewController {
        let mpv =  MPVViewController()
        mpv.playDelegate = coordinator
        mpv.playUrl = coordinator.playUrl
        
        context.coordinator.player = mpv
        return mpv
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
    }
    
    public func makeCoordinator() -> Coordinator {
        coordinator
    }
    
    func play(_ url: URL) -> Self {
        coordinator.playUrl = url
        return self
    }
    
    func onPropertyChange(_ handler: @escaping (MPVViewController, String, Any?) -> Void) -> Self {
        coordinator.onPropertyChange = handler
        return self
    }
    
    @MainActor
    public final class Coordinator: MPVPlayerDelegate, ObservableObject {
        weak var player: MPVViewController?
        
        var playUrl : URL?
        var onPropertyChange: ((MPVViewController, String, Any?) -> Void)?
        
        func play(_ url: URL) {
            player?.loadFile(url)
        }
        
        func propertyChange(mpv: OpaquePointer, propertyName: String, data: Any?) {
            guard let player else { return }
            
            self.onPropertyChange?(player, propertyName, data)
        }
    }
}
