import Foundation

enum Build {
    static func performCommand(_ options: ArgumentOptions) throws {
        if Utility.shell("which brew") == nil {
            print("""
            You need to run the script first
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            """)
            return
        }
        if Utility.shell("which pkg-config") == nil {
            Utility.shell("brew install pkg-config")
        }
        if Utility.shell("which wget") == nil {
            Utility.shell("brew install wget")
        }
        let path = URL.currentDirectory + "dist"
        if !FileManager.default.fileExists(atPath: path.path) {
            try? FileManager.default.createDirectory(at: path, withIntermediateDirectories: false, attributes: nil)
        }
        try? FileManager.default.removeItem(atPath: (URL.currentDirectory + "dist/release/Package.swift").path)
        FileManager.default.changeCurrentDirectoryPath(path.path)
        BaseBuild.options = options
        if !options.platforms.isEmpty {
            BaseBuild.platforms = options.platforms
        }
    }
}


class ArgumentOptions {
    private let arguments: [String]
    var enableDebug: Bool = false
    var enableSplitPlatform: Bool = false
    var enableGPL: Bool = false
    var platforms : [PlatformType] = []
    var releaseVersion: String = "0.0.0"

    init() {
        self.arguments = []
    }

    init(arguments: [String]) {
        self.arguments = arguments
    }

    func contains(_ argument: String) -> Bool {  
        return self.arguments.firstIndex(of: argument) != nil
    }

    static func parse(_ arguments: [String]) throws -> ArgumentOptions {
        let options = ArgumentOptions(arguments: Array(arguments.dropFirst()))
        for argument in arguments {
            switch argument {
            case "enable-debug":
                options.enableDebug = true
            case "enable-gpl":
                options.enableGPL = true
            case "enable-split-platform":
                options.enableSplitPlatform = true
            default:
                if argument.hasPrefix("version=") {
                    let version = String(argument.suffix(argument.count - "version=".count))
                    options.releaseVersion = version
                }
                if argument.hasPrefix("platform=") {
                    let values = String(argument.suffix(argument.count - "platform=".count))
                    for val in values.split(separator: ",") {
                        let platformStr = val.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
                        switch platformStr {
                        case "ios":
                            options.platforms += [PlatformType.ios, PlatformType.isimulator]
                        case "tvos":
                            options.platforms += [PlatformType.tvos, PlatformType.tvsimulator]
                        case "xros":
                            options.platforms += [PlatformType.xros, PlatformType.xrsimulator]
                        default:
                            guard let other = PlatformType(rawValue: platformStr) else { throw NSError(domain: "unknown platform: \(val)", code: 1) } 
                            if !options.platforms.contains(other) {
                                options.platforms += [other]
                            }
                        }
                    }
                }
            }
        }

        return options
    }
}

class BaseBuild {
    static let defaultPath = "/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
    static var platforms = PlatformType.allCases
    static var options = ArgumentOptions()
    static let splitPlatformGroups = [
        PlatformType.macos.rawValue: [PlatformType.macos, PlatformType.maccatalyst],
        PlatformType.ios.rawValue: [PlatformType.ios, PlatformType.isimulator],
        PlatformType.tvos.rawValue: [PlatformType.tvos, PlatformType.tvsimulator],
        PlatformType.xros.rawValue: [PlatformType.xros, PlatformType.xrsimulator]
    ]
    let library: Library
    let directoryURL: URL
    let xcframeworkDirectoryURL: URL
    var pullLatestVersion = false;
    init(library: Library) {
        self.library = library
        directoryURL = URL.currentDirectory + "\(library.rawValue)-\(library.version)"
        xcframeworkDirectoryURL = URL.currentDirectory + ["release", "xcframework"]
    }

    func beforeBuild() throws {
        if FileManager.default.fileExists(atPath: directoryURL.path) {
            return 
        }

        // pull code from git
        if pullLatestVersion {
            try! Utility.launch(path: "/usr/bin/git", arguments: ["-c", "advice.detachedHead=false", "clone", "--depth", "1", library.url, directoryURL.path])
        } else {
            try! Utility.launch(path: "/usr/bin/git", arguments: ["-c", "advice.detachedHead=false", "clone", "--depth", "1", "--branch", library.version, library.url, directoryURL.path])
        }

        // apply patch
        let patch = URL.currentDirectory + "../Sources/BuildScripts/patch/\(library.rawValue)"
        if FileManager.default.fileExists(atPath: patch.path) {
            _ = try? Utility.launch(path: "/usr/bin/git", arguments: ["checkout", "."], currentDirectoryURL: directoryURL)
            let fileNames = try! FileManager.default.contentsOfDirectory(atPath: patch.path).sorted()
            for fileName in fileNames {
                if !fileName.hasSuffix(".patch") {
                    continue
                }
                try! Utility.launch(path: "/usr/bin/git", arguments: ["apply", "\((patch + fileName).path)"], currentDirectoryURL: directoryURL)
            }
        }
    }

    func buildALL() throws {
        try beforeBuild()
        try? FileManager.default.removeItem(at: URL.currentDirectory + library.rawValue)
        try? FileManager.default.removeItem(at: directoryURL.appendingPathExtension("log"))
        for platform in BaseBuild.platforms {
            for arch in architectures(platform) {
                try build(platform: platform, arch: arch)
            }
        }
        try createXCFramework()
        try packageRelease()
        try afterBuild()
    }

    func afterBuild() throws {
        try generatePackageManagerFile()
    }

    func architectures(_ platform: PlatformType) -> [ArchType] {
        platform.architectures
    }

    func platforms() -> [PlatformType] {
        BaseBuild.platforms
    }

    func build(platform: PlatformType, arch: ArchType) throws {
        let buildURL = scratch(platform: platform, arch: arch)
        try? FileManager.default.createDirectory(at: buildURL, withIntermediateDirectories: true, attributes: nil)
        let environ = environment(platform: platform, arch: arch)
        if FileManager.default.fileExists(atPath: (directoryURL + "meson.build").path) {
            if Utility.shell("which meson") == nil {
                Utility.shell("brew install meson")
            }
            if Utility.shell("which ninja") == nil {
                Utility.shell("brew install ninja")
            }
            

            let crossFile = createMesonCrossFile(platform: platform, arch: arch)
            let meson = Utility.shell("which meson", isOutput: true)!
            try Utility.launch(path: meson, arguments: ["setup", buildURL.path, "--cross-file=\(crossFile.path)"] + arguments(platform: platform, arch: arch), currentDirectoryURL: directoryURL, environment: environ)
            try Utility.launch(path: meson, arguments: ["compile", "--clean"], currentDirectoryURL: buildURL, environment: environ)
            try Utility.launch(path: meson, arguments: ["compile", "--verbose"], currentDirectoryURL: buildURL, environment: environ)
            try Utility.launch(path: meson, arguments: ["install"], currentDirectoryURL: buildURL, environment: environ)
        } else if FileManager.default.fileExists(atPath: (directoryURL + wafPath()).path) {
            let waf = (directoryURL + wafPath()).path
            try Utility.launch(path: waf, arguments: ["configure"] + arguments(platform: platform, arch: arch), currentDirectoryURL: directoryURL, environment: environ)
            try Utility.launch(path: waf, arguments: wafBuildArg(), currentDirectoryURL: directoryURL, environment: environ)
            try Utility.launch(path: waf, arguments: ["install"] + wafInstallArg(), currentDirectoryURL: directoryURL, environment: environ)
        } else {
            try configure(buildURL: buildURL, environ: environ, platform: platform, arch: arch)
            try Utility.launch(path: "/usr/bin/make", arguments: ["-j8"], currentDirectoryURL: buildURL, environment: environ)
            try Utility.launch(path: "/usr/bin/make", arguments: ["-j8", "install"], currentDirectoryURL: buildURL, environment: environ)
        }
    }

    func wafPath() -> String {
        "./waf"
    }

    func wafBuildArg() -> [String] {
        ["build"]
    }

    func wafInstallArg() -> [String] {
        []
    }

    func configure(buildURL: URL, environ: [String: String], platform: PlatformType, arch: ArchType) throws {
        let autogen = directoryURL + "autogen.sh"
        if FileManager.default.fileExists(atPath: autogen.path) {
            var environ = environ
            environ["NOCONFIGURE"] = "1"
            try Utility.launch(executableURL: autogen, arguments: [], currentDirectoryURL: directoryURL, environment: environ)
        }
        let makeLists = directoryURL + "CMakeLists.txt"
        if FileManager.default.fileExists(atPath: makeLists.path) {
            if Utility.shell("which cmake") == nil {
                Utility.shell("brew install cmake")
            }
            let cmake = Utility.shell("which cmake", isOutput: true)!
            let thinDirPath = thinDir(platform: platform, arch: arch).path
            var arguments = [
                makeLists.path,
                "-DCMAKE_VERBOSE_MAKEFILE=0",
                "-DCMAKE_BUILD_TYPE=Release",
                "-DCMAKE_OSX_SYSROOT=\(platform.sdk.lowercased())",
                "-DCMAKE_OSX_ARCHITECTURES=\(arch.rawValue)",
                "-DCMAKE_SYSTEM_NAME=\(platform.cmakeSystemName)",
                "-DCMAKE_SYSTEM_PROCESSOR=\(arch.rawValue)",
                "-DCMAKE_INSTALL_PREFIX=\(thinDirPath)",
                "-DBUILD_SHARED_LIBS=0",
            ]
            arguments.append(contentsOf: self.arguments(platform: platform, arch: arch))
            try Utility.launch(path: cmake, arguments: arguments, currentDirectoryURL: buildURL, environment: environ)
        } else {
            let configure = directoryURL + "configure"
            if !FileManager.default.fileExists(atPath: configure.path) {
                var bootstrap = directoryURL + "bootstrap"
                if !FileManager.default.fileExists(atPath: bootstrap.path) {
                    bootstrap = directoryURL + ".bootstrap"
                }
                if FileManager.default.fileExists(atPath: bootstrap.path) {
                    try Utility.launch(executableURL: bootstrap, arguments: [], currentDirectoryURL: directoryURL, environment: environ)
                }
            }
            var arguments = [
                "--prefix=\(thinDir(platform: platform, arch: arch).path)",
            ]
            arguments.append(contentsOf: self.arguments(platform: platform, arch: arch))
            try Utility.launch(executableURL: configure, arguments: arguments, currentDirectoryURL: buildURL, environment: environ)
        }
    }

    func environment(platform: PlatformType, arch: ArchType) -> [String: String] {
        let cFlags = cFlags(platform: platform, arch: arch).joined(separator: " ")
        let ldFlags = ldFlags(platform: platform, arch: arch).joined(separator: " ")
        let pkgConfigPath = platform.pkgConfigPath(arch: arch)
        let pkgConfigPathDefault = Utility.shell("pkg-config --variable pc_path pkg-config", isOutput: true)!
        return [
            "LC_CTYPE": "C",
            "CC": "/usr/bin/clang",
            "CXX": "/usr/bin/clang++",
            // "SDKROOT": platform.sdk.lowercased(),
            "CURRENT_ARCH": arch.rawValue,
            "CFLAGS": cFlags,
            // makefile can't use CPPFLAGS
            "CPPFLAGS": cFlags,
            // 这个要加，不然cmake在编译maccatalyst 会有问题
            "CXXFLAGS": cFlags,
            "LDFLAGS": ldFlags,
            "PKG_CONFIG_LIBDIR": pkgConfigPath + pkgConfigPathDefault,
            "PATH": BaseBuild.defaultPath,
        ]
    }

    func cFlags(platform: PlatformType, arch: ArchType) -> [String] {
        var cFlags = platform.cFlags(arch: arch)
        let librarys = flagsDependencelibrarys()
        for library in librarys {
            let path = URL.currentDirectory + [library.rawValue, platform.rawValue, "thin", arch.rawValue]
            if FileManager.default.fileExists(atPath: path.path) {
                cFlags.append("-I\(path.path)/include")
            }
        }
        return cFlags
    }

    func ldFlags(platform: PlatformType, arch: ArchType) -> [String] {
        var ldFlags = platform.ldFlags(arch: arch)
        let librarys = flagsDependencelibrarys()
        for library in librarys {
            let path = URL.currentDirectory + [library.rawValue, platform.rawValue, "thin", arch.rawValue]
            if FileManager.default.fileExists(atPath: path.path) {
                var libname = library.rawValue
                if libname.hasPrefix("lib") {
                    libname = String(libname.dropFirst(3))
                }
                ldFlags.append("-L\(path.path)/lib")
                ldFlags.append("-l\(libname)")
            }
        }
        return ldFlags
    }

    func flagsDependencelibrarys() -> [Library] {
        []
    }


    func arguments(platform: PlatformType, arch: ArchType) -> [String] {
        return []
    }

    func frameworks() throws -> [String] {
        [library.rawValue]
    }

    func createXCFramework() throws {
        // clean all old xcframework
        try? Utility.removeFiles(extensions: [".xcframework"], currentDirectoryURL: self.xcframeworkDirectoryURL)

        var frameworks: [String] = []
        let libNames = try self.frameworks()
        for libName in libNames {
            if libName.hasPrefix("lib") {
                frameworks.append("Lib" + libName.dropFirst(3))
            } else {
                frameworks.append(libName)
            }
        }
        for framework in frameworks {
            var frameworkGenerated = [PlatformType: String]()
            for platform in BaseBuild.platforms {
                if let frameworkPath = try createFramework(framework: framework, platform: platform) {
                    frameworkGenerated[platform] = frameworkPath
                }
            }
            try buildXCFramework(name: framework, paths: Array(frameworkGenerated.values))

            // Generate xcframework for different platforms
            if BaseBuild.options.enableSplitPlatform {
                for (group, platforms) in BaseBuild.splitPlatformGroups {
                    var frameworkPaths: [String] = []
                    for platform in platforms {
                        if let frameworkPath = frameworkGenerated[platform] {
                            frameworkPaths.append(frameworkPath)
                        }
                    }
                    try buildXCFramework(name: "\(framework)-\(group)", paths: frameworkPaths)
                }
            }
        }
    }

    private func buildXCFramework(name: String, paths: [String]) throws {
        if paths.isEmpty {
            return
        }

        var arguments = ["-create-xcframework"]
        for frameworkPath in paths {
            arguments.append("-framework")
            arguments.append(frameworkPath)
        }
        arguments.append("-output")
        let XCFrameworkFile = self.xcframeworkDirectoryURL + [name + ".xcframework"]
        arguments.append(XCFrameworkFile.path)
        if FileManager.default.fileExists(atPath: XCFrameworkFile.path) {
            try? FileManager.default.removeItem(at: XCFrameworkFile)
        }
        try Utility.launch(path: "/usr/bin/xcodebuild", arguments: arguments)
    }

    func createFramework(framework: String, platform: PlatformType) throws -> String? {
        let platformDir = URL.currentDirectory + [library.rawValue, platform.rawValue]
        if !FileManager.default.fileExists(atPath: platformDir.path) {
            return nil
        }
        let frameworkDir = URL.currentDirectory + [library.rawValue, platform.rawValue, "\(framework).framework"]
        if !platforms().contains(platform) {
            if FileManager.default.fileExists(atPath: frameworkDir.path) {
                return frameworkDir.path
            } else {
                return nil
            }
        }
        try? FileManager.default.removeItem(at: frameworkDir)
        try FileManager.default.createDirectory(at: frameworkDir, withIntermediateDirectories: true, attributes: nil)
        var arguments = ["-create"]
        for arch in platform.architectures {
            let prefix = thinDir(platform: platform, arch: arch)
            if !FileManager.default.fileExists(atPath: prefix.path) {
                return nil
            }
            let libname = framework.hasPrefix("lib") || framework.hasPrefix("Lib") ? framework : "lib" + framework
            var libPath = prefix + ["lib", "\(libname).a"]
            if !FileManager.default.fileExists(atPath: libPath.path) {
                libPath = prefix + ["lib", "\(libname).dylib"]
            }
            arguments.append(libPath.path)
            var headerURL: URL = prefix + "include" + framework
            if !FileManager.default.fileExists(atPath: headerURL.path) {
                headerURL = prefix + "include"
            }
            try? FileManager.default.copyItem(at: headerURL, to: frameworkDir + "Headers")
        }
        arguments.append("-output")
        arguments.append((frameworkDir + framework).path)
        try Utility.launch(path: "/usr/bin/lipo", arguments: arguments)
        try FileManager.default.createDirectory(at: frameworkDir + "Modules", withIntermediateDirectories: true, attributes: nil)
        var modulemap = """
        framework module \(framework) [system] {
            umbrella "."

        """
        frameworkExcludeHeaders(framework).forEach { header in
            modulemap += """
                exclude header "\(header).h"

            """
        }
        modulemap += """
            export *
        }
        """
        FileManager.default.createFile(atPath: frameworkDir.path + "/Modules/module.modulemap", contents: modulemap.data(using: .utf8), attributes: nil)
        createPlist(path: frameworkDir.path + "/Info.plist", name: framework, minVersion: platform.minVersion, platform: platform.sdk)
        return frameworkDir.path
    }

    func thinDir(library: Library, platform: PlatformType, arch: ArchType) -> URL {
        URL.currentDirectory + [library.rawValue, platform.rawValue, "thin", arch.rawValue]
    }

    func thinDir(platform: PlatformType, arch: ArchType) -> URL {
        thinDir(library: library, platform: platform, arch: arch)
    }

    func scratch(platform: PlatformType, arch: ArchType) -> URL {
        URL.currentDirectory + [library.rawValue, platform.rawValue, "scratch", arch.rawValue]
    }

    func frameworkExcludeHeaders(_: String) -> [String] {
        []
    }

    private func createPlist(path: String, name: String, minVersion: String, platform: String) {
        let identifier = "com.mpvkit." + normalizeBundleIdentifier(name)
        let content = """
        <?xml version="1.0" encoding="UTF-8"?>
        <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
        <plist version="1.0">
        <dict>
        <key>CFBundleDevelopmentRegion</key>
        <string>en</string>
        <key>CFBundleExecutable</key>
        <string>\(name)</string>
        <key>CFBundleIdentifier</key>
        <string>\(identifier)</string>
        <key>CFBundleInfoDictionaryVersion</key>
        <string>6.0</string>
        <key>CFBundleName</key>
        <string>\(name)</string>
        <key>CFBundlePackageType</key>
        <string>FMWK</string>
        <key>CFBundleShortVersionString</key>
        <string>87.88.520</string>
        <key>CFBundleVersion</key>
        <string>87.88.520</string>
        <key>CFBundleSignature</key>
        <string>????</string>
        <key>MinimumOSVersion</key>
        <string>\(minVersion)</string>
        <key>CFBundleSupportedPlatforms</key>
        <array>
        <string>\(platform)</string>
        </array>
        <key>NSPrincipalClass</key>
        <string></string>
        </dict>
        </plist>
        """
        FileManager.default.createFile(atPath: path, contents: content.data(using: .utf8), attributes: nil)
    }

    // CFBundleIdentifier must contain only alphanumerics, dots, hyphens 
    private func normalizeBundleIdentifier(_ identifier: String) -> String {
        return identifier.replacingOccurrences(of: "_", with: "-")
    }


    private func createMesonCrossFile(platform: PlatformType, arch: ArchType) -> URL {
        let url = scratch(platform: platform, arch: arch)
        let crossFile = url + "crossFile.meson"
        let prefix = thinDir(platform: platform, arch: arch)
        let cFlags = cFlags(platform: platform, arch: arch).map {
            "'" + $0 + "'"
        }.joined(separator: ", ")
        let ldFlags = ldFlags(platform: platform, arch: arch).map {
            "'" + $0 + "'"
        }.joined(separator: ", ")
        let content = """
        [binaries]
        c = '/usr/bin/clang'
        cpp = '/usr/bin/clang++'
        objc = '/usr/bin/clang'
        objcpp = '/usr/bin/clang++'
        ar = '\(platform.xcrunFind(tool: "ar"))'
        strip = '\(platform.xcrunFind(tool: "strip"))'
        pkg-config = 'pkg-config'

        [properties]
        has_function_printf = true
        has_function_hfkerhisadf = false

        [host_machine]
        system = 'darwin'
        subsystem = '\(platform.mesonSubSystem)'
        kernel = 'xnu'
        cpu_family = '\(arch.cpuFamily)'
        cpu = '\(arch.targetCpu)'
        endian = 'little'

        [built-in options]
        default_library = 'static'
        buildtype = 'release'
        prefix = '\(prefix.path)'
        c_args = [\(cFlags)]
        cpp_args = [\(cFlags)]
        objc_args = [\(cFlags)]
        objcpp_args = [\(cFlags)]
        c_link_args = [\(ldFlags)]
        cpp_link_args = [\(ldFlags)]
        objc_link_args = [\(ldFlags)]
        objcpp_link_args = [\(ldFlags)]
        """
        FileManager.default.createFile(atPath: crossFile.path, contents: content.data(using: .utf8), attributes: nil)
        return crossFile
    }

    func packageRelease() throws {
        let releaseDirPath = URL.currentDirectory + ["release"]
        if !FileManager.default.fileExists(atPath: releaseDirPath.path) {
            try? FileManager.default.createDirectory(at: releaseDirPath, withIntermediateDirectories: true, attributes: nil)
        }
        let releaseLibPath = releaseDirPath + [library.rawValue]
        try? FileManager.default.removeItem(at: releaseLibPath)

        // copy static libraries
        for platform in BaseBuild.platforms {
            for arch in architectures(platform) {
                 let thinLibPath = thinDir(platform: platform, arch: arch) + ["lib"]
                 if !FileManager.default.fileExists(atPath: thinLibPath.path) {
                     continue
                 }
                 let staticLibraries = try FileManager.default.contentsOfDirectory(atPath: thinLibPath.path).filter { $0.hasSuffix(".a") }

                 let releaseThinLibPath = releaseDirPath + [library.rawValue, "lib", platform.rawValue, "thin", arch.rawValue, "lib"]
                 try? FileManager.default.createDirectory(at: releaseThinLibPath, withIntermediateDirectories: true, attributes: nil)
                 for lib in staticLibraries {
                    let sourceURL = thinLibPath + [lib]
                    let destinationURL = releaseThinLibPath + [lib]
                    try FileManager.default.copyItem(at: sourceURL, to: destinationURL)
                }
            }
        }

        // copy includes
        guard let firstPlatform = getFirstSuccessPlatform() else { return }
        let firstArch = architectures(firstPlatform).first!
        let includePath = thinDir(platform: firstPlatform, arch: firstArch) + ["include"]
        let destIncludePath = releaseDirPath + [library.rawValue, "include"]
        try FileManager.default.copyItem(at: includePath, to: destIncludePath)


        // copy pkg-config file example
        try packagePkgConfigRelease()

        // zip build artifacts when there are frameworks to generate
        if try self.frameworks().count > 0 {
            let sourceLib = releaseDirPath + [library.rawValue]
            let destZipLibPath = releaseDirPath + [library.rawValue + "-all.zip"]
            try? FileManager.default.removeItem(at: destZipLibPath)
            try Utility.launch(path: "/usr/bin/zip", arguments: ["-qr", destZipLibPath.path, "./"], currentDirectoryURL: sourceLib)
        }

        // zip xcframeworks
        var frameworks: [String] = []
        let libNames = try self.frameworks()
        for libName in libNames {
            if libName.hasPrefix("lib") {
                frameworks.append("Lib" + libName.dropFirst(3))
            } else {
                frameworks.append(libName)
            }
        }
        for framework in frameworks {
            // clean old files
            try Utility.launch(path: "/bin/rm", arguments: ["-rf", "\(framework)*.xcframework.zip"], currentDirectoryURL: releaseDirPath)
            try Utility.launch(path: "/bin/rm", arguments: ["-rf", "\(framework)*.checksum.txt"], currentDirectoryURL: releaseDirPath)

            let XCFrameworkFile =  framework + ".xcframework"
            let zipFile = releaseDirPath + [framework + ".xcframework.zip"]
            let checksumFile = releaseDirPath + [framework + ".xcframework.checksum.txt"]
            try Utility.launch(path: "/usr/bin/zip", arguments: ["-qr", zipFile.path, XCFrameworkFile], currentDirectoryURL: self.xcframeworkDirectoryURL)
            Utility.shell("swift package compute-checksum \(zipFile.path) > \(checksumFile.path)")

            if BaseBuild.options.enableSplitPlatform {
                for group in BaseBuild.splitPlatformGroups.keys {
                    let XCFrameworkName =  "\(framework)-\(group)"
                    let XCFrameworkFile =  XCFrameworkName + ".xcframework"
                    let XCFrameworkPath = self.xcframeworkDirectoryURL + ["\(framework)-\(group).xcframework"]
                    if FileManager.default.fileExists(atPath: XCFrameworkPath.path) {
                        let zipFile = releaseDirPath + [XCFrameworkName + ".xcframework.zip"]
                        let checksumFile = releaseDirPath + [XCFrameworkName + ".xcframework.checksum.txt"]
                        try Utility.launch(path: "/usr/bin/zip", arguments: ["-qr", zipFile.path, XCFrameworkFile], currentDirectoryURL: self.xcframeworkDirectoryURL)
                        Utility.shell("swift package compute-checksum \(zipFile.path) > \(checksumFile.path)")
                    }
                }
            }
        }
    }

    func packagePkgConfigRelease() throws {
        let releaseDirPath = URL.currentDirectory + ["release"]
        // copy pkg-config file example
        for platform in BaseBuild.platforms {
            for arch in architectures(platform) {
                let thinLibPath = thinDir(platform: platform, arch: arch) + ["lib"]
                let pkgconfigPath = thinLibPath + ["pkgconfig"]
                if !FileManager.default.fileExists(atPath: pkgconfigPath.path) {
                    continue
                }
                let destPkgConfigDir = releaseDirPath + [library.rawValue, "pkgconfig-example", platform.rawValue]
                let destPkgConfigPath = destPkgConfigDir + arch.rawValue
                try? FileManager.default.createDirectory(at: destPkgConfigDir, withIntermediateDirectories: true, attributes: nil)
                try FileManager.default.copyItem(at: pkgconfigPath, to: destPkgConfigPath)

                let pkgconfigFiles = Utility.listAllFiles(in: destPkgConfigPath)
                for file in pkgconfigFiles {
                    if let data = FileManager.default.contents(atPath: file.path), var str = String(data: data, encoding: .utf8) {
                        str = str.replacingOccurrences(of: URL.currentDirectory.path, with: "/path/to/workdir")
                        try! str.write(toFile: file.path, atomically: true, encoding: .utf8)
                    }
                }
            }
        }
    }

    func generatePackageManagerFile() throws {
        let releaseDirPath = URL.currentDirectory + ["release"]
        let template = URL.currentDirectory + ["../docs/Package.template.swift"]
        let packageFile = releaseDirPath + "Package.swift"

        if !FileManager.default.fileExists(atPath: packageFile.path) {
            try! FileManager.default.createDirectory(at: releaseDirPath, withIntermediateDirectories: true, attributes: nil)
            try! FileManager.default.copyItem(at: template, to: packageFile)
        }

        var dependencyTargetContent = ""
        if self is ZipBaseBuild {
            for target in library.targets {
                let tmpChecksum = FileManager.default.temporaryDirectory + "\(library.rawValue)_checksum.txt"
                if FileManager.default.fileExists(atPath: tmpChecksum.path) {
                    try? FileManager.default.removeItem(at: tmpChecksum)
                }
                try! Utility.launch(path: "wget", arguments: ["-q", "-O", tmpChecksum.path, target.checksum], currentDirectoryURL: FileManager.default.temporaryDirectory)
                let checksum = try String(contentsOf: tmpChecksum, encoding: .utf8).trimmingCharacters(in: .whitespacesAndNewlines)
                dependencyTargetContent += """
                
                        .binaryTarget(
                            name: "\(target.name)",
                            url: "\(target.url)",
                            checksum: "\(checksum)"
                        ),
                """
                try? FileManager.default.removeItem(at: tmpChecksum)
            }
        } else {
            for target in library.targets {
                let checksumFile = releaseDirPath + [target.name + ".xcframework.checksum.txt"]
                if !FileManager.default.fileExists(atPath: checksumFile.path) {
                    continue
                }
                let checksum = try String(contentsOf: checksumFile, encoding: .utf8).trimmingCharacters(in: .whitespacesAndNewlines)
                dependencyTargetContent += """

                        .binaryTarget(
                            name: "\(target.name)",
                            url: "\(target.url)",
                            checksum: "\(checksum)"
                        ),
                """
            }
        }

        if dependencyTargetContent.isEmpty {
            return
        }

        if let data = FileManager.default.contents(atPath: packageFile.path), var str = String(data: data, encoding: .utf8) {
            let placeholderChars = "//AUTO_GENERATE_TARGETS_END//"
            str = str.replacingOccurrences(of: 
            """
                    \(placeholderChars)
            """, with: 
            """
            \(dependencyTargetContent)
                    \(placeholderChars)
            """)
            try! str.write(toFile: packageFile.path, atomically: true, encoding: .utf8)
        }
    }

    func getFirstSuccessPlatform() -> PlatformType? {
        for platform in BaseBuild.platforms {
            let firstArch = architectures(platform).first!
            let thinPath = thinDir(platform: platform, arch: firstArch)
            if FileManager.default.fileExists(atPath: thinPath.path) {
                return platform
            }
        }

        return nil
    }
}


class ZipBaseBuild : BaseBuild {

    override func beforeBuild() throws {
        // unzip builded static library
        let outputFileName = "\(library.rawValue).zip"
        let outputFile = directoryURL + outputFileName
        // delete invalid downloaded files
        let attributes = try? FileManager.default.attributesOfItem(atPath: outputFile.path)
        if let fileSize = attributes?[FileAttributeKey.size] as? UInt64, fileSize <= 0 {
            try? FileManager.default.removeItem(atPath: directoryURL.path)
        }
        try! FileManager.default.createDirectory(atPath: directoryURL.path, withIntermediateDirectories: true, attributes: nil)

        if !FileManager.default.fileExists(atPath: outputFile.path) {
            try! Utility.launch(path: "wget", arguments: ["-O", outputFileName, library.url], currentDirectoryURL: directoryURL)
            try! Utility.launch(path: "/usr/bin/unzip", arguments: ["-o",outputFileName], currentDirectoryURL: directoryURL)
        }
    }

    override func buildALL() throws {
        try beforeBuild()
        try? FileManager.default.removeItem(at: URL.currentDirectory + library.rawValue)
        try? FileManager.default.removeItem(at: directoryURL.appendingPathExtension("log"))
        try? FileManager.default.createDirectory(atPath: (URL.currentDirectory + library.rawValue).path, withIntermediateDirectories: true, attributes: nil)
        for platform in BaseBuild.platforms {
            for arch in architectures(platform) {
                // restore lib
                let srcThinLibPath = directoryURL + ["lib"] + [platform.rawValue, "thin", arch.rawValue, "lib"]
                // ignore if platform not support
                if !FileManager.default.fileExists(atPath: srcThinLibPath.path) {
                    continue
                }
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

        try afterBuild()
    }

    override func afterBuild() throws {
        try super.afterBuild()
    }
}

class PackageTarget {
    let name: String
    let url : String
    let checksum: String

    init(name: String, url : String, checksum: String) {
        self.name = name
        self.url = url
        self.checksum = checksum
    }

    static func target(
        name: String,
        url : String,
        checksum: String
    ) -> PackageTarget {
        return PackageTarget(name: name, url: url, checksum: checksum)
    }
}


enum PlatformType: String, CaseIterable {
    case xros, xrsimulator, maccatalyst, macos, isimulator, tvsimulator, tvos, ios
    var minVersion: String {
        switch self {
        case .ios, .isimulator:
            return "13.0"
        case .tvos, .tvsimulator:
            return "13.0"
        case .macos:
            return "11.0"
        case .maccatalyst:
            // return "14.0"
            return ""
        case .xros, .xrsimulator:
            return "1.0"
        }
    }

    var name: String {
        switch self {
        case .ios, .tvos, .macos:
            return rawValue
        case .tvsimulator:
            return "tvossim"
        case .isimulator:
            return "iossim"
        case .maccatalyst:
            return "maccat"
        case .xros:
            return "visionos"
        case .xrsimulator:
            return "visionossim"
        }
    }

    var frameworkName: String {
        switch self {
        case .ios:
            return "ios-arm64"
        case .maccatalyst:
            return "ios-arm64_x86_64-maccatalyst"
        case .isimulator:
            return "ios-arm64_x86_64-simulator"
        case .macos:
            return "macos-arm64_x86_64"
        case .tvos:
            // 保持和xcode一致：https://github.com/KhronosGroup/MoltenVK/issues/431#issuecomment-771137085
            return "tvos-arm64_arm64e"
        case .tvsimulator:
            return "tvos-arm64_x86_64-simulator"
        case .xros:
            return "xros-arm64"
        case .xrsimulator:
            return "xros-arm64_x86_64-simulator"
        }
    }


    var architectures: [ArchType] {
        switch self {
        case .ios, .xros:
            return [.arm64]
        case .tvos:
            return [.arm64, .arm64e]
        case .xrsimulator:
            return [.arm64]
        case .isimulator, .tvsimulator:
            return [.arm64, .x86_64]  
        case .macos:
            // macos 不能用arm64，不然打包release包会报错，不能通过
            #if arch(x86_64)
            return [.x86_64, .arm64]
            #else
            return [.arm64, .x86_64]
            #endif
        case .maccatalyst:
            return [.arm64, .x86_64]
        }
    }

    func deploymentTarget(_ arch: ArchType) -> String {
        switch self {
        case .ios, .tvos, .macos, .xros:
            return "\(arch.targetCpu)-apple-\(rawValue)\(minVersion)"
        case .maccatalyst:
            return "\(arch.targetCpu)-apple-ios-macabi"
        case .isimulator:
            return PlatformType.ios.deploymentTarget(arch) + "-simulator"
        case .tvsimulator:
            return PlatformType.tvos.deploymentTarget(arch) + "-simulator"
        case .xrsimulator:
            return PlatformType.xros.deploymentTarget(arch) + "-simulator"
        }
    }


    private var osVersionMin: String {
        switch self {
        case .ios, .tvos:
            return "-m\(rawValue)-version-min=\(minVersion)"
        case .macos:
            return "-mmacosx-version-min=\(minVersion)"
        case .isimulator:
            return "-mios-simulator-version-min=\(minVersion)"
        case .tvsimulator:
            return "-mtvos-simulator-version-min=\(minVersion)"
        case .maccatalyst, .xros, .xrsimulator:
            return ""
            // return "-miphoneos-version-min=\(minVersion)"
        }
    }

    var sdk : String {
        switch self {
        case .ios:
            return "iPhoneOS"
        case .isimulator:
            return "iPhoneSimulator"
        case .tvos:
            return "AppleTVOS"
        case .tvsimulator:
            return "AppleTVSimulator"
        case .macos:
            return "MacOSX"
        case .maccatalyst:
            return "MacOSX"
        case .xros:
            return "XROS"
        case .xrsimulator:
            return "XRSimulator"
        }
    }

    var isysroot: String {
        xcrunFind(tool: "--show-sdk-path")
    }

    var mesonSubSystem: String {
        switch self {
        case .isimulator:
            return "ios-simulator"
        case .tvsimulator:
            return "tvos-simulator"
        case .xrsimulator:
            return "xros-simulator"
        default:
            return rawValue
        }
    }

    var cmakeSystemName: String {
        switch self {
        case .ios, .isimulator:
            return "iOS"
        case .tvos, .tvsimulator:
            return "tvOS"
        case .macos, .maccatalyst:
            return "Darwin"
        case .xros, .xrsimulator:
            return "visionOS"
        }
    }

    func host(arch: ArchType) -> String {
        switch self {
        case .ios, .isimulator, .maccatalyst:
            return "\(arch == .x86_64 ? "x86_64" : "arm64")-ios-darwin"
        case .tvos, .tvsimulator:
            return "\(arch == .x86_64 ? "x86_64" : "arm64")-tvos-darwin"
        case .xros, .xrsimulator:
            return "\(arch == .x86_64 ? "x86_64" : "arm64")-xros-darwin"
        case .macos:
            return "\(arch == .x86_64 ? "x86_64" : "arm64")-apple-darwin"
        }
    }

    func ldFlags(arch: ArchType) -> [String] {
        // ldFlags的关键参数要跟cFlags保持一致，不然会在ld的时候不通过。
        var flags = ["-lc++", "-arch", arch.rawValue, "-isysroot", isysroot, "-target", deploymentTarget(arch), osVersionMin]
        // maccatalyst的vulkan库需要加载UIKit框架
        if self == .maccatalyst {
            flags += ["-iframework", "\(isysroot)/System/iOSSupport/System/Library/Frameworks"]
        }
        return flags
    }


    func cFlags(arch: ArchType) -> [String] {
        var cflags = ["-arch", arch.rawValue, "-isysroot", isysroot, "-target", deploymentTarget(arch), osVersionMin]
//        if self == .macos || self == .maccatalyst {
        // 不能同时有强符合和弱符号出现
        // cflags.append("-fno-common")
//        }
        if self == .tvos || self == .tvsimulator {
            cflags.append("-DHAVE_FORK=0")
        }
        return cflags
    }

    func xcrunFind(tool: String) -> String {
        try! Utility.launch(path: "/usr/bin/xcrun", arguments: ["--sdk", sdk.lowercased(), "--find", tool], isOutput: true)
    }

    func pkgConfigPath(arch: ArchType) -> String {
        var pkgConfigPath = ""
        for lib in Library.allCases {
            let path = URL.currentDirectory + [lib.rawValue, rawValue, "thin", arch.rawValue]
            if FileManager.default.fileExists(atPath: path.path) {
                pkgConfigPath += "\(path.path)/lib/pkgconfig:"
            }
        }
        return pkgConfigPath
    }
}

enum ArchType: String, CaseIterable {
    // swiftlint:disable identifier_name
    case arm64, x86_64, arm64e
    // swiftlint:enable identifier_name
    var executable: Bool {
        guard let architecture = Bundle.main.executableArchitectures?.first?.intValue else {
            return false
        }
        // NSBundleExecutableArchitectureARM64
        if architecture == 0x0100_000C, self == .arm64 {
            return true
        } else if architecture == NSBundleExecutableArchitectureX86_64, self == .x86_64 {
            return true
        }
        return false
    }


    var cpuFamily: String {
        switch self {
        case .arm64, .arm64e:
            return "aarch64"
        case .x86_64:
            return "x86_64"
        }
    }

    var targetCpu: String {
        switch self {
        case .arm64, .arm64e:
            return "arm64"
        case .x86_64:
            return "x86_64"
        }
    }

    static var hostArch : ArchType {
        #if arch(arm64)
        return .arm64
        #else
        return .x86_64
        #endif
    }
}



enum Utility {
    @discardableResult
    static func shell(_ command: String, isOutput : Bool = false, currentDirectoryURL: URL? = nil, environment: [String: String] = [:]) -> String? {
        do {
            return try launch(executableURL: URL(fileURLWithPath: "/bin/bash"), arguments: ["-c", command], isOutput: isOutput, currentDirectoryURL: currentDirectoryURL, environment: environment)
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }

    @discardableResult
    static func launch(path: String, arguments: [String], isOutput: Bool = false, currentDirectoryURL: URL? = nil, environment: [String: String] = [:]) throws -> String {
        if !path.hasPrefix("/") {
            let execPath = Utility.shell("which \(path)", isOutput: true)!
            if execPath.isEmpty {
                throw NSError(domain: "[\(path)] not found", code: 1)
            }
            return try launch(executableURL: URL(fileURLWithPath: execPath), arguments: arguments, isOutput: isOutput, currentDirectoryURL: currentDirectoryURL, environment: environment)
        } else {
            return try launch(executableURL: URL(fileURLWithPath: path), arguments: arguments, isOutput: isOutput, currentDirectoryURL: currentDirectoryURL, environment: environment)
        }
    }

    @discardableResult
    static func launch(executableURL: URL, arguments: [String], isOutput: Bool = false, currentDirectoryURL: URL? = nil, environment: [String: String] = [:]) throws -> String {
        let task = Process()
        var environment = environment
        // for homebrew 1.12
        if ProcessInfo.processInfo.environment.keys.contains("HOME") {
            environment["HOME"] = ProcessInfo.processInfo.environment["HOME"]
        }
        if !environment.keys.contains("PATH") {
            environment["PATH"] = BaseBuild.defaultPath

            // meson need to use pip version on GITHUB ACTION, use brew version will build failed
            if ProcessInfo.processInfo.environment.keys.contains("GITHUB_ACTION") {
                environment["PATH"] = "/Library/Frameworks/Python.framework/Versions/Current/bin:" + environment["PATH"]!
            }
        }
        task.environment = environment

        var outputFileHandle: FileHandle?
        var logURL: URL?
        var outputBuffer = Data()
        let outputPipe = Pipe()
        let errorPipe = Pipe()
        task.standardOutput = outputPipe
        task.standardError = errorPipe
        
        if let curURL = currentDirectoryURL {
            // output to file
            logURL = curURL.appendingPathExtension("log")
            if !FileManager.default.fileExists(atPath: logURL!.path) {
                FileManager.default.createFile(atPath: logURL!.path, contents: nil)
            }

            outputFileHandle = try FileHandle(forWritingTo: logURL!)
            outputFileHandle?.seekToEndOfFile()
        }
        outputPipe.fileHandleForReading.readabilityHandler = { fileHandle in
            let data = fileHandle.availableData

            if !data.isEmpty {
                outputBuffer.append(data)
                if let outputString = String(data: data, encoding: .utf8) {
                    if isOutput {
                        print(outputString.trimmingCharacters(in: .newlines))
                    }

                    // Write to file simultaneously.
                    outputFileHandle?.write(data)
                }
            } else {
                // Close the read capability processing program and clean up resources.
                fileHandle.readabilityHandler = nil
                fileHandle.closeFile()
            }
        }
        errorPipe.fileHandleForReading.readabilityHandler = { fileHandle in
            let data = fileHandle.availableData

            if !data.isEmpty {
                if let outputString = String(data: data, encoding: .utf8) {
                    print(outputString.trimmingCharacters(in: .newlines))

                    // Write to file simultaneously.
                    outputFileHandle?.write(data)
                }
            } else {
                // Close the read capability processing program and clean up resources.
                fileHandle.readabilityHandler = nil
                fileHandle.closeFile()
            }
        }
    
        task.arguments = arguments
        var log = executableURL.path + " " + arguments.joined(separator: " ") + " environment: " + environment.description
        if let currentDirectoryURL {
            log += " url: \(currentDirectoryURL)"
        }
        print(log)
        outputFileHandle?.write("\(log)\n".data(using: .utf8)!)
        task.currentDirectoryURL = currentDirectoryURL
        task.executableURL = executableURL
        try task.run()
        task.waitUntilExit()
        if task.terminationStatus == 0 {
            if isOutput {
                let result = String(data: outputBuffer, encoding: .utf8)?.trimmingCharacters(in: .newlines) ?? ""
                return result
            } else {
                return ""
            }
        } else {
            if let logURL = logURL {
                // print log when run in GitHub Action
                if ProcessInfo.processInfo.environment.keys.contains("GITHUB_ACTION") {
                    if let content = String(data: try Data(contentsOf: logURL), encoding: .utf8) {
                        print("############# \(logURL) CONTENT BEGIN #############")
                        print(content)
                        print("#############  \(logURL) CONTENT END #############")
                        if #available(macOS 13.0, *) {
                            let regErrLogPath = try Regex("A full log can be found at\\s+?(/.*\\.txt)")
                            if let firstMatch = content.firstMatch(of: regErrLogPath) {
                                let errPath = "\(firstMatch[1].value ?? "")"
                                if !errPath.isEmpty {
                                    print("############# \(errPath) CONTENT BEGIN #############")
                                    let content = Utility.shell("cat \(errPath)", isOutput: true)
                                    print(content ?? "")
                                    print("#############  \(errPath) CONTENT END #############")
                                }
                            }
                        }
                    }
                    
                }
                print("please view log file for detail: \(logURL)\n")
            }
            throw NSError(domain: "\(executableURL.lastPathComponent) execute failed", code: Int(task.terminationStatus))
        }
    }

    @discardableResult
    static func listAllFiles(in directory: URL) -> [URL] {
        var allFiles: [URL] = []
        let enumerator = FileManager.default.enumerator(atPath: directory.path)

        while let file = enumerator?.nextObject() as? String {
            let filePath = directory + [file]
            var isDirectory: ObjCBool = false

            if FileManager.default.fileExists(atPath: filePath.path, isDirectory: &isDirectory) {
                if isDirectory.boolValue {
                    // 如果是目录，则递归遍历该目录
                    listAllFiles(in: filePath)
                } else {
                    allFiles.append(filePath)
                }
            }
        }

        return allFiles
    }

    static func removeFiles(extensions: [String], currentDirectoryURL: URL) throws {
        for ext in extensions {
            let directoryContents = try FileManager.default.contentsOfDirectory(atPath: currentDirectoryURL.path)
            for item in directoryContents {
                if item.hasSuffix(ext) {
                    try FileManager.default.removeItem(at: currentDirectoryURL.appendingPathComponent(item))
                }
            }
        }
    }
}

extension URL {
    static var currentDirectory: URL {
        URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
    }

    static func + (left: URL, right: String) -> URL {
        var url = left
        url.appendPathComponent(right)
        return url
    }

    static func + (left: URL, right: [String]) -> URL {
        var url = left
        right.forEach {
            url.appendPathComponent($0)
        }
        return url
    }
}

