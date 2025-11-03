import XCTest
@testable import WorkoutTracker

@MainActor
final class WorkoutTrackerTests: XCTestCase {

    // MARK: - Test 1
    func testInitialState_isEmpty() {
        let viewModel = ExerciseViewModel()

        XCTAssertTrue(viewModel.bodyParts.isEmpty, "Body parts should start empty")
        XCTAssertTrue(viewModel.exercises.isEmpty, "Exercises should start empty")
        XCTAssertFalse(viewModel.isLoading, "Loading state should be false initially")
        XCTAssertNil(viewModel.errorMessage, "Error message should start nil")
    }

    // MARK: - Test 2
    func testExercisesProperty_canStoreAndRetrieveExercises() {
        let viewModel = ExerciseViewModel()

        // Adjust this initializer to match your Exercise.swift file exactly:
        let mockExercises = [
            Exercise(
                name: "Bench Press",
                bodyPart: "chest",
                target: "pectorals",
                equipment: "barbell",
                gifUrl: "",
            
            ),
            Exercise(
                name: "Squat",
                bodyPart: "legs",
                target: "quadriceps",
                equipment: "barbell",
                gifUrl: "",
                
            )
        ]

        viewModel.exercises = mockExercises

        XCTAssertEqual(viewModel.exercises.count, 2, "Should store two exercises")
        XCTAssertEqual(viewModel.exercises.first?.name, "Bench Press", "First exercise should match")
        XCTAssertEqual(viewModel.exercises.last?.bodyPart, "legs", "Second exercise bodyPart should be legs")
    }
}
