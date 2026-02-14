import SwiftUI

struct TimerRingView: View {
    let progress: Double
    let label: String
    var size: CGFloat = 120

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.gray.opacity(0.15), lineWidth: 8)

            Circle()
                .trim(from: 0, to: CGFloat(min(progress, 1.0)))
                .stroke(
                    AngularGradient(
                        gradient: Gradient(colors: [.blue, .purple, .blue]),
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: 8, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 1), value: progress)

            Text(label)
                .font(.system(size: size > 60 ? 22 : 12, weight: .medium, design: .monospaced))
                .foregroundStyle(.primary)
        }
        .frame(width: size, height: size)
        .glassEffect(.clear, in: .circle)
    }
}
