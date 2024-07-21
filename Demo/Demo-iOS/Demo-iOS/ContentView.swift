import SwiftUI

struct ContentView: View {
    @ObservedObject var coordinator = MPVMetalPlayerView.Coordinator()
    @State var loading = false
    
    
    var body: some View {
        VStack {
            MPVMetalPlayerView(coordinator: coordinator)
                .play(URL(string: "https://github.com/mpvkit/video-test/raw/master/resources/HDR10_ToneMapping_Test_240_1000_nits.mp4")!)
                .onPropertyChange{ player, propertyName, propertyData in
                    switch propertyName {
                    case MPVProperty.pausedForCache:
                        loading = propertyData as! Bool
                    default: break
                    }
                }
        }
        .overlay {
            VStack {
                Spacer()
                ScrollView(.horizontal) {
                    HStack {
                        Button {
                            coordinator.play(URL(string: "https://vjs.zencdn.net/v/oceans.mp4")!)
                        } label: {
                            Text("h264").frame(width: 130, height: 100)
                        }
                        Button {
                            coordinator.play(URL(string: "https://github.com/mpvkit/video-test/raw/master/resources/h265.mp4")!)
                        } label: {
                            Text("h265").frame(width: 130, height: 100)
                        }
                        Button {
                            coordinator.play(URL(string: "https://github.com/mpvkit/video-test/raw/master/resources/pgs_subtitle.mkv")!)
                        } label: {
                            Text("subtitle").frame(width: 130, height: 100)
                        }
                        Button {
                            coordinator.play(URL(string: "https://github.com/mpvkit/video-test/raw/master/resources/hdr.mkv")!)
                        } label: {
                            Text("HDR").frame(width: 130, height: 100)
                        }
                        Button {
                            coordinator.play(URL(string: "https://github.com/mpvkit/video-test/raw/master/resources/DolbyVision_P5.mp4")!)
                        } label: {
                            Text("DV_P5").frame(width: 130, height: 100)
                        }
                        Button {
                            coordinator.play(URL(string: "https://github.com/mpvkit/video-test/raw/master/resources/DolbyVision_P8.mp4")!)
                        } label: {
                            Text("DV_P8").frame(width: 130, height: 100)
                        }
                    }
                }
            }
        }
        .overlay(overlayView)
        .preferredColorScheme(.dark)
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
