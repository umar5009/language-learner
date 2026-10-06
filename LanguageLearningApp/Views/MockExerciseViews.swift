import SwiftUI

// MARK: - Listening exercise (questions stay on screen while audio plays)

struct ListeningExerciseView: View {
    let languageId: String
    let week: Int
    let exercise: ListeningExercise

    @EnvironmentObject var profile: UserProfileStore
    @EnvironmentObject var progressStore: ProgressStore
    @ObservedObject private var voice = VoiceCoach.shared

    @State private var answers: [Int?] = []
    @State private var plays = 0
    @State private var saved = false
    @State private var submitted = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(exercise.instruction).font(.subheadline).foregroundStyle(.secondary)
            if !submitted {
                Button {
                    guard plays < exercise.resolvedPlayLimit else { return }
                    plays += 1
                    voice.speakLines(exercise.audioLines, courseId: languageId)
                } label: {
                    Label("\(profile.text(.playAIVoice)) (\(plays)/\(exercise.resolvedPlayLimit))", systemImage: "play.fill")
                        .font(.body.bold())
                        .frame(maxWidth: .infinity).padding()
                        .background(plays >= exercise.resolvedPlayLimit ? Color.gray : Color.accentColor)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .disabled(plays >= exercise.resolvedPlayLimit && !voice.isSpeaking)

                Text(profile.text(.questionsOnScreen))
                    .font(.caption)
                    .foregroundStyle(.secondary)

                ScrollView {
                    ExamQuestionList(questions: exercise.questions, answers: $answers)
                }

                Button(profile.text(.submitAnswers)) {
                    voice.stop()
                    submitted = true
                }
                .buttonStyle(.borderedProminent)
                .disabled(plays == 0)
            } else {
                mockResult(score: MockScoring.percent(answers, exercise.questions), saved: $saved) {
                    progressStore.recordExerciseScore(
                        languageId: languageId,
                        week: week,
                        exerciseId: exercise.id,
                        percent: MockScoring.percent(answers, exercise.questions)
                    )
                }
            }
        }
        .padding()
        .navigationTitle(exercise.title)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if answers.count != exercise.questions.count {
                answers = Array(repeating: nil, count: exercise.questions.count)
            }
            voice.preparePlayback()
        }
        .onDisappear { voice.stop() }
    }
}

// MARK: - Speaking exercise (realtime; Part 2 cue card + prep time)

struct SpeakingExerciseView: View {
    let languageId: String
    let weekNumber: Int
    let level: String
    let exercise: SpeakingExercise

    @EnvironmentObject var profile: UserProfileStore
    @EnvironmentObject var progressStore: ProgressStore
    @ObservedObject private var voice = VoiceCoach.shared
    @StateObject private var speech = SpeechPracticeEngine()

    @State private var phase = 0
    @State private var turn: InterviewTurnResult?
    @State private var permissionDenied = false
    @State private var saved = false
    @State private var remaining = 0

    private var prep: Int { exercise.resolvedPrepSeconds(courseId: languageId) }
    private var speakLimit: Int { exercise.resolvedSpeakSeconds(courseId: languageId) }
    private var hasCueCard: Bool { !(exercise.cueBullets ?? []).isEmpty || prep > 0 }

    var body: some View {
        VStack(spacing: 16) {
            Text(exercise.instruction).font(.subheadline).foregroundStyle(.secondary)
            if phase == 0 {
                cueCard
                Spacer()
                Button(hasCueCard ? profile.text(.startPrep) : profile.text(.startRealtimeInterview)) {
                    Task { await start() }
                }
                .buttonStyle(.borderedProminent)
                Spacer()
            } else if phase == 4 {
                cueCard
                Text(String(format: profile.text(.prepareSeconds), remaining))
                    .font(.title2.monospacedDigit().bold())
                Text(profile.text(.prepareNotes)).font(.caption).foregroundStyle(.secondary)
                Spacer()
                Button(profile.text(.startSpeakingNow)) {
                    beginTimedSpeaking()
                }
                .buttonStyle(.borderedProminent)
            } else if phase == 1 || phase == 2 {
                if hasCueCard { cueCard } else {
                    Text(exercise.examinerQuestion).font(.title3.bold())
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(Color.accentColor.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                if phase == 2 {
                    if speakLimit > 0 {
                        Text(String(format: profile.text(.speakSecondsLeft), remaining))
                            .font(.caption.monospacedDigit().bold())
                            .foregroundStyle(remaining <= 10 ? .orange : .secondary)
                    }
                    Text(speech.transcript.isEmpty ? profile.text(.speakNow) : speech.transcript)
                        .frame(maxWidth: .infinity, minHeight: 60, alignment: .topLeading)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    Button(profile.text(.imDoneSpeaking)) {
                        Task { await finish() }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(speech.transcript.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                } else {
                    Text(profile.text(.aiSpeaking)).foregroundStyle(.secondary)
                }
                Spacer()
            } else if let turn {
                ScrollView {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("\(profile.text(.score)): \(turn.overall)%").font(.title2.bold())
                        Text(turn.feedback).font(.subheadline)
                        Text(profile.text(.yourSpeech)).font(.caption.bold())
                        Text(turn.userAnswer)
                        Text(profile.text(.corrections)).font(.caption.bold())
                        ForEach(turn.corrections) { c in
                            Text("• \(c.message)").font(.caption)
                            if let s = c.suggestion {
                                Text("→ \(s)").font(.caption).foregroundStyle(Color.accentColor)
                            }
                        }
                        Text(profile.text(.improvedAnswer)).font(.caption.bold())
                        Text(turn.improvedAnswer)
                        Button(saved ? profile.text(.done) : profile.text(.saveScore)) {
                            progressStore.recordExerciseScore(
                                languageId: languageId,
                                week: weekNumber,
                                exerciseId: exercise.id,
                                percent: turn.overall
                            )
                            saved = true
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(saved)
                    }
                }
            }
        }
        .padding()
        .navigationTitle(exercise.title)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            speech.configure(courseId: languageId)
            voice.preparePlayback()
        }
        .onDisappear { voice.stop(); speech.stop() }
        .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { _ in
            guard remaining > 0, phase == 4 || phase == 2 else { return }
            remaining -= 1
            if remaining == 0 {
                if phase == 4 {
                    beginTimedSpeaking()
                } else if phase == 2 {
                    Task { await finish() }
                }
            }
        }
        .alert(profile.text(.permissionNeeded), isPresented: $permissionDenied) {
            Button(profile.text(.done), role: .cancel) {}
        } message: {
            Text(profile.text(.micPermission))
        }
    }

    @ViewBuilder
    private var cueCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(profile.text(.cueCard)).font(.caption.bold()).foregroundStyle(.secondary)
            Text(exercise.examinerQuestion).font(.title3.bold())
            if let bullets = exercise.cueBullets, !bullets.isEmpty {
                Text(profile.text(.youShouldSay)).font(.caption).foregroundStyle(.secondary)
                ForEach(bullets, id: \.self) { bullet in
                    Text("• \(bullet)").font(.subheadline)
                }
            }
            if let tip = exercise.tip {
                Text(tip).font(.caption).foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.accentColor.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func start() async {
        guard await speech.requestPermissions() else {
            permissionDenied = true
            return
        }
        if prep > 0 {
            remaining = prep
            phase = 4
            return
        }
        phase = 1
        voice.speak(exercise.examinerQuestion, courseId: languageId) {
            Task { await beginListening() }
        }
    }

    private func beginTimedSpeaking() {
        remaining = 0
        phase = 1
        voice.speak(profile.text(.startSpeakingNow), courseId: languageId) {
            Task { await beginListening() }
        }
    }

    private func beginListening() async {
        remaining = speakLimit
        phase = 2
        try? await Task.sleep(nanoseconds: 150_000_000)
        do {
            try speech.start(autoStopOnFinal: false)
        } catch {
            permissionDenied = true
        }
    }

    private func finish() async {
        speech.stop()
        remaining = 0
        turn = InterviewEvaluator.evaluateTurn(
            question: exercise.examinerQuestion,
            userAnswer: speech.transcript,
            modelAnswer: exercise.modelAnswer,
            courseId: languageId,
            level: level,
            grammarTitle: nil
        )
        phase = 3
    }
}

// MARK: - Reading exercise (passage stays visible — computer split-paper)

struct ReadingExerciseView: View {
    let languageId: String
    let week: Int
    let exercise: ReadingExercise

    @EnvironmentObject var profile: UserProfileStore
    @EnvironmentObject var progressStore: ProgressStore

    @State private var answers: [Int?] = []
    @State private var saved = false
    @State private var submitted = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if !submitted {
                Text(exercise.instruction).font(.caption).foregroundStyle(.secondary)
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Text(profile.text(.readingPassage)).font(.caption.bold()).foregroundStyle(.secondary)
                        Text(exercise.passage).font(.body).lineSpacing(4)
                        Divider()
                        ExamQuestionList(questions: exercise.questions, answers: $answers)
                    }
                }
                Button(profile.text(.submitAnswers)) {
                    submitted = true
                }
                .buttonStyle(.borderedProminent)
                .disabled(answers.allSatisfy { $0 == nil })
            } else {
                mockResult(score: MockScoring.percent(answers, exercise.questions), saved: $saved) {
                    progressStore.recordExerciseScore(
                        languageId: languageId,
                        week: week,
                        exerciseId: exercise.id,
                        percent: MockScoring.percent(answers, exercise.questions)
                    )
                }
            }
        }
        .padding()
        .navigationTitle(exercise.title)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if answers.count != exercise.questions.count {
                answers = Array(repeating: nil, count: exercise.questions.count)
            }
        }
    }
}

// MARK: - Writing exercise (word count + optional Task 1/2 timer)

struct WritingExerciseView: View {
    let languageId: String
    let week: Int
    let level: String
    let grammarTitle: String
    let exercise: WritingExercise

    @EnvironmentObject var profile: UserProfileStore
    @EnvironmentObject var progressStore: ProgressStore

    @State private var draft = ""
    @State private var report: GrammarReport?
    @State private var saved = false
    @State private var remaining = 0
    @State private var timerStarted = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text(exercise.instruction).font(.caption).foregroundStyle(.secondary)
                Text(exercise.prompt).font(.body.bold())
                HStack {
                    Text("\(profile.text(.words)): \(wordCount) / \(exercise.minWords)+")
                        .font(.caption.monospacedDigit())
                        .foregroundStyle(wordCount >= exercise.minWords ? .green : .secondary)
                    Spacer()
                    if exercise.resolvedMinutes > 0 {
                        Text("\(profile.text(.timeRemaining)) \(clock(remaining))")
                            .font(.caption.monospacedDigit().bold())
                            .foregroundStyle(remaining <= 60 && timerStarted ? .orange : .secondary)
                    }
                }
                TextEditor(text: $draft)
                    .frame(minHeight: 180)
                    .padding(8)
                    .background(Color.gray.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                Button(profile.text(.checkWriting)) {
                    report = GrammarCoach.analyze(
                        text: draft,
                        expected: exercise.modelAnswer,
                        languageCode: GrammarCoach.languageCode(forCourseId: languageId),
                        weekGrammarTitle: grammarTitle
                    )
                }
                .buttonStyle(.borderedProminent)
                .disabled(wordCount < max(8, exercise.minWords / 3))

                if let report {
                    Text("\(profile.text(.score)): \(report.scorePercent)%").font(.headline)
                    ForEach(report.issues) { issue in
                        Text("• \(issue.message)").font(.caption)
                        if let s = issue.suggestion {
                            Text("→ \(s)").font(.caption).foregroundStyle(Color.accentColor)
                        }
                    }
                    Text(profile.text(.modelAnswer)).font(.caption.bold())
                    Text(exercise.modelAnswer).font(.subheadline)
                    Button(saved ? profile.text(.done) : profile.text(.saveScore)) {
                        progressStore.recordExerciseScore(
                            languageId: languageId,
                            week: week,
                            exerciseId: exercise.id,
                            percent: report.scorePercent
                        )
                        saved = true
                    }
                    .buttonStyle(.bordered)
                    .disabled(saved)
                }
            }
            .padding()
        }
        .navigationTitle(exercise.title)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if !timerStarted, exercise.resolvedMinutes > 0 {
                remaining = exercise.resolvedMinutes * 60
                timerStarted = true
            }
        }
        .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { _ in
            guard timerStarted, remaining > 0 else { return }
            remaining -= 1
        }
    }

    private var wordCount: Int {
        draft.split { $0.isWhitespace || $0.isNewline }.filter { !$0.isEmpty }.count
    }

    private func clock(_ seconds: Int) -> String {
        String(format: "%d:%02d", seconds / 60, seconds % 60)
    }
}

// MARK: - Shared

enum MockScoring {
    static func percent(_ answers: [Int?], _ questions: [QuizQuestion]) -> Int {
        guard !questions.isEmpty else { return 0 }
        let correct = zip(answers, questions).filter { $0 == $1.answerIndex }.count
        return Int((Double(correct) / Double(questions.count) * 100).rounded())
    }
}

struct ExamQuestionList: View {
    let questions: [QuizQuestion]
    @Binding var answers: [Int?]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            ForEach(Array(questions.enumerated()), id: \.offset) { i, q in
                VStack(alignment: .leading, spacing: 8) {
                    Text("\(i + 1). \(q.question)")
                        .font(.subheadline.bold())
                    ForEach(Array(q.options.enumerated()), id: \.offset) { optIndex, opt in
                        Button {
                            if answers.count == questions.count {
                                answers[i] = optIndex
                            }
                        } label: {
                            HStack {
                                Text(opt).multilineTextAlignment(.leading)
                                Spacer()
                                if answers.indices.contains(i), answers[i] == optIndex {
                                    Image(systemName: "checkmark.circle.fill").foregroundStyle(Color.accentColor)
                                }
                            }
                            .padding(10)
                            .background(Color.gray.opacity(0.12))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                        .foregroundStyle(.primary)
                    }
                }
            }
        }
    }
}

@ViewBuilder
func mockResult(score: Int, saved: Binding<Bool>, onSave: @escaping () -> Void) -> some View {
    VStack(spacing: 16) {
        Spacer()
        Text("\(score)%").font(.largeTitle.bold())
        Button(saved.wrappedValue ? "Done" : "Save score") {
            onSave()
            saved.wrappedValue = true
        }
        .buttonStyle(.borderedProminent)
        .disabled(saved.wrappedValue)
        Spacer()
    }
    .frame(maxWidth: .infinity)
}
