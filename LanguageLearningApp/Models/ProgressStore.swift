import Foundation
import Combine

enum SkillKind: String, CaseIterable, Codable {
    case listening, speaking, reading, writing, quiz

    var icon: String {
        switch self {
        case .listening: return "ear"
        case .speaking: return "mic.fill"
        case .reading: return "book.fill"
        case .writing: return "pencil.line"
        case .quiz: return "checkmark.circle.fill"
        }
    }

    var l10nKey: L10n.Key {
        switch self {
        case .listening: return .listening
        case .speaking: return .speaking
        case .reading: return .reading
        case .writing: return .writing
        case .quiz: return .quiz
        }
    }
}

/// Tracks per-course week / skill / level progress using UserDefaults.
final class ProgressStore: ObservableObject {
    static let shared = ProgressStore()

    static let passThreshold = 70

    @Published private var completedWeeks: Set<String> = []
    @Published private var bestScores: [String: Int] = [:]
    @Published private var skillScores: [String: Int] = [:]
    @Published private var passedLevels: Set<String> = []
    @Published private var exerciseScores: [String: Int] = [:]
    @Published private var levelExamResults: [String: OfficialExamResult] = [:]

    private let completedKey = "completedWeeks.v1"
    private let scoresKey = "bestScores.v1"
    private let skillScoresKey = "skillScores.v1"
    private let passedLevelsKey = "passedLevels.v1"
    private let exerciseScoresKey = "exerciseScores.v1"
    private let levelExamResultsKey = "levelExamResults.v1"

    private init() {
        if let saved = UserDefaults.standard.array(forKey: completedKey) as? [String] {
            completedWeeks = Set(saved)
        }
        if let saved = UserDefaults.standard.dictionary(forKey: scoresKey) as? [String: Int] {
            bestScores = saved
        }
        if let saved = UserDefaults.standard.dictionary(forKey: skillScoresKey) as? [String: Int] {
            skillScores = saved
        }
        if let saved = UserDefaults.standard.array(forKey: passedLevelsKey) as? [String] {
            passedLevels = Set(saved)
        }
        if let saved = UserDefaults.standard.dictionary(forKey: exerciseScoresKey) as? [String: Int] {
            exerciseScores = saved
        }
        if let data = UserDefaults.standard.data(forKey: levelExamResultsKey),
           let decoded = try? JSONDecoder().decode([String: OfficialExamResult].self, from: data) {
            levelExamResults = decoded
        }
    }

    private func weekKey(languageId: String, week: Int) -> String {
        "\(languageId)#\(week)"
    }

    private func skillKey(languageId: String, week: Int, skill: SkillKind) -> String {
        "\(languageId)#\(week)#\(skill.rawValue)"
    }

    private func levelKey(languageId: String, level: String) -> String {
        "\(languageId)#level#\(level)"
    }

    func isWeekCompleted(languageId: String, week: Int) -> Bool {
        completedWeeks.contains(weekKey(languageId: languageId, week: week))
    }

    func markWeekCompleted(languageId: String, week: Int) {
        completedWeeks.insert(weekKey(languageId: languageId, week: week))
        UserDefaults.standard.set(Array(completedWeeks), forKey: completedKey)
    }

    func bestScore(languageId: String, week: Int) -> Int? {
        bestScores[weekKey(languageId: languageId, week: week)]
    }

    func skillScore(languageId: String, week: Int, skill: SkillKind) -> Int? {
        skillScores[skillKey(languageId: languageId, week: week, skill: skill)]
    }

    func didPassSpeaking(languageId: String, week: Int) -> Bool {
        (skillScore(languageId: languageId, week: week, skill: .speaking) ?? 0) >= Self.passThreshold
    }

    func isLevelPassed(languageId: String, level: String) -> Bool {
        if passedLevels.contains(levelKey(languageId: languageId, level: level)) { return true }
        if passedLevels.contains(levelKey(languageId: languageId, level: ExamScoreMapper.cefrBase(from: level))) { return true }
        if let result = levelExamResult(languageId: languageId, level: level) {
            let failed = result.awardedLevel.lowercased().contains("below")
                || result.overallDisplay.lowercased().contains("no apto")
            if !failed && result.overallPercent >= 50 { return true }
        }
        return false
    }

    /// Records a skill score as a percentage 0…100.
    func recordSkillScore(languageId: String, week: Int, skill: SkillKind, percent: Int, course: LanguageCourse? = nil) {
        let clamped = max(0, min(100, percent))
        let k = skillKey(languageId: languageId, week: week, skill: skill)
        let existing = skillScores[k] ?? -1
        if clamped > existing {
            skillScores[k] = clamped
            UserDefaults.standard.set(skillScores, forKey: skillScoresKey)
        }
        refreshWeekAggregate(languageId: languageId, week: week)
        if let course {
            refreshLevelProgress(languageId: languageId, course: course)
        }
    }

    func recordScore(languageId: String, week: Int, score: Int, outOf: Int, course: LanguageCourse? = nil) {
        let percent = outOf > 0 ? Int((Double(score) / Double(outOf) * 100).rounded()) : 0
        recordSkillScore(languageId: languageId, week: week, skill: .quiz, percent: percent, course: course)
    }

    private func refreshWeekAggregate(languageId: String, week: Int) {
        let skills = SkillKind.allCases.compactMap { skillScore(languageId: languageId, week: week, skill: $0) }
        guard !skills.isEmpty else { return }
        let avg = Int((Double(skills.reduce(0, +)) / Double(skills.count)).rounded())
        let k = weekKey(languageId: languageId, week: week)
        let existing = bestScores[k] ?? -1
        if avg > existing {
            bestScores[k] = avg
            UserDefaults.standard.set(bestScores, forKey: scoresKey)
        }

        // Week complete when written quiz + speaking interview both pass.
        let quizOk = (skillScore(languageId: languageId, week: week, skill: .quiz) ?? 0) >= Self.passThreshold
        let speakingOk = didPassSpeaking(languageId: languageId, week: week)
        if quizOk && speakingOk {
            markWeekCompleted(languageId: languageId, week: week)
        }
    }

    func refreshLevelProgress(languageId: String, course: LanguageCourse) {
        for level in course.levelsInOrder {
            let weeks = course.weeks(forLevel: level)
            guard !weeks.isEmpty else { continue }
            let allSpeakingPassed = weeks.allSatisfy { didPassSpeaking(languageId: languageId, week: $0.week) }
            let key = levelKey(languageId: languageId, level: level)
            if allSpeakingPassed {
                if !passedLevels.contains(key) {
                    passedLevels.insert(key)
                    UserDefaults.standard.set(Array(passedLevels), forKey: passedLevelsKey)
                }
            }
        }
        objectWillChange.send()
    }

    func levelSpeakingAverage(languageId: String, course: LanguageCourse, level: String) -> Int? {
        let weeks = course.weeks(forLevel: level)
        let scores = weeks.compactMap { skillScore(languageId: languageId, week: $0.week, skill: .speaking) }
        guard !scores.isEmpty else { return nil }
        return Int((Double(scores.reduce(0, +)) / Double(scores.count)).rounded())
    }

    func levelOverallAverage(languageId: String, course: LanguageCourse, level: String) -> Int? {
        let weeks = course.weeks(forLevel: level)
        let avgs = weeks.compactMap { weekAverage(languageId: languageId, week: $0.week) }
        guard !avgs.isEmpty else { return nil }
        return Int((Double(avgs.reduce(0, +)) / Double(avgs.count)).rounded())
    }

    /// First level that is not fully speaking-passed; otherwise the last level.
    func currentLevel(languageId: String, course: LanguageCourse) -> String {
        for level in course.levelsInOrder {
            if !isLevelPassed(languageId: languageId, level: level) {
                return level
            }
        }
        return course.levelsInOrder.last ?? "—"
    }

    func passedLevelCount(languageId: String, course: LanguageCourse) -> Int {
        course.levelsInOrder.filter { isLevelPassed(languageId: languageId, level: $0) }.count
    }

    func weekAverage(languageId: String, week: Int) -> Int? {
        let skills = SkillKind.allCases.compactMap { skillScore(languageId: languageId, week: week, skill: $0) }
        guard !skills.isEmpty else { return bestScore(languageId: languageId, week: week) }
        return Int((Double(skills.reduce(0, +)) / Double(skills.count)).rounded())
    }

    func courseAverage(languageId: String, totalWeeks: Int) -> Int? {
        let weeks = (1...totalWeeks).compactMap { weekAverage(languageId: languageId, week: $0) }
        guard !weeks.isEmpty else { return nil }
        return Int((Double(weeks.reduce(0, +)) / Double(weeks.count)).rounded())
    }

    func completedCount(languageId: String, totalWeeks: Int) -> Int {
        (1...totalWeeks).filter { isWeekCompleted(languageId: languageId, week: $0) }.count
    }

    func currentWeekNumber(languageId: String, totalWeeks: Int) -> Int {
        for w in 1...totalWeeks {
            if !isWeekCompleted(languageId: languageId, week: w) { return w }
        }
        return totalWeeks
    }

    func skillsCompletedCount(languageId: String, week: Int) -> Int {
        SkillKind.allCases.filter { skillScore(languageId: languageId, week: week, skill: $0) != nil }.count
    }

    // MARK: - Mock exercises

    private func exerciseKey(languageId: String, week: Int, exerciseId: String) -> String {
        "\(languageId)#w\(week)#ex#\(exerciseId)"
    }

    func exerciseScore(languageId: String, week: Int, exerciseId: String) -> Int? {
        exerciseScores[exerciseKey(languageId: languageId, week: week, exerciseId: exerciseId)]
    }

    func recordExerciseScore(languageId: String, week: Int, exerciseId: String, percent: Int) {
        let clamped = max(0, min(100, percent))
        let k = exerciseKey(languageId: languageId, week: week, exerciseId: exerciseId)
        let existing = exerciseScores[k] ?? -1
        if clamped > existing {
            exerciseScores[k] = clamped
            UserDefaults.standard.set(exerciseScores, forKey: exerciseScoresKey)
        }
    }

    func completedExerciseCount(languageId: String, week: Int, ids: [String]) -> Int {
        ids.filter { exerciseScore(languageId: languageId, week: week, exerciseId: $0) != nil }.count
    }

    func isPrepReadyForLevelExam(languageId: String, course: LanguageCourse, level: String) -> Bool {
        let weeks = course.weeks(forLevel: level)
        if weeks.isEmpty {
            // Capstone papers (C2 / TOPIK 6급 / YKI 6) unlock after the previous official level.
            guard let previous = course.previousLevel(before: level),
                  let lastWeek = course.weeks.last else { return false }
            return isLevelPassed(languageId: languageId, level: previous)
                && (isWeekCompleted(languageId: languageId, week: lastWeek.week)
                    || isLevelPassed(languageId: languageId, level: previous))
        }
        return weeks.allSatisfy { week in
            let mocks = week.resolvedMockExercises
            let ids = mocks.listening.map(\.id) + mocks.speaking.map(\.id) + mocks.reading.map(\.id) + mocks.writing.map(\.id)
            let practiced = completedExerciseCount(languageId: languageId, week: week.week, ids: ids)
            let needed = min(8, max(4, ids.count / 5))
            return practiced >= needed || isWeekCompleted(languageId: languageId, week: week.week)
        }
    }

    // MARK: - Official level exams

    private func examResultKey(languageId: String, level: String) -> String {
        "\(languageId)#exam#\(ExamScoreMapper.cefrBase(from: level))"
    }

    func levelExamResult(languageId: String, level: String) -> OfficialExamResult? {
        levelExamResults[examResultKey(languageId: languageId, level: level)]
            ?? levelExamResults[examResultKey(languageId: languageId, level: ExamScoreMapper.cefrBase(from: level))]
    }

    func saveLevelExamResult(_ result: OfficialExamResult) {
        let key = examResultKey(languageId: result.courseId, level: result.level)
        levelExamResults[key] = result
        if let data = try? JSONEncoder().encode(levelExamResults) {
            UserDefaults.standard.set(data, forKey: levelExamResultsKey)
        }
        // Mark level passed when overall meets threshold.
        let failedLabel = result.awardedLevel.lowercased()
        let failed = failedLabel.contains("below") || result.overallDisplay.lowercased().contains("no apto")
        if !failed && result.overallPercent >= 50 {
            let lk = levelKey(languageId: result.courseId, level: result.level)
            // Also try matching full week level labels in course via cefr base later on dashboard.
            passedLevels.insert(lk)
            // Store under awarded/display level variants used in UI.
            passedLevels.insert(levelKey(languageId: result.courseId, level: result.awardedLevel))
            UserDefaults.standard.set(Array(passedLevels), forKey: passedLevelsKey)
        }
        objectWillChange.send()
    }

    func latestOfficialResult(languageId: String, course: LanguageCourse) -> OfficialExamResult? {
        let results = course.levelsInOrder.compactMap { levelExamResult(languageId: languageId, level: $0) }
        return results.sorted { $0.date > $1.date }.first
    }
}
