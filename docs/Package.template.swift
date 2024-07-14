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
                "Libmpv", "_FFmpegKit", "Libuchardet",
                .target(name: "Libbluray", condition: .when(platforms: [.macOS, .macCatalyst])),
                .target(name: "Libluajit", condition: .when(platforms: [.macOS])),
            ],
            linkerSettings: [
                .linkedFramework("AVFoundation"),
                .linkedFramework("CoreAudio"),
            ],
            path: "Sources/_MPVKit"
        ),
        .target(
            name: "_FFmpegKit",
            dependencies: [
                "Libavcodec", "Libavfilter", "Libavformat", "Libavutil", "Libswresample", "Libswscale",
                "Libass", "Libfreetype", "Libfribidi", "Libharfbuzz",
                "MoltenVK", "Libshaderc_combined", "lcms2", "Libplacebo", "Libdovi", "Libunibreak",
                "gmp", "nettle", "hogweed", "gnutls", "Libdav1d"
            ],
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
            ],
            path: "Sources/_FFmpegKit"
        ),
        .target(
            name: "_MPVKit-GPL",
            dependencies: [
                "Libmpv-GPL", "_FFmpegKit-GPL", "Libuchardet",
                .target(name: "Libbluray", condition: .when(platforms: [.macOS, .macCatalyst])),
                .target(name: "Libluajit", condition: .when(platforms: [.macOS])),
            ],
            linkerSettings: [
                .linkedFramework("AVFoundation"),
                .linkedFramework("CoreAudio"),
            ],
            path: "Sources/_MPVKit-GPL"
        ),
        .target(
            name: "_FFmpegKit-GPL",
            dependencies: [
                "Libavcodec-GPL", "Libavfilter-GPL", "Libavformat-GPL", "Libavutil-GPL", "Libswresample-GPL", "Libswscale-GPL",
                "Libass", "Libfreetype", "Libfribidi", "Libharfbuzz",
                "MoltenVK", "Libshaderc_combined", "lcms2", "Libplacebo", "Libdovi", "Libunibreak",
                "Libsmbclient", "gmp", "nettle", "hogweed", "gnutls", "Libdav1d"
            ],
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
            ],
            path: "Sources/_FFmpegKit-GPL"
        ),

        .binaryTarget(
            name: "Libmpv-GPL",
            url: "\(Libmpv-GPL_url)",
            checksum: "\(Libmpv-GPL_checksum)"
        ),
        .binaryTarget(
            name: "Libavcodec-GPL",
            url: "\(Libavcodec-GPL_url)",
            checksum: "\(Libavcodec-GPL_checksum)"
        ),
        .binaryTarget(
            name: "Libavformat-GPL",
            url: "\(Libavformat-GPL_url)",
            checksum: "\(Libavformat-GPL_checksum)"
        ),
        .binaryTarget(
            name: "Libavfilter-GPL",
            url: "\(Libavfilter-GPL_url)",
            checksum: "\(Libavfilter-GPL_checksum)"
        ),
        .binaryTarget(
            name: "Libavutil-GPL",
            url: "\(Libavutil-GPL_url)",
            checksum: "\(Libavutil-GPL_checksum)"
        ),
        .binaryTarget(
            name: "Libswresample-GPL",
            url: "\(Libswresample-GPL_url)",
            checksum: "\(Libswresample-GPL_checksum)"
        ),
        .binaryTarget(
            name: "Libswscale-GPL",
            url: "\(Libswscale-GPL_url)",
            checksum: "\(Libswscale-GPL_checksum)"
        ),
        //AUTO_GENERATE_TARGETS_BEGIN//
        //AUTO_GENERATE_TARGETS_END//
    ]
)
