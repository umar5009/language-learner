import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var profile: UserProfileStore
    @EnvironmentObject var dataStore: LanguageDataStore

    @State private var step = 0
    @State private var selectedUI = ""
    @State private var selectedCourseId: String?

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                progressHeader
                if step == 0 {
                    regionalStep
                } else {
                    courseStep
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                if selectedUI.isEmpty {
                    selectedUI = RegionalLanguage.matching(code: profile.uiLanguageCode).code
                }
            }
        }
    }

    private var progressHeader: some View {
        HStack(spacing: 8) {
            Capsule().fill(step >= 0 ? Color.accentColor : Color.gray.opacity(0.25)).frame(height: 4)
            Capsule().fill(step >= 1 ? Color.accentColor : Color.gray.opacity(0.25)).frame(height: 4)
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 8)
    }

    private var regionalStep: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text(L10n.t(.chooseRegionalTitle, selectedUI.isEmpty ? profile.uiLanguageCode : selectedUI))
                    .font(.largeTitle.bold())
                Text(L10n.t(.chooseRegionalSubtitle, selectedUI.isEmpty ? profile.uiLanguageCode : selectedUI))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)

            List(RegionalLanguage.supported, selection: Binding(
                get: { selectedUI },
                set: { selectedUI = $0 ?? selectedUI }
            )) { lang in
                HStack(spacing: 14) {
                    Text(lang.flagEmoji).font(.title2)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(lang.nativeName).font(.headline)
                        Text(lang.name).font(.caption).foregroundStyle(.secondary)
                    }
                    Spacer()
                    if selectedUI == lang.code {
                        Image(systemName: "checkmark.circle.fill").foregroundStyle(Color.accentColor)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture { selectedUI = lang.code }
                .tag(lang.code)
            }
            .listStyle(.plain)

            Button {
                profile.uiLanguageCode = selectedUI
                withAnimation { step = 1 }
            } label: {
                Text(L10n.t(.continueButton, selectedUI))
                    .font(.body.bold())
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .padding(20)
            .disabled(selectedUI.isEmpty)
        }
    }

    private var courseStep: some View {
        let ui = profile.uiLanguageCode
        return VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text(L10n.t(.chooseCourseTitle, ui))
                    .font(.largeTitle.bold())
                Text(L10n.t(.chooseCourseSubtitle, ui))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)

            if let error = dataStore.loadError {
                ContentUnavailableView(L10n.t(.contentError, ui), systemImage: "exclamationmark.triangle", description: Text(error))
            } else {
                List(dataStore.manifest) { entry in
                    HStack(spacing: 14) {
                        Text(entry.flagEmoji).font(.title2)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(entry.name).font(.headline)
                            Text(entry.institute).font(.caption).foregroundStyle(.secondary)
                            Text(entry.framework).font(.caption2).foregroundStyle(.secondary)
                        }
                        Spacer()
                        if selectedCourseId == entry.id {
                            Image(systemName: "checkmark.circle.fill").foregroundStyle(Color.accentColor)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture { selectedCourseId = entry.id }
                    .padding(.vertical, 4)
                }
                .listStyle(.plain)
            }

            HStack(spacing: 12) {
                Button {
                    withAnimation { step = 0 }
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.body.bold())
                        .frame(width: 52, height: 52)
                        .background(Color.gray.opacity(0.15))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }

                Button {
                    guard let selectedCourseId else { return }
                    profile.completeOnboarding(uiLanguageCode: ui, courseId: selectedCourseId)
                } label: {
                    Text(L10n.t(.startLearning, ui))
                        .font(.body.bold())
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(selectedCourseId == nil ? Color.gray.opacity(0.4) : Color.accentColor)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .disabled(selectedCourseId == nil)
            }
            .padding(20)
        }
    }
}
