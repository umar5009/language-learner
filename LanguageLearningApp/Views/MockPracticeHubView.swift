import SwiftUI

struct MockPracticeHubView: View {
    let languageId: String
    let week: CourseWeek

    @EnvironmentObject var profile: UserProfileStore
    @EnvironmentObject var progressStore: ProgressStore

    private var mocks: MockExerciseSet { week.resolvedMockExercises }

    var body: some View {
        List {
            Section {
                Text(profile.text(.mockPracticeIntro))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                if week.level.contains("N5") || week.level.contains("N4") || week.level.contains("N3")
                    || week.level.contains("N2") || week.level.contains("N1") {
                    Text(profile.text(.jlptSkillsNote))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                if week.level.contains("TOPIK 1") || week.level.contains("TOPIK 2") {
                    Text(profile.text(.topikIWritingNote))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Section(profile.text(.listening)) {
                ForEach(mocks.listening) { ex in
                    NavigationLink {
                        ListeningExerciseView(languageId: languageId, week: week.week, exercise: ex)
                    } label: {
                        exerciseRow(ex.title, id: ex.id, icon: "ear")
                    }
                }
            }

            Section(profile.text(.speaking)) {
                ForEach(mocks.speaking) { ex in
                    NavigationLink {
                        SpeakingExerciseView(languageId: languageId, weekNumber: week.week, level: week.level, exercise: ex)
                    } label: {
                        exerciseRow(ex.title, id: ex.id, icon: "mic.fill")
                    }
                }
            }

            Section(profile.text(.reading)) {
                ForEach(mocks.reading) { ex in
                    NavigationLink {
                        ReadingExerciseView(languageId: languageId, week: week.week, exercise: ex)
                    } label: {
                        exerciseRow(ex.title, id: ex.id, icon: "book.fill")
                    }
                }
            }

            Section(profile.text(.writing)) {
                ForEach(mocks.writing) { ex in
                    NavigationLink {
                        WritingExerciseView(
                            languageId: languageId,
                            week: week.week,
                            level: week.level,
                            grammarTitle: week.grammar.title,
                            exercise: ex
                        )
                    } label: {
                        exerciseRow(ex.title, id: ex.id, icon: "pencil.line")
                    }
                }
            }
        }
        .navigationTitle(profile.text(.mockExercises))
        .navigationBarTitleDisplayMode(.inline)
    }

    private func exerciseRow(_ title: String, id: String, icon: String) -> some View {
        HStack {
            Label(title, systemImage: icon)
            Spacer()
            if let score = progressStore.exerciseScore(languageId: languageId, week: week.week, exerciseId: id) {
                Text("\(score)%")
                    .font(.caption.monospacedDigit().bold())
                    .foregroundStyle(score >= ProgressStore.passThreshold ? .green : .secondary)
            } else {
                Text(profile.text(.notStarted))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
