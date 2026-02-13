import SwiftUI
import AppKit

class ViolationPanelController {
    static let shared = ViolationPanelController()

    private var panel: NSPanel?
    private var dismissTimer: Timer?

    func show(violation: MonitoringEngine.Violation) {
        dismissTimer?.invalidate()
        panel?.close()

        let panel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: 320, height: 80),
            styleMask: [.nonactivatingPanel, .titled, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        panel.level = .mainMenu
        panel.isFloatingPanel = true
        panel.hidesOnDeactivate = false
        panel.titlebarAppearsTransparent = true
        panel.titleVisibility = .hidden
        panel.isMovableByWindowBackground = true
        panel.backgroundColor = .clear

        let content = ViolationPanelContent(reason: violation.reason)
        let hostingView = NSHostingView(rootView: content)
        panel.contentView = hostingView

        if let screen = NSScreen.main {
            let screenFrame = screen.visibleFrame
            let x = screenFrame.midX - 160
            let y = screenFrame.maxY - 100
            panel.setFrameOrigin(NSPoint(x: x, y: y))
        }

        panel.orderFront(nil)
        self.panel = panel

        dismissTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false) { [weak self] _ in
            self?.panel?.close()
            self?.panel = nil
        }
    }
}

private struct ViolationPanelContent: View {
    let reason: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "exclamationmark.shield.fill")
                .font(.title)
                .foregroundStyle(.red)
            VStack(alignment: .leading) {
                Text("Blocked")
                    .font(.headline)
                Text(reason)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
        }
        .padding()
        .frame(width: 320)
        .background(.ultraThickMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}
