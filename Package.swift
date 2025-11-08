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
            path: "dist/release/xcframework/Libmpv.xcframework"
        ),
        .binaryTarget(
            name: "Libavcodec-GPL",
            path: "dist/release/xcframework/Libavcodec.xcframework"
        ),
        .binaryTarget(
            name: "Libavdevice-GPL",
            path: "dist/release/xcframework/Libavdevice.xcframework"
        ),
        .binaryTarget(
            name: "Libavformat-GPL",
            path: "dist/release/xcframework/Libavformat.xcframework"
        ),
        .binaryTarget(
            name: "Libavfilter-GPL",
            path: "dist/release/xcframework/Libavfilter.xcframework"
        ),
        .binaryTarget(
            name: "Libavutil-GPL",
            path: "dist/release/xcframework/Libavutil.xcframework"
        ),
        .binaryTarget(
            name: "Libswresample-GPL",
            path: "dist/release/xcframework/Libswresample.xcframework"
        ),
        .binaryTarget(
            name: "Libswscale-GPL",
            path: "dist/release/xcframework/Libswscale.xcframework"
        ),
        //AUTO_GENERATE_TARGETS_BEGIN//

        .binaryTarget(
            name: "Libcrypto",
            path: "dist/release/xcframework/Libcrypto.xcframework"
        ),
        .binaryTarget(
            name: "Libssl",
            path: "dist/release/xcframework/Libssl.xcframework"
        ),

        .binaryTarget(
            name: "gmp",
            path: "dist/release/xcframework/gmp.xcframework"
        ),

        .binaryTarget(
            name: "nettle",
            path: "dist/release/xcframework/nettle.xcframework"
        ),
        .binaryTarget(
            name: "hogweed",
            path: "dist/release/xcframework/hogweed.xcframework"
        ),

        .binaryTarget(
            name: "gnutls",
            path: "dist/release/xcframework/gnutls.xcframework"
        ),

        .binaryTarget(
            name: "Libunibreak",
            path: "dist/release/xcframework/Libunibreak.xcframework"
        ),

        .binaryTarget(
            name: "Libfreetype",
            path: "dist/release/xcframework/Libfreetype.xcframework"
        ),

        .binaryTarget(
            name: "Libfribidi",
            path: "dist/release/xcframework/Libfribidi.xcframework"
        ),

        .binaryTarget(
            name: "Libharfbuzz",
            path: "dist/release/xcframework/Libharfbuzz.xcframework"
        ),

        .binaryTarget(
            name: "Libass",
            path: "dist/release/xcframework/Libass.xcframework"
        ),

        .binaryTarget(
            name: "Libsmbclient",
            path: "dist/release/xcframework/Libsmbclient.xcframework"
        ),

        .binaryTarget(
            name: "Libbluray",
            path: "dist/release/xcframework/Libbluray.xcframework"
        ),

        .binaryTarget(
            name: "Libuavs3d",
            path: "dist/release/xcframework/Libuavs3d.xcframework"
        ),

        .binaryTarget(
            name: "Libdovi",
            url: "https://github.com/mpvkit/libdovi-build/releases/download/3.3.0/Libdovi.xcframework.zip",
            checksum: "ca4382ea4e17103fbcc979d0ddee69a6eb8967c0ab235cb786ffa96da5f512ed"
        ),

        .binaryTarget(
            name: "MoltenVK",
            url: "https://github.com/mpvkit/moltenvk-build/releases/download/1.2.9-fix/MoltenVK.xcframework.zip",
            checksum: "63836d61deceb5721ff0790dac651890e44ef770ab7b971fb83cc1b2524d1025"
        ),

        .binaryTarget(
            name: "Libshaderc_combined",
            path: "dist/release/xcframework/Libshaderc_combined.xcframework"
        ),

        .binaryTarget(
            name: "lcms2",
            path: "dist/release/xcframework/lcms2.xcframework"
        ),

        .binaryTarget(
            name: "Libplacebo",
            path: "dist/release/xcframework/Libplacebo.xcframework"
        ),

        .binaryTarget(
            name: "Libdav1d",
            path: "dist/release/xcframework/Libdav1d.xcframework"
        ),

        .binaryTarget(
            name: "Libavcodec",
            path: "dist/release/xcframework/Libavcodec.xcframework"
        ),
        .binaryTarget(
            name: "Libavdevice",
           path: "dist/release/xcframework/Libavdevice.xcframework"
        ),
        .binaryTarget(
            name: "Libavformat",
            path: "dist/release/xcframework/Libavformat.xcframework"
        ),
        .binaryTarget(
            name: "Libavfilter",
            path: "dist/release/xcframework/Libavfilter.xcframework"
        ),
        .binaryTarget(
            name: "Libavutil",
            path: "dist/release/xcframework/Libavutil.xcframework"
        ),
        .binaryTarget(
            name: "Libswresample",
            path: "dist/release/xcframework/Libswresample.xcframework"
        ),
        .binaryTarget(
            name: "Libswscale",
            path: "dist/release/xcframework/Libswscale.xcframework"
        ),

        .binaryTarget(
            name: "Libuchardet",
            path: "dist/release/xcframework/Libuchardet.xcframework"
        ),

        .binaryTarget(
            name: "Libluajit",
            path: "dist/release/xcframework/Libluajit.xcframework"
        ),

        .binaryTarget(
            name: "Libmpv",
            path: "dist/release/xcframework/Libmpv.xcframework"
        ),
        //AUTO_GENERATE_TARGETS_END//
    ]
)
