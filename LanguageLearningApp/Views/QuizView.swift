import SwiftUI

/// Timed knowledge exam: no instant feedback; full review with corrections at the end.
struct QuizView: View {
    let languageId: String
    let week: CourseWeek

    private enum Stage {
        case ready
        case exam
        case review
    }

    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var profile: UserProfileStore
    @EnvironmentObject var progressStore: ProgressStore
    @EnvironmentObject var dataStore: LanguageDataStore

    @State private var stage: Stage = .ready
    @State private var quizIndex = 0
    @State private var answers: [Int?] = []
    @State private var secondsLeft = 0
    @State private var timerRunning = false
    @State private var saved = false

    private let secondsPerQuestion = 45

    private var totalSeconds: Int {
        max(week.quiz.count * secondsPerQuestion, 60)
    }

    private var score: Int {
        zip(answers, week.quiz).reduce(0) { partial, pair in
            let (answer, question) = pair
            return partial + ((answer == question.answerIndex) ? 1 : 0)
        }
    }

    private var percent: Int {
        week.quiz.isEmpty ? 0 : Int((Double(score) / Double(week.quiz.count) * 100).rounded())
    }

    var body: some View {
        VStack {
            switch stage {
            case .ready: readyView
            case .exam: examView
            case .review: reviewView
            }
        }
        .padding()
        .navigationTitle(stage == .review ? profile.text(.reviewAnswers) : profile.text(.examMode))
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear { timerRunning = false }
    }

    private var readyView: some View {
        VStack(spacing: 18) {
            Spacer()
            Image(systemName: "list.clipboard.fill")
                .font(.system(size: 56))
                .foregroundStyle(Color.accentColor)
            Text(profile.text(.knowledgeQuiz))
                .font(.title2.bold())
            Text("\(week.quiz.count) \(profile.text(.question).lowercased()) · \(totalSeconds / 60)m \(totalSeconds % 60)s")
                .foregroundStyle(.secondary)
            Text(profile.text(.examMode))
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Spacer()
            Button {
                answers = Array(repeating: nil, count: week.quiz.count)
                quizIndex = 0
                secondsLeft = totalSeconds
                stage = .exam
                startTimer()
            } label: {
                Text(profile.text(.startQuiz))
                    .font(.body.bold())
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }

    private var examView: some View {
        let question = week.quiz[quizIndex]
        return VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("\(profile.text(.question)) \(quizIndex + 1)/\(week.quiz.count)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Label("\(secondsLeft / 60):\(String(format: "%02d", secondsLeft % 60))", systemImage: "timer")
                    .font(.caption.monospacedDigit().bold())
                    .foregroundStyle(secondsLeft < 30 ? .red : .secondary)
            }

            ProgressView(value: Double(quizIndex + 1), total: Double(week.quiz.count))

            Text(question.question)
                .font(.title3.bold())
                .padding(.top, 4)

            ForEach(Array(question.options.enumerated()), id: \.offset) { index, option in
                Button {
                    answers[quizIndex] = index
                } label: {
                    HStack {
                        Text(option)
                        Spacer()
                        if answers[quizIndex] == index {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(Color.accentColor)
                        }
                    }
                    .padding()
                    .background(answers[quizIndex] == index ? Color.accentColor.opacity(0.15) : Color.gray.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .foregroundStyle(.primary)
            }

            Spacer()

            HStack {
                Button {
                    if quizIndex > 0 { quizIndex -= 1 }
                } label: {
                    Image(systemName: "chevron.left")
                }
                .disabled(quizIndex == 0)

                Spacer()

                if quizIndex + 1 < week.quiz.count {
                    Button(profile.text(.nextQuestion)) {
                        quizIndex += 1
                    }
                    .font(.body.bold())
                    .disabled(answers[quizIndex] == nil)
                } else {
                    Button(profile.text(.submitExam)) {
                        finishExam()
                    }
                    .font(.body.bold())
                    .disabled(answers[quizIndex] == nil)
                }
            }
        }
    }

    private var reviewView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    VStack(alignment: .leading) {
                        Text(profile.text(.results)).font(.title2.bold())
                        Text("\(profile.text(.youScored)) \(score)/\(week.quiz.count) (\(percent)%)")
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Image(systemName: percent >= ProgressStore.passThreshold ? "checkmark.seal.fill" : "xmark.seal.fill")
                        .font(.system(size: 36))
                        .foregroundStyle(percent >= ProgressStore.passThreshold ? .green : .orange)
                }

                Text(profile.text(.reviewAnswers)).font(.headline)

                ForEach(Array(week.quiz.enumerated()), id: \.offset) { idx, question in
                    let selected = answers[idx]
                    let correct = selected == question.answerIndex
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text("\(profile.text(.question)) \(idx + 1)")
                                .font(.subheadline.bold())
                            Spacer()
                            Image(systemName: correct ? "checkmark.circle.fill" : "xmark.circle.fill")
                                .foregroundStyle(correct ? .green : .red)
                        }
                        Text(question.question).font(.body)
                        if let selected {
                            Text("\(profile.text(.yourAnswer)): \(question.options[selected])")
                                .font(.caption)
                                .foregroundStyle(correct ? .green : .red)
                        } else {
                            Text("\(profile.text(.yourAnswer)): —")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        if !correct {
                            Text("\(profile.text(.correct)): \(question.options[question.answerIndex])")
                                .font(.caption)
                                .foregroundStyle(Color.accentColor)
                        }
                        Text(question.explanation)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }

                Button {
                    progressStore.recordScore(
                        languageId: languageId,
                        week: week.week,
                        score: score,
                        outOf: week.quiz.count,
                        course: dataStore.course(for: languageId)
                    )
                    saved = true
                    dismiss()
                } label: {
                    Text(profile.text(.saveFinish))
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

    private func startTimer() {
        timerRunning = true
        Task {
            while timerRunning, secondsLeft > 0, stage == .exam {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                guard timerRunning, stage == .exam else { break }
                secondsLeft -= 1
            }
            if secondsLeft <= 0, stage == .exam {
                finishExam()
            }
        }
    }

    private func finishExam() {
        timerRunning = false
        stage = .review
    }
}
