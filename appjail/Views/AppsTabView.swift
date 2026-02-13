import SwiftUI

struct AppsTabView: View {
    @ObservedObject var blockList: BlockList
    @State private var apps: [AppInfo] = []
    @State private var searchText = ""
    @State private var isLoading = true

    private var filteredApps: [AppInfo] {
        if searchText.isEmpty { return apps }
        return apps.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        VStack(spacing: 0) {
            TextField("Search apps...", text: $searchText)
                .textFieldStyle(.roundedBorder)
                .padding(8)

            if isLoading {
                Spacer()
                ProgressView("Scanning apps...")
                Spacer()
            } else {
                List(filteredApps) { app in
                    AppRowView(app: app, isBlocked: blockList.isBlocked(app.id)) {
                        blockList.toggleBlock(app.id)
                    }
                }
            }
        }
        .task {
            apps = AppScanner.scanInstalledApps()
            isLoading = false
        }
    }
}
