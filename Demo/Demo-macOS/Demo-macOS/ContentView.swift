import SwiftUI

struct ContentView: View {
    @ObservedObject var coordinator = MPVMetalPlayerView.Coordinator()
    @State var hdrAvailable = false
    @State var tonemappingVisualizeEnabled = false
    @State var showControlOverlay = false
    
    var body: some View {
        VStack {
            MPVMetalPlayerView(coordinator: coordinator)
                .play(URL(string: "https://github.com/cxfksword/video-test/raw/master/resources/HDR10_ToneMapping_Test_240_1000_nits.mp4")!)
                .onPropertyChange{ player, propertyName, propertyData in
                    switch propertyName {
                    case MPVProperty.videoParamsSigPeak:
                        coordinator.hdrAvailable = player.hdrAvailable
                    case "edr":
                        if let edrRange = propertyData as? CGFloat {
                            coordinator.edrRange = String(format: "%.1f", edrRange)
                        }
                    default: break
                    }
                }
        }
        .overlay {
            HStack {
                VStack(alignment: .leading, spacing: 12) {
                    Button {
                        coordinator.pause.toggle()
                    } label: {
                        Text(coordinator.pause ? "play" : "pause").frame(maxWidth: .infinity)
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
                        Toggle("", isOn: $coordinator.hdrEnabled)
                            .disabled(!coordinator.hdrAvailable)
                            .toggleStyle(.switch)
                    }
                    HStack() {
                        Text("EDR")
                        Spacer()
                        Text(coordinator.edrRange)
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
