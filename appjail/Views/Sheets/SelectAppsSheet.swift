import SwiftUI

struct SelectAppsSheet: View {
    @ObservedObject var blockList: BlockList
    var onDismiss: () -> Void
    @State private var apps: [AppInfo] = []
    @State private var searchText = ""
    @State private var isLoading = true

    private var blockedApps: [AppInfo] {
        apps.filter { blockList.isBlocked($0.id) }
    }

    private var availableApps: [AppInfo] {
        let filtered = apps.filter { !blockList.isBlocked($0.id) }
        if searchText.isEmpty { return filtered }
        return filtered.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider()

            if isLoading {
                Spacer()
                ProgressView("Scanning apps...")
                Spacer()
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        if !blockedApps.isEmpty {
                            blockedSection
                        }
                        availableSection
                    }
                    .padding()
                }
            }

            Divider()
            footer
        }
        .task {
            apps = AppScanner.scanInstalledApps()
            isLoading = false
        }
    }

    private var header: some View {
        HStack {
            Button(action: onDismiss) {
                Image(systemName: "chevron.left")
                    .font(.body)
            }
            .buttonStyle(.plain)
            Text("Select Apps")
                .font(.headline)
            Spacer()
            Text("\(blockedApps.count) blocked")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
    }

    private var blockedSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Blocked")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            ForEach(blockedApps) { app in
                HStack(spacing: 10) {
                    Image(nsImage: app.icon)
                        .resizable()
                        .frame(width: 32, height: 32)
                    VStack(alignment: .leading) {
                        Text(app.name)
                            .lineLimit(1)
                        if app.isBrowser {
                            Text("Browser")
                                .font(.caption2)
                                .foregroundStyle(.blue)
                        }
                    }
                    Spacer()
                    Button {
                        blockList.toggleBlock(app.id)
                    } label: {
                        Image(systemName: "minus.circle.fill")
                            .foregroundStyle(.red)
                            .font(.title3)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.vertical, 2)
            }
        }
    }

    private var availableSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            TextField("Search apps...", text: $searchText)
                .textFieldStyle(.roundedBorder)

            Text("Available Apps")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            ForEach(availableApps) { app in
                HStack(spacing: 10) {
                    Image(nsImage: app.icon)
                        .resizable()
                        .frame(width: 32, height: 32)
                    VStack(alignment: .leading) {
                        Text(app.name)
                            .lineLimit(1)
                        if app.isBrowser {
                            Text("Browser")
                                .font(.caption2)
                                .foregroundStyle(.blue)
                        }
                    }
                    Spacer()
                    Button {
                        blockList.toggleBlock(app.id)
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(.green)
                            .font(.title3)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.vertical, 2)
            }
        }
    }

    private var footer: some View {
        HStack {
            Button("Clear All") {
                for app in blockedApps {
                    blockList.toggleBlock(app.id)
                }
            }
            .buttonStyle(.plain)
            .foregroundStyle(.red)
            .disabled(blockedApps.isEmpty)

            Spacer()

            Button("Done", action: onDismiss)
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
        }
        .padding()
    }
}
