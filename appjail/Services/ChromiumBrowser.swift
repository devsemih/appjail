struct ChromiumBrowser: BrowserProtocol {
    let browserName: String
    let bundleIdentifier: String
    private let appleScriptAppName: String

    init(name: String, bundleIdentifier: String, appleScriptAppName: String) {
        self.browserName = name
        self.bundleIdentifier = bundleIdentifier
        self.appleScriptAppName = appleScriptAppName
    }

    nonisolated func getActiveURL() -> String? {
        AppleScriptRunner.execute("""
            tell application "\(appleScriptAppName)"
                if (count of windows) > 0 then
                    return URL of active tab of first window
                end if
            end tell
        """)
    }

    nonisolated func closeActiveTab() -> Bool {
        AppleScriptRunner.executeIgnoringResult("""
            tell application "\(appleScriptAppName)"
                if (count of windows) > 0 then
                    close active tab of first window
                end if
            end tell
        """)
    }
}
