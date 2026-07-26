import SwiftUI
import OSLog

private let log = OSLog(subsystem: "com.browserproxy.app", category: "AppDelegate")

@main
struct BrowserProxyApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .windowResizability(.contentSize)
        .windowStyle(.hiddenTitleBar)
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    static var launchedViaURL = false

    func applicationWillFinishLaunching(_ notification: Notification) {
        let msg = "applicationWillFinishLaunching"
        os_log(.debug, log: log, "%{public}s", msg)
        try? msg.write(toFile: "/tmp/browserproxy_debug.log", atomically: true, encoding: .utf8)
        NSAppleEventManager.shared().setEventHandler(
            self,
            andSelector: #selector(handleURLEvent(_:with:)),
            forEventClass: AEEventClass(kInternetEventClass),
            andEventID: AEEventID(kAEGetURL))
    }

    @objc func handleURLEvent(_ event: NSAppleEventDescriptor, with reply: NSAppleEventDescriptor) {
        Self.launchedViaURL = true
        let urlString = event.paramDescriptor(forKeyword: keyDirectObject)?.stringValue ?? "nil"
        let eventMsg = "handleURLEvent: \(urlString)"
        os_log(.debug, log: log, "%{public}s", eventMsg)
        try? eventMsg.write(toFile: "/tmp/browserproxy_debug.log", atomically: true, encoding: .utf8)
        guard urlString != "nil" else {
            scheduleTerminate()
            return
        }
        Router.shared.handle(urlString)
        scheduleTerminate()
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        let launchMsg = "applicationDidFinishLaunching, launchedViaURL=\(Self.launchedViaURL)"
        os_log(.debug, log: log, "%{public}s", launchMsg)
        if var data = try? String(contentsOfFile: "/tmp/browserproxy_debug.log") {
            data += "\n" + launchMsg
            try? data.write(toFile: "/tmp/browserproxy_debug.log", atomically: true, encoding: .utf8)
        }
        if !Self.launchedViaURL {
            NSApp.activate(ignoringOtherApps: true)
        }
        if let window = NSApp.windows.first {
            window.styleMask.remove(.resizable)
            window.setContentSize(NSSize(width: 460, height: 530))
        }
    }

    private func scheduleTerminate() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            os_log(.debug, log: log, "terminating")
            NSApp.terminate(nil)
        }
    }
}
