import SwiftUI

struct ContentView: View {
    @ObservedObject var coordinator = MPVMetalPlayerView.Coordinator()
    @State var hdrAvailable = false
    @State var tonemappingVisualizeEnabled = false
    @State var showControlOverlay = false
    @State var loading = false
    
    var body: some View {
        VStack {
            MPVMetalPlayerView(coordinator: coordinator)
                .play(URL(string: "https://github.com/mpvkit/video-test/raw/master/resources/HDR10_ToneMapping_Test_240_1000_nits.mp4")!)
                .onPropertyChange{ player, propertyName, propertyData in
                    switch propertyName {
                    case MPVProperty.videoParamsSigPeak:
                        coordinator.hdrAvailable = player.hdrAvailable
                    case MPVProperty.pausedForCache:
                        loading = propertyData as! Bool
                    case "edr":
                        if let edrRange = propertyData as? CGFloat {
                            coordinator.edrRange = String(format: "%.1f", edrRange)
                        }
                    default: break
                    }
                }
        }
        .focusable()
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
                        coordinator.play(URL(string: "https://github.com/mpvkit/video-test/raw/master/resources/h265.mp4")!)
                    } label: {
                        Text("h265").frame(maxWidth: .infinity)
                    }
                    Button {
                        coordinator.play(URL(string: "https://github.com/mpvkit/video-test/raw/master/resources/pgs_subtitle.mkv")!)
                    } label: {
                        Text("subtitle").frame(maxWidth: .infinity)
                    }
                    Button {
                        coordinator.play(URL(string: "https://framatube.org/static/streaming-playlists/hls/66fcff64-d8f9-49c1-8deb-011b115786de/73451ad8-d30e-4beb-aa92-3dba23ba07c8-720.m3u8")!)
                    } label: {
                        Text("hls").frame(maxWidth: .infinity)
                    }
                    Button {
                        coordinator.play(URL(string: "https://github.com/mpvkit/video-test/raw/master/resources/hdr.mkv")!)
                    } label: {
                        Text("HDR").frame(maxWidth: .infinity)
                    }
                    Button {
                        coordinator.play(URL(string: "https://github.com/mpvkit/video-test/raw/master/resources/HDR10+.mp4")!)
                    } label: {
                        Text("HDR10+").frame(maxWidth: .infinity)
                    }
                    Button {
                        coordinator.play(URL(string: "https://github.com/mpvkit/video-test/raw/master/resources/DolbyVision_P5.mp4")!)
                    } label: {
                        Text("DV_P5").frame(maxWidth: .infinity)
                    }
                    Button {
                        coordinator.play(URL(string: "https://github.com/mpvkit/video-test/raw/master/resources/DolbyVision_P8.mp4")!)
                    } label: {
                        Text("DV_P8").frame(maxWidth: .infinity)
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
        .onKeyPress(action: { key in
            debugPrint("key: \(key.characters)")
            return .handled
        })
        .onKeyPress(.leftArrow, action: {
            coordinator.seek(relative: -10)
            return .handled
        })
        .onKeyPress(.rightArrow, action: {
            coordinator.seek(relative: 10)
            return .handled
        })
        .overlay(overlayView)
        .preferredColorScheme(.dark)
        .ignoresSafeArea()
    }
    
    @ViewBuilder
    private var overlayView: some View {
        if loading {
            ProgressView()
        } else {
            EmptyView()
        }
    }
}
