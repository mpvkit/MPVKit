// swift-tools-version:5.8

import PackageDescription

let package = Package(
    name: "MPVKit",
    platforms: [.macOS(.v10_15), .iOS(.v13), .tvOS(.v13)],
    products: [
        .library(
            name: "MPVKit",
            targets: ["MPVKit"]
        ),
    ],
    targets: [
        .target(
            name: "MPVKit",
            dependencies: [
                "FFmpegKit", "Libuchardet", "Libmpv",
                .target(name: "Libbluray", condition: .when(platforms: [.macOS, .macCatalyst])),
                .target(name: "Libluajit", condition: .when(platforms: [.macOS])),
            ],
            linkerSettings: [
                .linkedFramework("AVFoundation"),
                .linkedFramework("CoreAudio"),
            ]
        ),
        .target(
            name: "FFmpegKit",
            dependencies: [
                "Libavcodec", "Libavfilter", "Libavformat", "Libavutil", "Libswresample", "Libswscale",
                "Libssl", "Libcrypto", "Libass", "Libfreetype", "Libfribidi", "Libharfbuzz",
                "MoltenVK", "Libshaderc_combined", "lcms2", "Libplacebo", "Libfontconfig", "Libdovi", "Libunibreak",
                "libsmbclient", "gmp", "nettle", "hogweed", "gnutls", "Libdav1d"
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
            ]
        ),
        //DEPENDENCY_TARGETS_BEGIN//

        .binaryTarget(
            name: "gmp",
            url: "https://github.com/mpvkit/gnutls-build/releases/download/3.8.3/gmp.xcframework.zip",
            checksum: "56335db8813453b8fc4fa856a8946619c1d250fb75956aec5a7747db6b391b06"
        ),

        .binaryTarget(
            name: "nettle",
            url: "https://github.com/mpvkit/gnutls-build/releases/download/3.8.3/nettle.xcframework.zip",
            checksum: "d67acef64dfaca72478d0b828d6b07263d684b1c5a37eb91a67f319619754c4c"
        ),

        .binaryTarget(
            name: "gnutls",
            url: "https://github.com/mpvkit/gnutls-build/releases/download/3.8.3/gnutls.xcframework.zip",
            checksum: "22793c592f174383f3afec21991a85ad6d7082d3784dee6e6d0fe3f78d2be45b"
        ),

        .binaryTarget(
            name: "Libunibreak",
            url: "https://github.com/mpvkit/libass-build/releases/download/0.17.3/Libunibreak.xcframework.zip",
            checksum: "bf5f7236d5fa22b632ac88165b735a04bff491cfafdc0f7f4f996036e78304d3"
        ),

        .binaryTarget(
            name: "Libfreetype",
            url: "https://github.com/mpvkit/libass-build/releases/download/0.17.3/Libfreetype.xcframework.zip",
            checksum: "4a7d3c32eaa3d29cdb0d84adfaa2c923dd48231de7124a8170c16669d713d569"
        ),

        .binaryTarget(
            name: "Libfribidi",
            url: "https://github.com/mpvkit/libass-build/releases/download/0.17.3/Libfribidi.xcframework.zip",
            checksum: "aee6a3a344f0e9a28856f95748cb0beff6f9bb32cc4a86b3f7cae3b64e9becc7"
        ),

        .binaryTarget(
            name: "Libharfbuzz",
            url: "https://github.com/mpvkit/libass-build/releases/download/0.17.3/Libharfbuzz.xcframework.zip",
            checksum: "a785d8f1c84c7300aa30259fd170da9742bcbda75f29344cd4c3a41499a2eee5"
        ),

        .binaryTarget(
            name: "Libass",
            url: "https://github.com/mpvkit/libass-build/releases/download/0.17.3/Libass.xcframework.zip",
            checksum: "cc792a69776620969499041adaff28968838202157dac8e63cbc13531ac27d4b"
        ),

        .binaryTarget(
            name: "Libsmbclient",
            url: "https://github.com/mpvkit/libsmbclient-build/releases/download/4.15.13/Libsmbclient.xcframework.zip",
            checksum: "41432c74d776535c97a4605c2150cda8fc2fd69eb4b567755a252bd3ea78d53e"
        ),

        .binaryTarget(
            name: "Libdovi",
            url: "https://github.com/mpvkit/libdovi-build/releases/download/v3.3.0/Libdovi.xcframework.zip",
            checksum: "7cdbec528784c8292167d6fb7548b54d61f48e1d9ef4ad7215c99dfe9c606111"
        ),

        .binaryTarget(
            name: "MoltenVK",
            url: "https://github.com/mpvkit/moltenvk-build/releases/download/1.2.9/MoltenVK.xcframework.zip",
            checksum: "b784a06a22706e7546f3b5a15ab0963557135517f6e5900fead80a08cec48ff6"
        ),

        .binaryTarget(
            name: "Libshaderc_combined",
            url: "https://github.com/mpvkit/libshaderc-build/releases/download/2024.1.0/Libshaderc_combined.xcframework.zip",
            checksum: "48a512e3f4041c73c62e043f537d27de63022bf553b7238d4716b27e8148cbe4"
        ),

        .binaryTarget(
            name: "lcms2",
            url: "https://github.com/mpvkit/libplacebo-build/releases/download/7.349.0/lcms2.xcframework.zip",
            checksum: "bd2816cfb6b1e6929bd6d04e95ee2b6f7cc905b5a83e1b36c19995785e969c66"
        ),

        .binaryTarget(
            name: "Libplacebo",
            url: "https://github.com/mpvkit/libplacebo-build/releases/download/7.349.0/Libplacebo.xcframework.zip",
            checksum: "6b06349690b08aac64c2724d35b925fe18504757b67de5004a4af4b2eaae1981"
        ),

        .binaryTarget(
            name: "Libdav1d",
            url: "https://github.com/mpvkit/libdav1d-build/releases/download/1.4.3/Libdav1d.xcframework.zip",
            checksum: "369a6211f693e7637b60203facea85f810ae3b1ed4688fa47f59ba95e7fd3791"
        ),

        .binaryTarget(
            name: "Libavcodec",
            url: "https://github.com/mpvkit/MPVKit/releases/download/0.38.0/Libavcodec.xcframework.zip",
            checksum: "1148308f1f718340048dc28e3c8240cc8316dc78baa03da46302dfb3b68ca653"
        ),
        .binaryTarget(
            name: "Libavformat",
            url: "https://github.com/mpvkit/MPVKit/releases/download/0.38.0/Libavformat.xcframework.zip",
            checksum: "ff46798cc8089ec68bb55dca9c0085ae40f935cc1763a3d65bf1345f89480faa"
        ),
        .binaryTarget(
            name: "Libavfilter",
            url: "https://github.com/mpvkit/MPVKit/releases/download/0.38.0/Libavfilter.xcframework.zip",
            checksum: "f9796391196af25615be53e327a79e453baf2955a2d7537f9e9fa51cd68b8c63"
        ),
        .binaryTarget(
            name: "Libavutil",
            url: "https://github.com/mpvkit/MPVKit/releases/download/0.38.0/Libavutil.xcframework.zip",
            checksum: "234c11385074af8d34d5e560569e3da4e35b3f0f9b3a4a4bedd3209ce5052321"
        ),
        .binaryTarget(
            name: "Libswresample",
            url: "https://github.com/mpvkit/MPVKit/releases/download/0.38.0/Libswresample.xcframework.zip",
            checksum: "8f7b30e34b54b0668e1fb20a8250add428a1e8c22d5529fb0d8b1c84ab5466b5"
        ),
        .binaryTarget(
            name: "Libswscale",
            url: "https://github.com/mpvkit/MPVKit/releases/download/0.38.0/Libswscale.xcframework.zip",
            checksum: "2039141e9c640daac075555b13ba45e99e6e14bb0237cc54345024c81e7a05fa"
        ),

        .binaryTarget(
            name: "Libuchardet",
            url: "https://github.com/mpvkit/MPVKit/releases/download/0.38.0/Libuchardet.xcframework.zip",
            checksum: "4e177b974e2a4e742c620b9772b23da012f6e2a73b2c8a3863bf3546777cabb3"
        ),

        .binaryTarget(
            name: "Libbluray",
            url: "https://github.com/mpvkit/MPVKit/releases/download/0.38.0/Libbluray.xcframework.zip",
            checksum: "b9529ad564faa20707b3b621c1e518146cd91ec6246a07f6a17465e46b6302c3"
        ),

        .binaryTarget(
            name: "Libluajit",
            url: "https://github.com/mpvkit/libluajit-build/releases/download/2.1.0/Libluajit.xcframework.zip",
            checksum: "a63165ff58b9f46cdabe7b6d545bd507ff2ab0e696f6929366b7aa1be08e7df7"
        ),

        .binaryTarget(
            name: "Libmpv",
            url: "https://github.com/mpvkit/MPVKit/releases/download/0.38.0/Libmpv.xcframework.zip",
            checksum: "7d791c5c1159544246374aab160187541061fce15b87c96f85f7f28f1c9645dc"
        ),
        //DEPENDENCY_TARGETS_END//
    ]
)
