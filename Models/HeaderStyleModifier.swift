import SwiftUI

struct HeaderStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 32, weight: .semibold, design: .rounded))
            .foregroundStyle(
                LinearGradient(
                    colors: [
                        Color(red: 0.82, green: 0.36, blue: 1.0), // soft pink-purple
                        Color(red: 0.56, green: 0.31, blue: 1.0)  // lavender purple
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .shadow(color: Color.purple.opacity(0.15), radius: 6, x: 0, y: 3)
            .padding(.top, 12)
            .padding(.bottom, 6)
            .padding(.horizontal)
    }
}

extension View {
    func headerStyle() -> some View {
        self.modifier(HeaderStyle())
    }
}
