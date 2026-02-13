import AppKit

enum AppScanner {
    static func scanInstalledApps() -> [AppInfo] {
        let directories = ["/Applications", "/System/Applications"]
        let fileManager = FileManager.default
        let ownBundleID = Bundle.main.bundleIdentifier ?? "com.appjail"

        var apps: [AppInfo] = []
        var seenBundleIDs = Set<String>()

        for directory in directories {
            guard let urls = try? fileManager.contentsOfDirectory(
                at: URL(fileURLWithPath: directory),
                includingPropertiesForKeys: nil,
                options: [.skipsHiddenFiles]
            ) else { continue }

            for url in urls where url.pathExtension == "app" {
                guard let bundle = Bundle(url: url),
                      let bundleID = bundle.bundleIdentifier,
                      bundleID != ownBundleID,
                      !seenBundleIDs.contains(bundleID)
                else { continue }

                seenBundleIDs.insert(bundleID)

                let name = bundle.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
                    ?? bundle.object(forInfoDictionaryKey: "CFBundleName") as? String
                    ?? url.deletingPathExtension().lastPathComponent

                let icon = NSWorkspace.shared.icon(forFile: url.path)
                icon.size = NSSize(width: 32, height: 32)

                let isBrowser = BrowserRegistry.isBrowser(bundleID)

                apps.append(AppInfo(
                    id: bundleID,
                    name: name,
                    icon: icon,
                    bundleURL: url,
                    isBrowser: isBrowser
                ))
            }
        }

        return apps.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }
}
