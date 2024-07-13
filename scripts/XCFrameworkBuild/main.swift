import Foundation

do {
    let options = try ArgumentOptions.parse(CommandLine.arguments)
    try Build.performCommand(options)

    // SSL
    // try BuildOpenSSL().buildALL()
    try BuildGmp().buildALL()
    try BuildNettle().buildALL()
    try BuildGnutls().buildALL()

    // libass
    try BuildUnibreak().buildALL()
    try BuildFreetype().buildALL()
    try BuildFribidi().buildALL()
    try BuildHarfbuzz().buildALL()
    try BuildASS().buildALL()

    // libsmbclient
    if !options.disableGPL {
        try BuildSmbclient().buildALL()
    }
    
    // ffmpeg
    try BuildDovi().buildALL()
    try BuildVulkan().buildALL()
    try BuildShaderc().buildALL()
    try BuildLittleCms().buildALL()
    try BuildPlacebo().buildALL()
    try BuildDav1d().buildALL()
    try BuildFFMPEG().buildALL()

    // mpv
    try BuildUchardet().buildALL()
    try BuildBluray().buildALL()
    try BuildLuaJIT().buildALL()
    try BuildMPV().buildALL()
} catch {
    print(error.localizedDescription)
    exit(1)
}


enum Library: String, CaseIterable {
    case libmpv, FFmpeg, libshaderc, vulkan, lcms2, libdovi, openssl, libunibreak, libfreetype, libfribidi, libharfbuzz, libass, libsmbclient, libplacebo, libdav1d, gmp, nettle, gnutls, libuchardet, libbluray, libluajit
    var version: String {
        switch self {
        case .libmpv:
            return "v0.38.0"
        case .FFmpeg:
            return "n7.0.1"
        case .openssl:
            return "3.2.0"
        case .gnutls:
            return "3.8.3"
        case .nettle:
            return "3.8.3"
        case .gmp:
            return "3.8.3"
        case .libass:
            return "0.17.3"
        case .libunibreak:
            return "0.17.3"
        case .libfreetype:
            return "0.17.3"
        case .libfribidi:
            return "0.17.3"
        case .libharfbuzz:
            return "0.17.3"
        case .libsmbclient:
            return "4.15.13"
        case .libdav1d:    // AV1 decoding
            return "1.4.3"
        case .lcms2:
            return "7.349.0"
        case .libplacebo:
            return "7.349.0"
        case .libdovi:
            return "v3.3.0"
        case .vulkan:
            return "1.2.9"
        case .libshaderc:  // compiling GLSL (OpenGL Shading Language) shaders into SPIR-V (Standard Portable Intermediate Representation - Vulkan) code
            return "2024.1.0"
        case .libuchardet:
            return "v0.0.8"
        case .libbluray:
            return "1.3.4"
        case .libluajit:
            return "2.1.0"
        }
    }

    var url: String {
        switch self {
        case .libmpv:
            return "https://github.com/mpv-player/mpv"
        case .FFmpeg:
            return "https://github.com/FFmpeg/FFmpeg"
        case .openssl:
            return "https://github.com/mpvkit/openssl-build/releases/download/\(self.version)/openssl-all.zip"
        case .gnutls:
            return "https://github.com/mpvkit/gnutls-build/releases/download/\(self.version)/gnutls-all.zip"
        case .nettle:
            return "https://github.com/mpvkit/gnutls-build/releases/download/\(self.version)/nettle-all.zip"
        case .gmp:
            return "https://github.com/mpvkit/gnutls-build/releases/download/\(self.version)/gmp-all.zip"
        case .libass:
            return "https://github.com/mpvkit/libass-build/releases/download/\(self.version)/libass-all.zip"
        case .libunibreak:
            return "https://github.com/mpvkit/libass-build/releases/download/\(self.version)/libunibreak-all.zip"
        case .libfreetype:
            return "https://github.com/mpvkit/libass-build/releases/download/\(self.version)/libfreetype-all.zip"
        case .libfribidi:
            return "https://github.com/mpvkit/libass-build/releases/download/\(self.version)/libfribidi-all.zip"
        case .libharfbuzz:
            return "https://github.com/mpvkit/libass-build/releases/download/\(self.version)/libharfbuzz-all.zip"
        case .libsmbclient:
            return "https://github.com/mpvkit/libsmbclient-build/releases/download/\(self.version)/libsmbclient-all.zip"
        case .lcms2:
            return "https://github.com/mpvkit/libplacebo-build/releases/download/\(self.version)/lcms2-all.zip"
        case .libplacebo:
            return "https://github.com/mpvkit/libplacebo-build/releases/download/\(self.version)/libplacebo-all.zip"
        case .libdav1d:
            return "https://github.com/mpvkit/libdav1d-build/releases/download/\(self.version)/libdav1d-all.zip"
        case .libdovi:
            return "https://github.com/mpvkit/libdovi-build/releases/download/\(self.version)/libdovi-all.zip"
        case .vulkan:
            return "https://github.com/mpvkit/moltenvk-build/releases/download/\(self.version)/MoltenVK-all.zip"
        case .libshaderc:
            return "https://github.com/mpvkit/libshaderc-build/releases/download/\(self.version)/libshaderc-all.zip"
        case .libuchardet:
            return "https://gitlab.freedesktop.org/uchardet/uchardet"
        case .libbluray:
            return "https://code.videolan.org/videolan/libbluray.git"
        case .libluajit:
            return "https://github.com/mpvkit/libluajit-build/releases/download/\(self.version)/libluajit-all.zip"
        }
    }

    // for generate Package.swift
    var targets : [PackageTarget] {
        switch self {
        case .libmpv:
            return [
                .target(
                    name: "Libmpv",
                    url: "https://github.com/mpvkit/MPVKit/releases/download/\(BaseBuild.options.releaseVersion)/Libmpv.xcframework.zip",
                    checksum: ""
                ),
            ]
        case .FFmpeg:
            return  [
                .target(
                    name: "Libavcodec",
                    url: "https://github.com/mpvkit/MPVKit/releases/download/\(BaseBuild.options.releaseVersion)/Libavcodec.xcframework.zip",
                    checksum: ""
                ),
                .target(
                    name: "Libavformat",
                    url: "https://github.com/mpvkit/MPVKit/releases/download/\(BaseBuild.options.releaseVersion)/Libavformat.xcframework.zip",
                    checksum: ""
                ),
                .target(
                    name: "Libavfilter",
                    url: "https://github.com/mpvkit/MPVKit/releases/download/\(BaseBuild.options.releaseVersion)/Libavfilter.xcframework.zip",
                    checksum: ""
                ),
                .target(
                    name: "Libavutil",
                    url: "https://github.com/mpvkit/MPVKit/releases/download/\(BaseBuild.options.releaseVersion)/Libavutil.xcframework.zip",
                    checksum: ""
                ),
                .target(
                    name: "Libswresample",
                    url: "https://github.com/mpvkit/MPVKit/releases/download/\(BaseBuild.options.releaseVersion)/Libswresample.xcframework.zip",
                    checksum: ""
                ),
                .target(
                    name: "Libswscale",
                    url: "https://github.com/mpvkit/MPVKit/releases/download/\(BaseBuild.options.releaseVersion)/Libswscale.xcframework.zip",
                    checksum: ""
                ),
            ]
        case .openssl:
            return  [
                .target(
                    name: "Libcrypto",
                    url: "https://github.com/mpvkit/openssl-build/releases/download/\(self.version)/Libcrypto.xcframework.zip",
                    checksum: "https://github.com/mpvkit/openssl-build/releases/download/\(self.version)/Libcrypto.xcframework.checksum.txt"
                ),
                .target(
                    name: "Libcrypto",
                    url: "https://github.com/mpvkit/openssl-build/releases/download/\(self.version)/Libssl.xcframework.zip",
                    checksum: "https://github.com/mpvkit/openssl-build/releases/download/\(self.version)/Libssl.xcframework.checksum.txt"
                ),
            ]
        case .gnutls:
            return  [
                .target(
                    name: "gnutls",
                    url: "https://github.com/mpvkit/gnutls-build/releases/download/\(self.version)/gnutls.xcframework.zip",
                    checksum: "https://github.com/mpvkit/gnutls-build/releases/download/\(self.version)/gnutls.xcframework.checksum.txt"
                ),
            ]
        case .nettle:
            return  [
                .target(
                    name: "nettle",
                    url: "https://github.com/mpvkit/gnutls-build/releases/download/\(self.version)/nettle.xcframework.zip",
                    checksum: "https://github.com/mpvkit/gnutls-build/releases/download/\(self.version)/nettle.xcframework.checksum.txt"
                ),
            ]
        case .gmp:
            return  [
                .target(
                    name: "gmp",
                    url: "https://github.com/mpvkit/gnutls-build/releases/download/\(self.version)/gmp.xcframework.zip",
                    checksum: "https://github.com/mpvkit/gnutls-build/releases/download/\(self.version)/gmp.xcframework.checksum.txt"
                ),
            ]
        case .libass:
            return  [
                .target(
                    name: "Libass",
                    url: "https://github.com/mpvkit/libass-build/releases/download/\(self.version)/Libass.xcframework.zip",
                    checksum: "https://github.com/mpvkit/libass-build/releases/download/\(self.version)/Libass.xcframework.checksum.txt"
                ),
            ]
        case .libunibreak:
            return  [
                .target(
                    name: "Libunibreak",
                    url: "https://github.com/mpvkit/libass-build/releases/download/\(self.version)/Libunibreak.xcframework.zip",
                    checksum: "https://github.com/mpvkit/libass-build/releases/download/\(self.version)/Libunibreak.xcframework.checksum.txt"
                ),
            ]
        case .libfreetype:
            return  [
                .target(
                    name: "Libfreetype",
                    url: "https://github.com/mpvkit/libass-build/releases/download/\(self.version)/Libfreetype.xcframework.zip",
                    checksum: "https://github.com/mpvkit/libass-build/releases/download/\(self.version)/Libfreetype.xcframework.checksum.txt"
                ),
            ]
        case .libfribidi:
            return  [
                .target(
                    name: "Libfribidi",
                    url: "https://github.com/mpvkit/libass-build/releases/download/\(self.version)/Libfribidi.xcframework.zip",
                    checksum: "https://github.com/mpvkit/libass-build/releases/download/\(self.version)/Libfribidi.xcframework.checksum.txt"
                ),
            ]
        case .libharfbuzz:
            return  [
                .target(
                    name: "Libharfbuzz",
                    url: "https://github.com/mpvkit/libass-build/releases/download/\(self.version)/Libharfbuzz.xcframework.zip",
                    checksum: "https://github.com/mpvkit/libass-build/releases/download/\(self.version)/Libharfbuzz.xcframework.checksum.txt"
                ),
            ]
        case .libsmbclient:
            return  [
                .target(
                    name: "Libsmbclient",
                    url: "https://github.com/mpvkit/libsmbclient-build/releases/download/\(self.version)/Libsmbclient.xcframework.zip",
                    checksum: "https://github.com/mpvkit/libsmbclient-build/releases/download/\(self.version)/Libsmbclient.xcframework.checksum.txt"
                ),
            ]
        case .lcms2:
            return  [
                .target(
                    name: "lcms2",
                    url: "https://github.com/mpvkit/libplacebo-build/releases/download/\(self.version)/lcms2.xcframework.zip",
                    checksum: "https://github.com/mpvkit/libplacebo-build/releases/download/\(self.version)/lcms2.xcframework.checksum.txt"
                ),
            ]
        case .libplacebo:
            return  [
                .target(
                    name: "Libplacebo",
                    url: "https://github.com/mpvkit/libplacebo-build/releases/download/\(self.version)/Libplacebo.xcframework.zip",
                    checksum: "https://github.com/mpvkit/libplacebo-build/releases/download/\(self.version)/Libplacebo.xcframework.checksum.txt"
                ),
            ]
        case .libdav1d:
            return  [
                .target(
                    name: "Libdav1d",
                    url: "https://github.com/mpvkit/libdav1d-build/releases/download/\(self.version)/Libdav1d.xcframework.zip",
                    checksum: "https://github.com/mpvkit/libdav1d-build/releases/download/\(self.version)/Libdav1d.xcframework.checksum.txt"
                ),
            ]
        case .libdovi:
            return  [
                .target(
                    name: "Libdovi",
                    url: "https://github.com/mpvkit/libdovi-build/releases/download/\(self.version)/Libdovi.xcframework.zip",
                    checksum: "https://github.com/mpvkit/libdovi-build/releases/download/\(self.version)/Libdovi.xcframework.checksum.txt"
                ),
            ]
        case .vulkan:
            return  [
                .target(
                    name: "MoltenVK",
                    url: "https://github.com/mpvkit/moltenvk-build/releases/download/\(self.version)/MoltenVK.xcframework.zip",
                    checksum: "https://github.com/mpvkit/moltenvk-build/releases/download/\(self.version)/MoltenVK.xcframework.checksum.txt"
                ),
            ]
        case .libshaderc:
            return  [
                .target(
                    name: "Libshaderc_combined",
                    url: "https://github.com/mpvkit/libshaderc-build/releases/download/\(self.version)/Libshaderc_combined.xcframework.zip",
                    checksum: "https://github.com/mpvkit/libshaderc-build/releases/download/\(self.version)/Libshaderc_combined.xcframework.checksum.txt"
                ),
            ]
        case .libuchardet:
            return  [
                .target(
                    name: "Libuchardet",
                    url: "https://github.com/mpvkit/MPVKit/releases/download/\(BaseBuild.options.releaseVersion)/Libuchardet.xcframework.zip",
                    checksum: ""
                ),
            ]
        case .libbluray:
            return [
                .target(
                    name: "Libbluray",
                    url: "https://github.com/mpvkit/MPVKit/releases/download/\(BaseBuild.options.releaseVersion)/Libbluray.xcframework.zip",
                    checksum: ""
                ),
            ]
        case .libluajit:
            return  [
                .target(
                    name: "Libluajit",
                    url: "https://github.com/mpvkit/libluajit-build/releases/download/\(self.version)/Libluajit.xcframework.zip",
                    checksum: "https://github.com/mpvkit/libluajit-build/releases/download/\(self.version)/Libluajit.xcframework.checksum.txt"
                ),
            ]
        }
    }
}

private class BuildUchardet: BaseBuild {
    init() {
        super.init(library: .libuchardet)
    }
}



private class BuildBluray: BaseBuild {
    init() {
        super.init(library: .libbluray)

        Utility.shell("git submodule update --init --recursive", currentDirectoryURL: directoryURL)
    }

    override func build(platform: PlatformType, arch: ArchType) throws {
        // 依赖 DiskArbitration 框架，只能 macos 下使用，不然提示缺少 DiskArbitration/DADisk.h
        if platform != .macos && platform != .maccatalyst {
            return
        }
        try super.build(platform: platform, arch: arch)
    }

    override func arguments(platform: PlatformType, arch: ArchType) -> [String] {
        [
            "--without-external-libudfread",
            "--disable-doxygen-doc",
            "--disable-doxygen-dot",
            "--disable-doxygen-html",
            "--disable-doxygen-ps",
            "--disable-doxygen-pdf",
            "--disable-examples",
            "--disable-bdjava-jar",
            "--with-pic",
            "--enable-static",
            "--disable-shared",
            "--disable-fast-install",
            "--disable-dependency-tracking",
            "--host=\(platform.host(arch: arch))",
        ]
    }
}

private class BuildLuaJIT: ZipBaseBuild {
    init() {
        super.init(library: .libluajit)
    }
}


private class BuildMPV: BaseBuild {
    init() {
        super.init(library: .libmpv)
 
        let path = directoryURL + "meson.build"
        if let data = FileManager.default.contents(atPath: path.path), var str = String(data: data, encoding: .utf8) {
            str = str.replacingOccurrences(of: "# ffmpeg", with: """
            add_languages('objc')
            #ffmpeg
            """)
            str = str.replacingOccurrences(of: """
            subprocess_source = files('osdep/subprocess-posix.c')
            """, with: """
            if host_machine.subsystem() == 'tvos' or host_machine.subsystem() == 'tvos-simulator'
                subprocess_source = files('osdep/subprocess-dummy.c')
            else
                subprocess_source =files('osdep/subprocess-posix.c')
            endif
            """)
            try! str.write(toFile: path.path, atomically: true, encoding: .utf8)
        }
    }

    override func flagsDependencelibrarys() -> [Library] {
        [.gmp, .libsmbclient]
    }


    override func arguments(platform: PlatformType, arch: ArchType) -> [String] {
        var array = [
            "-Dlibmpv=true",
            "-Dplain-gl=enabled",
            "-Diconv=enabled",
            "-Duchardet=enabled",
            "-Dvulkan=enabled",
            "-Dmoltenvk=enabled",  // from patch option

            "-Djavascript=disabled",
            "-Dzimg=disabled",
            "-Djpeg=disabled",
            "-Dvapoursynth=disabled",
            "-Drubberband=disabled",
        ]
        if !BaseBuild.options.disableGPL {
            array.append("-Dgl=enabled")
        }
        let blurayLibPath = URL.currentDirectory + [Library.libbluray.rawValue, platform.rawValue, "thin", arch.rawValue]
        if FileManager.default.fileExists(atPath: blurayLibPath.path) {
            array.append("-Dlibbluray=enabled")
        } else {
            array.append("-Dlibbluray=disabled")
        }
        if !(platform == .macos && arch.executable) {
            array.append("-Dcplayer=false")
        }
        if platform == .macos {
            array.append("-Dswift-flags=-sdk \(platform.isysroot) -target \(platform.deploymentTarget(arch))")
            array.append("-Dcocoa=enabled")
            array.append("-Dcoreaudio=enabled")
            array.append("-Davfoundation=enabled")
            array.append("-Dgl-cocoa=enabled")
            array.append("-Dvideotoolbox-gl=enabled")
            array.append("-Dlua=luajit")  // macos show video stats need enable 
        } else {
            array.append("-Dvideotoolbox-gl=disabled")
            array.append("-Dswift-build=disabled")
            array.append("-Daudiounit=enabled")
            array.append("-Davfoundation=disabled")
            array.append("-Dlua=disabled")
            if platform == .maccatalyst {
                array.append("-Dcocoa=disabled")
                array.append("-Dcoreaudio=disabled")
            } else {
                array.append("-Dios-gl=enabled")
            }
        }
        return array
    }

    override func buildALL() throws {
        try super.buildALL()

        // copy headers
        let firstPlatform = getFirstSuccessPlatform()
        let firstArch = architectures(firstPlatform).first!
        let includePath = thinDir(platform: firstPlatform, arch: firstArch) + ["include"]
        let destIncludePath = URL.currentDirectory + "../Sources/MPVKit/include"
        print("Copy headers to path: \(destIncludePath.path)")
        try? FileManager.default.removeItem(at: destIncludePath)
        try FileManager.default.copyItem(at: includePath, to: destIncludePath)
    }

}


private class BuildFFMPEG: BaseBuild {
    init() {
        super.init(library: .FFmpeg)

        if Utility.shell("which nasm") == nil {
            Utility.shell("brew install nasm")
        }
        if Utility.shell("which sdl2-config") == nil {
            Utility.shell("brew install sdl2")
        }
        
        let lldbFile = URL.currentDirectory + "LLDBInitFile"
        try? FileManager.default.removeItem(at: lldbFile)
        FileManager.default.createFile(atPath: lldbFile.path, contents: nil, attributes: nil)
        let path = directoryURL + "libavcodec/videotoolbox.c"
        if let data = FileManager.default.contents(atPath: path.path), var str = String(data: data, encoding: .utf8) {
            str = str.replacingOccurrences(of: "kCVPixelBufferOpenGLESCompatibilityKey", with: "kCVPixelBufferMetalCompatibilityKey")
            str = str.replacingOccurrences(of: "kCVPixelBufferIOSurfaceOpenGLTextureCompatibilityKey", with: "kCVPixelBufferMetalCompatibilityKey")
            try? str.write(toFile: path.path, atomically: true, encoding: .utf8)
        }
    }

    override func flagsDependencelibrarys() -> [Library] {
        [.gmp, .nettle, .gnutls, .libsmbclient]
    }

    override func cFlags(platform: PlatformType, arch: ArchType) -> [String] {
        var cFlags = super.cFlags(platform: platform, arch: arch)

        // append special libsmbclient include path
        let path = thinDir(library: .libsmbclient, platform: platform, arch: arch)
        if FileManager.default.fileExists(atPath: path.path) {
            cFlags.append("-I\(path.path)/include/samba-4.0")
        }

        return cFlags
    }

    override func ldFlags(platform: PlatformType, arch: ArchType) -> [String] {
        var ldFlags = super.ldFlags(platform: platform, arch: arch)

        var path = thinDir(library: .nettle, platform: platform, arch: arch)
        if FileManager.default.fileExists(atPath: path.path) {
            ldFlags.append("-lhogweed")
        }
        path = thinDir(library: .gnutls, platform: platform, arch: arch)
        if FileManager.default.fileExists(atPath: path.path) {
            ldFlags.append(contentsOf: ["-framework", "Security", "-framework", "CoreFoundation"])
        }
        path = thinDir(library: .libsmbclient, platform: platform, arch: arch)
        if FileManager.default.fileExists(atPath: path.path) {
            ldFlags.append(contentsOf: ["-lresolv", "-lpthread", "-lz", "-liconv"])
        }
        return ldFlags
    }

    override func frameworks() throws -> [String] {
        var frameworks: [String] = []
        if let platform = platforms().first {
            if let arch = platform.architectures.first {
                let lib = thinDir(platform: platform, arch: arch) + "lib"
                let fileNames = try FileManager.default.contentsOfDirectory(atPath: lib.path)
                for fileName in fileNames {
                    if fileName.hasPrefix("lib"), fileName.hasSuffix(".a") {
                        // 因为其他库也可能引入libavformat,所以把lib改成大写，这样就可以排在前面，覆盖别的库。
                        frameworks.append("Lib" + fileName.dropFirst(3).dropLast(2))
                    }
                }
            }
        }
        return frameworks
    }

    override func build(platform: PlatformType, arch: ArchType) throws {
        try super.build(platform: platform, arch: arch)
        let buildURL = scratch(platform: platform, arch: arch)
        let prefix = thinDir(platform: platform, arch: arch)
        let lldbFile = URL.currentDirectory + "LLDBInitFile"
        if let data = FileManager.default.contents(atPath: lldbFile.path), var str = String(data: data, encoding: .utf8) {
            str.append("settings \(str.isEmpty ? "set" : "append") target.source-map \((buildURL + "src").path) \(directoryURL.path)\n")
            try str.write(toFile: lldbFile.path, atomically: true, encoding: .utf8)
        }
        try FileManager.default.copyItem(at: buildURL + "config.h", to: prefix + "include/libavutil/config.h")
        try FileManager.default.copyItem(at: buildURL + "config.h", to: prefix + "include/libavcodec/config.h")
        try FileManager.default.copyItem(at: buildURL + "config.h", to: prefix + "include/libavformat/config.h")
        try FileManager.default.copyItem(at: buildURL + "src/libavutil/getenv_utf8.h", to: prefix + "include/libavutil/getenv_utf8.h")
        try FileManager.default.copyItem(at: buildURL + "src/libavutil/libm.h", to: prefix + "include/libavutil/libm.h")
        try FileManager.default.copyItem(at: buildURL + "src/libavutil/thread.h", to: prefix + "include/libavutil/thread.h")
        try FileManager.default.copyItem(at: buildURL + "src/libavutil/intmath.h", to: prefix + "include/libavutil/intmath.h")
        try FileManager.default.copyItem(at: buildURL + "src/libavutil/mem_internal.h", to: prefix + "include/libavutil/mem_internal.h")
        try FileManager.default.copyItem(at: buildURL + "src/libavutil/attributes_internal.h", to: prefix + "include/libavutil/attributes_internal.h")
        try FileManager.default.copyItem(at: buildURL + "src/libavcodec/mathops.h", to: prefix + "include/libavcodec/mathops.h")
        try FileManager.default.copyItem(at: buildURL + "src/libavformat/os_support.h", to: prefix + "include/libavformat/os_support.h")
        let internalPath = prefix + "include/libavutil/internal.h"
        try FileManager.default.copyItem(at: buildURL + "src/libavutil/internal.h", to: internalPath)
        if let data = FileManager.default.contents(atPath: internalPath.path), var str = String(data: data, encoding: .utf8) {
            str = str.replacingOccurrences(of: """
            #include "timer.h"
            """, with: """
            // #include "timer.h"
            """)
            str = str.replacingOccurrences(of: "kCVPixelBufferIOSurfaceOpenGLTextureCompatibilityKey", with: "kCVPixelBufferMetalCompatibilityKey")
            try str.write(toFile: internalPath.path, atomically: true, encoding: .utf8)
        }
        
    }


    override func arguments(platform: PlatformType, arch: ArchType) -> [String] {
        var arguments = ffmpegConfiguers
        if BaseBuild.options.enableDebug {
            arguments.append("--enable-debug")
            arguments.append("--disable-stripping")
            arguments.append("--disable-optimizations")
        } else {
            arguments.append("--disable-debug")
            arguments.append("--enable-stripping")
            arguments.append("--enable-optimizations")
        }
        if !BaseBuild.options.disableGPL {
            arguments.append("--enable-gpl")
        }
        // arguments += Build.ffmpegConfiguers
        arguments.append("--disable-large-tests")
        arguments.append("--ignore-tests=TESTS")
        arguments.append("--arch=\(arch.cpuFamily)")
        arguments.append("--target-os=darwin")
        // arguments.append(arch.cpu())

        /**
         aacpsdsp.o), building for Mac Catalyst, but linking in object file built for
         x86_64 binaries are built without ASM support, since ASM for x86_64 is actually x86 and that confuses `xcodebuild -create-xcframework` https://stackoverflow.com/questions/58796267/building-for-macos-but-linking-in-object-file-built-for-free-standing/59103419#59103419
         */
        if platform == .maccatalyst || arch == .x86_64 {
            arguments.append("--disable-neon")
            arguments.append("--disable-asm")
        } else {
            arguments.append("--enable-neon")
            arguments.append("--enable-asm")
        }
        if platform == .macos, arch.executable {
            arguments.append("--enable-ffplay")
            arguments.append("--enable-sdl2")
            arguments.append("--enable-decoder=rawvideo")
            arguments.append("--enable-filter=color")
            arguments.append("--enable-filter=lut")
            arguments.append("--enable-filter=testsrc")
            arguments.append("--disable-avdevice")
            //            arguments.append("--enable-avdevice")
            //            arguments.append("--enable-indev=lavfi")
        } else {
            arguments.append("--disable-avdevice")
            arguments.append("--disable-programs")
        }
        //        if platform == .isimulator || platform == .tvsimulator {
        //            arguments.append("--assert-level=1")
        //        }
        for library in [Library.gmp, .gnutls, .libsmbclient, .libfreetype, .libharfbuzz, .libfribidi, .libass, .vulkan, .libshaderc, .lcms2, .libplacebo, .libdav1d] {
            let path = URL.currentDirectory + [library.rawValue, platform.rawValue, "thin", arch.rawValue]
            if FileManager.default.fileExists(atPath: path.path) {
                arguments.append("--enable-\(library.rawValue)")
                if library == .libsmbclient {
                    arguments.append("--enable-protocol=\(library.rawValue)")
                } else if library == .libdav1d {
                    arguments.append("--enable-decoder=\(library.rawValue)")
                } else if library == .libass {
                    arguments.append("--enable-filter=ass")
                    arguments.append("--enable-filter=subtitles")
                } else if library == .libplacebo {
                    arguments.append("--enable-filter=libplacebo")
                }
            }
        }
        
        return arguments
    }

    private func replaceBin(prefix: URL, item: String) throws {
        if FileManager.default.fileExists(atPath: (prefix + ["bin", item]).path) {
            try? FileManager.default.removeItem(at: URL(fileURLWithPath: "/usr/local/bin/\(item)"))
            try? FileManager.default.copyItem(at: prefix + ["bin", item], to: URL(fileURLWithPath: "/usr/local/bin/\(item)"))
        }
    }


    private func makeFFmpegSourece() throws {
        guard let platform = BaseBuild.platforms.first, let arch = architectures(platform).first else {
            return
        }
        let target = URL.currentDirectory + ["../Sources", "FFmpeg"]
        try? FileManager.default.removeItem(at: target)
        try? FileManager.default.createDirectory(at: target, withIntermediateDirectories: true, attributes: nil)
        let thin = thinDir(platform: platform, arch: arch)
        try? FileManager.default.copyItem(at: thin + "include", to: target + "include")
        let scratchURL = scratch(platform: platform, arch: arch)
        try? FileManager.default.createDirectory(at: target + "include", withIntermediateDirectories: true, attributes: nil)
        try? FileManager.default.copyItem(at: scratchURL + "config.h", to: target + "include" + "config.h")
        let fileNames = try FileManager.default.contentsOfDirectory(atPath: scratchURL.path)
        for fileName in fileNames where fileName.hasPrefix("lib") {
            var url = scratchURL + fileName
            var isDir: ObjCBool = false
            if FileManager.default.fileExists(atPath: url.path, isDirectory: &isDir), isDir.boolValue {
                // copy .c
                if let subpaths = FileManager.default.enumerator(atPath: url.path) {
                    let dstDir = target + fileName
                    while let subpath = subpaths.nextObject() as? String {
                        if subpath.hasSuffix(".c") {
                            let srcURL = url + subpath
                            let dstURL = target + "include" + fileName + subpath
                            try? FileManager.default.copyItem(at: srcURL, to: dstURL)
                        } else if subpath.hasSuffix(".o") {
                            let subpath = subpath.replacingOccurrences(of: ".o", with: ".c")
                            let srcURL = scratchURL + "src" + fileName + subpath
                            let dstURL = dstDir + subpath
                            let dstURLDir = dstURL.deletingLastPathComponent()
                            if !FileManager.default.fileExists(atPath: dstURLDir.path) {
                                try? FileManager.default.createDirectory(at: dstURLDir, withIntermediateDirectories: true, attributes: nil)
                            }
                            try? FileManager.default.copyItem(at: srcURL, to: dstURL)
                        }
                    }
                }
                url = scratchURL + "src" + fileName
                // copy .h
                try? FileManager.default.copyItem(at: scratchURL + "src" + "compat", to: target + "compat")
                if let subpaths = FileManager.default.enumerator(atPath: url.path) {
                    let dstDir = target + "include" + fileName
                    while let subpath = subpaths.nextObject() as? String {
                        if subpath.hasSuffix(".h") || subpath.hasSuffix("_template.c") {
                            let srcURL = url + subpath
                            let dstURL = dstDir + subpath
                            let dstURLDir = dstURL.deletingLastPathComponent()
                            if !FileManager.default.fileExists(atPath: dstURLDir.path) {
                                try? FileManager.default.createDirectory(at: dstURLDir, withIntermediateDirectories: true, attributes: nil)
                            }
                            try? FileManager.default.copyItem(at: srcURL, to: dstURL)
                        }
                    }
                }
            }
        }
    }

    override func frameworkExcludeHeaders(_ framework: String) -> [String] {
        if framework == "Libavcodec" {
            return ["xvmc", "vdpau", "qsv", "dxva2", "d3d11va"]
        } else if framework == "Libavutil" {
            return ["hwcontext_vulkan", "hwcontext_vdpau", "hwcontext_vaapi", "hwcontext_qsv", "hwcontext_opencl", "hwcontext_dxva2", "hwcontext_d3d11va", "hwcontext_cuda"]
        } else {
            return super.frameworkExcludeHeaders(framework)
        }
    }

    private let ffmpegConfiguers = [
        // Configuration options:
        "--disable-armv5te", "--disable-armv6", "--disable-armv6t2",
        "--disable-bzlib", "--disable-gray", "--disable-iconv", "--disable-linux-perf",
        "--disable-shared", "--disable-small", "--disable-swscale-alpha", "--disable-symver", "--disable-xlib",
        "--enable-cross-compile", "--enable-libxml2", "--enable-nonfree",
        "--enable-optimizations", "--enable-pic", "--enable-runtime-cpudetect", "--enable-static", "--enable-thumb", "--enable-version3",
        "--pkg-config-flags=--static",
        // Documentation options:
        "--disable-doc", "--disable-htmlpages", "--disable-manpages", "--disable-podpages", "--disable-txtpages",
        // Component options:
        "--enable-avcodec", "--enable-avformat", "--enable-avutil", "--enable-network", "--enable-swresample", "--enable-swscale",
        "--disable-devices", "--disable-outdevs", "--disable-indevs", "--disable-postproc",
        // ,"--disable-pthreads"
        // ,"--disable-w32threads"
        // ,"--disable-os2threads"
        // ,"--disable-dct"
        // ,"--disable-dwt"
        // ,"--disable-lsp"
        // ,"--disable-lzo"
        // ,"--disable-mdct"
        // ,"--disable-rdft"
        // ,"--disable-fft"
        // Hardware accelerators:
        "--disable-d3d11va", "--disable-dxva2", "--disable-vaapi", "--disable-vdpau",
        // Individual component options:
        // ,"--disable-everything"
        // ./configure --list-muxers
        "--disable-muxers",
        "--enable-muxer=flac", "--enable-muxer=dash", "--enable-muxer=hevc",
        "--enable-muxer=m4v", "--enable-muxer=matroska", "--enable-muxer=mov", "--enable-muxer=mp4",
        "--enable-muxer=mpegts", "--enable-muxer=webm*",
        // ./configure --list-encoders
        "--disable-encoders",
        "--enable-encoder=aac", "--enable-encoder=alac", "--enable-encoder=flac", "--enable-encoder=pcm*",
        "--enable-encoder=movtext", "--enable-encoder=mpeg4", "--enable-encoder=h264_videotoolbox",
        "--enable-encoder=hevc_videotoolbox", "--enable-encoder=prores", "--enable-encoder=prores_videotoolbox",
        // ./configure --list-protocols
        "--enable-protocols",
        // ./configure --list-demuxers
        // 用所有的demuxers的话，那avformat就会达到8MB了，指定的话，那就只要4MB。
        "--disable-demuxers",
        "--enable-demuxer=aac", "--enable-demuxer=ac3", "--enable-demuxer=aiff", "--enable-demuxer=amr",
        "--enable-demuxer=ape", "--enable-demuxer=asf", "--enable-demuxer=ass", "--enable-demuxer=av1",
        "--enable-demuxer=avi", "--enable-demuxer=caf", "--enable-demuxer=concat",
        "--enable-demuxer=dash", "--enable-demuxer=data", "--enable-demuxer=dv",
        "--enable-demuxer=eac3",
        "--enable-demuxer=flac", "--enable-demuxer=flv", "--enable-demuxer=h264", "--enable-demuxer=hevc",
        "--enable-demuxer=hls", "--enable-demuxer=live_flv", "--enable-demuxer=loas", "--enable-demuxer=m4v",
        // matroska=mkv,mka,mks,mk3d
        "--enable-demuxer=matroska", "--enable-demuxer=mov", "--enable-demuxer=mp3", "--enable-demuxer=mpeg*",
        "--enable-demuxer=ogg", "--enable-demuxer=rm", "--enable-demuxer=rtsp", "--enable-demuxer=rtp",
        "--enable-demuxer=srt", "--enable-demuxer=webvtt",
        "--enable-demuxer=vc1", "--enable-demuxer=wav", "--enable-demuxer=webm_dash_manifest",
        // ./configure --list-bsfs
        "--enable-bsfs",
        // ./configure --list-decoders
        // 用所有的decoders的话，那avcodec就会达到40MB了，指定的话，那就只要20MB。
        "--disable-decoders",
        // 视频
        "--enable-decoder=av1", "--enable-decoder=dca", "--enable-decoder=dxv",
        "--enable-decoder=ffv1", "--enable-decoder=ffvhuff", "--enable-decoder=flv",
        "--enable-decoder=h263", "--enable-decoder=h263i", "--enable-decoder=h263p", "--enable-decoder=h264",
        "--enable-decoder=hap", "--enable-decoder=hevc", "--enable-decoder=huffyuv",
        "--enable-decoder=indeo5",
        "--enable-decoder=mjpeg", "--enable-decoder=mjpegb", "--enable-decoder=mpeg*", "--enable-decoder=mts2",
        "--enable-decoder=prores",
        "--enable-decoder=mpeg4", "--enable-decoder=mpegvideo",
        "--enable-decoder=rv10", "--enable-decoder=rv20", "--enable-decoder=rv30", "--enable-decoder=rv40",
        "--enable-decoder=snow", "--enable-decoder=svq3",
        "--enable-decoder=tscc", "--enable-decoder=txd",
        "--enable-decoder=wmv1", "--enable-decoder=wmv2", "--enable-decoder=wmv3",
        "--enable-decoder=vc1", "--enable-decoder=vp6", "--enable-decoder=vp6a", "--enable-decoder=vp6f",
        "--enable-decoder=vp7", "--enable-decoder=vp8", "--enable-decoder=vp9",
        // 音频
        "--enable-decoder=aac*", "--enable-decoder=ac3*", "--enable-decoder=adpcm*", "--enable-decoder=alac*",
        "--enable-decoder=amr*", "--enable-decoder=ape", "--enable-decoder=cook",
        "--enable-decoder=dca", "--enable-decoder=dolby_e", "--enable-decoder=eac3*", "--enable-decoder=flac",
        "--enable-decoder=mp1*", "--enable-decoder=mp2*", "--enable-decoder=mp3*", "--enable-decoder=opus",
        "--enable-decoder=pcm*", "--enable-decoder=sonic",
        "--enable-decoder=truehd", "--enable-decoder=tta", "--enable-decoder=vorbis", "--enable-decoder=wma*",
        // 字幕
        "--enable-decoder=ass", "--enable-decoder=ccaption", "--enable-decoder=dvbsub", "--enable-decoder=dvdsub",
        "--enable-decoder=mpl2", "--enable-decoder=movtext",
        "--enable-decoder=pgssub", "--enable-decoder=srt", "--enable-decoder=ssa", "--enable-decoder=subrip",
        "--enable-decoder=xsub", "--enable-decoder=webvtt",

        // ./configure --list-filters
        "--disable-filters",
        "--enable-filter=aformat", "--enable-filter=amix", "--enable-filter=anull", "--enable-filter=aresample",
        "--enable-filter=areverse", "--enable-filter=asetrate", "--enable-filter=atempo", "--enable-filter=atrim",
        "--enable-filter=bwdif", "--enable-filter=delogo",
        "--enable-filter=equalizer", "--enable-filter=estdif",
        "--enable-filter=firequalizer", "--enable-filter=format", "--enable-filter=fps",
        "--enable-filter=hflip", "--enable-filter=hwdownload", "--enable-filter=hwmap", "--enable-filter=hwupload",
        "--enable-filter=idet", "--enable-filter=lenscorrection", "--enable-filter=lut*", "--enable-filter=negate", "--enable-filter=null",
        "--enable-filter=overlay",
        "--enable-filter=palettegen", "--enable-filter=paletteuse", "--enable-filter=pan",
        "--enable-filter=rotate",
        "--enable-filter=scale", "--enable-filter=setpts", "--enable-filter=superequalizer",
        "--enable-filter=transpose", "--enable-filter=trim",
        "--enable-filter=vflip", "--enable-filter=volume",
        "--enable-filter=w3fdif",
        "--enable-filter=yadif",
        "--enable-filter=avgblur_vulkan", "--enable-filter=blend_vulkan", "--enable-filter=bwdif_vulkan",
        "--enable-filter=chromaber_vulkan", "--enable-filter=flip_vulkan", "--enable-filter=gblur_vulkan",
        "--enable-filter=hflip_vulkan", "--enable-filter=nlmeans_vulkan", "--enable-filter=overlay_vulkan",
        "--enable-filter=vflip_vulkan", "--enable-filter=xfade_vulkan",
    ]

    override func buildALL() throws {
        try super.buildALL()

        // copy headers
        let firstPlatform = getFirstSuccessPlatform()
        let firstArch = architectures(firstPlatform).first!
        let includePath = thinDir(platform: firstPlatform, arch: firstArch) + ["include"]
        let destIncludePath = URL.currentDirectory + "../Sources/FFmpegKit/include"
        print("Copy headers to path: \(destIncludePath.path)")
        try? FileManager.default.removeItem(at: destIncludePath)
        try FileManager.default.copyItem(at: includePath, to: destIncludePath)
    }
}

private class BuildPlacebo: ZipBaseBuild {
    init() {
        super.init(library: .libplacebo)
    }
}

private class BuildOpenSSL: ZipBaseBuild {
    init() {
        super.init(library: .openssl)
    }
}

private class BuildGmp: ZipBaseBuild {
    init() {
        super.init(library: .gmp)
    }
}

private class BuildNettle: ZipBaseBuild {
    init() {
        super.init(library: .nettle)
    }
}

private class BuildGnutls: ZipBaseBuild {
    init() {
        super.init(library: .gnutls)
    }
}

private class BuildASS: ZipBaseBuild {
    init() {
        super.init(library: .libass)
    }
}

private class BuildUnibreak: ZipBaseBuild {
    init() {
        super.init(library: .libunibreak)
    }
}

private class BuildFreetype: ZipBaseBuild {
    init() {
        super.init(library: .libfreetype)
    }
}

private class BuildFribidi: ZipBaseBuild {
    init() {
        super.init(library: .libfribidi)
    }
}

private class BuildHarfbuzz: ZipBaseBuild {
    init() {
        super.init(library: .libharfbuzz)
    }
}


private class BuildSmbclient: ZipBaseBuild {
    init() {
        super.init(library: .libsmbclient)
    }
}

private class BuildDav1d: ZipBaseBuild {
    init() {
        super.init(library: .libdav1d)
    }

    override func buildALL() throws {
        try super.buildALL()

        // // TODO: maccatalyst平台会导致ffmpeg编译失败，暂时删除忽略
        // if platform == .maccatalyst {
        //     return
        // }
    }
}

private class BuildLittleCms: ZipBaseBuild {
    init() {
        super.init(library: .lcms2)
    }
}

private class BuildDovi: ZipBaseBuild {
    init() throws {
        super.init(library: .libdovi)
    }
}

private class BuildShaderc: ZipBaseBuild {
    init() throws {
        super.init(library: .libshaderc)
    }
}


private class BuildVulkan: ZipBaseBuild {
    init() {
        super.init(library: .vulkan)
    }

    override func buildALL() throws {
        try? FileManager.default.removeItem(at: URL.currentDirectory + library.rawValue)
        try? FileManager.default.removeItem(at: directoryURL.appendingPathExtension("log"))
        try? FileManager.default.createDirectory(atPath: (URL.currentDirectory + library.rawValue).path, withIntermediateDirectories: true, attributes: nil)
        for platform in BaseBuild.platforms {
            for arch in architectures(platform) {
                // restore lib
                let srcThinLibPath = directoryURL + ["lib", "MoltenVK.xcframework", platform.frameworkName]
                let destThinPath = thinDir(platform: platform, arch: arch)
                let destThinLibPath = destThinPath + ["lib"]
                try? FileManager.default.createDirectory(atPath: destThinPath.path, withIntermediateDirectories: true, attributes: nil)
                try? FileManager.default.copyItem(at: srcThinLibPath, to: destThinLibPath)

                // restore include
                let srcIncludePath = directoryURL + ["include"]
                let destIncludePath = destThinPath + ["include"]
                try? FileManager.default.copyItem(at: srcIncludePath, to: destIncludePath)

                // restore pkgconfig
                let srcPkgConfigPath = directoryURL + ["pkgconfig-example", platform.rawValue, arch.rawValue]
                let destPkgConfigPath = destThinPath + ["lib", "pkgconfig"]
                try? FileManager.default.copyItem(at: srcPkgConfigPath, to: destPkgConfigPath)
                Utility.listAllFiles(in: destPkgConfigPath).forEach { file in
                    if let data = FileManager.default.contents(atPath: file.path), var str = String(data: data, encoding: .utf8) {
                        str = str.replacingOccurrences(of: "/path/to/workdir", with: URL.currentDirectory.path)
                        try! str.write(toFile: file.path, atomically: true, encoding: .utf8)
                    }
                }
            }
        }

        try generatePackageManagerFile()
    }
}
