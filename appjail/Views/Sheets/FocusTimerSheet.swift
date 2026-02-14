import SwiftUI

struct FocusTimerSheet: View {
    @ObservedObject var focusTimer: FocusTimerManager
    var onDismiss: () -> Void

    private let presets = [25, 45, 60, 90]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: onDismiss) {
                    Image(systemName: "chevron.left")
                        .font(.body)
                }
                .buttonStyle(.plain)
                Text("Focus Timer")
                    .font(.headline)
                Spacer()
            }
            .padding()

            Divider()

            VStack(spacing: 20) {
                Spacer()

                TimerRingView(
                    progress: focusTimer.isIdle ? 0 : focusTimer.progress,
                    label: focusTimer.isIdle
                        ? "\(focusTimer.state.durationSeconds / 60)m"
                        : focusTimer.formattedRemaining,
                    size: 140
                )

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
                }

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

                if focusTimer.isIdle {
                    Toggle("Strict Mode", isOn: Binding(
                        get: { focusTimer.state.strictMode },
                        set: { newValue in
                            focusTimer.state.strictMode = newValue
                        }
                    ))
                    .toggleStyle(.switch)
                    .controlSize(.small)
                    .padding(.horizontal, 40)

                    Text("Strict mode prevents stopping the timer early")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }

                Spacer()
            }
            .padding()

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
}
