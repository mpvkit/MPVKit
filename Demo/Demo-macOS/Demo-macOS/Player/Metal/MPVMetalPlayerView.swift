import Foundation
import SwiftUI

struct MPVMetalPlayerView: NSViewControllerRepresentable {
    @ObservedObject var coordinator: Coordinator
    
    func makeNSViewController(context: Context) -> some NSViewController {
        let mpv =  MPVMetalViewController()
        mpv.delegate = coordinator
        mpv.playUrl = coordinator.playUrl
        
        context.coordinator.player = mpv
        return mpv
    }
    
    func updateNSViewController(_ nsViewController: NSViewControllerType, context: Context) {
    }
    
    public func makeCoordinator() -> Coordinator {
        coordinator
    }
    
    func play(_ url: URL) -> Self {
        coordinator.playUrl = url
        return self
    }
    
    func onPropertyChange(_ handler: @escaping (MPVMetalViewController, String, Any?) -> Void) -> Self {
        coordinator.onPropertyChange = handler
        return self
    }
    
    @MainActor
    public final class Coordinator: MPVPlayerDelegate, ObservableObject {
        weak var player: MPVMetalViewController?
        
        var playUrl : URL?
        var onPropertyChange: ((MPVMetalViewController, String, Any?) -> Void)?
        
        func play(_ url: URL) {
            player?.loadFile(url)
        }
        
        func propertyChange(mpv: OpaquePointer, propertyName: String, data: Any?) {
            guard let player else { return }
            self.onPropertyChange?(player, propertyName, data)
        }
    }
}

