import Cocoa

struct ConfigData: Codable {
    var defaultBrowser: String = "com.google.Chrome"
    var smartMode: Bool = true
    var batteryBrowser: String = ""
    var acBrowser: String = ""
}

final class Config {
    static let shared = Config()
    private let key = "BrowserProxyConfig"
    private let selfBundleID = "com.browserproxy.app"

    var data: ConfigData {
        get {
            guard let d = UserDefaults.standard.data(forKey: key),
                  let v = try? JSONDecoder().decode(ConfigData.self, from: d)
            else { return ConfigData() }
            return v
        }
        set {
            guard let d = try? JSONEncoder().encode(newValue) else { return }
            UserDefaults.standard.set(d, forKey: key)
        }
    }

    var smartMode: Bool {
        get { data.smartMode }
        set { var d = data; d.smartMode = newValue; self.data = d }
    }

    var defaultBrowser: String {
        get { data.defaultBrowser }
        set { var d = data; d.defaultBrowser = newValue; self.data = d }
    }

    var batteryBrowser: String {
        get { data.batteryBrowser }
        set { var d = data; d.batteryBrowser = newValue; self.data = d }
    }

    var acBrowser: String {
        get { data.acBrowser }
        set { var d = data; d.acBrowser = newValue; self.data = d }
    }

    func browser(for power: String) -> String {
        switch power {
        case "battery": return batteryBrowser.isEmpty ? defaultBrowser : batteryBrowser
        case "ac":      return acBrowser.isEmpty ? defaultBrowser : acBrowser
        default:        return defaultBrowser
        }
    }

    var isDefaultBrowser: Bool {
        let http = LSCopyDefaultHandlerForURLScheme("http" as CFString)?.takeRetainedValue() as String?
        let https = LSCopyDefaultHandlerForURLScheme("https" as CFString)?.takeRetainedValue() as String?
        return http == selfBundleID && https == selfBundleID
    }

    func setAsDefault() {
        LSSetDefaultHandlerForURLScheme("http" as CFString, selfBundleID as CFString)
        LSSetDefaultHandlerForURLScheme("https" as CFString, selfBundleID as CFString)
    }
}
