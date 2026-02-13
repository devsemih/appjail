import SwiftUI

struct KeywordRowView: View {
    let keyword: String
    let onDelete: () -> Void

    var body: some View {
        HStack {
            Image(systemName: "globe")
                .foregroundStyle(.secondary)
            Text(keyword)
            Spacer()
            Button(action: onDelete) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
        }
    }
}
