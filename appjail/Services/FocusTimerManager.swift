import Foundation
import Combine
import UserNotifications

class FocusTimerManager: ObservableObject {
    @Published var state = FocusTimerState()

    private var timer: Timer?

    var progress: Double {
        guard state.durationSeconds > 0 else { return 0 }
        return 1.0 - Double(state.remainingSeconds) / Double(state.durationSeconds)
    }

    var formattedRemaining: String {
        let minutes = state.remainingSeconds / 60
        let seconds = state.remainingSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    var isRunning: Bool { state.status == .running }
    var isPaused: Bool { state.status == .paused }
    var isIdle: Bool { state.status == .idle }

    func setDuration(minutes: Int) {
        let seconds = minutes * 60
        state.durationSeconds = seconds
        state.remainingSeconds = seconds
    }

    func start() {
        guard state.durationSeconds > 0 else { return }
        state.status = .running
        state.startedAt = Date()
        state.remainingSeconds = state.durationSeconds
        startTimer()
    }

    func pause() {
        guard state.status == .running else { return }
        state.status = .paused
        stopTimer()
    }

    func resume() {
        guard state.status == .paused else { return }
        state.status = .running
        state.startedAt = Date().addingTimeInterval(-Double(state.durationSeconds - state.remainingSeconds))
        startTimer()
    }

    func stop() {
        state.status = .idle
        state.remainingSeconds = state.durationSeconds
        state.startedAt = nil
        stopTimer()
    }

    private func startTimer() {
        stopTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.tick()
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func tick() {
        guard state.status == .running, let startedAt = state.startedAt else { return }

        let elapsed = Int(Date().timeIntervalSince(startedAt))
        let remaining = max(0, state.durationSeconds - elapsed)
        state.remainingSeconds = remaining

        if remaining <= 0 {
            complete()
        }
    }

    private func complete() {
        state.status = .idle
        state.remainingSeconds = 0
        stopTimer()
        sendCompletionNotification()
        NotificationCenter.default.post(name: .focusTimerCompleted, object: nil)
    }

    private func sendCompletionNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Focus Session Complete"
        content.body = "Great work! Your focus session has ended."
        content.sound = .default

        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request)
    }
}

extension Notification.Name {
    static let focusTimerCompleted = Notification.Name("focusTimerCompleted")
}
