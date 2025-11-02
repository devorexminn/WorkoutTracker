//
//  PrimaryButtonStyle.swift
//  WorkoutTracker
//
//  Created by Devorex Minn on 11/1/25.
//

import SwiftUI

struct PrimaryButtonStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(.headline, design: .rounded))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity, minHeight: 44)
            .background(Color.purple.opacity(0.85))
            .cornerRadius(10)
            .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 2)
    }
}

extension View {
    func primaryButton() -> some View { self.modifier(PrimaryButtonStyle()) }
}

