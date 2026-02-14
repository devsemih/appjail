import SwiftUI

struct ScheduleSheet: View {
    @ObservedObject var blockList: BlockList
    var onDismiss: () -> Void
    @State private var showingAddForm = false
    @State private var editName = ""
    @State private var editStartTime = defaultStartDate()
    @State private var editEndTime = defaultEndDate()
    @State private var editWeekdays: Set<Int> = [2, 3, 4, 5, 6]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: onDismiss) {
                    Image(systemName: "chevron.left")
                        .font(.body)
                }
                .buttonStyle(.plain)
                Text("Schedules")
                    .font(.headline)
                Spacer()
                Button {
                    showingAddForm.toggle()
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            if blockList.schedules.isEmpty && !showingAddForm {
                Spacer()
                VStack(spacing: 8) {
                    Image(systemName: "calendar.badge.clock")
                        .font(.largeTitle)
                        .foregroundStyle(.tertiary)
                    Text("No schedules yet")
                        .foregroundStyle(.tertiary)
                }
                Spacer()
            } else {
                List {
                    if showingAddForm {
                        addFormSection
                    }

                    ForEach(blockList.schedules) { schedule in
                        scheduleRow(schedule)
                    }
                }
            }

            Divider()

            HStack {
                Spacer()
                Button("Done", action: onDismiss)
                    .buttonStyle(.borderedProminent)
                    .controlSize(.small)
            }
            .padding()
        }
    }

    private var addFormSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("New Schedule")
                .font(.subheadline)
                .fontWeight(.medium)

            TextField("Schedule name", text: $editName)
                .textFieldStyle(.roundedBorder)

            HStack {
                DatePicker("Start", selection: $editStartTime, displayedComponents: .hourAndMinute)
                    .labelsHidden()
                Text("to")
                    .foregroundStyle(.secondary)
                DatePicker("End", selection: $editEndTime, displayedComponents: .hourAndMinute)
                    .labelsHidden()
            }

            WeekdayPicker(selectedDays: $editWeekdays)

            HStack {
                Button("Cancel") {
                    showingAddForm = false
                    resetForm()
                }
                .buttonStyle(.bordered)
                .controlSize(.small)

                Button("Add") {
                    addSchedule()
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
                .disabled(editName.trimmingCharacters(in: .whitespaces).isEmpty || editWeekdays.isEmpty)
            }
        }
        .padding(.vertical, 4)
    }

    private func scheduleRow(_ schedule: BlockSchedule) -> some View {
        HStack(spacing: 10) {
            VStack(alignment: .leading, spacing: 4) {
                Text(schedule.name)
                    .fontWeight(.medium)

                Text(formatTimeRange(schedule))
                    .font(.caption)
                    .foregroundStyle(.secondary)

                HStack(spacing: 2) {
                    ForEach(weekdayLabels(schedule.weekdays), id: \.self) { day in
                        Text(day)
                            .font(.system(size: 9))
                            .padding(.horizontal, 4)
                            .padding(.vertical, 1)
                            .background(Color.accentColor.opacity(0.2), in: Capsule())
                    }
                }
            }

            Spacer()

            Toggle("", isOn: Binding(
                get: { schedule.isEnabled },
                set: { newValue in
                    var updated = schedule
                    updated.isEnabled = newValue
                    blockList.updateSchedule(updated)
                }
            ))
            .toggleStyle(.switch)
            .labelsHidden()
            .controlSize(.small)

            Button {
                blockList.removeSchedule(schedule.id)
            } label: {
                Image(systemName: "trash")
                    .foregroundStyle(.red)
                    .font(.caption)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 4)
    }

    private func addSchedule() {
        let calendar = Calendar.current
        let startComponents = calendar.dateComponents([.hour, .minute], from: editStartTime)
        let endComponents = calendar.dateComponents([.hour, .minute], from: editEndTime)

        let schedule = BlockSchedule(
            name: editName.trimmingCharacters(in: .whitespaces),
            startTime: startComponents,
            endTime: endComponents,
            weekdays: editWeekdays
        )
        blockList.addSchedule(schedule)
        showingAddForm = false
        resetForm()
    }

    private func resetForm() {
        editName = ""
        editStartTime = Self.defaultStartDate()
        editEndTime = Self.defaultEndDate()
        editWeekdays = [2, 3, 4, 5, 6]
    }

    private func formatTimeRange(_ schedule: BlockSchedule) -> String {
        let startH = schedule.startTime.hour ?? 0
        let startM = schedule.startTime.minute ?? 0
        let endH = schedule.endTime.hour ?? 0
        let endM = schedule.endTime.minute ?? 0
        return String(format: "%02d:%02d - %02d:%02d", startH, startM, endH, endM)
    }

    private func weekdayLabels(_ days: Set<Int>) -> [String] {
        let names = ["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"]
        return days.sorted().compactMap { day in
            guard day >= 1, day <= 7 else { return nil }
            return names[day - 1]
        }
    }

    private static func defaultStartDate() -> Date {
        Calendar.current.date(from: DateComponents(hour: 9, minute: 0)) ?? Date()
    }

    private static func defaultEndDate() -> Date {
        Calendar.current.date(from: DateComponents(hour: 17, minute: 0)) ?? Date()
    }
}
