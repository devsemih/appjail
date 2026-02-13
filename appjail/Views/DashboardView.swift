import SwiftUI

struct DashboardView: View {
    @ObservedObject var blockList: BlockList
    @ObservedObject var engine: MonitoringEngine

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Image(systemName: "lock.shield.fill")
                    .foregroundStyle(.tint)
                Text("AppJail")
                    .font(.headline)
                Spacer()
                Toggle("", isOn: $engine.isMonitoring)
                    .toggleStyle(.switch)
                    .labelsHidden()
            }
            .padding()

            Divider()

            TabView {
                AppsTabView(blockList: blockList)
                    .tabItem { Label("Apps", systemImage: "app.fill") }
                BrowsersTabView(blockList: blockList)
                    .tabItem { Label("Browsers", systemImage: "globe") }
            }

            Divider()

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
        .frame(width: 350, height: 450)
    }
}
