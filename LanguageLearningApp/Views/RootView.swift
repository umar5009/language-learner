import SwiftUI

struct RootView: View {
    @EnvironmentObject var profile: UserProfileStore
    @EnvironmentObject var dataStore: LanguageDataStore
    @EnvironmentObject var progressStore: ProgressStore

    @State private var showLaunch = true

    var body: some View {
        ZStack {
            Group {
                if profile.hasCompletedOnboarding, let courseId = profile.selectedCourseId {
                    CourseDashboardView(courseId: courseId)
                } else {
                    OnboardingView()
                }
            }

            if showLaunch {
                LaunchView {
                    withAnimation(.easeInOut(duration: 0.35)) {
                        showLaunch = false
                    }
                }
                .transition(.opacity)
                .zIndex(1)
            }
        }
    }
}
