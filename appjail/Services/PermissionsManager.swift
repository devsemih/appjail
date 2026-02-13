import AppKit
import Combine

class PermissionsManager: ObservableObject {
    @Published var accessibilityGranted = false
    @Published var automationGranted = false

    var allPermissionsGranted: Bool {
        accessibilityGranted && automationGranted
    }

    private var pollTimer: Timer?

    init() {
        checkPermissions()
    }

    func checkPermissions() {
        accessibilityGranted = AXIsProcessTrusted()
        automationGranted = checkAutomation()
    }

    func requestAccessibility() {
        let options = [kAXTrustedCheckOptionPrompt.takeRetainedValue(): true] as CFDictionary
        AXIsProcessTrustedWithOptions(options)
    }

    func openAutomationSettings() {
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Automation") {
            NSWorkspace.shared.open(url)
        }
    }

    func startPolling() {
        pollTimer?.invalidate()
        pollTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            self?.checkPermissions()
        }
    }

    func stopPolling() {
        pollTimer?.invalidate()
        pollTimer = nil
    }

    private func checkAutomation() -> Bool {
        AppleScriptRunner.executeIgnoringResult("tell application \"System Events\" to return name of first process")
    }
}
