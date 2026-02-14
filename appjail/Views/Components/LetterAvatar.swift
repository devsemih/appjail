import SwiftUI

struct LetterAvatar: View {
    let text: String
    var size: CGFloat = 28

    private var letter: String {
        String(text.prefix(1)).uppercased()
    }

    private var color: Color {
        let colors: [Color] = [.red, .orange, .yellow, .green, .mint, .teal, .cyan, .blue, .indigo, .purple, .pink]
        let hash = abs(text.hashValue)
        return colors[hash % colors.count]
    }

    var body: some View {
        Text(letter)
            .font(.system(size: size * 0.45, weight: .semibold))
            .foregroundStyle(color)
            .frame(width: size, height: size)
            .glassEffect(.regular.tint(color), in: .circle)
    }
}
