import SwiftUI

struct SelectAppsSheet: View {
    @ObservedObject var blockList: BlockList
    var onDismiss: () -> Void
    @State private var apps: [AppInfo] = []
    @State private var searchText = ""
    @State private var isLoading = true
    @State private var showingAddApps = false

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
            if showingAddApps {
                addAppsView
            } else {
                mainView
            }
        }
        .task {
            apps = AppScanner.scanInstalledApps()
            isLoading = false
        }
    }

    // MARK: - Main View

    private var mainView: some View {
        VStack(spacing: 0) {
            SheetHeader(
                title: "Select Apps",
                trailingText: blockedApps.isEmpty ? nil : "\(blockedApps.count) blocked"
            )

            if isLoading {
                Spacer()
                ProgressView("Scanning apps...")
                Spacer()
            } else {
                ScrollView {
                    VStack(spacing: 12) {
                        NavigationRow(
                            icon: "plus.app.fill",
                            title: "Add Apps",
                            subtitle: "Browse installed apps",
                            action: { showingAddApps = true }
                        )

                        if !blockedApps.isEmpty {
                            blockedSection
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                }
            }

            SheetFooter(
                leadingTitle: "Clear All",
                leadingAction: {
                    for app in blockedApps {
                        blockList.toggleBlock(app.id)
                    }
                },
                leadingDisabled: blockedApps.isEmpty,
                leadingDestructive: true,
                trailingTitle: "Select",
                trailingAction: onDismiss
            )
        }
    }

    private var blockedSection: some View {
        VStack(spacing: 0) {
            ForEach(Array(blockedApps.enumerated()), id: \.element.id) { index, app in
                appRow(app: app, isBlocked: true)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                if index < blockedApps.count - 1 {
                    Divider().padding(.leading, 12)
                }
            }
        }
        .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Add Apps View

    private var addAppsView: some View {
        VStack(spacing: 0) {
            SheetHeader(title: "Add Apps", backAction: {
                searchText = ""
                showingAddApps = false
            })

            ScrollView {
                VStack(spacing: 12) {
                    // Search field in glass section
                    TextField("Search apps...", text: $searchText)
                        .textFieldStyle(.roundedBorder)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 12))

                    if !availableApps.isEmpty {
                        VStack(spacing: 0) {
                            ForEach(Array(availableApps.enumerated()), id: \.element.id) { index, app in
                                appRow(app: app, isBlocked: false)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 10)
                                if index < availableApps.count - 1 {
                                    Divider().padding(.leading, 12)
                                }
                            }
                        }
                        .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 12))
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
            }

            SheetFooter(
                trailingTitle: "Done",
                trailingAction: {
                    searchText = ""
                    showingAddApps = false
                }
            )
        }
    }

    // MARK: - Shared

    private func appRow(app: AppInfo, isBlocked: Bool) -> some View {
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
                Image(systemName: isBlocked ? "minus.circle.fill" : "plus.circle.fill")
                    .foregroundStyle(isBlocked ? .red : .green)
                    .font(.title3)
                    .frame(width: 32, height: 32)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
    }
}
