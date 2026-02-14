import SwiftUI

@main
struct appjailApp: App {
    @StateObject private var blockList: BlockList
    @StateObject private var permissionsManager: PermissionsManager
    @StateObject private var engine: MonitoringEngine
    @StateObject private var focusTimerManager: FocusTimerManager
    @StateObject private var scheduleManager: ScheduleManager

    init() {
        let bl = BlockList()
        let ftm = FocusTimerManager()
        let sm = ScheduleManager(blockList: bl)
        let eng = MonitoringEngine(blockList: bl)
        eng.bind(focusTimer: ftm, schedule: sm)

        _blockList = StateObject(wrappedValue: bl)
        _permissionsManager = StateObject(wrappedValue: PermissionsManager())
        _engine = StateObject(wrappedValue: eng)
        _focusTimerManager = StateObject(wrappedValue: ftm)
        _scheduleManager = StateObject(wrappedValue: sm)
    }

    var body: some Scene {
        MenuBarExtra("AppJail", systemImage: "lock.shield") {
            if permissionsManager.allPermissionsGranted {
                DashboardView(
                    blockList: blockList,
                    engine: engine,
                    focusTimer: focusTimerManager,
                    scheduleManager: scheduleManager
                )
            } else {
                OnboardingView(permissionsManager: permissionsManager)
            }
        }
        .menuBarExtraStyle(.window)
    }
}
