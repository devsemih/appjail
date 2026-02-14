import SwiftUI

struct KeywordRowView: View {
    let keyword: String
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            LetterAvatar(text: keyword, size: 28)
            Text(keyword)
            Spacer()
            Button(action: onDelete) {
                Image(systemName: "minus.circle.fill")
                    .foregroundStyle(.red)
            }
            .buttonStyle(.plain)
        }
    }
}
