import SwiftUI

/// Realtime AI speaking interview: examiner speaks → user answers aloud → AI evaluates report.
struct SpeakingPracticeView: View {
    let languageId: String
    let week: CourseWeek
    var course: LanguageCourse?

    @EnvironmentObject var profile: UserProfileStore
    @EnvironmentObject var progressStore: ProgressStore
    @EnvironmentObject var dataStore: LanguageDataStore
    @ObservedObject private var voice = VoiceCoach.shared
    @StateObject private var speech = SpeechPracticeEngine()

    private enum Phase {
        case intro
        case aiAsking
        case userSpeaking
        case bridging
        case report
    }

    @State private var phase: Phase = .intro
    @State private var index = 0
    @State private var turns: [InterviewTurnResult] = []
    @State private var report: InterviewReport?
    @State private var permissionDenied = false
    @State private var levelJustPassed = false
    @State private var saved = false
    @State private var liveTranscript = ""

    private var prompts: [SpeakingInterviewPrompt] {
        week.interviewPrompts
    }

    private var resolvedCourse: LanguageCourse? {
        course ?? dataStore.course(for: languageId)
    }

    var body: some View {
        Group {
            if prompts.isEmpty {
                ContentUnavailableView(profile.text(.contentError), systemImage: "mic.slash")
            } else if phase == .report, let report {
                reportView(report)
            } else {
                liveInterviewView
            }
        }
        .padding()
        .navigationTitle(profile.text(.realtimeInterview))
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            speech.configure(courseId: languageId)
            voice.preparePlayback()
        }
        .onDisappear {
            voice.stop()
            speech.stop()
        }
        .onChange(of: speech.transcript) { _, newValue in
            liveTranscript = newValue
        }
        .alert(profile.text(.permissionNeeded), isPresented: $permissionDenied) {
            Button(profile.text(.done), role: .cancel) {}
        } message: {
            Text(profile.text(.micPermission))
        }
    }

    private var liveInterviewView: some View {
        VStack(spacing: 18) {
            HStack {
                Text("\(profile.text(.level)): \(week.level)")
                    .font(.caption.bold())
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.accentColor.opacity(0.15))
                    .clipShape(Capsule())
                Spacer()
                if phase != .intro {
                    Text("\(profile.text(.question)) \(min(index + 1, prompts.count))/\(prompts.count)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            statusBanner

            Spacer(minLength: 8)

            ZStack {
                Circle()
                    .fill(Color.accentColor.opacity(phase == .userSpeaking ? 0.18 : 0.08))
                    .frame(width: 160, height: 160)
                Image(systemName: phaseIcon)
                    .font(.system(size: 56))
                    .foregroundStyle(phase == .userSpeaking ? .red : Color.accentColor)
                    .symbolEffect(.variableColor.iterative, isActive: voice.isSpeaking || speech.isRecording)
            }

            if phase == .intro {
                Text(profile.text(.realtimeInterviewHint))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                Button {
                    Task { await beginInterview() }
                } label: {
                    Text(profile.text(.startRealtimeInterview))
                        .font(.body.bold())
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
            } else {
                VStack(alignment: .leading, spacing: 10) {
                    Label(profile.text(.aiTutorPrompt), systemImage: "person.wave.2.fill")
                        .font(.caption.bold())
                        .foregroundStyle(.secondary)
                    Text(currentQuestionText)
                        .font(.title3.bold())
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.accentColor.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 14))

                if phase == .userSpeaking {
                    VStack(spacing: 8) {
                        Text(profile.text(.listeningToYou))
                            .font(.subheadline.bold())
                        Text(liveTranscript.isEmpty ? profile.text(.speakNow) : liveTranscript)
                            .font(.body)
                            .foregroundStyle(liveTranscript.isEmpty ? .secondary : .primary)
                            .frame(maxWidth: .infinity, minHeight: 72, alignment: .topLeading)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 12))

                        Button {
                            Task { await finishUserAnswer() }
                        } label: {
                            Label(profile.text(.imDoneSpeaking), systemImage: "checkmark.circle.fill")
                                .font(.body.bold())
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(liveTranscript.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color.gray.opacity(0.35) : Color.accentColor)
                                .foregroundStyle(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .disabled(liveTranscript.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                } else if phase == .aiAsking || phase == .bridging {
                    Text(voice.isSpeaking ? profile.text(.aiSpeaking) : profile.text(.pleaseWait))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()
        }
    }

    private var statusBanner: some View {
        Text(statusText)
            .font(.headline)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var statusText: String {
        switch phase {
        case .intro: return profile.text(.endOfWeekInterview)
        case .aiAsking: return profile.text(.aiAsking)
        case .userSpeaking: return profile.text(.yourTurnToSpeak)
        case .bridging: return profile.text(.aiEvaluating)
        case .report: return profile.text(.evaluationReport)
        }
    }

    private var phaseIcon: String {
        switch phase {
        case .intro: return "waveform.circle.fill"
        case .aiAsking, .bridging: return "person.wave.2.fill"
        case .userSpeaking: return "mic.circle.fill"
        case .report: return "doc.text.magnifyingglass"
        }
    }

    private var currentQuestionText: String {
        guard index < prompts.count else { return "" }
        return prompts[index].examinerQuestion
    }

    private func beginInterview() async {
        let ok = await speech.requestPermissions()
        guard ok else {
            permissionDenied = true
            return
        }
        turns = []
        index = 0
        phase = .aiAsking
        let intro = InterviewEvaluator.introPhrase(courseId: languageId, level: week.level)
        voice.speak(intro, courseId: languageId) {
            askCurrentQuestion()
        }
    }

    private func askCurrentQuestion() {
        guard index < prompts.count else {
            finalizeReport()
            return
        }
        phase = .aiAsking
        liveTranscript = ""
        speech.transcript = ""
        let question = prompts[index].examinerQuestion
        voice.speak(question, courseId: languageId) {
            Task { await startListeningForAnswer() }
        }
    }

    private func startListeningForAnswer() async {
        phase = .userSpeaking
        try? await Task.sleep(nanoseconds: 150_000_000)
        do {
            try speech.start(autoStopOnFinal: false)
        } catch {
            permissionDenied = true
        }
    }

    private func finishUserAnswer() async {
        speech.stop()
        let prompt = prompts[index]
        let answer = speech.transcript
        let turn = InterviewEvaluator.evaluateTurn(
            question: prompt.examinerQuestion,
            userAnswer: answer,
            modelAnswer: prompt.modelAnswer,
            courseId: languageId,
            level: week.level,
            grammarTitle: week.grammar.title
        )
        turns.append(turn)

        let isLast = index + 1 >= prompts.count
        phase = .bridging
        let bridge = InterviewEvaluator.bridgePhrase(courseId: languageId, isLast: isLast)
        voice.speak(bridge, courseId: languageId) {
            if isLast {
                finalizeReport()
            } else {
                index += 1
                askCurrentQuestion()
            }
        }
    }

    private func finalizeReport() {
        let built = InterviewEvaluator.buildReport(turns: turns, level: week.level)
        report = built
        phase = .report
        // Spoken summary in learning language
        let summary: String
        let lang = GrammarCoach.languageCode(forCourseId: languageId)
        if lang == "es" {
            summary = built.passed
                ? "Tu puntuación es \(built.overallPercent) por ciento. Nivel aprobado."
                : "Tu puntuación es \(built.overallPercent) por ciento. Sigue practicando."
        } else {
            summary = built.passed
                ? "Your overall score is \(built.overallPercent) percent. Level speaking passed."
                : "Your overall score is \(built.overallPercent) percent. Keep practicing."
        }
        voice.speak(summary, courseId: languageId == "ielts_english" ? languageId : "ielts_english")
    }

    private func reportView(_ report: InterviewReport) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(profile.text(.evaluationReport)).font(.title2.bold())
                        Text("\(profile.text(.level)): \(report.level)")
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Text("\(report.overallPercent)%")
                        .font(.largeTitle.bold().monospacedDigit())
                        .foregroundStyle(report.passed ? .green : .orange)
                }

                Label(
                    report.passed ? profile.text(.levelPassed) : profile.text(.keepPracticing),
                    systemImage: report.passed ? "checkmark.seal.fill" : "exclamationmark.triangle.fill"
                )
                .foregroundStyle(report.passed ? .green : .orange)

                if levelJustPassed {
                    Text(profile.text(.speakingPassHint))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                criteriaGrid(report)

                if !report.strengths.isEmpty {
                    sectionTitle(profile.text(.strengths))
                    ForEach(report.strengths, id: \.self) { item in
                        Label(item, systemImage: "plus.circle.fill").foregroundStyle(.green)
                    }
                }

                if !report.improvements.isEmpty {
                    sectionTitle(profile.text(.improvements))
                    ForEach(report.improvements, id: \.self) { item in
                        Label(item, systemImage: "arrow.up.circle.fill").foregroundStyle(.orange)
                    }
                }

                sectionTitle(profile.text(.turnByTurn))
                ForEach(Array(report.turns.enumerated()), id: \.element.id) { idx, turn in
                    turnCard(index: idx + 1, turn: turn)
                }

                Button {
                    saveReport(report)
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

                Button {
                    restartInterview()
                } label: {
                    Text(profile.text(.tryAgain))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray.opacity(0.15))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
        }
    }

    private func criteriaGrid(_ report: InterviewReport) -> some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
            metric(profile.text(.relevance), report.relevanceAvg)
            metric(profile.text(.fluency), report.fluencyAvg)
            metric(profile.text(.grammar), report.grammarAvg)
            metric(profile.text(.vocabulary), report.vocabularyAvg)
        }
    }

    private func metric(_ title: String, _ value: Int) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title).font(.caption).foregroundStyle(.secondary)
            Text("\(value)%").font(.title3.bold().monospacedDigit())
            ProgressView(value: Double(value), total: 100)
                .tint(value >= ProgressStore.passThreshold ? .green : .orange)
        }
        .padding(10)
        .background(Color.gray.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private func turnCard(index: Int, turn: InterviewTurnResult) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("\(profile.text(.question)) \(index)")
                    .font(.subheadline.bold())
                Spacer()
                Text("\(turn.overall)%")
                    .font(.subheadline.monospacedDigit().bold())
                    .foregroundStyle(turn.overall >= ProgressStore.passThreshold ? .green : .orange)
            }
            Text(turn.question).font(.caption).foregroundStyle(.secondary)
            Text(profile.text(.yourSpeech)).font(.caption.bold())
            Text(turn.userAnswer).font(.body)
            Text(turn.feedback).font(.caption).foregroundStyle(.secondary)

            if !turn.corrections.isEmpty {
                Text(profile.text(.corrections)).font(.caption.bold())
                ForEach(turn.corrections) { issue in
                    VStack(alignment: .leading, spacing: 2) {
                        Text("• \(issue.message)").font(.caption)
                        if let suggestion = issue.suggestion {
                            Text("→ \(suggestion)")
                                .font(.caption)
                                .foregroundStyle(Color.accentColor)
                        }
                    }
                }
            }

            Text(profile.text(.improvedAnswer)).font(.caption.bold())
            Text(turn.improvedAnswer)
                .font(.body)
                .padding(8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.green.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 8))

            Button {
                voice.speak(turn.improvedAnswer, courseId: languageId)
            } label: {
                Label(profile.text(.hearCorrection), systemImage: "speaker.wave.2.fill")
                    .font(.caption)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func sectionTitle(_ text: String) -> some View {
        Text(text).font(.headline).padding(.top, 4)
    }

    private func saveReport(_ report: InterviewReport) {
        let before: Bool
        if let resolvedCourse {
            before = progressStore.isLevelPassed(languageId: languageId, level: week.level)
        } else {
            before = false
        }
        progressStore.recordSkillScore(
            languageId: languageId,
            week: week.week,
            skill: .speaking,
            percent: report.overallPercent,
            course: resolvedCourse
        )
        if let resolvedCourse {
            let after = progressStore.isLevelPassed(languageId: languageId, level: week.level)
            levelJustPassed = !before && after
        }
        saved = true
    }

    private func restartInterview() {
        voice.stop()
        speech.stop()
        index = 0
        turns = []
        report = nil
        saved = false
        levelJustPassed = false
        liveTranscript = ""
        phase = .intro
    }
}
