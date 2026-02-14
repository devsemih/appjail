import Foundation

struct FocusTimerState: Codable {
    enum Status: String, Codable {
        case idle, running, paused
    }

    var durationSeconds: Int = 0
    var remainingSeconds: Int = 0
    var status: Status = .idle
    var startedAt: Date?
    var strictMode: Bool = false
}
