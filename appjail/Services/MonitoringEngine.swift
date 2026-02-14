import AppKit
import Combine

class MonitoringEngine: ObservableObject {
    @Published var manuallyEnabled = false
    @Published var lastViolation: Violation?

    var isMonitoring: Bool {
        manuallyEnabled || timerRunning || scheduleActive
    }

    @Published private(set) var timerRunning = false
    @Published private(set) var scheduleActive = false

    struct Violation: Identifiable {
        let id = UUID()
        let appName: String
        let reason: String
        let timestamp = Date()
    }

    private let blockList: BlockList
    nonisolated(unsafe) private var observer: NSObjectProtocol?
    private var lastCheckTime = Date.distantPast
    private var cancellables = Set<AnyCancellable>()
    private var wasMonitoring = false

    init(blockList: BlockList) {
        self.blockList = blockList
    }

    func bind(focusTimer: FocusTimerManager, schedule: ScheduleManager) {
        focusTimer.$state
            .map { $0.status == .running }
            .removeDuplicates()
            .receive(on: RunLoop.main)
            .assign(to: &$timerRunning)

        schedule.$isScheduleActive
            .removeDuplicates()
            .receive(on: RunLoop.main)
            .assign(to: &$scheduleActive)

        Publishers.CombineLatest3($manuallyEnabled, $timerRunning, $scheduleActive)
            .map { manual, timer, sched in manual || timer || sched }
            .removeDuplicates()
            .receive(on: RunLoop.main)
            .sink { [weak self] shouldMonitor in
                guard let self else { return }
                if shouldMonitor && !self.wasMonitoring {
                    self.startObserving()
                    self.wasMonitoring = true
                } else if !shouldMonitor && self.wasMonitoring {
                    self.stopObserving()
                    self.wasMonitoring = false
                }
            }
            .store(in: &cancellables)
    }

    private func startObserving() {
        guard observer == nil else { return }
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

        let keywords = blockList.effectiveKeywords
        if let browser = BrowserRegistry.browser(for: bundleID),
           !keywords.isEmpty {
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
