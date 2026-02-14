import Foundation
import Combine

class ScheduleManager: ObservableObject {
    @Published var isScheduleActive = false
    @Published var activeSchedule: BlockSchedule?
    @Published var nextSchedule: BlockSchedule?

    private let blockList: BlockList
    private var timer: Timer?
    private var cancellables = Set<AnyCancellable>()

    init(blockList: BlockList) {
        self.blockList = blockList

        blockList.$schedules
            .sink { [weak self] _ in self?.evaluate() }
            .store(in: &cancellables)

        startPolling()
        evaluate()
    }

    private func startPolling() {
        timer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { [weak self] _ in
            self?.evaluate()
        }
    }

    func evaluate() {
        let active = blockList.schedules.first { $0.isActiveNow() }
        isScheduleActive = active != nil
        activeSchedule = active

        let calendar = Calendar.current
        let now = Date()
        let currentWeekday = calendar.component(.weekday, from: now)
        let currentMinutes = calendar.component(.hour, from: now) * 60 + calendar.component(.minute, from: now)

        var closest: BlockSchedule?
        var closestDiff = Int.max

        for schedule in blockList.schedules where schedule.isEnabled && !schedule.isActiveNow() {
            let startMinutes = (schedule.startTime.hour ?? 0) * 60 + (schedule.startTime.minute ?? 0)

            for weekday in schedule.weekdays {
                var dayDiff = weekday - currentWeekday
                if dayDiff < 0 { dayDiff += 7 }

                var minuteDiff = dayDiff * 24 * 60 + (startMinutes - currentMinutes)
                if minuteDiff <= 0 { minuteDiff += 7 * 24 * 60 }

                if minuteDiff < closestDiff {
                    closestDiff = minuteDiff
                    closest = schedule
                }
            }
        }

        nextSchedule = closest
    }

    deinit {
        timer?.invalidate()
    }
}
