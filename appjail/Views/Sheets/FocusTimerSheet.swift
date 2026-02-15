import SwiftUI

struct FocusTimerSheet: View {
    @ObservedObject var focusTimer: FocusTimerManager
    var onDismiss: () -> Void

    private let presets = [25, 45, 60, 90]

    var body: some View {
        VStack(spacing: 0) {
            SheetHeader(title: "Focus Timer")

            ScrollView {
                VStack(spacing: 16) {
                    // Timer ring in glass section
                    VStack(spacing: 16) {
                        TimerRingView(
                            progress: focusTimer.isIdle ? 0 : focusTimer.progress,
                            label: focusTimer.isIdle
                                ? "\(focusTimer.state.durationSeconds / 60)m"
                                : focusTimer.formattedRemaining,
                            size: 140
                        )
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 12))

                    // Presets in glass section (only when idle)
                    if focusTimer.isIdle {
                        HStack(spacing: 8) {
                            ForEach(presets, id: \.self) { minutes in
                                Button("\(minutes)m") {
                                    focusTimer.setDuration(minutes: minutes)
                                }
                                .buttonStyle(.bordered)
                                .controlSize(.small)
                                .tint(focusTimer.state.durationSeconds == minutes * 60 ? .accentColor : .gray)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 12))
                    }

                    // Controls
                    HStack(spacing: 12) {
                        if focusTimer.isIdle {
                            Button("Start") {
                                focusTimer.start()
                            }
                            .buttonStyle(.borderedProminent)
                            .disabled(focusTimer.state.durationSeconds == 0)
                        } else if focusTimer.isRunning {
                            Button("Pause") {
                                focusTimer.pause()
                            }
                            .buttonStyle(.bordered)

                            if !focusTimer.state.strictMode {
                                Button("Stop") {
                                    focusTimer.stop()
                                }
                                .buttonStyle(.bordered)
                                .tint(.red)
                            }
                        } else if focusTimer.isPaused {
                            Button("Resume") {
                                focusTimer.resume()
                            }
                            .buttonStyle(.borderedProminent)

                            Button("Stop") {
                                focusTimer.stop()
                            }
                            .buttonStyle(.bordered)
                            .tint(.red)
                        }
                    }

                    // Strict mode toggle in glass section (only when idle)
                    if focusTimer.isIdle {
                        VStack(spacing: 6) {
                            Toggle("Strict Mode", isOn: Binding(
                                get: { focusTimer.state.strictMode },
                                set: { newValue in
                                    focusTimer.state.strictMode = newValue
                                }
                            ))
                            .toggleStyle(.switch)
                            .controlSize(.small)

                            Text("Strict mode prevents stopping the timer early")
                                .font(.caption2)
                                .foregroundStyle(.tertiary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 12))
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
            }

            SheetFooter(
                trailingTitle: "Done",
                trailingAction: onDismiss
            )
        }
    }
}
