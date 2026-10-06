import Foundation
import Combine

/// Persists the learner's regional (UI) language and the single active course to learn.
final class UserProfileStore: ObservableObject {
    static let shared = UserProfileStore()

    @Published var uiLanguageCode: String {
        didSet { UserDefaults.standard.set(uiLanguageCode, forKey: Keys.uiLanguage) }
    }

    @Published var selectedCourseId: String? {
        didSet { UserDefaults.standard.set(selectedCourseId, forKey: Keys.courseId) }
    }

    var hasCompletedOnboarding: Bool {
        selectedCourseId != nil
    }

    private enum Keys {
        static let uiLanguage = "profile.uiLanguage.v1"
        static let courseId = "profile.selectedCourseId.v1"
    }

    private init() {
        uiLanguageCode = UserDefaults.standard.string(forKey: Keys.uiLanguage)
            ?? Locale.current.language.languageCode?.identifier
            ?? "en"
        selectedCourseId = UserDefaults.standard.string(forKey: Keys.courseId)
    }

    func completeOnboarding(uiLanguageCode: String, courseId: String) {
        self.uiLanguageCode = uiLanguageCode
        self.selectedCourseId = courseId
    }

    func changeCourse(to courseId: String) {
        selectedCourseId = courseId
    }

    func resetOnboarding() {
        selectedCourseId = nil
    }
}

struct RegionalLanguage: Identifiable, Hashable {
    let code: String
    let name: String
    let nativeName: String
    let flagEmoji: String

    var id: String { code }

    static let supported: [RegionalLanguage] = [
        .init(code: "en", name: "English", nativeName: "English", flagEmoji: "🇬🇧"),
        .init(code: "es", name: "Spanish", nativeName: "Español", flagEmoji: "🇪🇸"),
        .init(code: "fr", name: "French", nativeName: "Français", flagEmoji: "🇫🇷"),
        .init(code: "de", name: "German", nativeName: "Deutsch", flagEmoji: "🇩🇪"),
        .init(code: "pt", name: "Portuguese", nativeName: "Português", flagEmoji: "🇵🇹"),
        .init(code: "it", name: "Italian", nativeName: "Italiano", flagEmoji: "🇮🇹"),
        .init(code: "cs", name: "Czech", nativeName: "Čeština", flagEmoji: "🇨🇿"),
        .init(code: "fi", name: "Finnish", nativeName: "Suomi", flagEmoji: "🇫🇮"),
        .init(code: "ja", name: "Japanese", nativeName: "日本語", flagEmoji: "🇯🇵"),
        .init(code: "ko", name: "Korean", nativeName: "한국어", flagEmoji: "🇰🇷"),
        .init(code: "ar", name: "Arabic", nativeName: "العربية", flagEmoji: "🇸🇦"),
        .init(code: "ur", name: "Urdu", nativeName: "اردو", flagEmoji: "🇵🇰"),
        .init(code: "zh", name: "Chinese", nativeName: "中文", flagEmoji: "🇨🇳"),
        .init(code: "hi", name: "Hindi", nativeName: "हिन्दी", flagEmoji: "🇮🇳"),
    ]

    static func matching(code: String) -> RegionalLanguage {
        supported.first { $0.code == code } ?? supported[0]
    }
}
