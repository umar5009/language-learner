import SwiftUI

/// Quiz hub: knowledge quiz + end-of-week speaking interview.
struct QuizHubView: View {
    let languageId: String
    let week: CourseWeek

    @EnvironmentObject var profile: UserProfileStore
    @EnvironmentObject var progressStore: ProgressStore

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 6) {
                    Text("\(profile.text(.level)): \(week.level)")
                        .font(.subheadline.bold())
                    Text(profile.text(.endOfWeekInterview))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(profile.text(.passToUnlock))
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 4)
            }

            Section(profile.text(.quizHub)) {
                NavigationLink {
                    QuizView(languageId: languageId, week: week)
                } label: {
                    quizRow(
                        title: profile.text(.knowledgeQuiz),
                        icon: "checkmark.circle.fill",
                        skill: .quiz
                    )
                }

                NavigationLink {
                    SpeakingPracticeView(languageId: languageId, week: week)
                } label: {
                    quizRow(
                        title: profile.text(.speakingInterview),
                        icon: "mic.fill",
                        skill: .speaking
                    )
                }
            }

            Section(profile.text(.skillScores)) {
                scoreLine(skill: .quiz)
                scoreLine(skill: .speaking)
            }
        }
        .navigationTitle(profile.text(.quiz))
        .navigationBarTitleDisplayMode(.inline)
    }

    private func quizRow(title: String, icon: String, skill: SkillKind) -> some View {
        HStack {
            Label(title, systemImage: icon)
            Spacer()
            if let score = progressStore.skillScore(languageId: languageId, week: week.week, skill: skill) {
                Text("\(score)%")
                    .font(.caption.monospacedDigit().bold())
                    .foregroundStyle(score >= ProgressStore.passThreshold ? .green : .secondary)
                if score >= ProgressStore.passThreshold {
                    Image(systemName: "checkmark.circle.fill").foregroundStyle(.green)
                }
            } else {
                Text(profile.text(.notStarted))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func scoreLine(skill: SkillKind) -> some View {
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
