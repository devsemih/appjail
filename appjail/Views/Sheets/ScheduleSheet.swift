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
            if showingAddForm {
                addScheduleView
            } else {
                mainView
            }
        }
    }

    // MARK: - Main View

    private var mainView: some View {
        VStack(spacing: 0) {
            SheetHeader(
                title: "Schedules",
                trailingIcon: "plus.circle.fill",
                trailingAction: { showingAddForm = true }
            )

            if blockList.schedules.isEmpty {
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
                ScrollView {
                    VStack(spacing: 12) {
                        // Schedules in glass grouped section
                        VStack(spacing: 0) {
                            ForEach(Array(blockList.schedules.enumerated()), id: \.element.id) { index, schedule in
                                scheduleRow(schedule)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 10)
                                if index < blockList.schedules.count - 1 {
                                    Divider().padding(.leading, 12)
                                }
                            }
                        }
                        .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 12))
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                }
            }

            SheetFooter(
                trailingTitle: "Done",
                trailingAction: onDismiss
            )
        }
    }

    // MARK: - Add Schedule View

    private var addScheduleView: some View {
        VStack(spacing: 0) {
            SheetHeader(title: "New Schedule", backAction: {
                showingAddForm = false
                resetForm()
            })

            ScrollView {
                VStack(spacing: 12) {
                    // Name field in glass section
                    TextField("Schedule name", text: $editName)
                        .textFieldStyle(.roundedBorder)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 12))

                    // Start/end time pickers grouped in glass section
                    VStack(spacing: 8) {
                        HStack {
                            Text("Start")
                                .foregroundStyle(.secondary)
                            Spacer()
                            DatePicker("Start", selection: $editStartTime, displayedComponents: .hourAndMinute)
                                .labelsHidden()
                        }
                        Divider()
                        HStack {
                            Text("End")
                                .foregroundStyle(.secondary)
                            Spacer()
                            DatePicker("End", selection: $editEndTime, displayedComponents: .hourAndMinute)
                                .labelsHidden()
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 12))

                    // Weekday picker
                    WeekdayPicker(selectedDays: $editWeekdays)
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
            }

            SheetFooter(
                leadingTitle: "Cancel",
                leadingAction: {
                    showingAddForm = false
                    resetForm()
                },
                trailingTitle: "Save",
                trailingAction: {
                    addSchedule()
                }
            )
        }
    }

    // MARK: - Schedule Row

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
                    .frame(width: 28, height: 28)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Helpers

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
