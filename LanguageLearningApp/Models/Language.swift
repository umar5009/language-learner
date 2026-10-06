import Foundation

// MARK: - Manifest (lightweight list used for the home screen)

struct LanguageManifestEntry: Codable, Identifiable, Hashable {
    let id: String
    let name: String
    let flagEmoji: String
    let institute: String
    let framework: String
    let description: String
    let fileName: String
    let weekCount: Int
}

// MARK: - Full language content (loaded on demand per language)

struct LanguageCourse: Codable, Identifiable, Hashable {
    let id: String
    let name: String
    let flagEmoji: String
    let institute: String
    let framework: String
    let description: String
    let weeks: [CourseWeek]
    let levelExams: [LevelExam]?
    let examFramework: ExamFramework?

    /// Ordered unique levels from the official test (A1→C2, N5→N1, TOPIK 1–6, …).
    var levelsInOrder: [String] {
        if let official = examFramework?.officialLevels, !official.isEmpty {
            return official.map(\.label)
        }
        var order: [String] = []
        var seen = Set<String>()
        for week in weeks {
            if !seen.contains(week.level) {
                order.append(week.level)
                seen.insert(week.level)
            }
        }
        return order
    }

    func previousLevel(before level: String) -> String? {
        let order = levelsInOrder
        guard let idx = order.firstIndex(of: level), idx > 0 else { return nil }
        return order[idx - 1]
    }

    func weeks(forLevel level: String) -> [CourseWeek] {
        let direct = weeks.filter { $0.level == level }
        if !direct.isEmpty { return direct }
        guard let meta = examFramework?.officialLevels.first(where: { $0.label == level || $0.id == ExamScoreMapper.cefrBase(from: level) }) else {
            return []
        }
        return weeks.filter { meta.weeks.contains($0.week) }
    }

    func levelExam(for level: String) -> LevelExam? {
        let targetCEFR = ExamScoreMapper.cefrBase(from: level)
        if let match = levelExams?.first(where: {
            $0.level == level
                || ExamScoreMapper.cefrBase(from: $0.level) == targetCEFR
        }) {
            return match
        }
        // Fallback: synthesize from weeks of that level.
        let levelWeeks = weeks(forLevel: level)
        guard let last = levelWeeks.last else { return nil }
        let pack = last.resolvedStudyPack
        let speaking = last.interviewPrompts.prefix(4).enumerated().map { idx, p in
            SpeakingExercise(
                id: "exam-s\(idx + 1)",
                title: "Speaking Part \(idx + 1)",
                instruction: "Official speaking exam question. Answer in full sentences.",
                examinerQuestion: p.examinerQuestion,
                modelAnswer: p.modelAnswer,
                tip: p.tip
            )
        }
        return LevelExam(
            id: "\(id)-\(ExamScoreMapper.cefrBase(from: level))",
            level: ExamScoreMapper.cefrBase(from: level),
            title: "\(ExamScoreMapper.cefrBase(from: level)) Official Mock Exam",
            description: "Full skills exam after your 2-week prep block.",
            requiredWeeks: levelWeeks.map(\.week),
            listening: ListeningExercise(
                id: "exam-l",
                title: "Listening paper",
                instruction: "Listen once or twice, then answer.",
                audioLines: last.dialogue.map(\.line),
                questions: Array(last.quiz.prefix(4))
            ),
            speaking: Array(speaking),
            reading: ReadingExercise(
                id: "exam-r",
                title: "Reading paper",
                instruction: "Read the passage and answer.",
                passage: pack.readingPassage.body,
                questions: Array(last.quiz.suffix(min(3, last.quiz.count)))
            ),
            writing: WritingExercise(
                id: "exam-w",
                title: "Writing paper",
                instruction: "Write a response for the exam task.",
                prompt: "\(last.title). \(last.focus)",
                modelAnswer: pack.grammarDeepDive.example,
                minWords: 40
            )
        )
    }
}

struct CourseWeek: Codable, Identifiable, Hashable {
    let week: Int
    let level: String
    let title: String
    let focus: String
    let vocabulary: [VocabItem]
    let grammar: GrammarPoint
    let dialogue: [DialogueLine]
    let cultureNote: String
    let quiz: [QuizQuestion]
    /// End-of-week level prep interview (examiner ↔ model answers).
    let speakingInterview: [SpeakingInterviewPrompt]?
    /// Full weekly preparation pack (passage, worksheet, checklist, tips).
    let studyPack: StudyPack?
    /// Mock practice exercises (10 per skill) before the official level exam.
    let mockExercises: MockExerciseSet?

    var id: Int { week }

    var resolvedMockExercises: MockExerciseSet {
        if let mockExercises { return mockExercises }
        return MockExerciseSet(
            listening: [
                ListeningExercise(
                    id: "\(week)-L1",
                    title: "Exercise 1",
                    instruction: "Listen and answer.",
                    audioLines: dialogue.map(\.line),
                    questions: Array(quiz.prefix(2))
                )
            ],
            speaking: interviewPrompts.prefix(3).enumerated().map { idx, p in
                SpeakingExercise(
                    id: "\(week)-S\(idx + 1)",
                    title: "Exercise \(idx + 1)",
                    instruction: "Realtime speaking practice.",
                    examinerQuestion: p.examinerQuestion,
                    modelAnswer: p.modelAnswer,
                    tip: p.tip
                )
            },
            reading: [
                ReadingExercise(
                    id: "\(week)-R1",
                    title: "Exercise 1",
                    instruction: "Read and answer.",
                    passage: resolvedStudyPack.readingPassage.body,
                    questions: Array(quiz.prefix(2))
                )
            ],
            writing: [
                WritingExercise(
                    id: "\(week)-W1",
                    title: "Exercise 1",
                    instruction: "Write a short response.",
                    prompt: title,
                    modelAnswer: grammar.example,
                    minWords: 30
                )
            ]
        )
    }

    var interviewPrompts: [SpeakingInterviewPrompt] {
        if let speakingInterview, !speakingInterview.isEmpty {
            return speakingInterview
        }
        // Fallback for older content: build from dialogue pairs.
        var prompts: [SpeakingInterviewPrompt] = []
        let lines = dialogue
        var i = 0
        while i < lines.count {
            let q = lines[i].line
            let a = (i + 1 < lines.count) ? lines[i + 1].line : lines[i].line
            prompts.append(SpeakingInterviewPrompt(
                examinerQuestion: q,
                modelAnswer: a,
                tip: "Answer in full sentences for \(level).",
                level: level
            ))
            i += 2
        }
        return prompts
    }

    /// Prefer bundled study pack; otherwise synthesize a minimal pack from week fields.
    var resolvedStudyPack: StudyPack {
        if let studyPack { return studyPack }
        return StudyPack(
            title: "Week \(week) Prep Pack — \(title)",
            instituteSource: focus,
            level: level,
            learningObjectives: [title, grammar.title, "Prepare speaking interview"],
            canDoStatements: ["Practise this week's vocabulary and grammar"],
            readingPassage: StudyPassage(
                title: title,
                body: dialogue.map(\.line).joined(separator: " "),
                sourceNote: cultureNote,
                focusWords: vocabulary.prefix(4).map(\.word).joined(separator: ", ")
            ),
            keyPhrases: vocabulary.map {
                StudyPhrase(phrase: $0.word, meaning: $0.translation, usage: $0.example)
            },
            worksheet: [
                StudyWorksheetItem(type: "rewrite", prompt: grammar.title, answer: grammar.example)
            ],
            prepChecklist: ["Study vocabulary", "Review grammar", "Complete skills exams"],
            examTips: [cultureNote],
            selfStudyPlan: focus,
            grammarDeepDive: StudyGrammarDeepDive(
                title: grammar.title,
                explanation: grammar.explanation,
                example: grammar.example,
                practiceHint: "Write 5 sentences using this grammar point."
            )
        )
    }
}

struct StudyPack: Codable, Hashable {
    let title: String
    let instituteSource: String
    let level: String
    let learningObjectives: [String]
    let canDoStatements: [String]
    let readingPassage: StudyPassage
    let keyPhrases: [StudyPhrase]
    let worksheet: [StudyWorksheetItem]
    let prepChecklist: [String]
    let examTips: [String]
    let selfStudyPlan: String
    let grammarDeepDive: StudyGrammarDeepDive
}

struct StudyPassage: Codable, Hashable {
    let title: String
    let body: String
    let sourceNote: String
    let focusWords: String?
}

struct StudyPhrase: Codable, Hashable, Identifiable {
    var id: String { phrase + meaning }
    let phrase: String
    let meaning: String
    let usage: String
}

struct StudyWorksheetItem: Codable, Hashable, Identifiable {
    var id: String { type + prompt }
    let type: String
    let prompt: String
    let answer: String
}

struct StudyGrammarDeepDive: Codable, Hashable {
    let title: String
    let explanation: String
    let example: String
    let practiceHint: String
}

struct SpeakingInterviewPrompt: Codable, Hashable {
    let examinerQuestion: String
    let modelAnswer: String
    let tip: String?
    let level: String?
}

struct VocabItem: Codable, Hashable {
    let word: String
    let translation: String
    let example: String
}

struct GrammarPoint: Codable, Hashable {
    let title: String
    let explanation: String
    let example: String
}

struct DialogueLine: Codable, Hashable {
    let speaker: String
    let line: String
    let translation: String
}

struct QuizQuestion: Codable, Hashable {
    let question: String
    let options: [String]
    let answerIndex: Int
    let explanation: String
    /// Official-style item type: mcq, tfng, ynng, noteCompletion, matching, shortAnswer.
    let taskType: String?

    init(question: String, options: [String], answerIndex: Int, explanation: String, taskType: String? = nil) {
        self.question = question
        self.options = options
        self.answerIndex = answerIndex
        self.explanation = explanation
        self.taskType = taskType
    }
}

// MARK: - Official exam framework (per language test)

struct FlexibleText: Codable, Hashable {
    let value: String

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let int = try? container.decode(Int.self) {
            value = String(int)
        } else if let double = try? container.decode(Double.self) {
            value = String(Int(double))
        } else {
            value = (try? container.decode(String.self)) ?? ""
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(value)
    }
}

struct ExamFramework: Codable, Hashable {
    let testName: String
    let awardingBody: String
    let scoreSystem: String
    let scoreSystemId: String
    let isLevelExam: Bool
    let notes: String
    let passRule: String
    let officialLevels: [OfficialExamLevel]
    let officialSkills: [String]
    let classroomSkills: [String]
    let skillPapers: [String: SkillPaperSpec]
}

struct OfficialExamLevel: Codable, Hashable, Identifiable {
    let id: String
    let label: String
    let cefr: String
    let examName: String
    let weeks: [Int]
}

struct SkillPaperSpec: Codable, Hashable {
    let officialName: String
    let minutes: FlexibleText?
    let playCount: Int?
    let parts: [String]?
    let example: String?
}
