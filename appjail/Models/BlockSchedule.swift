import Foundation

struct BlockSchedule: Codable, Identifiable {
    var id: UUID = UUID()
    var name: String
    var startTime: DateComponents
    var endTime: DateComponents
    var weekdays: Set<Int>
    var isEnabled: Bool = true

    func isActiveNow() -> Bool {
        guard isEnabled else { return false }
        let calendar = Calendar.current
        let now = Date()
        let currentWeekday = calendar.component(.weekday, from: now)
        guard weekdays.contains(currentWeekday) else { return false }

        let currentHour = calendar.component(.hour, from: now)
        let currentMinute = calendar.component(.minute, from: now)
        let currentTotal = currentHour * 60 + currentMinute

        let startTotal = (startTime.hour ?? 0) * 60 + (startTime.minute ?? 0)
        let endTotal = (endTime.hour ?? 0) * 60 + (endTime.minute ?? 0)

        if startTotal <= endTotal {
            return currentTotal >= startTotal && currentTotal < endTotal
        } else {
            return currentTotal >= startTotal || currentTotal < endTotal
        }
    }
}
