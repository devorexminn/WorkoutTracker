//  SavedPopupView.swift
//  WorkoutTracker

import SwiftUI

struct SavedPopupView: View {
    var message: String
    var detail: String
    var color: Color = .green

    var body: some View {
        VStack {
            Spacer()
            HStack(spacing: 12) {
                Image(systemName: color == .green ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                    .foregroundColor(color)
                    .font(.system(size: 28))

                VStack(alignment: .leading, spacing: 4) {
                    Text(message)
                        .font(.headline)
                    Text(detail)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(.ultraThinMaterial)
            .cornerRadius(16)
            .shadow(radius: 10)
            .padding(.bottom, 40)
            .transition(.move(edge: .bottom).combined(with: .opacity))
        }
        .animation(.easeOut(duration: 0.3), value: message)
    }
}

#Preview {
    ZStack {
        Color(.systemBackground)
        SavedPopupView(message: "Workout Saved!", detail: "Review or start it in your Workout tab.")
    }
}
