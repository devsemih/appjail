import SwiftUI

struct QuickConfigCard: View {
    let icon: String
    let label: String
    let count: Int
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(.tint)
                Text(label)
                    .font(.caption)
                    .foregroundStyle(.primary)
                Text("\(count)")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 10))
        }
        .buttonStyle(.plain)
    }
}
