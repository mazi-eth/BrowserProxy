import Cocoa
import IOKit.ps
import OSLog

private let log = OSLog(subsystem: "com.browserproxy.app", category: "Router")

final class Router {
    static let shared = Router()

    private let knownBrowsers: [(id: String, name: String)] = [
        ("com.apple.Safari", "Safari"),
        ("com.google.Chrome", "Google Chrome"),
        ("org.mozilla.firefox", "Firefox"),
        ("com.microsoft.edgemac", "Microsoft Edge"),
        ("com.brave.Browser", "Brave"),
        ("company.thebrowser.Browser", "Arc"),
        ("com.operasoftware.Opera", "Opera"),
        ("com.vivaldi.Vivaldi", "Vivaldi"),
    ]

    var installedBrowsers: [(id: String, name: String)] {
        knownBrowsers.filter { id, _ in
            NSWorkspace.shared.urlForApplication(withBundleIdentifier: id) != nil
        }
    }

    private func runningBrowserIDs() -> [String] {
        let running = NSWorkspace.shared.runningApplications.compactMap(\.bundleIdentifier)
        return knownBrowsers.map(\.id).filter { running.contains($0) }
    }

    private func powerSource() -> String {
        guard let info = IOPSCopyPowerSourcesInfo()?.takeRetainedValue(),
              let list = IOPSCopyPowerSourcesList(info)?.takeRetainedValue() as? [[String: Any]]
        else { return "ac" }
        if list.isEmpty { return "ac" }
        for src in list {
            if src[kIOPSPowerSourceStateKey] as? String == kIOPSBatteryPowerValue {
                return "battery"
            }
        }
        return "ac"
    }

    func handle(_ urlString: String) {
        let logMsg = "=== handle URL: \(urlString) ==="
        os_log(.debug, log: log, "%{public}s", logMsg)
        try? logMsg.write(toFile: "/tmp/browserproxy_debug.log", atomically: true, encoding: .utf8)

        let config = Config.shared
        let configMsg = "smartMode: \(config.smartMode), default: \(config.defaultBrowser), battery: \(config.batteryBrowser), ac: \(config.acBrowser)"
        os_log(.debug, log: log, "%{public}s", configMsg)
        if var data = try? String(contentsOfFile: "/tmp/browserproxy_debug.log") {
            data += "\n" + configMsg
            try? data.write(toFile: "/tmp/browserproxy_debug.log", atomically: true, encoding: .utf8)
        }

        let power = powerSource()
        let targetID: String

        if config.smartMode {
            let running = runningBrowserIDs()
            let runMsg = "smart mode - running: \(running.joined(separator: ", "))"
            os_log(.debug, log: log, "%{public}s", runMsg)
            if var data = try? String(contentsOfFile: "/tmp/browserproxy_debug.log") {
                data += "\n" + runMsg
                try? data.write(toFile: "/tmp/browserproxy_debug.log", atomically: true, encoding: .utf8)
            }
            if running.contains(config.defaultBrowser) {
                targetID = config.defaultBrowser
            } else {
                targetID = running.first ?? config.browser(for: power)
            }
        } else {
            targetID = config.browser(for: power)
        }

        let targetMsg = "target: \(targetID) (power: \(power))"
        os_log(.debug, log: log, "%{public}s", targetMsg)
        if var data = try? String(contentsOfFile: "/tmp/browserproxy_debug.log") {
            data += "\n" + targetMsg
            try? data.write(toFile: "/tmp/browserproxy_debug.log", atomically: true, encoding: .utf8)
        }

        guard let url = URL(string: urlString) else { return }

        openURL(url, in: targetID)
    }

    private func openURL(_ url: URL, in bundleID: String) {
        let appName = knownBrowsers.first(where: { $0.id == bundleID })?.name ?? bundleID
        let escaped = url.absoluteString.replacingOccurrences(of: "\"", with: "\\\"")

        os_log(.debug, log: log, "telling %{public}s to open %{public}s", appName, url.absoluteString)

        let script: String
        if bundleID == "com.apple.Safari" {
            script = """
            tell application "Safari"
                activate
                tell window 1
                    set current tab to (make new tab with properties {URL:"\(escaped)"})
                end tell
            end tell
            """
        } else {
            script = """
            tell application "\(appName)"
                activate
                open location "\(escaped)"
            end tell
            """
        }

        var error: NSDictionary?
        if let scriptObj = NSAppleScript(source: script) {
            scriptObj.executeAndReturnError(&error)
        }

        if error != nil {
            os_log(.error, log: log, "AppleScript error for %{public}s: %{public}@", appName, error ?? "")
            os_log(.debug, log: log, "fallback: open -b %{public}s", bundleID)
            let process = Process()
            process.executableURL = URL(fileURLWithPath: "/usr/bin/open")
            process.arguments = ["-b", bundleID, url.absoluteString]
            try? process.run()
            process.waitUntilExit()
        }
    }
}
