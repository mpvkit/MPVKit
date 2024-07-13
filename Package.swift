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
            name: "hogweed",
            url: "https://github.com/mpvkit/gnutls-build/releases/download/3.8.3/hogweed.xcframework.zip",
            checksum: "0c5c57a508fde663413cb9798ad0ca272a137d5b1d2c5ec205c393b5f60140aa"
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
            checksum: "a77ac8abdbb4d7ede1fd862338c7b5a0c8bc5d8d2d17c59672d6050afb810923"
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
            checksum: "9344661b72d4ed0ab43a3c249a320f3f07d0e5e6fda613d00fdaa10234142b4f"
        ),
        .binaryTarget(
            name: "Libavformat",
            url: "https://github.com/mpvkit/MPVKit/releases/download/0.38.0/Libavformat.xcframework.zip",
            checksum: "3e5bd141bf0e855b105230aae409c121635f575a26d408675a55d676eccb86d6"
        ),
        .binaryTarget(
            name: "Libavfilter",
            url: "https://github.com/mpvkit/MPVKit/releases/download/0.38.0/Libavfilter.xcframework.zip",
            checksum: "5ff23c5591624707dcea3731280660cbcc40abc040697591c7f86d28adb4b680"
        ),
        .binaryTarget(
            name: "Libavutil",
            url: "https://github.com/mpvkit/MPVKit/releases/download/0.38.0/Libavutil.xcframework.zip",
            checksum: "e27c302ab4005ce4b57892adbde9d9c8c35d9521c512fe51010af37161e82276"
        ),
        .binaryTarget(
            name: "Libswresample",
            url: "https://github.com/mpvkit/MPVKit/releases/download/0.38.0/Libswresample.xcframework.zip",
            checksum: "56138781e8aa3f34e390329a510b9662151b9234b7636de4c02b6ab4c22e9f7a"
        ),
        .binaryTarget(
            name: "Libswscale",
            url: "https://github.com/mpvkit/MPVKit/releases/download/0.38.0/Libswscale.xcframework.zip",
            checksum: "b5243428e360f7735460c6b860144d3f9bab325d52bd99fb4380bc7b84c3291d"
        ),

        .binaryTarget(
            name: "Libuchardet",
            url: "https://github.com/mpvkit/MPVKit/releases/download/0.38.0/Libuchardet.xcframework.zip",
            checksum: "07644a3f27919c39db075070e1bf790f5e68f638be18bbba22b9c555e6eb1430"
        ),

        .binaryTarget(
            name: "Libbluray",
            url: "https://github.com/mpvkit/MPVKit/releases/download/0.38.0/Libbluray.xcframework.zip",
            checksum: "395315f85ad316aad3f74db5312ad0a9134e4004f6959b3a3074bbe21b63d89d"
        ),

        .binaryTarget(
            name: "Libluajit",
            url: "https://github.com/mpvkit/libluajit-build/releases/download/2.1.0/Libluajit.xcframework.zip",
            checksum: "a63165ff58b9f46cdabe7b6d545bd507ff2ab0e696f6929366b7aa1be08e7df7"
        ),

        .binaryTarget(
            name: "Libmpv",
            url: "https://github.com/mpvkit/MPVKit/releases/download/0.38.0/Libmpv.xcframework.zip",
            checksum: "0fa52159d9b996d97c16fa0da49a7b7bda348bc8e50c5263dc0bd17a6875eb14"
        ),
        //DEPENDENCY_TARGETS_END//
    ]
)
