import SwiftUI

@main
struct appjailApp: App {
    @StateObject private var blockList: BlockList
    @StateObject private var permissionsManager: PermissionsManager
    @StateObject private var engine: MonitoringEngine

    init() {
        let bl = BlockList()
        _blockList = StateObject(wrappedValue: bl)
        _permissionsManager = StateObject(wrappedValue: PermissionsManager())
        _engine = StateObject(wrappedValue: MonitoringEngine(blockList: bl))
    }

    var body: some Scene {
        MenuBarExtra("AppJail", systemImage: "lock.shield") {
            if permissionsManager.allPermissionsGranted {
                DashboardView(blockList: blockList, engine: engine)
            } else {
                OnboardingView(permissionsManager: permissionsManager)
            }
        }
        .menuBarExtraStyle(.window)
    }
}
