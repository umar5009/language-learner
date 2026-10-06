import SwiftUI

/// Official level exam after ~2 weeks of prep → real-style scorecard (IELTS bands / CEFR).
struct LevelExamView: View {
    let languageId: String
    let course: LanguageCourse
    let exam: LevelExam

    @EnvironmentObject var profile: UserProfileStore
    @EnvironmentObject var progressStore: ProgressStore
    @ObservedObject private var voice = VoiceCoach.shared
    @StateObject private var speech = SpeechPracticeEngine()

    private enum Stage: Int {
        case intro, listening, speaking, reading, writing, report
    }

    @State private var stage: Stage = .intro
    @State private var listenAnswers: [Int?] = []
    @State private var listenPlays = 0
    @State private var speakingIndex = 0
    @State private var speakingScores: [Int] = []
    @State private var readAnswers: [Int?] = []
    @State private var writingDraft = ""
    @State private var writingPercent = 0
    @State private var result: OfficialExamResult?
    @State private var permissionDenied = false
    @State private var speakPrepRemaining = 0
    @State private var speakLimitRemaining = 0
    @State private var inSpeakPrep = false
    @State private var writingRemaining = 0
    @State private var writingTimerOn = false

    var body: some View {
        Group {
            switch stage {
            case .intro: introView
            case .listening: listeningView
            case .speaking: speakingView
            case .reading: readingView
            case .writing: writingView
            case .report:
                if let result {
                    OfficialScorecardView(result: result, courseName: course.name)
                }
            }
        }
        .padding()
        .navigationTitle(exam.title)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            speech.configure(courseId: languageId)
            voice.preparePlayback()
        }
        .onDisappear { voice.stop(); speech.stop() }
        .alert(profile.text(.permissionNeeded), isPresented: $permissionDenied) {
            Button(profile.text(.done), role: .cancel) {}
        } message: { Text(profile.text(.micPermission)) }
    }

    private var introView: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(profile.text(.officialLevelExam)).font(.title2.bold())
            Text(exam.description).font(.subheadline).foregroundStyle(.secondary)
            Text("\(profile.text(.level)): \(exam.level)").font(.headline)
            if let name = course.examFramework?.testName {
                Text(name).font(.caption.weight(.semibold))
            }
            Text(examPaperSummary).font(.caption).foregroundStyle(.secondary)
            if let rule = course.examFramework?.passRule {
                Text(rule).font(.caption2).foregroundStyle(.secondary)
            }
            Label("\(profile.text(.week)) \(exam.requiredWeeks.map(String.init).joined(separator: " + "))", systemImage: "calendar")
                .font(.caption)
            Spacer()
            Button(profile.text(.startOfficialExam)) {
                listenAnswers = Array(repeating: nil, count: exam.listening.questions.count)
                listenPlays = 0
                stage = .listening
            }
            .buttonStyle(.borderedProminent)
            .frame(maxWidth: .infinity)
        }
    }

    private var listeningView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(profile.text(.listening)).font(.headline)
            Text(exam.listening.instruction).font(.caption).foregroundStyle(.secondary)
            Text(profile.text(.questionsOnScreen)).font(.caption2).foregroundStyle(.secondary)
            Button {
                guard listenPlays < exam.listening.resolvedPlayLimit else { return }
                listenPlays += 1
                voice.speakLines(exam.listening.audioLines, courseId: languageId)
            } label: {
                Label("\(profile.text(.playAIVoice)) (\(listenPlays)/\(exam.listening.resolvedPlayLimit))", systemImage: "play.fill")
                    .frame(maxWidth: .infinity).padding()
                    .background(listenPlays >= exam.listening.resolvedPlayLimit ? Color.gray : Color.accentColor)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .disabled(listenPlays >= exam.listening.resolvedPlayLimit && !voice.isSpeaking)
            ScrollView {
                ExamQuestionList(questions: exam.listening.questions, answers: $listenAnswers)
            }
            Button(profile.text(.submitAnswers)) {
                voice.stop()
                speakingIndex = 0
                speakingScores = []
                stage = .speaking
                askSpeaking()
            }
            .buttonStyle(.borderedProminent)
            .disabled(listenPlays == 0)
        }
    }

    private var speakingView: some View {
        let item = exam.speaking[speakingIndex]
        let prep = item.resolvedPrepSeconds(courseId: languageId)
        return VStack(alignment: .leading, spacing: 12) {
            Text("\(profile.text(.speaking)) \(speakingIndex + 1)/\(exam.speaking.count)").font(.headline)
            if !exam.isOfficial(.speaking) {
                Text(profile.text(.classroomPracticeHint)).font(.caption).foregroundStyle(.secondary)
            }
            Text(item.instruction).font(.caption).foregroundStyle(.secondary)
            VStack(alignment: .leading, spacing: 8) {
                if prep > 0 { Text(profile.text(.cueCard)).font(.caption.bold()).foregroundStyle(.secondary) }
                Text(item.examinerQuestion).font(.title3.bold())
                if let bullets = item.cueBullets, !bullets.isEmpty {
                    Text(profile.text(.youShouldSay)).font(.caption).foregroundStyle(.secondary)
                    ForEach(bullets, id: \.self) { Text("• \($0)").font(.subheadline) }
                }
            }
            .padding().frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.accentColor.opacity(0.1)).clipShape(RoundedRectangle(cornerRadius: 12))

            if inSpeakPrep {
                Text(String(format: profile.text(.prepareSeconds), speakPrepRemaining))
                    .font(.title2.monospacedDigit().bold())
                Text(profile.text(.prepareNotes)).font(.caption).foregroundStyle(.secondary)
                Button(profile.text(.startSpeakingNow)) { beginSpeakingTurn() }
                    .buttonStyle(.borderedProminent)
            } else if speech.isRecording || !speech.transcript.isEmpty {
                if speakLimitRemaining > 0 {
                    Text(String(format: profile.text(.speakSecondsLeft), speakLimitRemaining))
                        .font(.caption.monospacedDigit().bold())
                }
                Text(speech.transcript.isEmpty ? profile.text(.speakNow) : speech.transcript)
                    .padding().frame(maxWidth: .infinity, minHeight: 70, alignment: .topLeading)
                    .background(Color.gray.opacity(0.1)).clipShape(RoundedRectangle(cornerRadius: 10))
            }
            if speech.isRecording {
                Button(profile.text(.imDoneSpeaking)) { finishSpeakingTurn() }
                .buttonStyle(.borderedProminent)
                .disabled(speech.transcript.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            } else if voice.isSpeaking {
                Text(profile.text(.aiSpeaking)).foregroundStyle(.secondary)
            }
            Spacer()
        }
        .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { _ in
            if inSpeakPrep, speakPrepRemaining > 0 {
                speakPrepRemaining -= 1
                if speakPrepRemaining == 0 { beginSpeakingTurn() }
            } else if speech.isRecording, speakLimitRemaining > 0 {
                speakLimitRemaining -= 1
                if speakLimitRemaining == 0 { finishSpeakingTurn() }
            }
        }
    }

    private var readingView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(profile.text(.reading)).font(.headline)
            Text(exam.reading.instruction).font(.caption).foregroundStyle(.secondary)
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    Text(exam.reading.passage).font(.body).lineSpacing(3)
                    Divider()
                    ExamQuestionList(questions: exam.reading.questions, answers: $readAnswers)
                }
            }
            Button(profile.text(.submitAnswers)) {
                writingDraft = ""
                let minutes = exam.writing.resolvedMinutes
                writingRemaining = minutes * 60
                writingTimerOn = minutes > 0
                stage = .writing
            }
            .buttonStyle(.borderedProminent)
            .disabled(readAnswers.allSatisfy { $0 == nil })
        }
    }

    private var writingView: some View {
        let words = writingDraft.split { $0.isWhitespace || $0.isNewline }.filter { !$0.isEmpty }.count
        return ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text(profile.text(.writing)).font(.headline)
                if !exam.isOfficial(.writing) {
                    Text(profile.text(.classroomPracticeHint)).font(.caption).foregroundStyle(.secondary)
                }
                Text(exam.writing.instruction).font(.caption).foregroundStyle(.secondary)
                Text(exam.writing.prompt).font(.body)
                HStack {
                    Text("\(profile.text(.words)): \(words) / \(exam.writing.minWords)+")
                        .font(.caption.monospacedDigit())
                        .foregroundStyle(words >= exam.writing.minWords ? .green : .secondary)
                    Spacer()
                    if writingTimerOn {
                        Text("\(profile.text(.timeRemaining)) \(String(format: "%d:%02d", writingRemaining / 60, writingRemaining % 60))")
                            .font(.caption.monospacedDigit().bold())
                    }
                }
                TextEditor(text: $writingDraft).frame(minHeight: 150)
                    .padding(8).background(Color.gray.opacity(0.08)).clipShape(RoundedRectangle(cornerRadius: 10))
                Button(profile.text(.submitExam)) {
                    let report = GrammarCoach.analyze(
                        text: writingDraft,
                        expected: exam.writing.modelAnswer,
                        languageCode: GrammarCoach.languageCode(forCourseId: languageId),
                        weekGrammarTitle: nil
                    )
                    writingPercent = report.scorePercent
                    finalize()
                }
                .buttonStyle(.borderedProminent)
                .disabled(words < max(10, exam.writing.minWords / 4))
            }
        }
        .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { _ in
            guard writingTimerOn, writingRemaining > 0 else { return }
            writingRemaining -= 1
        }
    }

    private func askSpeaking() {
        Task {
            let ok = await speech.requestPermissions()
            guard ok else { permissionDenied = true; return }
            speech.transcript = ""
            let item = exam.speaking[speakingIndex]
            let prep = item.resolvedPrepSeconds(courseId: languageId)
            if prep > 0 {
                inSpeakPrep = true
                speakPrepRemaining = prep
                speakLimitRemaining = item.resolvedSpeakSeconds(courseId: languageId)
                return
            }
            inSpeakPrep = false
            voice.speak(item.examinerQuestion, courseId: languageId) {
                Task { await startExamListening() }
            }
        }
    }

    private func beginSpeakingTurn() {
        inSpeakPrep = false
        speakPrepRemaining = 0
        let item = exam.speaking[speakingIndex]
        speakLimitRemaining = item.resolvedSpeakSeconds(courseId: languageId)
        voice.speak(profile.text(.startSpeakingNow), courseId: languageId) {
            Task { await startExamListening() }
        }
    }

    private func startExamListening() async {
        try? await Task.sleep(nanoseconds: 150_000_000)
        do {
            try speech.start(autoStopOnFinal: false)
        } catch {
            permissionDenied = true
        }
    }

    private func finishSpeakingTurn() {
        let item = exam.speaking[speakingIndex]
        speech.stop()
        speakLimitRemaining = 0
        let turn = InterviewEvaluator.evaluateTurn(
            question: item.examinerQuestion,
            userAnswer: speech.transcript,
            modelAnswer: item.modelAnswer,
            courseId: languageId,
            level: exam.level,
            grammarTitle: nil
        )
        speakingScores.append(turn.overall)
        if speakingIndex + 1 < exam.speaking.count {
            speakingIndex += 1
            askSpeaking()
        } else {
            readAnswers = Array(repeating: nil, count: exam.reading.questions.count)
            stage = .reading
        }
    }

    private func finalize() {
        let listening = percent(listenAnswers, exam.listening.questions)
        let speaking = speakingScores.isEmpty ? 0 : Int((Double(speakingScores.reduce(0, +)) / Double(speakingScores.count)).rounded())
        let reading = percent(readAnswers, exam.reading.questions)
        let built = ExamScoreMapper.buildResult(
            courseId: languageId,
            targetLevel: exam.level,
            listening: listening,
            speaking: speaking,
            reading: reading,
            writing: writingPercent,
            exam: exam,
            framework: course.examFramework
        )
        progressStore.saveLevelExamResult(built)
        result = built
        stage = .report
    }

    private var examPaperSummary: String {
        let official = exam.scoredSkills.map { profile.text($0.l10nKey) }.joined(separator: " · ")
        let classroom = (exam.classroomSkills ?? []).joined(separator: ", ")
        if classroom.isEmpty {
            return "\(profile.text(.officialPapers)): \(official)"
        }
        return "\(profile.text(.officialPapers)): \(official)\n\(profile.text(.classroomPractice)): \(classroom)"
    }

    private func percent(_ answers: [Int?], _ questions: [QuizQuestion]) -> Int {
        guard !questions.isEmpty else { return 0 }
        let correct = zip(answers, questions).filter { $0 == $1.answerIndex }.count
        return Int((Double(correct) / Double(questions.count) * 100).rounded())
    }
}

struct OfficialScorecardView: View {
    let result: OfficialExamResult
    let courseName: String

    @EnvironmentObject var profile: UserProfileStore

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                Text(profile.text(.officialScorecard)).font(.title.bold())
                Text(courseName).font(.subheadline).foregroundStyle(.secondary)
                Text(result.scoreSystem).font(.caption).foregroundStyle(.secondary)

                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.accentColor.opacity(0.12))
                    VStack(spacing: 6) {
                        Text(profile.text(.overallScore)).font(.caption).foregroundStyle(.secondary)
                        Text(result.overallDisplay)
                            .font(.system(size: 54, weight: .bold, design: .rounded))
                        Text("\(profile.text(.awardedLevel)): \(result.awardedLevel)")
                            .font(.title3.bold())
                        Text("\(profile.text(.targetLevel)): \(result.level)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                }
                .frame(maxWidth: .infinity)
                .frame(height: 180)

                ForEach(ExamScoreMapper.skillScores(from: result)) { skill in
                    HStack {
                        Label(profile.text(skill.skill.l10nKey), systemImage: skill.skill.icon)
                        Spacer()
                        Text(skill.displayScore)
                            .font(.title2.bold().monospacedDigit())
                            .foregroundStyle(skillAccent(skill))
                    }
                    .padding()
                    .background(Color.gray.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                Text(profile.text(.scorecardFootnote))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.bottom)
        }
    }

    private func skillAccent(_ skill: OfficialSkillScore) -> Color {
        let text = skill.displayScore.lowercased()
        if text.contains("—") || text.contains("not on") || text.contains("no writing") {
            return .secondary
        }
        return skill.percent >= 60 ? .green : .primary
    }
}
