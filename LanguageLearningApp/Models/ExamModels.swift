import Foundation

// MARK: - Mock practice exercises (prep before official level exam)

struct MockExerciseSet: Codable, Hashable {
    let listening: [ListeningExercise]
    let speaking: [SpeakingExercise]
    let reading: [ReadingExercise]
    let writing: [WritingExercise]
}

struct ListeningExercise: Codable, Hashable, Identifiable {
    let id: String
    let title: String
    let instruction: String
    let audioLines: [String]
    let questions: [QuizQuestion]
    let playLimit: Int?

    var resolvedPlayLimit: Int { max(1, playLimit ?? 2) }

    init(id: String, title: String, instruction: String, audioLines: [String], questions: [QuizQuestion], playLimit: Int? = nil) {
        self.id = id
        self.title = title
        self.instruction = instruction
        self.audioLines = audioLines
        self.questions = questions
        self.playLimit = playLimit
    }
}

struct SpeakingExercise: Codable, Hashable, Identifiable {
    let id: String
    let title: String
    let instruction: String
    let examinerQuestion: String
    let modelAnswer: String
    let tip: String?
    /// IELTS Part 2 cue-card bullets (you should say…).
    let cueBullets: [String]?
    let prepSeconds: Int?
    let speakSeconds: Int?

    init(
        id: String,
        title: String,
        instruction: String,
        examinerQuestion: String,
        modelAnswer: String,
        tip: String?,
        cueBullets: [String]? = nil,
        prepSeconds: Int? = nil,
        speakSeconds: Int? = nil
    ) {
        self.id = id
        self.title = title
        self.instruction = instruction
        self.examinerQuestion = examinerQuestion
        self.modelAnswer = modelAnswer
        self.tip = tip
        self.cueBullets = cueBullets
        self.prepSeconds = prepSeconds
        self.speakSeconds = speakSeconds
    }

    func resolvedPrepSeconds(courseId: String) -> Int {
        if let prepSeconds, prepSeconds > 0 { return prepSeconds }
        if courseId == "ielts_english", title.localizedCaseInsensitiveContains("Part 2") { return 60 }
        return 0
    }

    func resolvedSpeakSeconds(courseId: String) -> Int {
        if let speakSeconds, speakSeconds > 0 { return speakSeconds }
        if courseId == "ielts_english", title.localizedCaseInsensitiveContains("Part 2") { return 120 }
        return 0
    }
}

struct ReadingExercise: Codable, Hashable, Identifiable {
    let id: String
    let title: String
    let instruction: String
    let passage: String
    let questions: [QuizQuestion]
}

struct WritingExercise: Codable, Hashable, Identifiable {
    let id: String
    let title: String
    let instruction: String
    let prompt: String
    let modelAnswer: String
    let minWords: Int
    let minutes: Int?

    init(
        id: String,
        title: String,
        instruction: String,
        prompt: String,
        modelAnswer: String,
        minWords: Int,
        minutes: Int? = nil
    ) {
        self.id = id
        self.title = title
        self.instruction = instruction
        self.prompt = prompt
        self.modelAnswer = modelAnswer
        self.minWords = minWords
        self.minutes = minutes
    }

    var resolvedMinutes: Int {
        if let minutes, minutes > 0 { return minutes }
        if minWords >= 250 { return 40 }
        if minWords >= 150 { return 20 }
        return 0
    }
}

// MARK: - Official level exam (after ~2 weeks prep)

struct LevelExam: Codable, Hashable, Identifiable {
    let id: String
    let level: String
    let title: String
    let description: String
    let requiredWeeks: [Int]
    let listening: ListeningExercise
    let speaking: [SpeakingExercise]
    let reading: ReadingExercise
    let writing: WritingExercise
    let officialSkills: [String]?
    let classroomSkills: [String]?
    let scoreSystemId: String?

    var scoredSkills: [ExamSkill] {
        let raw = officialSkills ?? ExamSkill.allCases.map(\.rawValue)
        let mapped = raw.compactMap { ExamSkill(rawValue: $0) }
        return mapped.isEmpty ? ExamSkill.allCases : mapped
    }

    func isOfficial(_ skill: ExamSkill) -> Bool {
        scoredSkills.contains(skill)
    }

    init(
        id: String,
        level: String,
        title: String,
        description: String,
        requiredWeeks: [Int],
        listening: ListeningExercise,
        speaking: [SpeakingExercise],
        reading: ReadingExercise,
        writing: WritingExercise,
        officialSkills: [String]? = nil,
        classroomSkills: [String]? = nil,
        scoreSystemId: String? = nil
    ) {
        self.id = id
        self.level = level
        self.title = title
        self.description = description
        self.requiredWeeks = requiredWeeks
        self.listening = listening
        self.speaking = speaking
        self.reading = reading
        self.writing = writing
        self.officialSkills = officialSkills
        self.classroomSkills = classroomSkills
        self.scoreSystemId = scoreSystemId
    }
}

struct OfficialSkillScore: Hashable, Identifiable {
    var id: String { skill.rawValue }
    let skill: ExamSkill
    let percent: Int
    let displayScore: String
    let label: String
}

enum ExamSkill: String, CaseIterable, Hashable, Codable {
    case listening, speaking, reading, writing

    var icon: String {
        switch self {
        case .listening: return "ear"
        case .speaking: return "mic.fill"
        case .reading: return "book.fill"
        case .writing: return "pencil.line"
        }
    }

    var l10nKey: L10n.Key {
        switch self {
        case .listening: return .listening
        case .speaking: return .speaking
        case .reading: return .reading
        case .writing: return .writing
        }
    }
}

struct OfficialExamResult: Codable, Hashable {
    let courseId: String
    let level: String
    let listeningPercent: Int
    let speakingPercent: Int
    let readingPercent: Int
    let writingPercent: Int
    let overallPercent: Int
    let listeningDisplay: String
    let speakingDisplay: String
    let readingDisplay: String
    let writingDisplay: String
    let overallDisplay: String
    let awardedLevel: String
    let scoreSystem: String
    let date: Date
}

/// Maps skill percents to the official scoring system of each language test.
enum ExamScoreMapper {
    static func cefrBase(from levelLabel: String) -> String {
        for key in ["C2", "C1", "B2", "B1", "A2", "A1"] where levelLabel.contains(key) {
            return key
        }
        return "A1"
    }

    static func lowerCEFR(_ level: String) -> String {
        switch cefrBase(from: level) {
        case "C2": return "C1"
        case "C1": return "B2"
        case "B2": return "B1"
        case "B1": return "A2"
        default: return "A1"
        }
    }

    /// Classroom mock of the IELTS 0–9 band scale (not an official British Council score).
    static func ieltsBand(from percent: Int) -> Double {
        let p = max(0, min(100, percent))
        switch p {
        case 0..<12: return 2.0
        case 12..<20: return 2.5
        case 20..<28: return 3.0
        case 28..<36: return 3.5
        case 36..<44: return 4.0
        case 44..<52: return 4.5
        case 52..<60: return 5.0
        case 60..<68: return 5.5
        case 68..<76: return 6.0
        case 76..<82: return 6.5
        case 82..<88: return 7.0
        case 88..<93: return 7.5
        case 93..<97: return 8.0
        case 97..<100: return 8.5
        default: return 9.0
        }
    }

    static func formatBand(_ band: Double) -> String {
        String(format: "%.1f", band)
    }

    static func cefrFromIELTSBand(_ band: Double) -> String {
        switch band {
        case ..<3.0: return "A1"
        case ..<4.0: return "A2"
        case ..<5.5: return "B1"
        case ..<7.0: return "B2"
        case ..<8.5: return "C1"
        default: return "C2"
        }
    }

    static func cefrFromOverallPercent(_ percent: Int) -> String {
        switch percent {
        case 0..<40: return "A1"
        case 40..<55: return "A2"
        case 55..<70: return "B1"
        case 70..<82: return "B2"
        case 82..<92: return "C1"
        default: return "C2"
        }
    }

    static func ykiGrade(percent: Int, targetLevel: String) -> String {
        let sitting = cefrBase(from: targetLevel)
        // Each YKI sitting awards the lower or higher grade of that pair, or "below".
        let low: Int
        let high: Int
        switch sitting {
        case "A1", "A2": low = 1; high = 2
        case "B1", "B2": low = 3; high = 4
        default: low = 5; high = 6
        }
        if percent < 40 { return "below \(low)" }
        if percent < 70 { return "YKI \(low)" }
        return "YKI \(high)"
    }

    static func topikAward(percent: Int, targetLevel: String) -> String {
        let cefr = cefrBase(from: targetLevel)
        if cefr == "A1" || cefr == "A2" {
            // TOPIK I / 200: level 1 ≥80 (40%), level 2 ≥140 (70%)
            if percent >= 70 { return "TOPIK 2급" }
            if percent >= 40 { return "TOPIK 1급" }
            return "Below TOPIK 1급"
        }
        // TOPIK II / 300: 3≥120 (40%), 4≥150 (50%), 5≥190 (63%), 6≥230 (77%)
        if percent >= 77 { return "TOPIK 6급" }
        if percent >= 63 { return "TOPIK 5급" }
        if percent >= 50 { return "TOPIK 4급" }
        if percent >= 40 { return "TOPIK 3급" }
        return "Below TOPIK 3급"
    }

    private static func naDisplay(_ percent: Int, formatted: String) -> String {
        percent < 0 ? "—" : formatted
    }

    static func buildResult(
        courseId: String,
        targetLevel: String,
        listening: Int,
        speaking: Int,
        reading: Int,
        writing: Int,
        exam: LevelExam? = nil,
        framework: ExamFramework? = nil
    ) -> OfficialExamResult {
        let systemId = exam?.scoreSystemId ?? framework?.scoreSystemId ?? (courseId == "ielts_english" ? "ieltsBand" : "cefr")
        let official = exam?.scoredSkills ?? ExamSkill.allCases
        func include(_ skill: ExamSkill, _ percent: Int) -> Int {
            official.contains(skill) ? percent : -1
        }
        let l = include(.listening, listening)
        let s = include(.speaking, speaking)
        let r = include(.reading, reading)
        let w = include(.writing, writing)
        let scored = [l, s, r, w].filter { $0 >= 0 }
        let overall = scored.isEmpty ? 0 : Int((Double(scored.reduce(0, +)) / Double(scored.count)).rounded())

        var lDisp = "\(max(l, 0))%"
        var sDisp = "\(max(s, 0))%"
        var rDisp = "\(max(r, 0))%"
        var wDisp = "\(max(w, 0))%"
        var oDisp = "\(overall)%"
        var awarded = targetLevel
        var system = framework?.scoreSystem ?? "CEFR mock"

        switch systemId {
        case "ieltsBand":
            func band(_ p: Int) -> Double { p < 0 ? 0 : ieltsBand(from: p) }
            let lb = band(l), sb = band(s), rb = band(r), wb = band(w)
            let officialBands = zip([l, s, r, w], [lb, sb, rb, wb]).compactMap { percent, band in percent >= 0 ? band : nil }
            let avg = officialBands.isEmpty ? 0 : officialBands.reduce(0, +) / Double(officialBands.count)
            let overallBand = (avg * 2).rounded() / 2.0
            lDisp = naDisplay(l, formatted: formatBand(lb))
            sDisp = naDisplay(s, formatted: formatBand(sb))
            rDisp = naDisplay(r, formatted: formatBand(rb))
            wDisp = naDisplay(w, formatted: formatBand(wb))
            oDisp = formatBand(overallBand)
            awarded = cefrFromIELTSBand(overallBand)
            system = "IELTS Band"

        case "goethe100":
            // 25 points per module, 60/100 to pass the full exam (A1 Start Deutsch 1).
            func pts(_ p: Int) -> Int { p < 0 ? 0 : Int((Double(p) / 100.0 * 25.0).rounded()) }
            let lp = pts(l), sp = pts(s), rp = pts(r), wp = pts(w)
            let total = [l, s, r, w].enumerated().reduce(0) { acc, pair in
                acc + (pair.element >= 0 ? [lp, sp, rp, wp][pair.offset] : 0)
            }
            lDisp = naDisplay(l, formatted: "\(lp)/25")
            sDisp = naDisplay(s, formatted: "\(sp)/25")
            rDisp = naDisplay(r, formatted: "\(rp)/25")
            wDisp = naDisplay(w, formatted: "\(wp)/25")
            oDisp = "\(total)/100"
            awarded = total >= 60 ? targetLevel : lowerCEFR(targetLevel)
            system = "Goethe / 100"

        case "dele100":
            func pts(_ p: Int) -> Int { p < 0 ? 0 : Int((Double(p) / 100.0 * 25.0).rounded()) }
            let group1 = (r >= 0 ? pts(r) : 0) + (w >= 0 ? pts(w) : 0) // reading + writing
            let group2 = (l >= 0 ? pts(l) : 0) + (s >= 0 ? pts(s) : 0) // listening + speaking
            lDisp = naDisplay(l, formatted: "\(pts(l))/25")
            sDisp = naDisplay(s, formatted: "\(pts(s))/25")
            rDisp = naDisplay(r, formatted: "\(pts(r))/25")
            wDisp = naDisplay(w, formatted: "\(pts(w))/25")
            let apto = group1 >= 30 && group2 >= 30
            oDisp = apto ? "Apto" : "No apto"
            awarded = apto ? targetLevel : lowerCEFR(targetLevel)
            system = "DELE Apto (30/50 per group)"

        case "delf100":
            func pts(_ p: Int) -> Int { p < 0 ? 0 : Int((Double(p) / 100.0 * 25.0).rounded()) }
            let officialPts = zip([l, s, r, w], [pts(l), pts(s), pts(r), pts(w)]).compactMap { percent, value in percent >= 0 ? value : nil }
            let total = officialPts.reduce(0, +)
            let minOk = zip([l, s, r, w], [pts(l), pts(s), pts(r), pts(w)]).filter { percent, _ in percent >= 0 }.allSatisfy { _, value in value >= 5 }
            lDisp = naDisplay(l, formatted: "\(pts(l))/25")
            sDisp = naDisplay(s, formatted: "\(pts(s))/25")
            rDisp = naDisplay(r, formatted: "\(pts(r))/25")
            wDisp = naDisplay(w, formatted: "\(pts(w))/25")
            oDisp = "\(total)/100"
            awarded = (total >= 50 && minOk) ? targetLevel : lowerCEFR(targetLevel)
            system = "DELF-DALF / 100"

        case "jlpt":
            lDisp = naDisplay(l, formatted: "\(l)%")
            sDisp = s < 0 ? "Not on JLPT" : "\(s)%"
            rDisp = naDisplay(r, formatted: "\(r)%")
            wDisp = w < 0 ? "Not on JLPT" : "\(w)%"
            oDisp = "\(overall)%"
            awarded = overall >= 60 && l >= 40 && r >= 40 ? targetLevel : lowerCEFR(targetLevel)
            system = "JLPT (Language Knowledge · Reading · Listening)"

        case "topik":
            lDisp = naDisplay(l, formatted: "\(l)%")
            sDisp = s < 0 ? "—" : "Speaking \(s)%"
            rDisp = naDisplay(r, formatted: "\(r)%")
            wDisp = w < 0 ? "TOPIK I: no writing" : "\(w)%"
            oDisp = "\(overall)%"
            awarded = topikAward(percent: overall, targetLevel: targetLevel)
            system = "TOPIK levels 1–6"

        case "yki":
            func g(_ p: Int) -> String { p < 0 ? "—" : ykiGrade(percent: p, targetLevel: targetLevel) }
            lDisp = g(l)
            sDisp = g(s)
            rDisp = g(r)
            wDisp = g(w)
            oDisp = ykiGrade(percent: overall, targetLevel: targetLevel)
            awarded = oDisp
            system = "YKI grades 1–6"

        default:
            lDisp = naDisplay(l, formatted: "\(l)%")
            sDisp = naDisplay(s, formatted: "\(s)%")
            rDisp = naDisplay(r, formatted: "\(r)%")
            wDisp = naDisplay(w, formatted: "\(w)%")
            oDisp = "\(overall)%"
            awarded = overall >= 60 ? targetLevel : lowerCEFR(targetLevel)
            system = framework?.scoreSystem ?? "CCE / CEFR mock"
        }

        return OfficialExamResult(
            courseId: courseId,
            level: targetLevel,
            listeningPercent: l,
            speakingPercent: s,
            readingPercent: r,
            writingPercent: w,
            overallPercent: overall,
            listeningDisplay: lDisp,
            speakingDisplay: sDisp,
            readingDisplay: rDisp,
            writingDisplay: wDisp,
            overallDisplay: oDisp,
            awardedLevel: awarded,
            scoreSystem: system,
            date: Date()
        )
    }

    static func skillScores(from result: OfficialExamResult) -> [OfficialSkillScore] {
        [
            .init(skill: .listening, percent: max(result.listeningPercent, 0), displayScore: result.listeningDisplay, label: result.scoreSystem),
            .init(skill: .speaking, percent: max(result.speakingPercent, 0), displayScore: result.speakingDisplay, label: result.scoreSystem),
            .init(skill: .reading, percent: max(result.readingPercent, 0), displayScore: result.readingDisplay, label: result.scoreSystem),
            .init(skill: .writing, percent: max(result.writingPercent, 0), displayScore: result.writingDisplay, label: result.scoreSystem),
        ]
    }
}
