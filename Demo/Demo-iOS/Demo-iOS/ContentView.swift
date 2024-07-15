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
                            coordinator.play(URL(string: "https://github.com/cxfksword/video-test/raw/master/resources/h265.mp4")!)
                        } label: {
                            Text("h265").frame(width: 130, height: 100)
                        }
                        Button {
                            coordinator.play(URL(string: "https://github.com/cxfksword/video-test/raw/master/resources/hdr.mkv")!)
                        } label: {
                            Text("HDR").frame(width: 130, height: 100)
                        }
                        Button {
                            coordinator.play(URL(string: "https://github.com/cxfksword/video-test/raw/master/resources/pgs_subtitle.mkv")!)
                        } label: {
                            Text("subtitle").frame(width: 130, height: 100)
                        }
                        Button {
                            coordinator.play(URL(string: "https://github.com/cxfksword/video-test/raw/master/resources/rmvb.rm")!)
                        } label: {
                            Text("rmvb").frame(width: 130, height: 100)
                        }
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}
