import AppKit
import Combine

class MonitoringEngine: ObservableObject {
    @Published var isMonitoring = false {
        didSet {
            if isMonitoring { startObserving() }
            else { stopObserving() }
        }
    }

    @Published var lastViolation: Violation?

    struct Violation: Identifiable {
        let id = UUID()
        let appName: String
        let reason: String
        let timestamp = Date()
    }

    private let blockList: BlockList
    nonisolated(unsafe) private var observer: NSObjectProtocol?
    private var lastCheckTime = Date.distantPast

    init(blockList: BlockList) {
        self.blockList = blockList
    }

    private func startObserving() {
        observer = NSWorkspace.shared.notificationCenter.addObserver(
            forName: NSWorkspace.didActivateApplicationNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            guard let self,
                  let app = notification.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication,
                  let bundleID = app.bundleIdentifier,
                  bundleID != Bundle.main.bundleIdentifier
            else { return }
            self.handleAppActivation(app: app, bundleID: bundleID)
        }
    }

    private func stopObserving() {
        if let observer {
            NSWorkspace.shared.notificationCenter.removeObserver(observer)
        }
        observer = nil
    }

    private func handleAppActivation(app: NSRunningApplication, bundleID: String) {
        let now = Date()
        guard now.timeIntervalSince(lastCheckTime) > 0.5 else { return }
        lastCheckTime = now

        if blockList.isBlocked(bundleID) {
            let name = app.localizedName ?? bundleID
            app.terminate()
            let violation = Violation(appName: name, reason: "Blocked app launched: \(name)")
            lastViolation = violation
            ViolationPanelController.shared.show(violation: violation)
            return
        }

        if let browser = BrowserRegistry.browser(for: bundleID),
           !blockList.urlKeywords.isEmpty {
            let keywords = blockList.urlKeywords
            let appName = browser.browserName
            Task.detached {
                try? await Task.sleep(for: .milliseconds(300))
                guard let url = browser.getActiveURL() else { return }
                let lower = url.lowercased()
                guard let matched = keywords.first(where: { lower.contains($0) }) else { return }
                let _ = browser.closeActiveTab()
                await MainActor.run { [weak self] in
                    guard let self else { return }
                    let violation = Violation(appName: appName, reason: "Blocked URL keyword \"\(matched)\" in \(appName)")
                    self.lastViolation = violation
                    ViolationPanelController.shared.show(violation: violation)
                }
            }
        }
    }

    deinit {
        if let observer {
            NSWorkspace.shared.notificationCenter.removeObserver(observer)
        }
    }
}
