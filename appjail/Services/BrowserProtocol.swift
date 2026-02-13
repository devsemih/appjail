protocol BrowserProtocol: Sendable {
    var browserName: String { get }
    var bundleIdentifier: String { get }
    nonisolated func getActiveURL() -> String?
    nonisolated func closeActiveTab() -> Bool
}
