import SwiftUI

struct OnboardingView: View {
    @ObservedObject var permissionsManager: PermissionsManager

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "lock.shield.fill")
                .font(.largeTitle)
                .foregroundStyle(.tint)

            Text("AppJail Setup")
                .font(.headline)

            Text("Grant permissions to enable app blocking.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Divider()

            PermissionRow(
                title: "Accessibility",
                detail: "Required to monitor running apps",
                granted: permissionsManager.accessibilityGranted,
                action: { permissionsManager.requestAccessibility() }
            )

            PermissionRow(
                title: "Automation",
                detail: "Required to manage browser tabs",
                granted: permissionsManager.automationGranted,
                action: { permissionsManager.openAutomationSettings() }
            )

            Spacer()

            if permissionsManager.allPermissionsGranted {
                Text("All set!")
                    .font(.caption)
                    .foregroundStyle(.green)
            } else {
                Text("Permissions are checked automatically.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .frame(width: 300, height: 320)
        .onAppear { permissionsManager.startPolling() }
        .onDisappear { permissionsManager.stopPolling() }
    }
}

private struct PermissionRow: View {
    let title: String
    let detail: String
    let granted: Bool
    let action: () -> Void

    var body: some View {
        HStack {
            Image(systemName: granted ? "checkmark.circle.fill" : "xmark.circle")
                .foregroundStyle(granted ? .green : .red)
            VStack(alignment: .leading) {
                Text(title)
                    .font(.body)
                Text(detail)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            if !granted {
                Button("Grant") { action() }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.small)
            }
        }
    }
}
