import Foundation
import SwiftUI

struct MPVMetalPlayerView: NSViewControllerRepresentable {
    @ObservedObject var coordinator: Coordinator
    
    func makeNSViewController(context: Context) -> some NSViewController {
        let mpv =  MPVMetalViewController()
        mpv.playDelegate = coordinator
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
        
        @Published var pause : Bool = false {
            didSet {
                if pause {
                    self.player?.pause()
                } else {
                    self.player?.play()
                }
            }
        }
        
        @Published var hdrEnabled : Bool = false {
            didSet {
                self.player?.hdrEnabled = hdrEnabled
            }
        }
        
        @Published var hdrAvailable : Bool = false
        @Published var edrRange : String = "1.0"
        
        var playUrl : URL?
        var onPropertyChange: ((MPVMetalViewController, String, Any?) -> Void)?
        
        func play(_ url: URL) {
            player?.loadFile(url)
            self.pause = false
        }
        
        func seek(relative time: TimeInterval) {
            player?.seek(relative: time)
        }
        
        func propertyChange(mpv: OpaquePointer, propertyName: String, data: Any?) {
            guard let player else { return }
            self.onPropertyChange?(player, propertyName, data)
        }
    }
}

