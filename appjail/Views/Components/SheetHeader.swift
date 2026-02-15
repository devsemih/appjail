import SwiftUI

struct SheetHeader: View {
    let title: String
    var backAction: (() -> Void)?
    var trailingText: String?
    var trailingIcon: String?
    var trailingAction: (() -> Void)?

    var body: some View {
        HStack {
            if let backAction {
                Button(action: backAction) {
                    Image(systemName: "chevron.left")
                        .font(.body)
                        .frame(width: 28, height: 28)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
            Text(title)
                .font(.title3)
                .fontWeight(.bold)
            Spacer()
            if let text = trailingText {
                Text(text)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            if let icon = trailingIcon, let action = trailingAction {
                Button(action: action) {
                    Image(systemName: icon)
                        .font(.title3)
                        .frame(width: 32, height: 32)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal)
        .padding(.top, 16)
        .padding(.bottom, 8)
    }
}
