import SwiftUI

struct WritingPracticeView: View {
    let languageId: String
    let week: CourseWeek

    @EnvironmentObject var profile: UserProfileStore
    @EnvironmentObject var progressStore: ProgressStore

    @State private var draft = ""
    @State private var report: GrammarReport?
    @State private var saved = false

    private var languageCode: String {
        GrammarCoach.languageCode(forCourseId: languageId)
    }

    private var prompt: String {
        // Target-language writing task grounded in the week's theme.
        let vocab = week.vocabulary.prefix(3).map(\.word).joined(separator: ", ")
        return "\(week.title). \(week.focus). Use: \(vocab)."
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(profile.text(.writingPrompt))
                        .font(.caption.bold())
                        .foregroundStyle(.secondary)
                    Text(prompt)
                        .font(.body)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.accentColor.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))

                Text(profile.text(.writeHere))
                    .font(.headline)

                TextEditor(text: $draft)
                    .frame(minHeight: 180)
                    .padding(8)
                    .background(Color.gray.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .onChange(of: draft) { _, newValue in
                        guard newValue.count > 8 else { return }
                        report = GrammarCoach.analyze(
                            text: newValue,
                            expected: nil,
                            languageCode: languageCode,
                            weekGrammarTitle: week.grammar.title
                        )
                    }

                Button {
                    report = GrammarCoach.analyze(
                        text: draft,
                        expected: nil,
                        languageCode: languageCode,
                        weekGrammarTitle: week.grammar.title
                    )
                } label: {
                    Label(profile.text(.checkWriting), systemImage: "text.badge.checkmark")
                        .font(.body.bold())
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .disabled(draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)

                if let report {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(profile.text(.corrections)).font(.headline)

                        let spelling = report.issues.filter { $0.kind == .spelling }
                        let grammar = report.issues.filter { $0.kind != .spelling }

                        if report.issues.isEmpty {
                            Text(profile.text(.noIssues)).foregroundStyle(.green)
                        }

                        if !spelling.isEmpty {
                            Text(profile.text(.spellingIssues)).font(.subheadline.bold())
                            ForEach(spelling) { issue in
                                issueRow(issue)
                            }
                        }

                        if !grammar.isEmpty {
                            Text(profile.text(.grammarTips)).font(.subheadline.bold())
                            ForEach(grammar) { issue in
                                issueRow(issue)
                            }
                        }

                        Text("\(profile.text(.words)): \(wordCount) · \(profile.text(.sentences)): \(sentenceCount)")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        Text("\(profile.text(.score)): \(report.scorePercent)%")
                            .font(.title3.bold())

                        Button {
                            progressStore.recordSkillScore(
                                languageId: languageId,
                                week: week.week,
                                skill: .writing,
                                percent: report.scorePercent
                            )
                            saved = true
                        } label: {
                            Text(saved ? profile.text(.done) : profile.text(.saveScore))
                                .font(.body.bold())
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.gray.opacity(0.15))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                    .padding()
                    .background(Color.orange.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            .padding()
        }
        .navigationTitle(profile.text(.writing))
        .navigationBarTitleDisplayMode(.inline)
    }

    private func issueRow(_ issue: GrammarIssue) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(issue.message).font(.subheadline)
            if let suggestion = issue.suggestion {
                Text("→ \(suggestion)")
                    .font(.caption)
                    .foregroundStyle(Color.accentColor)
            }
        }
    }

    private var wordCount: Int {
        draft.split { $0.isWhitespace || $0.isNewline }.filter { !$0.isEmpty }.count
    }

    private var sentenceCount: Int {
        let parts = draft.components(separatedBy: CharacterSet(charactersIn: ".!?。！？"))
        return max(parts.filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }.count, draft.isEmpty ? 0 : 1)
    }
}
