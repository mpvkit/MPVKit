// swift-tools-version:5.8

import PackageDescription

let package = Package(
    name: "MPVKit",
    platforms: [.macOS(.v10_15), .iOS(.v13), .tvOS(.v13)],
    products: [
        .library(
            name: "MPVKit",
            targets: ["_MPVKit"]
        ),
        .library(
            name: "MPVKit-GPL",
            targets: ["_MPVKit-GPL"]
        ),
    ],
    targets: [
        .target(
            name: "_MPVKit",
            dependencies: [
                "Libmpv", "_FFmpeg", "Libuchardet", "Libbluray",
                .target(name: "Libluajit", condition: .when(platforms: [.macOS])),
            ],
            path: "Sources/_MPVKit",
            linkerSettings: [
                .linkedFramework("AVFoundation"),
                .linkedFramework("CoreAudio"),
            ]
        ),
        .target(
            name: "_FFmpeg",
            dependencies: [
                "Libavcodec", "Libavdevice", "Libavfilter", "Libavformat", "Libavutil", "Libswresample", "Libswscale",
                "Libssl", "Libcrypto", "Libass", "Libfreetype", "Libfribidi", "Libharfbuzz",
                "MoltenVK", "Libshaderc_combined", "lcms2", "Libplacebo", "Libdovi", "Libunibreak",
                "gmp", "nettle", "hogweed", "gnutls", "Libdav1d", "Libuavs3d"
            ],
            path: "Sources/_FFmpeg",
            linkerSettings: [
                .linkedFramework("AudioToolbox"),
                .linkedFramework("CoreVideo"),
                .linkedFramework("CoreFoundation"),
                .linkedFramework("CoreMedia"),
                .linkedFramework("Metal"),
                .linkedFramework("VideoToolbox"),
                .linkedLibrary("bz2"),
                .linkedLibrary("iconv"),
                .linkedLibrary("expat"),
                .linkedLibrary("resolv"),
                .linkedLibrary("xml2"),
                .linkedLibrary("z"),
                .linkedLibrary("c++"),
            ]
        ),
        .target(
            name: "_MPVKit-GPL",
            dependencies: [
                "Libmpv-GPL", "_FFmpeg-GPL", "Libuchardet", "Libbluray",
                .target(name: "Libluajit", condition: .when(platforms: [.macOS])),
            ],
            path: "Sources/_MPVKit-GPL",
            linkerSettings: [
                .linkedFramework("AVFoundation"),
                .linkedFramework("CoreAudio"),
            ]
        ),
        .target(
            name: "_FFmpeg-GPL",
            dependencies: [
                "Libavcodec-GPL", "Libavdevice-GPL", "Libavfilter-GPL", "Libavformat-GPL", "Libavutil-GPL", "Libswresample-GPL", "Libswscale-GPL",
                "Libssl", "Libcrypto", "Libass", "Libfreetype", "Libfribidi", "Libharfbuzz",
                "MoltenVK", "Libshaderc_combined", "lcms2", "Libplacebo", "Libdovi", "Libunibreak",
                "Libsmbclient", "gmp", "nettle", "hogweed", "gnutls", "Libdav1d", "Libuavs3d"
            ],
            path: "Sources/_FFmpeg-GPL",
            linkerSettings: [
                .linkedFramework("AudioToolbox"),
                .linkedFramework("CoreVideo"),
                .linkedFramework("CoreFoundation"),
                .linkedFramework("CoreMedia"),
                .linkedFramework("Metal"),
                .linkedFramework("VideoToolbox"),
                .linkedLibrary("bz2"),
                .linkedLibrary("iconv"),
                .linkedLibrary("expat"),
                .linkedLibrary("resolv"),
                .linkedLibrary("xml2"),
                .linkedLibrary("z"),
                .linkedLibrary("c++"),
            ]
        ),

        .binaryTarget(
            name: "Libmpv-GPL",
            url: "https://github.com/mpvkit/MPVKit/releases/download/0.39.0-n7.1/Libmpv-GPL.xcframework.zip",
            checksum: "ffd4b845c49f16e43520ecf221fa0863a0fff3b5574a35651dc13c4e02c40a78"
        ),
        .binaryTarget(
            name: "Libavcodec-GPL",
            url: "https://github.com/mpvkit/MPVKit/releases/download/0.39.0-n7.1/Libavcodec-GPL.xcframework.zip",
            checksum: "963dbdc08f5802cbdb95807c2c9ef9e12a365d70dcda2f0f9134e3ac6d9cccf5"
        ),
        .binaryTarget(
            name: "Libavdevice-GPL",
            url: "https://github.com/mpvkit/MPVKit/releases/download/0.39.0-n7.1/Libavdevice-GPL.xcframework.zip",
            checksum: "0314bd8f49e6f5aa508a67de37ad1ba7ff754f69dadded7e61bdce6967c5ae04"
        ),
        .binaryTarget(
            name: "Libavformat-GPL",
            url: "https://github.com/mpvkit/MPVKit/releases/download/0.39.0-n7.1/Libavformat-GPL.xcframework.zip",
            checksum: "6bc144c0ce7c6aa67620341df684e66d6fbb1343f38152292ba24bc853d2aaf7"
        ),
        .binaryTarget(
            name: "Libavfilter-GPL",
            url: "https://github.com/mpvkit/MPVKit/releases/download/0.39.0-n7.1/Libavfilter-GPL.xcframework.zip",
            checksum: "a2789f3bc48c87108cc7dc76b755b84c54eb58ac2f510866a4feb3c729d868c2"
        ),
        .binaryTarget(
            name: "Libavutil-GPL",
            url: "https://github.com/mpvkit/MPVKit/releases/download/0.39.0-n7.1/Libavutil-GPL.xcframework.zip",
            checksum: "b9f679fe6e31b8423f09f0b9dcb618e51713369de903e5177a780593a666743c"
        ),
        .binaryTarget(
            name: "Libswresample-GPL",
            url: "https://github.com/mpvkit/MPVKit/releases/download/0.39.0-n7.1/Libswresample-GPL.xcframework.zip",
            checksum: "c47648e7a2380f0bacea471f5d858b316f2017858ae5025c0dc5f0ea17b43ec7"
        ),
        .binaryTarget(
            name: "Libswscale-GPL",
            url: "https://github.com/mpvkit/MPVKit/releases/download/0.39.0-n7.1/Libswscale-GPL.xcframework.zip",
            checksum: "bf1063e41174ca05145af024ab1209c692013136607a79a18f0e410fdbb6bc48"
        ),
        //AUTO_GENERATE_TARGETS_BEGIN//

        .binaryTarget(
            name: "Libcrypto",
            url: "https://github.com/mpvkit/openssl-build/releases/download/3.2.0/Libcrypto.xcframework.zip",
            checksum: "89989ea14f7297d98083eb8adfba9b389f5b4886cb54fb3d5b6e8b915b7adf1d"
        ),
        .binaryTarget(
            name: "Libssl",
            url: "https://github.com/mpvkit/openssl-build/releases/download/3.2.0/Libssl.xcframework.zip",
            checksum: "46ad8e8fa5a6efe7bd31c9b3c56b20c1bc29a581083588d86e941d261d7dbe98"
        ),

        .binaryTarget(
            name: "gmp",
            url: "https://github.com/mpvkit/gnutls-build/releases/download/3.8.3/gmp.xcframework.zip",
            checksum: "defd5623e6786543588001b8f33026395960a561540738deb6df6996d39f957d"
        ),

        .binaryTarget(
            name: "nettle",
            url: "https://github.com/mpvkit/gnutls-build/releases/download/3.8.3/nettle.xcframework.zip",
            checksum: "c3b8f506fa32bcb3f9bf65096b0556c4f5973f846ee964577d783edbe8e6969d"
        ),
        .binaryTarget(
            name: "hogweed",
            url: "https://github.com/mpvkit/gnutls-build/releases/download/3.8.3/hogweed.xcframework.zip",
            checksum: "47a34e7877f7ebd9175f5645059030e553276faa9a21b91e29fb7463b94e8daf"
        ),

        .binaryTarget(
            name: "gnutls",
            url: "https://github.com/mpvkit/gnutls-build/releases/download/3.8.3/gnutls.xcframework.zip",
            checksum: "5f5cf903a2d52157c29ad304260709f618ce086afea02061241982f8425a6fb0"
        ),

        .binaryTarget(
            name: "Libunibreak",
            url: "https://github.com/mpvkit/libass-build/releases/download/0.17.3/Libunibreak.xcframework.zip",
            checksum: "430ed1a8ff1a230bd93b6868021cde2aafb23c8cb2d586525836cac47c4f310f"
        ),

        .binaryTarget(
            name: "Libfreetype",
            url: "https://github.com/mpvkit/libass-build/releases/download/0.17.3/Libfreetype.xcframework.zip",
            checksum: "300d2966c914e06f0211d8da0ea6208a345709b888e9cbbf1cdd94df26330359"
        ),

        .binaryTarget(
            name: "Libfribidi",
            url: "https://github.com/mpvkit/libass-build/releases/download/0.17.3/Libfribidi.xcframework.zip",
            checksum: "4a3122a2027f021937ed0fa07173dca7f2c1c4c4202b7caf8043fa80408c0953"
        ),

        .binaryTarget(
            name: "Libharfbuzz",
            url: "https://github.com/mpvkit/libass-build/releases/download/0.17.3/Libharfbuzz.xcframework.zip",
            checksum: "f607773598caa72435d8b19ce6a9d54fa7f26cde126b6b66c0a3d2804f084c68"
        ),

        .binaryTarget(
            name: "Libass",
            url: "https://github.com/mpvkit/libass-build/releases/download/0.17.3/Libass.xcframework.zip",
            checksum: "af24cd1429069153f0ca5c650e0b374c27ae38283aca47cbbbc9edb3165b182e"
        ),

        .binaryTarget(
            name: "Libsmbclient",
            url: "https://github.com/mpvkit/libsmbclient-build/releases/download/4.15.13/Libsmbclient.xcframework.zip",
            checksum: "589db9c241e6cc274f2825bee542add273febd0666ebd7ea8a402574ed76e9af"
        ),

        .binaryTarget(
            name: "Libuavs3d",
            url: "https://github.com/mpvkit/libuavs3d-build/releases/download/1.2.1/Libuavs3d.xcframework.zip",
            checksum: "893257fc73c61b87fb45ee9de7df6ac4a6967062d7cac2c8d136cd2774a04971"
        ),

        .binaryTarget(
            name: "Libdovi",
            url: "https://github.com/mpvkit/libdovi-build/releases/download/3.3.0/Libdovi.xcframework.zip",
            checksum: "ca4382ea4e17103fbcc979d0ddee69a6eb8967c0ab235cb786ffa96da5f512ed"
        ),

        .binaryTarget(
            name: "MoltenVK",
            url: "https://github.com/mpvkit/moltenvk-build/releases/download/1.2.11/MoltenVK.xcframework.zip",
            checksum: "903b476d4d89d35ed0ce413f7514f54e3d8db9f3e7bd126896f74d07fa4134a1"
        ),

        .binaryTarget(
            name: "Libshaderc_combined",
            url: "https://github.com/mpvkit/libshaderc-build/releases/download/2024.2.0/Libshaderc_combined.xcframework.zip",
            checksum: "1ccd9fce68ea29af030dceb824716fc16d1f4dcdc0b912ba366d5cb91d7b1add"
        ),

        .binaryTarget(
            name: "lcms2",
            url: "https://github.com/mpvkit/libplacebo-build/releases/download/7.349.0/lcms2.xcframework.zip",
            checksum: "bd2c27366f8b7adfe7bf652a922599891c55b82f5c519bcc4eece1ccff57c889"
        ),

        .binaryTarget(
            name: "Libplacebo",
            url: "https://github.com/mpvkit/libplacebo-build/releases/download/7.349.0/Libplacebo.xcframework.zip",
            checksum: "f32d20351289a080cd7288742747cd927553fde8c217f63263b838083d07a01a"
        ),

        .binaryTarget(
            name: "Libdav1d",
            url: "https://github.com/mpvkit/libdav1d-build/releases/download/1.4.3/Libdav1d.xcframework.zip",
            checksum: "eccfe37da9418e350bc6c1566890fa5b9585fbb87b8ceb664de77800ef17fe04"
        ),

        .binaryTarget(
            name: "Libavcodec",
            url: "https://github.com/mpvkit/MPVKit/releases/download/0.39.0-n7.1/Libavcodec.xcframework.zip",
            checksum: "057f87dc3d678ab28b282a4f8502cebfacd8b6bba2ba69b619f8014e828859a8"
        ),
        .binaryTarget(
            name: "Libavdevice",
            url: "https://github.com/mpvkit/MPVKit/releases/download/0.39.0-n7.1/Libavdevice.xcframework.zip",
            checksum: "65fd1bc34688f7f4727615ad58ba3ecef584e7a8e8551444b5a6d1fcd3db58ef"
        ),
        .binaryTarget(
            name: "Libavformat",
            url: "https://github.com/mpvkit/MPVKit/releases/download/0.39.0-n7.1/Libavformat.xcframework.zip",
            checksum: "71ceff00b978ea75a25ca8b62ec4040330a0ae060f8e615ddfd00c90f93da0fe"
        ),
        .binaryTarget(
            name: "Libavfilter",
            url: "https://github.com/mpvkit/MPVKit/releases/download/0.39.0-n7.1/Libavfilter.xcframework.zip",
            checksum: "ba81bdb9b8876e4259a9bfba2b47b462afa051c5202d232d349b56437ce408a3"
        ),
        .binaryTarget(
            name: "Libavutil",
            url: "https://github.com/mpvkit/MPVKit/releases/download/0.39.0-n7.1/Libavutil.xcframework.zip",
            checksum: "03475c885c89e86109d08c0c01651990af9492fd75ab04f643df79807267f3cc"
        ),
        .binaryTarget(
            name: "Libswresample",
            url: "https://github.com/mpvkit/MPVKit/releases/download/0.39.0-n7.1/Libswresample.xcframework.zip",
            checksum: "f9c31fa604d5fbb07969c1b31a1a8e9415bdd6a3481276a891699fd824a79bf4"
        ),
        .binaryTarget(
            name: "Libswscale",
            url: "https://github.com/mpvkit/MPVKit/releases/download/0.39.0-n7.1/Libswscale.xcframework.zip",
            checksum: "638f68f576a69b287902c0e58631956dd4583451bbadfa9dd949ae7182677d2b"
        ),

        .binaryTarget(
            name: "Libuchardet",
            url: "https://github.com/mpvkit/libuchardet-build/releases/download/0.0.8/Libuchardet.xcframework.zip",
            checksum: "80b14d8080c2531ced6d6b234a826c13f0be459a8c751815f68e0eefd34afa30"
        ),

        .binaryTarget(
            name: "Libluajit",
            url: "https://github.com/mpvkit/libluajit-build/releases/download/2.1.0/Libluajit.xcframework.zip",
            checksum: "3765d7c6392b4f9a945b334ed593747b8adb9345078717ecfb6d7d12114a0f9e"
        ),

        .binaryTarget(
            name: "Libbluray",
            url: "https://github.com/mpvkit/MPVKit/releases/download/0.39.0-n7.1/Libbluray.xcframework.zip",
            checksum: "4cab5658d5bf6a88c06fa567b1b3e60c8d36562faa8947a573e8dd82dc6475aa"
        ),

        .binaryTarget(
            name: "Libmpv",
            url: "https://github.com/mpvkit/MPVKit/releases/download/0.39.0-n7.1/Libmpv.xcframework.zip",
            checksum: "a79db2390a8955dc5887b0e0fd8daddb2e6b7ef8574896c7316c20a5dc87a8cc"
        ),
        //AUTO_GENERATE_TARGETS_END//
    ]
)
