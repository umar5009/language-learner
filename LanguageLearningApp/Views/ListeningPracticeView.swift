import SwiftUI

/// Real listening exam: audio-only first (script hidden), then questions, then review.
struct ListeningPracticeView: View {
    let languageId: String
    let week: CourseWeek

    @EnvironmentObject var profile: UserProfileStore
    @EnvironmentObject var progressStore: ProgressStore
    @ObservedObject private var voice = VoiceCoach.shared

    private enum Stage { case listen, questions, review }

    @State private var stage: Stage = .listen
    @State private var questionIndex = 0
    @State private var answers: [Int?] = []
    @State private var playCount = 0
    @State private var showScript = false
    @State private var saved = false

    private var maxPlays: Int {
        week.resolvedMockExercises.listening.first?.resolvedPlayLimit ?? 2
    }

    private var questions: [QuizQuestion] { week.quiz }

    private var score: Int {
        zip(answers, questions).reduce(0) { partial, pair in
            let (answer, question) = pair
            return partial + ((answer == question.answerIndex) ? 1 : 0)
        }
    }

    private var percent: Int {
        questions.isEmpty ? 0 : Int((Double(score) / Double(questions.count) * 100).rounded())
    }

    var body: some View {
        VStack {
            switch stage {
            case .listen: listenView
            case .questions: questionView
            case .review: reviewView
            }
        }
        .padding()
        .navigationTitle(profile.text(.listeningExam))
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear { voice.stop() }
        .onAppear { voice.preparePlayback() }
    }

    private var listenView: some View {
        VStack(spacing: 18) {
            Image(systemName: "ear")
                .font(.system(size: 64))
                .foregroundStyle(Color.accentColor)
                .symbolEffect(.pulse, isActive: voice.isSpeaking)

            Text(profile.text(.examMode)).font(.title3.bold())
            Text(profile.text(.listeningOnlyHint))
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Label(profile.text(.hideScript), systemImage: "eye.slash")
                .font(.caption)
                .foregroundStyle(.secondary)

            Text("\(profile.text(.playAIVoice)): \(playCount)/\(maxPlays)")
                .font(.caption.monospacedDigit())
                .foregroundStyle(.secondary)

            Button {
                guard playCount < maxPlays, !voice.isSpeaking else { return }
                playCount += 1
                let lines = week.dialogue.map { $0.line }
                voice.speakLines(lines, courseId: languageId)
            } label: {
                Label(
                    voice.isSpeaking ? profile.text(.aiSpeaking) : profile.text(.playAIVoice),
                    systemImage: voice.isSpeaking ? "speaker.wave.2.fill" : "play.fill"
                )
                .font(.body.bold())
                .frame(maxWidth: .infinity)
                .padding()
                .background(playCount >= maxPlays && !voice.isSpeaking ? Color.gray.opacity(0.35) : Color.accentColor)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .disabled(playCount >= maxPlays && !voice.isSpeaking)

            if voice.isSpeaking {
                Button(profile.text(.stop)) { voice.stop() }
            }

            Spacer()

            Button {
                voice.stop()
                answers = Array(repeating: nil, count: questions.count)
                questionIndex = 0
                stage = .questions
            } label: {
                Text(profile.text(.listenAndAnswer))
                    .font(.body.bold())
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(playCount == 0 ? Color.gray.opacity(0.35) : Color.gray.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .disabled(playCount == 0)
        }
    }

    private var questionView: some View {
        let question = questions[questionIndex]
        return VStack(alignment: .leading, spacing: 14) {
            Text("\(profile.text(.question)) \(questionIndex + 1)/\(questions.count)")
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(question.question)
                .font(.title3.bold())

            ForEach(Array(question.options.enumerated()), id: \.offset) { index, option in
                Button {
                    answers[questionIndex] = index
                } label: {
                    HStack {
                        Text(option)
                        Spacer()
                        if answers[questionIndex] == index {
                            Image(systemName: "checkmark.circle.fill").foregroundStyle(Color.accentColor)
                        }
                    }
                    .padding()
                    .background(answers[questionIndex] == index ? Color.accentColor.opacity(0.15) : Color.gray.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .foregroundStyle(.primary)
            }

            Spacer()

            Button {
                if questionIndex + 1 < questions.count {
                    questionIndex += 1
                } else {
                    stage = .review
                }
            } label: {
                Text(questionIndex + 1 < questions.count ? profile.text(.nextQuestion) : profile.text(.submitExam))
                    .font(.body.bold())
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(answers[questionIndex] == nil ? Color.gray.opacity(0.4) : Color.accentColor)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .disabled(answers[questionIndex] == nil)
        }
    }

    private var reviewView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    VStack(alignment: .leading) {
                        Text(profile.text(.results)).font(.title2.bold())
                        Text("\(profile.text(.youScored)) \(score)/\(questions.count) (\(percent)%)")
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Text("\(percent)%")
                        .font(.largeTitle.bold().monospacedDigit())
                        .foregroundStyle(percent >= ProgressStore.passThreshold ? .green : .orange)
                }

                DisclosureGroup(isExpanded: $showScript) {
                    ForEach(Array(week.dialogue.enumerated()), id: \.offset) { _, line in
                        VStack(alignment: .leading, spacing: 2) {
                            Text(line.speaker).font(.caption.bold()).foregroundStyle(.secondary)
                            Text(line.line)
                        }
                        .padding(.vertical, 2)
                    }
                } label: {
                    Text(profile.text(.showScriptAfter)).font(.subheadline.bold())
                }

                Text(profile.text(.reviewAnswers)).font(.headline)

                ForEach(Array(questions.enumerated()), id: \.offset) { idx, question in
                    let selected = answers[idx]
                    let correct = selected == question.answerIndex
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text("\(profile.text(.question)) \(idx + 1)").font(.subheadline.bold())
                            Spacer()
                            Image(systemName: correct ? "checkmark.circle.fill" : "xmark.circle.fill")
                                .foregroundStyle(correct ? .green : .red)
                        }
                        Text(question.question)
                        if let selected {
                            Text("\(profile.text(.yourAnswer)): \(question.options[selected])")
                                .font(.caption)
                                .foregroundStyle(correct ? .green : .red)
                        }
                        if !correct {
                            Text("\(profile.text(.correct)): \(question.options[question.answerIndex])")
                                .font(.caption)
                                .foregroundStyle(Color.accentColor)
                        }
                        Text(question.explanation).font(.caption).foregroundStyle(.secondary)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }

                Button {
                    progressStore.recordSkillScore(
                        languageId: languageId,
                        week: week.week,
                        skill: .listening,
                        percent: percent
                    )
                    saved = true
                } label: {
                    Text(saved ? profile.text(.done) : profile.text(.saveScore))
                        .font(.body.bold())
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .disabled(saved)
            }
        }
    }
}
