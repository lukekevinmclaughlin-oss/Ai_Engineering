import Foundation

public enum CurriculumStore {
    public static func load(bundle: Bundle = .main) -> Curriculum {
        guard let url = bundle.url(forResource: "curriculum", withExtension: "json") else {
            assertionFailure("curriculum.json is missing from the app bundle")
            return Curriculum(courses: [])
        }

        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode(Curriculum.self, from: data)
        } catch {
            assertionFailure("Unable to decode curriculum.json: \(error)")
            return Curriculum(courses: [])
        }
    }
}
