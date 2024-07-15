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
                "Libmpv", "_FFmpegKit", "Libuchardet", "Libbluray",
                .target(name: "Libluajit", condition: .when(platforms: [.macOS])),
            ],
            path: "Sources/_MPVKit",
            linkerSettings: [
                .linkedFramework("AVFoundation"),
                .linkedFramework("CoreAudio"),
            ]
        ),
        .target(
            name: "_FFmpegKit",
            dependencies: [
                "Libavcodec", "Libavfilter", "Libavformat", "Libavutil", "Libswresample", "Libswscale",
                "Libssl", "Libcrypto", "Libass", "Libfreetype", "Libfribidi", "Libharfbuzz",
                "MoltenVK", "Libshaderc_combined", "lcms2", "Libplacebo", "Libdovi", "Libunibreak",
                "gmp", "nettle", "hogweed", "gnutls", "Libdav1d"
            ],
            path: "Sources/_FFmpegKit",
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
                "Libmpv-GPL", "_FFmpegKit-GPL", "Libuchardet", "Libbluray",
                .target(name: "Libluajit", condition: .when(platforms: [.macOS])),
            ],
            path: "Sources/_MPVKit-GPL",
            linkerSettings: [
                .linkedFramework("AVFoundation"),
                .linkedFramework("CoreAudio"),
            ]
        ),
        .target(
            name: "_FFmpegKit-GPL",
            dependencies: [
                "Libavcodec-GPL", "Libavfilter-GPL", "Libavformat-GPL", "Libavutil-GPL", "Libswresample-GPL", "Libswscale-GPL",
                "Libssl", "Libcrypto", "Libass", "Libfreetype", "Libfribidi", "Libharfbuzz",
                "MoltenVK", "Libshaderc_combined", "lcms2", "Libplacebo", "Libdovi", "Libunibreak",
                "Libsmbclient", "gmp", "nettle", "hogweed", "gnutls", "Libdav1d"
            ],
            path: "Sources/_FFmpegKit-GPL",
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
            url: "https://github.com/mpvkit/MPVKit/releases/download/0.38.0/Libmpv-GPL.xcframework.zip",
            checksum: "8afd47096f3e50879ef292f34ff43d51540d5ba1dc88a254e8fdfb9cad4b9e05"
        ),
        .binaryTarget(
            name: "Libavcodec-GPL",
            url: "https://github.com/mpvkit/MPVKit/releases/download/0.38.0/Libavcodec-GPL.xcframework.zip",
            checksum: "af155e887dc48f643e721b75f59ad06b712dd9c3066376524df90e08c2244b56"
        ),
        .binaryTarget(
            name: "Libavformat-GPL",
            url: "https://github.com/mpvkit/MPVKit/releases/download/0.38.0/Libavformat-GPL.xcframework.zip",
            checksum: "7fc5a9a4f237142e3453cc7bfa535ce93322b3e581b8971bf768586183497336"
        ),
        .binaryTarget(
            name: "Libavfilter-GPL",
            url: "https://github.com/mpvkit/MPVKit/releases/download/0.38.0/Libavfilter-GPL.xcframework.zip",
            checksum: "340d53d5c636e7ca5a6bded9d4e5d9e67df69e23a8855de3d2103041da73aa34"
        ),
        .binaryTarget(
            name: "Libavutil-GPL",
            url: "https://github.com/mpvkit/MPVKit/releases/download/0.38.0/Libavutil-GPL.xcframework.zip",
            checksum: "4154e300cde10e4248894eb75161ded91ae891b49157f4f67aac883c42aa760a"
        ),
        .binaryTarget(
            name: "Libswresample-GPL",
            url: "https://github.com/mpvkit/MPVKit/releases/download/0.38.0/Libswresample-GPL.xcframework.zip",
            checksum: "e27fa1b2168b558c5f9842fbfc2fcb769108974faae9076468a6efe463f6ed00"
        ),
        .binaryTarget(
            name: "Libswscale-GPL",
            url: "https://github.com/mpvkit/MPVKit/releases/download/0.38.0/Libswscale-GPL.xcframework.zip",
            checksum: "4ec03e55cd4bf91ebf5f28521bc933db1bbd76da93e1cc888cbb9b405b8de448"
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
            checksum: "4e6c464136044a989990866060849885e75fe8d51e40c3eaa0df905031e72de3"
        ),

        .binaryTarget(
            name: "nettle",
            url: "https://github.com/mpvkit/gnutls-build/releases/download/3.8.3/nettle.xcframework.zip",
            checksum: "36236b6ade0e0dacc394f30ec5bb9b6094b9d030a7c7c629b1808a5d6aca5f7b"
        ),
        .binaryTarget(
            name: "hogweed",
            url: "https://github.com/mpvkit/gnutls-build/releases/download/3.8.3/hogweed.xcframework.zip",
            checksum: "f37d1d826a7d31ce8d5e05e7c8a05d73ed7d96ef7462d6232eeaebab785ea058"
        ),

        .binaryTarget(
            name: "gnutls",
            url: "https://github.com/mpvkit/gnutls-build/releases/download/3.8.3/gnutls.xcframework.zip",
            checksum: "afbe9925bd0b6843e3cdd9122803ef7c107ae16761707c5aa506ec16c46928ff"
        ),

        .binaryTarget(
            name: "Libunibreak",
            url: "https://github.com/mpvkit/libass-build/releases/download/0.17.3/Libunibreak.xcframework.zip",
            checksum: "48956d3f3acdbb5a81e47cf8884f7e22ee73e2042ae63112cb43419cf9da338f"
        ),

        .binaryTarget(
            name: "Libfreetype",
            url: "https://github.com/mpvkit/libass-build/releases/download/0.17.3/Libfreetype.xcframework.zip",
            checksum: "d71f43c615f1d7b40e7204da1f552c8a2060a4d4e4a9021b9e048f4f86f9afc8"
        ),

        .binaryTarget(
            name: "Libfribidi",
            url: "https://github.com/mpvkit/libass-build/releases/download/0.17.3/Libfribidi.xcframework.zip",
            checksum: "e6cbcccf697d6401d1d57d5459a285bdbd2f1ab8b7d1f8acf373352a86b3b5af"
        ),

        .binaryTarget(
            name: "Libharfbuzz",
            url: "https://github.com/mpvkit/libass-build/releases/download/0.17.3/Libharfbuzz.xcframework.zip",
            checksum: "581a15bc38d2cfc400a143309a20b8d0a5d7a0654bb65e961279989d95f3bdfb"
        ),

        .binaryTarget(
            name: "Libass",
            url: "https://github.com/mpvkit/libass-build/releases/download/0.17.3/Libass.xcframework.zip",
            checksum: "51b548e30d6db0c8c64d88930a3eebe5bfc7d5333592b29589f4efdf1aa50e69"
        ),

        .binaryTarget(
            name: "Libdovi",
            url: "https://github.com/mpvkit/libdovi-build/releases/download/3.3.0/Libdovi.xcframework.zip",
            checksum: "ca4382ea4e17103fbcc979d0ddee69a6eb8967c0ab235cb786ffa96da5f512ed"
        ),

        .binaryTarget(
            name: "MoltenVK",
            url: "https://github.com/mpvkit/moltenvk-build/releases/download/1.2.9/MoltenVK.xcframework.zip",
            checksum: "02dd7f51814855b7db9eacd883042b3e9481eb658de6bc63290af80149f2b94f"
        ),

        .binaryTarget(
            name: "Libshaderc_combined",
            url: "https://github.com/mpvkit/libshaderc-build/releases/download/2024.1.0/Libshaderc_combined.xcframework.zip",
            checksum: "f6267f62881e9496608069266ba52b025bcfcd6ec5859d02d780feeabfacc947"
        ),

        .binaryTarget(
            name: "lcms2",
            url: "https://github.com/mpvkit/libplacebo-build/releases/download/7.349.0/lcms2.xcframework.zip",
            checksum: "64edeb9da07cd19fa8f488ed776d5a07aa8839f62d63812af722e0d92c19ab0d"
        ),

        .binaryTarget(
            name: "Libplacebo",
            url: "https://github.com/mpvkit/libplacebo-build/releases/download/7.349.0/Libplacebo.xcframework.zip",
            checksum: "ab71618032cfd3236a1b266e210c5fd5abad0304d75a700046c6e7f18c57851e"
        ),

        .binaryTarget(
            name: "Libdav1d",
            url: "https://github.com/mpvkit/libdav1d-build/releases/download/1.4.3/Libdav1d.xcframework.zip",
            checksum: "5db763f10d5bac53b779c2aaf2254fb5998a4c1375e112b99da2fd1ef4d05da0"
        ),

        .binaryTarget(
            name: "Libavcodec",
            url: "https://github.com/mpvkit/MPVKit/releases/download/0.38.0/Libavcodec.xcframework.zip",
            checksum: "ad9a8f841091ae0675b82b4839c5eca20d4d4b853fa200b8aa90705401913095"
        ),
        .binaryTarget(
            name: "Libavformat",
            url: "https://github.com/mpvkit/MPVKit/releases/download/0.38.0/Libavformat.xcframework.zip",
            checksum: "c798cd382f7bbc5e089321814b559359b9150006217acf033cc0bb49da659fec"
        ),
        .binaryTarget(
            name: "Libavfilter",
            url: "https://github.com/mpvkit/MPVKit/releases/download/0.38.0/Libavfilter.xcframework.zip",
            checksum: "491d1698a30421c111ad74dce5c10dde4931b4a2d0d213c5c9324f621a62accd"
        ),
        .binaryTarget(
            name: "Libavutil",
            url: "https://github.com/mpvkit/MPVKit/releases/download/0.38.0/Libavutil.xcframework.zip",
            checksum: "ec76ed536833f61c2e8636227a9efd1ef995222a30088edcbad66dcdb6b37bd6"
        ),
        .binaryTarget(
            name: "Libswresample",
            url: "https://github.com/mpvkit/MPVKit/releases/download/0.38.0/Libswresample.xcframework.zip",
            checksum: "4b90377948a917fe22e0dd3687b977cfd416bbc38608141f15ea4f8cc751e30c"
        ),
        .binaryTarget(
            name: "Libswscale",
            url: "https://github.com/mpvkit/MPVKit/releases/download/0.38.0/Libswscale.xcframework.zip",
            checksum: "198db2161b1e045a6eb5e73b02156485b555c344f2885c52db2232926e6f21c6"
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
            url: "https://github.com/mpvkit/MPVKit/releases/download/0.38.0/Libbluray.xcframework.zip",
            checksum: "dda8d743e3017f03b17415b9d1b73fff7e769cb674e73aa0c6038e65d1d664eb"
        ),

        .binaryTarget(
            name: "Libmpv",
            url: "https://github.com/mpvkit/MPVKit/releases/download/0.38.0/Libmpv.xcframework.zip",
            checksum: "4876b0cb840ff6a9a07eaf35631e46b02e72404dbb1c1593e740b7e82a0eba7e"
        ),
        //AUTO_GENERATE_TARGETS_END//
    ]
)
