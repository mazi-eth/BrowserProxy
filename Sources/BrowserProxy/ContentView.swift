import SwiftUI

struct ContentView: View {
    @StateObject private var state = SettingsState()

    var body: some View {
        VStack(spacing: 0) {
            header
                .padding(.horizontal, 24)
                .padding(.vertical, 20)
            Divider()
            VStack(spacing: 20) {
                strategySection
                browserSection
                powerSection
                statusSection
            }
            .padding(24)
        }
        .frame(width: 460)
        .background(Color(nsColor: .windowBackgroundColor))
        .onAppear { state.reload() }
    }

    private var header: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(.blue.opacity(0.12))
                    .frame(width: 36, height: 36)
                Image(systemName: "arrow.triangle.swap")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.blue)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text("BrowserProxy")
                    .font(.system(size: 16, weight: .semibold))
                Text("智能浏览器路由")
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
    }

    private var strategySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionLabel("路由策略")
            VStack(spacing: 0) {
                radioRow("始终使用选定的浏览器",
                         subtitle: "所有链接统一发送到下方指定的默认浏览器",
                         isSelected: !state.smartMode) {
                    state.smartMode = false
                    state.save()
                }
                Divider().padding(.leading, 40)
                radioRow("智能模式",
                         subtitle: "自动识别正在运行的浏览器并优先使用，未运行时回退到默认",
                         isSelected: state.smartMode) {
                    state.smartMode = true
                    state.save()
                }
            }
            .background(Color(nsColor: .controlBackgroundColor))
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        }
    }

    private var browserSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionLabel("默认浏览器")
            browserMenu
        }
    }

    private var powerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionLabel("电源模式覆盖")
            VStack(spacing: 0) {
                powerRow(label: "使用电池时",
                         selection: $state.batteryBrowser,
                         onChange: state.save,
                         disabled: !state.smartMode)
                Divider().padding(.leading, 100)
                powerRow(label: "接 电 源 时",
                         selection: $state.acBrowser,
                         onChange: state.save,
                         disabled: !state.smartMode)
            }
            .background(Color(nsColor: .controlBackgroundColor))
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .opacity(state.smartMode ? 1 : 0.45)
        }
    }

    private var statusSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionLabel("状态")
            HStack(spacing: 14) {
                Circle()
                    .fill(state.isDefault ? Color.green : Color.orange)
                    .frame(width: 8, height: 8)
                Text(state.isDefault ? "已是系统默认浏览器" : "尚未设为默认浏览器")
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
                Spacer()
                Button {
                    if state.isDefault {
                        state.restoreDefault()
                    } else {
                        state.setAsDefault()
                    }
                } label: {
                    Text(state.isDefault ? "恢复 Safari" : "设为默认")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(state.isDefault ? .secondary : Color.blue)
                }
                .buttonStyle(.plain)
                .opacity(0.8)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(nsColor: .controlBackgroundColor))
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        }
    }

    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 12, weight: .medium))
            .foregroundStyle(.secondary)
            .textCase(.uppercase)
            .tracking(1)
    }

    private func radioRow(_ title: String, subtitle: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .stroke(isSelected ? Color.blue : Color.gray.opacity(0.4), lineWidth: 2)
                        .frame(width: 18, height: 18)
                    if isSelected {
                        Circle()
                            .fill(.blue)
                            .frame(width: 10, height: 10)
                    }
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(.primary)
                    Text(subtitle)
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private var browserMenu: some View {
        HStack(spacing: 12) {
            if let current = state.selectedBrowser {
                Image(nsImage: current.icon)
                    .resizable()
                    .frame(width: 20, height: 20)
            }
            Menu {
                ForEach(state.availableBrowsers, id: \.id) { b in
                    Button {
                        state.defaultBrowser = b.id
                        state.save()
                    } label: {
                        HStack(spacing: 8) {
                            if let img = state.cachedIcon(for: b.id) {
                                Image(nsImage: img)
                                    .resizable()
                                    .frame(width: 16, height: 16)
                            }
                            Text(b.name)
                            if b.id == state.defaultBrowser {
                                Spacer()
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            } label: {
                HStack {
                    Text(state.selectedBrowser?.name ?? "选择浏览器")
                        .font(.system(size: 13))
                        .foregroundStyle(.primary)
                    Spacer()
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.system(size: 10))
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
            }
            .menuStyle(.borderlessButton)
            .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color(nsColor: .controlBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }

    private func powerRow(label: String, selection: Binding<String>, onChange: @escaping () -> Void, disabled: Bool = false) -> some View {
        HStack(spacing: 12) {
            Text(label)
                .font(.system(size: 13))
                .foregroundStyle(.secondary)
                .frame(width: 80, alignment: .trailing)
            Menu {
                Button {
                    selection.wrappedValue = ""
                    onChange()
                } label: {
                    HStack {
                        Text("跟随默认浏览器设置")
                        if selection.wrappedValue == "" {
                            Spacer()
                            Image(systemName: "checkmark")
                        }
                    }
                }
                ForEach(state.availableBrowsers, id: \.id) { b in
                    Button {
                        selection.wrappedValue = b.id
                        onChange()
                    } label: {
                        HStack(spacing: 8) {
                            if let img = state.cachedIcon(for: b.id) {
                                Image(nsImage: img)
                                    .resizable()
                                    .frame(width: 16, height: 16)
                            }
                            Text(b.name)
                            if b.id == selection.wrappedValue {
                                Spacer()
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            } label: {
                HStack {
                    Text(displayName(for: selection.wrappedValue))
                        .font(.system(size: 13))
                        .foregroundStyle(.primary)
                    Spacer()
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.system(size: 10))
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
            }
            .menuStyle(.borderlessButton)
            .fixedSize(horizontal: false, vertical: true)
            .disabled(disabled)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }

    private func displayName(for bundleID: String) -> String {
        guard !bundleID.isEmpty else { return "跟随默认浏览器设置" }
        return state.availableBrowsers.first(where: { $0.id == bundleID })?.name ?? bundleID
    }
}

struct BrowserItem: Identifiable {
    let id: String
    let name: String
    let icon: NSImage
}

final class SettingsState: ObservableObject {
    @Published var smartMode: Bool = true
    @Published var defaultBrowser: String = ""
    @Published var batteryBrowser: String = ""
    @Published var acBrowser: String = ""
    @Published var availableBrowsers: [BrowserItem] = []
    @Published var isDefault: Bool = false

    var selectedBrowser: BrowserItem? {
        availableBrowsers.first(where: { $0.id == defaultBrowser })
    }

    private let config = Config.shared
    private var iconCache: [String: NSImage] = [:]

    func cachedIcon(for id: String) -> NSImage? {
        iconCache[id]
    }

    func reload() {
        buildBrowserList()
        let d = config.data
        smartMode = d.smartMode
        defaultBrowser = d.defaultBrowser
        batteryBrowser = d.batteryBrowser
        acBrowser = d.acBrowser
        isDefault = config.isDefaultBrowser
        if !availableBrowsers.contains(where: { $0.id == defaultBrowser }) {
            defaultBrowser = availableBrowsers.first?.id ?? ""
            save()
        }
    }

    func save() {
        config.smartMode = smartMode
        config.defaultBrowser = defaultBrowser
        config.batteryBrowser = batteryBrowser
        config.acBrowser = acBrowser
        isDefault = config.isDefaultBrowser
    }

    func setAsDefault() {
        config.setAsDefault()
        isDefault = true
    }

    func restoreDefault() {
        LSSetDefaultHandlerForURLScheme("http" as CFString, "com.apple.Safari" as CFString)
        LSSetDefaultHandlerForURLScheme("https" as CFString, "com.apple.Safari" as CFString)
        isDefault = false
    }

    private func buildBrowserList() {
        let items = Router.shared.installedBrowsers.map { id, name -> BrowserItem in
            let icon: NSImage
            if let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: id) {
                icon = NSWorkspace.shared.icon(forFile: url.path)
            } else {
                icon = NSImage(systemSymbolName: "globe", accessibilityDescription: nil) ?? NSImage()
            }
            icon.size = NSSize(width: 16, height: 16)
            iconCache[id] = icon
            return BrowserItem(id: id, name: name, icon: icon)
        }
        availableBrowsers = items
    }
}
