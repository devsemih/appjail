import SwiftUI

enum ActiveSheet {
    case apps, websites, categories, timer, schedule
}

struct DashboardView: View {
    @ObservedObject var blockList: BlockList
    @ObservedObject var engine: MonitoringEngine
    @ObservedObject var focusTimer: FocusTimerManager
    @ObservedObject var scheduleManager: ScheduleManager

    @State private var activeSheet: ActiveSheet?

    var body: some View {
        Group {
            if let sheet = activeSheet {
                sheetContent(sheet)
            } else {
                mainDashboard
            }
        }
        .frame(width: 380, height: 520)
    }

    private var mainDashboard: some View {
        VStack(spacing: 0) {
            header
            Divider()

            ScrollView {
                VStack(spacing: 14) {
                    StatusCard(
                        engine: engine,
                        focusTimer: focusTimer,
                        scheduleManager: scheduleManager
                    )

                    quickConfigRow

                    timerSection

                    scheduleSection
                }
                .padding()
            }

            Divider()
            footer
        }
    }

    private var header: some View {
        HStack(spacing: 8) {
            Image(systemName: "lock.shield.fill")
                .foregroundStyle(.tint)
                .font(.title3)
            Text("AppJail")
                .font(.headline)
            Spacer()
        }
        .padding()
    }

    private var quickConfigRow: some View {
        GlassEffectContainer {
            HStack(spacing: 10) {
                QuickConfigCard(
                    icon: "app.fill",
                    label: "Apps",
                    count: blockList.blockedAppBundleIDs.count
                ) {
                    activeSheet = .apps
                }
                QuickConfigCard(
                    icon: "globe",
                    label: "Websites",
                    count: blockList.urlKeywords.count
                ) {
                    activeSheet = .websites
                }
                QuickConfigCard(
                    icon: "folder.fill",
                    label: "Categories",
                    count: blockList.enabledCategoryIDs.count
                ) {
                    activeSheet = .categories
                }
            }
        }
    }

    private var timerSection: some View {
        Button {
            activeSheet = .timer
        } label: {
            HStack(spacing: 12) {
                if focusTimer.isRunning || focusTimer.isPaused {
                    TimerRingView(
                        progress: focusTimer.progress,
                        label: focusTimer.formattedRemaining,
                        size: 40
                    )
                    VStack(alignment: .leading) {
                        Text("Focus Timer")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Text(focusTimer.isRunning ? "Running" : "Paused")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                } else {
                    Image(systemName: "timer")
                        .font(.title3)
                        .foregroundStyle(.tint)
                        .frame(width: 40, height: 40)
                    VStack(alignment: .leading) {
                        Text("Focus Timer")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Text("Start a focus session")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(.tertiary)
                    .font(.caption)
            }
            .padding(12)
            .contentShape(Rectangle())
            .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 10))
        }
        .buttonStyle(.plain)
    }

    private var scheduleSection: some View {
        Button {
            activeSheet = .schedule
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "calendar.badge.clock")
                    .font(.title3)
                    .foregroundStyle(.tint)
                    .frame(width: 40, height: 40)
                VStack(alignment: .leading) {
                    Text("Schedules")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    if let next = scheduleManager.nextSchedule {
                        Text("Next: \(next.name)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    } else if scheduleManager.isScheduleActive {
                        Text("Schedule active")
                            .font(.caption)
                            .foregroundStyle(.green)
                    } else {
                        Text("Set up blocking schedules")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                Spacer()
                if !blockList.schedules.isEmpty {
                    Text("\(blockList.schedules.count)")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                Image(systemName: "chevron.right")
                    .foregroundStyle(.tertiary)
                    .font(.caption)
            }
            .padding(12)
            .contentShape(Rectangle())
            .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 10))
        }
        .buttonStyle(.plain)
    }

    private var footer: some View {
        HStack {
            if engine.isMonitoring {
                Image(systemName: "circle.fill")
                    .foregroundStyle(.green)
                    .font(.caption2)
                Text("Monitoring")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
            .buttonStyle(.plain)
            .foregroundStyle(.red)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }

    @ViewBuilder
    private func sheetContent(_ sheet: ActiveSheet) -> some View {
        switch sheet {
        case .apps:
            SelectAppsSheet(blockList: blockList) { activeSheet = nil }
        case .websites:
            SelectWebsitesSheet(blockList: blockList) { activeSheet = nil }
        case .categories:
            WebsiteCategoriesSheet(blockList: blockList) { activeSheet = nil }
        case .timer:
            FocusTimerSheet(focusTimer: focusTimer) { activeSheet = nil }
        case .schedule:
            ScheduleSheet(blockList: blockList) { activeSheet = nil }
        }
    }
}
