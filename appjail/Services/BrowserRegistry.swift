import Foundation

enum BrowserRegistry {
    private static let browsers: [any BrowserProtocol] = [
        SafariBrowser(),
        ChromiumBrowser(name: "Google Chrome", bundleIdentifier: "com.google.Chrome", appleScriptAppName: "Google Chrome"),
        ChromiumBrowser(name: "Microsoft Edge", bundleIdentifier: "com.microsoft.edgemac", appleScriptAppName: "Microsoft Edge"),
        ChromiumBrowser(name: "Brave Browser", bundleIdentifier: "com.brave.Browser", appleScriptAppName: "Brave Browser"),
        ChromiumBrowser(name: "Arc", bundleIdentifier: "company.thebrowser.Browser", appleScriptAppName: "Arc"),
        ChromiumBrowser(name: "Dia", bundleIdentifier: "company.thebrowser.dia", appleScriptAppName: "Dia"),
        ChromiumBrowser(name: "Vivaldi", bundleIdentifier: "com.vivaldi.Vivaldi", appleScriptAppName: "Vivaldi"),
        ChromiumBrowser(name: "Opera", bundleIdentifier: "com.operasoftware.Opera", appleScriptAppName: "Opera"),
    ]

    private static let registry: [String: any BrowserProtocol] = {
        Dictionary(uniqueKeysWithValues: browsers.map { ($0.bundleIdentifier, $0) })
    }()

    static let browserBundleIDs: Set<String> = Set(browsers.map(\.bundleIdentifier))

    static func browser(for bundleID: String) -> (any BrowserProtocol)? {
        registry[bundleID]
    }

    static func isBrowser(_ bundleID: String) -> Bool {
        browserBundleIDs.contains(bundleID)
    }
}
