import SwiftUI

struct ReadingPracticeView: View {
    let languageId: String
    let week: CourseWeek

    @EnvironmentObject var profile: UserProfileStore
    @EnvironmentObject var progressStore: ProgressStore

    @State private var lineIndex = 0
    @State private var draft = ""
    @State private var report: GrammarReport?
    @State private var scores: [Int] = []
    @State private var showTranslation = false
    @State private var finished = false

    /// Prefer the week's study-pack article (sentence by sentence); fall back to dialogue.
    private var articleLines: [DialogueLine] {
        let body = week.resolvedStudyPack.readingPassage.body
            .trimmingCharacters(in: .whitespacesAndNewlines)
        if !body.isEmpty {
            let parts = body
                .components(separatedBy: CharacterSet(charactersIn: ".!?。！？"))
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { $0.count > 8 }
            if parts.count >= 2 {
                return parts.map { DialogueLine(speaker: "Article", line: $0 + ".", translation: $0 + ".") }
            }
            return [DialogueLine(speaker: "Article", line: body, translation: body)]
        }
        return week.dialogue
    }

    private var languageCode: String {
        GrammarCoach.languageCode(forCourseId: languageId)
    }

    var body: some View {
        Group {
            if finished {
                resultsView
            } else if articleLines.isEmpty {
                ContentUnavailableView(profile.text(.contentError), systemImage: "book.closed")
            } else {
                practiceView
            }
        }
        .padding()
        .navigationTitle(profile.text(.reading))
        .navigationBarTitleDisplayMode(.inline)
    }

    private var practiceView: some View {
        let line = articleLines[lineIndex]
        return ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(profile.text(.articleReady))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                VStack(alignment: .leading, spacing: 8) {
                    Text(profile.text(.readingArticle))
                        .font(.caption.bold())
                        .foregroundStyle(.secondary)
                    ForEach(Array(articleLines.enumerated()), id: \.offset) { idx, item in
                        Text(item.line)
                            .font(idx == lineIndex ? .body.bold() : .body)
                            .foregroundStyle(idx == lineIndex ? .primary : .secondary)
                            .padding(.vertical, 2)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))

                Text("\(profile.text(.typeAsYouRead)) (\(lineIndex + 1)/\(articleLines.count))")
                    .font(.headline)

                Text(profile.text(.rewriteSentence))
                    .font(.caption)
                    .foregroundStyle(.secondary)

                TextField(line.line, text: $draft, axis: .vertical)
                    .lineLimit(3...6)
                    .padding()
                    .background(Color.gray.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .onChange(of: draft) { _, newValue in
                        // Live light correction while typing (debounced by length checks in UI).
                        if newValue.count >= 3 {
                            report = GrammarCoach.analyze(
                                text: newValue,
                                expected: line.line,
                                languageCode: languageCode,
                                weekGrammarTitle: week.grammar.title
                            )
                        }
                    }

                if line.speaker != "Article" {
                    Button {
                        showTranslation.toggle()
                    } label: {
                        Text(showTranslation ? profile.text(.hideTranslation) : profile.text(.showTranslation))
                            .font(.caption)
                    }
                    if showTranslation {
                        Text(line.translation)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                if let report {
                    correctionsBox(report)
                }

                HStack {
                    Button(profile.text(.checkGrammar)) {
                        report = GrammarCoach.analyze(
                            text: draft,
                            expected: line.line,
                            languageCode: languageCode,
                            weekGrammarTitle: week.grammar.title
                        )
                    }
                    .buttonStyle(.bordered)

                    Spacer()

                    Button(lineIndex + 1 < articleLines.count ? profile.text(.next) : profile.text(.finish)) {
                        let score = report?.scorePercent
                            ?? GrammarCoach.analyze(
                                text: draft,
                                expected: line.line,
                                languageCode: languageCode,
                                weekGrammarTitle: nil
                            ).scorePercent
                        scores.append(score)
                        if lineIndex + 1 < articleLines.count {
                            lineIndex += 1
                            draft = ""
                            report = nil
                            showTranslation = false
                        } else {
                            finished = true
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }

    private func correctionsBox(_ report: GrammarReport) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(profile.text(.corrections)).font(.headline)
            if report.issues.isEmpty {
                Text(profile.text(.noIssues))
                    .foregroundStyle(.green)
            } else {
                ForEach(report.issues) { issue in
                    VStack(alignment: .leading, spacing: 2) {
                        Text(issue.message).font(.subheadline)
                        if let suggestion = issue.suggestion {
                            Text("→ \(suggestion)")
                                .font(.caption)
                                .foregroundStyle(Color.accentColor)
                        }
                    }
                }
            }
            Text("\(profile.text(.score)): \(report.scorePercent)%")
                .font(.caption.bold())
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.orange.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var resultsView: some View {
        let avg = scores.isEmpty ? 0 : Int((Double(scores.reduce(0, +)) / Double(scores.count)).rounded())
        return VStack(spacing: 20) {
            Spacer()
            Text(profile.text(.results)).font(.title.bold())
            Text("\(profile.text(.youScored)) \(avg)%").font(.title3)
            Spacer()
            Button {
                progressStore.recordSkillScore(languageId: languageId, week: week.week, skill: .reading, percent: avg)
            } label: {
                Text(profile.text(.saveScore))
                    .font(.body.bold())
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }
}
