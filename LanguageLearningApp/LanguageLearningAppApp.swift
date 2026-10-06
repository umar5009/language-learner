import SwiftUI

@main
struct LanguageLearningAppApp: App {
    @StateObject private var dataStore = LanguageDataStore.shared
    @StateObject private var progressStore = ProgressStore.shared
    @StateObject private var profile = UserProfileStore.shared
    @StateObject private var planStore = CustomPlanStore.shared

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(dataStore)
                .environmentObject(progressStore)
                .environmentObject(profile)
                .environmentObject(planStore)
        }
    }
}
