//  WorkoutPlannerView.swift
//  WorkoutTracker

import SwiftUI
import SwiftData

struct WorkoutPlannerView: View {
    @State private var workoutName: String = ""
    @State private var searchTerm: String = ""
    @State private var selectedBodyPart: String?
    @StateObject private var viewModel = ExerciseViewModel()
    
    @State private var addedExercises: [ExerciseItem] = []
    @State private var selectedExercises: Set<UUID> = []
    @State private var showingSupersetSheet = false
    @State private var showingAddCustomExercise = false

    @Environment(\.modelContext) private var context
    
    @Query(sort: \CustomExercise.dateAdded, order: .reverse)
    private var customExercises: [CustomExercise]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    // MARK: Header
                    Text("Design Your Workout")
                        .headerStyle()
                    
                    // MARK: Workout Name
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Workout Name:")
                            .font(.headline)
                        TextField("Enter workout name", text: $workoutName)
                            .textFieldStyle(.roundedBorder)
                    }
                    
                    // MARK: Add Custom Exercise
                    Button("+ Custom Exercise") {
                        showingAddCustomExercise = true
                    }
                    .buttonStyle(.borderedProminent)
                    .sheet(isPresented: $showingAddCustomExercise) {
                        AddCustomExerciseView { newExercise in
                            addedExercises.append(newExercise)
                        }
                    }


                    // MARK: Search Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Search Exercise or Body Part:")
                            .font(.headline)
                        
                        HStack {
                            TextField("e.g. glutes, chest, squat", text: $searchTerm)
                                .textFieldStyle(.roundedBorder)
                            
                            Button("Search") {
                                Task { await search() }
                            }
                            .buttonStyle(.borderedProminent)
                        }
                        
                        // MARK: Search Results
                        if viewModel.isLoading {
                            ProgressView("Loading...")
                                .padding(.top, 8)
                        } else if let error = viewModel.errorMessage {
                            Text(error)
                                .foregroundColor(.red)
                                .padding(.top, 8)
                        } else {
                            LazyVStack(alignment: .leading, spacing: 12) {

                                // MARK: Custom Exercises (SwiftData)
                                ForEach(customExercises.filter {
                                    searchTerm.isEmpty ||
                                    $0.name.localizedCaseInsensitiveContains(searchTerm) ||
                                    $0.target.localizedCaseInsensitiveContains(searchTerm) ||
                                    $0.bodyPart.localizedCaseInsensitiveContains(searchTerm)
                                }) { custom in
                                    VStack(alignment: .leading, spacing: 4) {
                                        HStack(spacing: 10) {
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(Color.purple.opacity(0.2))
                                                .frame(width: 60, height: 60)
                                                .overlay(
                                                    Text("C")
                                                        .font(.headline)
                                                        .foregroundColor(.purple)
                                                )

                                            VStack(alignment: .leading) {
                                                Text(custom.name.capitalized)
                                                    .font(.headline)
                                                Text("\(custom.bodyPart.capitalized) • \(custom.target.capitalized)")
                                                    .font(.subheadline)
                                                    .foregroundColor(.gray)
                                            }

                                            Spacer()

                                            // Optional “Custom” tag
                                            Text("Custom")
                                                .font(.caption2)
                                                .padding(4)
                                                .background(Color.purple.opacity(0.15))
                                                .cornerRadius(6)
                                        }

                                        Button("+ Add to Workout") {
                                            let newExercise = ExerciseItem(
                                                name: custom.name.capitalized,
                                                sets: 3,
                                                targetReps: 12,
                                                restPeriod: "60s",
                                                isSuperset: false
                                            )
                                            addedExercises.append(newExercise)
                                        }
                                        .font(.caption)
                                        .foregroundColor(.purple)
                                        .padding(.top, 4)
                                    }
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(10)
                                    .shadow(color: .gray.opacity(0.1), radius: 2)
                                }

                                // MARK: API Exercises
                                ForEach(viewModel.exercises) { exercise in
                                    VStack(alignment: .leading, spacing: 4) {
                                        HStack(spacing: 10) {
                                            AsyncImage(url: URL(string: exercise.gifUrl ?? "")) { image in
                                                image.resizable()
                                            } placeholder: {
                                                Color.gray.opacity(0.2)
                                            }
                                            .frame(width: 60, height: 60)
                                            .cornerRadius(8)
                                            
                                            VStack(alignment: .leading) {
                                                Text(exercise.name.capitalized)
                                                    .font(.headline)
                                                if let target = exercise.target {
                                                    Text(target.capitalized)
                                                        .font(.subheadline)
                                                        .foregroundColor(.gray)
                                                }
                                            }
                                            Spacer()
                                        }
                                        
                                        Button("+ Add to Workout") {
                                            addExercise(exercise)
                                        }
                                        .font(.caption)
                                        .foregroundColor(.purple)
                                        .padding(.top, 4)
                                    }
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(10)
                                    .shadow(color: .gray.opacity(0.1), radius: 2)
                                }
                            }
                        }
                    }
                    
                    Divider()
                    
                    // MARK: Superset + Delete Controls
                    HStack(spacing: 12) {
                        Button {
                            if !selectedExercises.isEmpty {
                                showingSupersetSheet = true
                            }
                        } label: {
                            Text("Superset")
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                                .background(selectedExercises.isEmpty ? Color.gray : Color.purple)
                                .cornerRadius(10)
                        }
                        .disabled(selectedExercises.isEmpty)
                        .sheet(isPresented: $showingSupersetSheet) {
                            SupersetSetPicker { selectedSetCount in
                                applySuperset(to: selectedExercises, sets: selectedSetCount)
                            }
                        }

                        Button {
                            for id in selectedExercises {
                                if let ex = addedExercises.first(where: { $0.id == id }) {
                                    removeExercise(ex)
                                }
                            }
                            selectedExercises.removeAll()
                        } label: {
                            Text("Delete")
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                                .background(selectedExercises.isEmpty ? Color.gray : Color.red)
                                .cornerRadius(10)
                        }
                        .disabled(selectedExercises.isEmpty)
                    }
                    .padding(.vertical, 6)
                    
                    // MARK: Table Header
                    HStack {
                        Text("Exercise Name").bold().frame(maxWidth: .infinity, alignment: .leading)
                        Text("Sets").bold().frame(width: 40, alignment: .center)
                        Text("Reps").bold().frame(width: 50, alignment: .center)
                        Text("Rest").bold().frame(width: 60, alignment: .center)
                    }
                    .font(.subheadline)
                    .padding(.horizontal, 4)
                    
                    // MARK: Superset Grouping
                    let grouped = groupExercisesBySuperset(addedExercises)
                    
                    LazyVStack(spacing: 8) {
                        ForEach(grouped, id: \.self) { group in
                            VStack(spacing: 0) {
                                ForEach(group) { exercise in
                                    ExerciseRow(
                                        exercise: binding(for: exercise),
                                        selectedExercises: $selectedExercises,
                                        onDelete: { removeExercise($0) }
                                    )
                                }
                            }
                            .background(group.first?.isSuperset == true ? Color.purple.opacity(0.05) : Color.white)
                            .cornerRadius(10)
                        }
                    }
                    
                    // MARK: Save Button
                    Button {
                        let newWorkout = WorkoutSession(
                            title: workoutName,
                            exercises: addedExercises.map { exercise in
                                ExerciseLog(
                                    name: exercise.name,
                                    sets: (1...exercise.sets).map {
                                        SetLog(setNumber: $0, reps: exercise.targetReps, weight: 0)
                                    },
                                    supersetID: exercise.supersetGroupID
                                )
                            }
                        )
                        
                        context.insert(newWorkout)
                        
                        do {
                            try context.save()
                            print("✅ Workout saved successfully: \(newWorkout.title)")
                            addedExercises.removeAll()
                            workoutName = ""
                        } catch {
                            print("❌ Failed to save workout: \(error)")
                        }
                    } label: {
                        Text("Save")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.purple)
                            .cornerRadius(10)
                    }
                    .padding(.top, 12)
                }
                .padding()
            }
            .navigationBarHidden(true)
        }
    }
    
    // MARK: - Helpers
    private func search() async {
        let input = searchTerm.lowercased()
        await viewModel.searchExercises(for: input)
    }

    private func addExercise(_ exercise: Exercise) {
        let newExercise = ExerciseItem(
            name: exercise.name.capitalized,
            sets: 3,
            targetReps: 12,
            restPeriod: "60s",
            isSuperset: false
        )
        addedExercises.append(newExercise)
    }
    
    private func removeExercise(_ exercise: ExerciseItem) {
        addedExercises.removeAll { $0.id == exercise.id }
    }
    
    private func applySuperset(to selected: Set<UUID>, sets: Int) {
        let supersetID = UUID()
        var updated: [ExerciseItem] = []

        for var exercise in addedExercises {
            if selected.contains(exercise.id) {
                exercise.isSuperset = true
                exercise.supersetGroupID = supersetID
                exercise.restPeriod = "90s"
                exercise.sets = sets
            }
            updated.append(exercise)
        }

        addedExercises = updated
        selectedExercises.removeAll()
    }

    private func binding(for exercise: ExerciseItem) -> Binding<ExerciseItem> {
        guard let index = addedExercises.firstIndex(of: exercise) else {
            fatalError("Exercise not found")
        }
        return $addedExercises[index]
    }
    
    private func groupExercisesBySuperset(_ exercises: [ExerciseItem]) -> [[ExerciseItem]] {
        var result: [[ExerciseItem]] = []
        var current: [ExerciseItem] = []

        for ex in exercises {
            if ex.isSuperset {
                current.append(ex)
            } else {
                if !current.isEmpty {
                    result.append(current)
                    current.removeAll()
                }
                result.append([ex])
            }
        }

        if !current.isEmpty {
            result.append(current)
        }
        return result
    }
}

// MARK: - Subviews

struct ExerciseRow: View {
    @Binding var exercise: ExerciseItem
    @Binding var selectedExercises: Set<UUID>
    var onDelete: (ExerciseItem) -> Void
    
    var body: some View {
        HStack(spacing: 8) {
            Button {
                if selectedExercises.contains(exercise.id) {
                    selectedExercises.remove(exercise.id)
                } else {
                    selectedExercises.insert(exercise.id)
                }
            } label: {
                Image(systemName: selectedExercises.contains(exercise.id) ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(selectedExercises.contains(exercise.id) ? .purple : .gray)
            }

            TextField("Exercise", text: $exercise.name)
                .textFieldStyle(.roundedBorder)
                .frame(maxWidth: .infinity)

            TextField("3", value: $exercise.sets, formatter: NumberFormatter())
                .multilineTextAlignment(.center)
                .frame(width: 40)
                .textFieldStyle(.roundedBorder)

            TextField("12", value: $exercise.targetReps, formatter: NumberFormatter())
                .multilineTextAlignment(.center)
                .frame(width: 50)
                .textFieldStyle(.roundedBorder)

            TextField("60s", text: $exercise.restPeriod)
                .multilineTextAlignment(.center)
                .frame(width: 60)
                .textFieldStyle(.roundedBorder)
        }
        .padding(6)
        .background(selectedExercises.contains(exercise.id) ? Color.purple.opacity(0.1) : Color.clear)
        .cornerRadius(8)
    }
}

struct SupersetSetPicker: View {
    @Environment(\.dismiss) private var dismiss
    @State private var setCount: Int = 3
    var onConfirm: (Int) -> Void

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("How many sets for this superset?")
                    .font(.headline)

                Stepper("Sets: \(setCount)", value: $setCount, in: 1...10)
                    .padding()

                Button("Confirm") {
                    onConfirm(setCount)
                    dismiss()
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.purple)
                .cornerRadius(10)

                Spacer()
            }
            .padding()
            .navigationTitle("Superset")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct ExerciseItem: Identifiable, Hashable {
    let id = UUID()
    var name: String
    var sets: Int
    var targetReps: Int
    var restPeriod: String
    var isSuperset: Bool
    var supersetGroupID: UUID?
}

#Preview {
    WorkoutPlannerView()
}
