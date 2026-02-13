import SwiftUI

struct AppRowView: View {
    let app: AppInfo
    let isBlocked: Bool
    let onToggle: () -> Void

    var body: some View {
        HStack {
            Image(nsImage: app.icon)
                .resizable()
                .frame(width: 24, height: 24)
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
            Toggle("", isOn: Binding(
                get: { isBlocked },
                set: { _ in onToggle() }
            ))
            .toggleStyle(.switch)
            .labelsHidden()
        }
        .padding(.vertical, 2)
    }
}
