struct SafariBrowser: BrowserProtocol {
    let browserName = "Safari"
    let bundleIdentifier = "com.apple.Safari"

    nonisolated func getActiveURL() -> String? {
        AppleScriptRunner.execute("""
            tell application "Safari"
                if (count of windows) > 0 then
                    return URL of front document
                end if
            end tell
        """)
    }

    nonisolated func closeActiveTab() -> Bool {
        AppleScriptRunner.executeIgnoringResult("""
            tell application "Safari"
                if (count of windows) > 0 then
                    tell front window
                        close current tab
                    end tell
                end if
            end tell
        """)
    }
}
