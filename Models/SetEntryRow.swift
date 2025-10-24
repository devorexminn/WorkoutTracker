//
//  SetEntryRow.swift
//  WorkoutTracker
//
//  Created by Devorex Minn on 10/22/25.
//

import SwiftUI

struct SetEntryRow: View {
    let setNumber: Int
    @Binding var reps: Double
    @Binding var weight: Double

    var body: some View {
        HStack {
            Text("Set \(setNumber)")
                .font(.subheadline)
                .frame(width: 60, alignment: .leading)

            Spacer()

            VStack(alignment: .center) {
                Text("Reps")
                    .font(.caption)
                    .foregroundColor(.gray)
                TextField("0", value: $reps, format: .number)
                    .keyboardType(.numberPad)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 60)
            }

            VStack(alignment: .center) {
                Text("Weight")
                    .font(.caption)
                    .foregroundColor(.gray)
                TextField("0", value: $weight, format: .number)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 70)
            }
        }
        .padding(.vertical, 6)
    }
}
