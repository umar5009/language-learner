import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var profile: UserProfileStore
    @EnvironmentObject var dataStore: LanguageDataStore
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section(profile.text(.regionalLanguage)) {
                    ForEach(RegionalLanguage.supported) { lang in
                        Button {
                            profile.uiLanguageCode = lang.code
                        } label: {
                            HStack {
                                Text(lang.flagEmoji)
                                Text(lang.nativeName)
                                Spacer()
                                if profile.uiLanguageCode == lang.code {
                                    Image(systemName: "checkmark").foregroundStyle(Color.accentColor)
                                }
                            }
                        }
                        .foregroundStyle(.primary)
                    }
                }

                Section(profile.text(.learningLanguage)) {
                    ForEach(dataStore.manifest) { entry in
                        Button {
                            profile.changeCourse(to: entry.id)
                            dismiss()
                        } label: {
                            HStack {
                                Text(entry.flagEmoji)
                                VStack(alignment: .leading) {
                                    Text(entry.name)
                                    Text(entry.institute).font(.caption).foregroundStyle(.secondary)
                                }
                                Spacer()
                                if profile.selectedCourseId == entry.id {
                                    Image(systemName: "checkmark").foregroundStyle(Color.accentColor)
                                }
                            }
                        }
                        .foregroundStyle(.primary)
                    }
                }

                Section {
                    Button(role: .destructive) {
                        profile.resetOnboarding()
                        dismiss()
                    } label: {
                        Text(profile.text(.resetCourse))
                    }
                }
            }
            .navigationTitle(profile.text(.settings))
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(profile.text(.done)) { dismiss() }
                }
            }
        }
    }
}
