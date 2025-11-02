//
//  RestTimerView.swift
//  WorkoutTracker
//
//  Created by Devorex Minn on 10/22/25.
//

import SwiftUI

struct RestTimerView: View {
    @State private var progress: Double = 0
    @State private var isRunning: Bool = false
    let duration: Double

    var body: some View {
        HStack {
            ZStack {
                Circle()
                    .stroke(Color.purple.opacity(0.2), lineWidth: 6)
                    .frame(width: 28, height: 28)

                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(Color.purple, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                    .frame(width: 28, height: 28)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.2), value: progress)
            }

            Text(isRunning ? timeRemainingFormatted : "Rest for \(Int(duration))s")
                .font(.subheadline)
                .foregroundColor(.purple)

            Spacer()

            Button(isRunning ? "Pause" : "Start") {
                toggleTimer()
            }
            .font(.caption.bold())
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 4)
            .background(Color.purple)
            .cornerRadius(8)
        }
        .padding(8)
        .background(Color.purple.opacity(0.1))
        .cornerRadius(10)
    }

    // MARK: - Computed
    private var timeRemaining: Double {
        duration * (1 - progress)
    }

    private var timeRemainingFormatted: String {
        let seconds = Int(timeRemaining)
        return "Rest: \(seconds)s"
    }

    // MARK: - Actions
    private func toggleTimer() {
        if isRunning {
            isRunning = false
        } else {
            startTimer()
        }
    }

    private func startTimer() {
        isRunning = true
        progress = 0

        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            if !isRunning {
                timer.invalidate()
                return
            }

            if progress < 1.0 {
                withAnimation(.linear(duration: 0.1)) {
                    progress += 0.1 / duration
                }
            } else {
                timer.invalidate()
                withAnimation(.easeOut(duration: 0.5)) {
                    isRunning = false
                    progress = 1.0
                }
            }
        }
    }
}
