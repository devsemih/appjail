import SwiftUI

struct AppRowView: View {
    let app: AppInfo
    let isBlocked: Bool
    let onToggle: () -> Void

    var body: some View {
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
            Button(action: onToggle) {
                Image(systemName: isBlocked ? "minus.circle.fill" : "plus.circle.fill")
                    .foregroundStyle(isBlocked ? .red : .green)
                    .font(.title3)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 4)
        .padding(.horizontal, 4)
        .background(Color.gray.opacity(0.05), in: RoundedRectangle(cornerRadius: 6))
    }
}
