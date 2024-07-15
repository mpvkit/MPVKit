import SwiftUI

struct ContentView: View {
    @ObservedObject var coordinator = MPVMetalPlayerView.Coordinator()
    @State var pause = false
    @State var hdrEnabled = false
    @State var tonemappingVisualizeEnabled = false
    @State var showControlOverlay = false
    
    var body: some View {
        VStack {
            MPVMetalPlayerView(coordinator: coordinator)
                .play(URL(string: "https://github.com/cxfksword/video-test/raw/master/resources/HDR10_ToneMapping_Test_240_1000_nits.mp4")!)
                .onPropertyChange{ player, propertyName, propertyData in
                    switch propertyName {
                    case MPVProperty.videoParamsSigPeak:
                        hdrEnabled = player.hdrEnabled
                        pause = false
                    default: break
                    }
                }
        }
        .overlay {
            HStack {
                VStack(alignment: .leading, spacing: 12) {
                    Button {
                        pause.toggle()
                        if pause {
                            coordinator.player?.pause()
                        } else {
                            coordinator.player?.play()
                        }
                    } label: {
                        Text(pause ? "play" : "pause").frame(maxWidth: .infinity)
                    }
                    Divider()
                    Button {
                        coordinator.play(URL(string: "https://vjs.zencdn.net/v/oceans.mp4")!)
                    } label: {
                        Text("h264").frame(maxWidth: .infinity)
                    }
                    Button {
                        coordinator.play(URL(string: "https://github.com/cxfksword/video-test/raw/master/resources/h265.mp4")!)
                    } label: {
                        Text("h265").frame(maxWidth: .infinity)
                    }
                    Button {
                        coordinator.play(URL(string: "https://github.com/cxfksword/video-test/raw/master/resources/hdr.mkv")!)
                    } label: {
                        Text("HDR").frame(maxWidth: .infinity)
                    }
                    Button {
                        coordinator.play(URL(string: "https://github.com/cxfksword/video-test/raw/master/resources/pgs_subtitle.mkv")!)
                    } label: {
                        Text("subtitle").frame(maxWidth: .infinity)
                    }
                    Button {
                        coordinator.play(URL(string: "https://github.com/cxfksword/video-test/raw/master/resources/rmvb.rm")!)
                    } label: {
                        Text("rmvb").frame(maxWidth: .infinity)
                    }
                    Divider()
                    
                    HStack() {
                        Text("HDR")
                        Spacer()
                        Text(hdrEnabled ? "ON" : "OFF")
                    }
                    Spacer()
                }
                .padding(.horizontal, 18)
                .padding(.top, 40)
                .background(.ultraThickMaterial)
                .frame(width: 200)
                Spacer()
            }
            .opacity(showControlOverlay ? 1 : 0)
        }
        .onHover { hover in
            showControlOverlay = hover
        }
        .preferredColorScheme(.dark)
        .ignoresSafeArea()
    }
}
