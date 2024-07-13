import Foundation

@main
enum CPlayer {
    static func main() {
        guard let architecture else {
            print("unsupported architecture")
            return
        }
        let arguments = Array(CommandLine.arguments.dropFirst())
        let binURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath + "/Script/libmpv/macos/thin/\(architecture)/bin/mpv")
        if !FileManager.default.fileExists(atPath: binURL.path) {
            print("mpv binary not found, please run build first.")
            return
        }
        do {
            try launch(executableURL: binURL, arguments: arguments)
        } catch {
            print(error.localizedDescription)
        }
    }

    static func launch(executableURL: URL, arguments: [String], currentDirectoryURL: URL? = nil) throws {
        let task = Process()
        task.environment = ProcessInfo.processInfo.environment
        task.arguments = arguments
        task.currentDirectoryURL = currentDirectoryURL
        task.executableURL = executableURL
        try task.run()
        task.waitUntilExit()
        if task.terminationStatus != 0 {
            throw NSError(domain: "fail", code: Int(task.terminationStatus))
        }
    }

    static var architecture: String? {
        guard let arch = Bundle.main.executableArchitectures?.first?.intValue else {
            return nil
        }
        // NSBundleExecutableArchitectureARM64
        if arch == 0x0100_000C {
            return "arm64"
        } else if arch == NSBundleExecutableArchitectureX86_64 {
            return "x86_64"
        }
        return nil
    }
}
