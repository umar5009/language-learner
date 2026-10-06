import SwiftUI

struct WeekDetailView: View {
    let languageId: String
    let week: CourseWeek

    @EnvironmentObject var profile: UserProfileStore
    @EnvironmentObject var progressStore: ProgressStore

    var body: some View {
        List {
            Section(profile.text(.overview)) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(week.title).font(.headline)
                    HStack {
                        Text("\(profile.text(.level)): \(week.level)")
                        if progressStore.didPassSpeaking(languageId: languageId, week: week.week) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                        }
                    }
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    Text(week.focus).font(.subheadline)
                    if let avg = progressStore.weekAverage(languageId: languageId, week: week.week) {
                        Text("\(profile.text(.averageScore)): \(avg)%")
                            .font(.caption.bold())
                            .foregroundStyle(Color.accentColor)
                    }
                }
                .padding(.vertical, 2)
            }

            Section(profile.text(.skills)) {
                skillLink(.study, icon: "books.vertical.fill", destination: AnyView(
                    StudyMaterialsView(languageId: languageId, week: week)
                ))
                skillLink(.listening, icon: SkillKind.listening.icon, destination: AnyView(
                    ListeningPracticeView(languageId: languageId, week: week)
                ), skill: .listening)
                skillLink(.reading, icon: SkillKind.reading.icon, destination: AnyView(
                    ReadingPracticeView(languageId: languageId, week: week)
                ), skill: .reading)
                skillLink(.writing, icon: SkillKind.writing.icon, destination: AnyView(
                    WritingPracticeView(languageId: languageId, week: week)
                ), skill: .writing)
            }

            Section(profile.text(.quiz)) {
                NavigationLink {
                    QuizHubView(languageId: languageId, week: week)
                } label: {
                    HStack {
                        Label(profile.text(.quizHub), systemImage: "list.clipboard.fill")
                        Spacer()
                        quizStatusBadge
                    }
                }

                NavigationLink {
                    SpeakingPracticeView(languageId: languageId, week: week)
                } label: {
                    HStack {
                        Label(profile.text(.speakingInterview), systemImage: "mic.fill")
                        Spacer()
                        if let score = progressStore.skillScore(languageId: languageId, week: week.week, skill: .speaking) {
                            Text("\(score)%")
                                .font(.caption.monospacedDigit())
                                .foregroundStyle(score >= ProgressStore.passThreshold ? .green : .secondary)
                            if score >= ProgressStore.passThreshold {
                                Image(systemName: "checkmark.circle.fill").foregroundStyle(.green)
                            }
                        }
                    }
                }
            }

            Section(profile.text(.skillScores)) {
                ForEach(SkillKind.allCases, id: \.self) { skill in
                    HStack {
                        Label(profile.text(skill.l10nKey), systemImage: skill.icon)
                        Spacer()
                        if let score = progressStore.skillScore(languageId: languageId, week: week.week, skill: skill) {
                            Text("\(score)%")
                                .font(.body.monospacedDigit().bold())
                                .foregroundStyle(score >= ProgressStore.passThreshold ? .green : .primary)
                        } else {
                            Text("—").foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
        .navigationTitle("\(profile.text(.week)) \(week.week)")
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private var quizStatusBadge: some View {
        let quiz = progressStore.skillScore(languageId: languageId, week: week.week, skill: .quiz)
        let speaking = progressStore.skillScore(languageId: languageId, week: week.week, skill: .speaking)
        if let quiz, let speaking {
            Text("\(max(quiz, speaking))%")
                .font(.caption.monospacedDigit())
                .foregroundStyle(.secondary)
        }
    }

    private func skillLink(_ key: L10n.Key, icon: String, destination: AnyView, skill: SkillKind? = nil) -> some View {
        NavigationLink {
            destination
        } label: {
            HStack {
                Label(profile.text(key), systemImage: icon)
                Spacer()
                if let skill, let score = progressStore.skillScore(languageId: languageId, week: week.week, skill: skill) {
                    Text("\(score)%")
                        .font(.caption.monospacedDigit())
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}
