import SwiftUI

enum YGTheme {
    static let gold = Color(red: 1.00, green: 0.78, blue: 0.08)
    static let navy = Color(red: 0.035, green: 0.09, blue: 0.19)
    static let cream = Color(red: 1.0, green: 0.97, blue: 0.88)
    static let orange = Color(red: 1.0, green: 0.39, blue: 0.10)
}

struct BrandMark: View {
    var compact = false
    var body: some View {
        HStack(spacing: compact ? 8 : 12) {
            ZStack {
                RoundedRectangle(cornerRadius: compact ? 10 : 16).fill(YGTheme.gold)
                Image(systemName: "arrow.turn.down.right").font(.system(size: compact ? 18 : 28, weight: .black)).foregroundStyle(YGTheme.navy)
            }.frame(width: compact ? 38 : 58, height: compact ? 38 : 58).rotationEffect(.degrees(-6))
            Text("YOUR GO").font(.system(size: compact ? 23 : 38, weight: .black, design: .rounded)).foregroundStyle(YGTheme.navy)
        }.accessibilityElement(children: .ignore).accessibilityLabel("Your Go")
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    var color: Color = YGTheme.orange
    func makeBody(configuration: Configuration) -> some View {
        configuration.label.font(.system(.headline, design: .rounded, weight: .black)).frame(maxWidth: .infinity)
            .padding(.vertical, 16).foregroundStyle(.white)
            .background(color.opacity(configuration.isPressed ? 0.75 : 1), in: RoundedRectangle(cornerRadius: 18))
            .scaleEffect(configuration.isPressed ? 0.98 : 1).animation(.snappy, value: configuration.isPressed)
    }
}

extension View {
    func readableWidth(_ width: CGFloat = 720) -> some View { frame(maxWidth: width).frame(maxWidth: .infinity) }
}
