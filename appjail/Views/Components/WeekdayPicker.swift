import SwiftUI

struct WeekdayPicker: View {
    @Binding var selectedDays: Set<Int>

    private let days: [(label: String, value: Int)] = [
        ("S", 1), ("M", 2), ("T", 3), ("W", 4), ("T", 5), ("F", 6), ("S", 7)
    ]

    var body: some View {
        GlassEffectContainer {
            HStack(spacing: 4) {
                ForEach(days, id: \.value) { day in
                    Button {
                        if selectedDays.contains(day.value) {
                            selectedDays.remove(day.value)
                        } else {
                            selectedDays.insert(day.value)
                        }
                    } label: {
                        Text(day.label)
                            .font(.caption2)
                            .fontWeight(.medium)
                            .foregroundStyle(selectedDays.contains(day.value) ? .white : .primary)
                            .frame(width: 30, height: 30)
                            .contentShape(Rectangle())
                            .glassEffect(
                                selectedDays.contains(day.value)
                                    ? .regular.tint(.accentColor)
                                    : .regular,
                                in: .circle
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}
