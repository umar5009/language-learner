import Foundation

/// Loads bundled JSON course content (manifest + per-language files) from the app bundle.
final class LanguageDataStore: ObservableObject {
    @Published private(set) var manifest: [LanguageManifestEntry] = []
    @Published private(set) var courses: [String: LanguageCourse] = [:]
    @Published private(set) var loadError: String?

    static let shared = LanguageDataStore()

    private init() {
        loadManifest()
    }

    private func loadManifest() {
        guard let url = Bundle.main.url(forResource: "manifest", withExtension: "json", subdirectory: "Languages") else {
            loadError = "manifest.json not found in bundle."
            return
        }
        do {
            let data = try Data(contentsOf: url)
            manifest = try JSONDecoder().decode([LanguageManifestEntry].self, from: data)
        } catch {
            loadError = "Failed to load manifest.json: \(error.localizedDescription)"
        }
    }

    /// Returns (and caches) the full course for a given language id, loading its JSON file lazily.
    func course(for id: String) -> LanguageCourse? {
        if let cached = courses[id] {
            return cached
        }
        guard let entry = manifest.first(where: { $0.id == id }) else { return nil }
        let fileNameNoExt = (entry.fileName as NSString).deletingPathExtension
        guard let url = Bundle.main.url(forResource: fileNameNoExt, withExtension: "json", subdirectory: "Languages") else {
            return nil
        }
        do {
            let data = try Data(contentsOf: url)
            let course = try JSONDecoder().decode(LanguageCourse.self, from: data)
            courses[id] = course
            return course
        } catch {
            loadError = "Failed to load \(entry.fileName): \(error.localizedDescription)"
            return nil
        }
    }
}
