//  ExerciseViewModel.swift
//  WorkoutTracker
//
//  Safe public version (API key stored securely in Environment Variables)

import Foundation

@MainActor
class ExerciseViewModel: ObservableObject {
    @Published var bodyParts: [String] = []
    @Published var exercises: [Exercise] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let baseURL = "https://exercisedb.p.rapidapi.com/exercises"

    // ✅ Secure: read key from environment variable, fallback to empty string
    private var headers: [String: String] {
        [
            "x-rapidapi-key": ProcessInfo.processInfo.environment["EXERCISE_API_KEY"] ?? "",
            "x-rapidapi-host": "exercisedb.p.rapidapi.com"
        ]
    }

    // MARK: - Fetch body parts
    func fetchBodyParts() async {
        guard let url = URL(string: "\(baseURL)/bodyPartList") else { return }
        await fetchData(from: url, decodeType: [String].self) { [weak self] result in
            self?.bodyParts = result
        }
    }

    // MARK: - Fetch exercises by body part
    func fetchExercises(forBodyPart bodyPart: String) async {
        guard let url = URL(string: "\(baseURL)/bodyPart/\(bodyPart)") else { return }
        await fetchData(from: url, decodeType: [Exercise].self) { [weak self] result in
            self?.exercises = result
        }
    }

    // MARK: - Fetch exercises by name
    func fetchExercises(byName name: String) async {
        guard let url = URL(string: "\(baseURL)/name/\(name)") else { return }
        await fetchData(from: url, decodeType: [Exercise].self) { [weak self] result in
            self?.exercises = result
        }
    }

    // MARK: - Smart Search (name → bodyPart → target)
    func searchExercises(for searchTerm: String) async {
        isLoading = true
        defer { isLoading = false }

        // 1️⃣ Try searching by name
        await fetchExercises(byName: searchTerm)
        if !exercises.isEmpty { return }

        // 2️⃣ Try searching by body part
        await fetchExercises(forBodyPart: searchTerm.lowercased())
        if !exercises.isEmpty { return }

        // 3️⃣ Try searching by target muscle
        guard let url = URL(string: "\(baseURL)/target/\(searchTerm.lowercased())") else { return }
        await fetchData(from: url, decodeType: [Exercise].self) { [weak self] result in
            self?.exercises = result
        }
    }

    // MARK: - Generic fetch helper
    private func fetchData<T: Decodable>(
        from url: URL,
        decodeType: T.Type,
        completion: @escaping (T) -> Void
    ) async {
        isLoading = true
        defer { isLoading = false }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        headers.forEach { request.setValue($1, forHTTPHeaderField: $0) }

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                errorMessage = "Please enter a valid exercise"
                return
            }

            // 🪶 Optional: Print raw JSON for debugging
            // if let jsonString = String(data: data, encoding: .utf8) {
            //     print("RAW JSON RESPONSE: \(jsonString)")
            // }

            let decoded = try JSONDecoder().decode(T.self, from: data)
            completion(decoded)
            errorMessage = nil
        } catch {
            errorMessage = "Error fetching data: \(error.localizedDescription)"
        }
    }
}
