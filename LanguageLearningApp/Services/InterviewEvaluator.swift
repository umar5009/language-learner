import Foundation

struct InterviewTurnResult: Identifiable {
    let id = UUID()
    let question: String
    let userAnswer: String
    let modelAnswer: String
    let relevance: Int
    let fluency: Int
    let grammar: Int
    let vocabulary: Int
    let overall: Int
    let corrections: [GrammarIssue]
    let improvedAnswer: String
    let feedback: String
}

struct InterviewReport {
    let level: String
    let turns: [InterviewTurnResult]
    let overallPercent: Int
    let fluencyAvg: Int
    let grammarAvg: Int
    let vocabularyAvg: Int
    let relevanceAvg: Int
    let strengths: [String]
    let improvements: [String]
    let passed: Bool

    var allCorrections: [GrammarIssue] {
        turns.flatMap(\.corrections)
    }
}

/// On-device AI evaluator for realtime speaking interviews.
enum InterviewEvaluator {
    static func evaluateTurn(
        question: String,
        userAnswer: String,
        modelAnswer: String,
        courseId: String,
        level: String,
        grammarTitle: String?
    ) -> InterviewTurnResult {
        let lang = GrammarCoach.languageCode(forCourseId: courseId)
        let trimmed = userAnswer.trimmingCharacters(in: .whitespacesAndNewlines)

        let relevance = relevanceScore(answer: trimmed, model: modelAnswer, question: question)
        let fluency = fluencyScore(answer: trimmed, level: level)
        let grammarReport = GrammarCoach.analyze(
            text: trimmed,
            expected: nil,
            languageCode: lang,
            weekGrammarTitle: grammarTitle
        )
        // Don't treat week-focus tip as a hard penalty for speaking.
        let grammarIssues = grammarReport.issues.filter { $0.kind != .style || $0.suggestion != nil || !$0.message.contains("focuses on") }
        let grammarScore = max(0, min(100, grammarReport.scorePercent + (grammarReport.issues.count - grammarIssues.count) * 4))
        let vocabulary = vocabularyScore(answer: trimmed, model: modelAnswer)

        let overall = Int((
            Double(relevance) * 0.30 +
            Double(fluency) * 0.25 +
            Double(grammarScore) * 0.25 +
            Double(vocabulary) * 0.20
        ).rounded())

        let improved: String
        if !modelAnswer.isEmpty, relevance < 75 {
            improved = modelAnswer
        } else if !grammarReport.correctedText.isEmpty {
            improved = grammarReport.correctedText
        } else {
            improved = modelAnswer
        }

        var corrections = grammarIssues
        if relevance < 60 {
            corrections.insert(GrammarIssue(
                kind: .grammar,
                message: "Answer was only partly related to the question.",
                suggestion: modelAnswer
            ), at: 0)
        } else if SpeechPracticeEngine.similarity(trimmed, modelAnswer) < 55, !modelAnswer.isEmpty {
            corrections.append(GrammarIssue(
                kind: .style,
                message: "Try a clearer, more complete answer for this level.",
                suggestion: modelAnswer
            ))
        }

        let feedback: String
        switch overall {
        case 85...: feedback = "Strong response — clear and appropriate for \(level)."
        case 70..<85: feedback = "Good response. A few corrections will make it sound more natural."
        case 50..<70: feedback = "Understandable, but expand your answer and fix key errors."
        default: feedback = "Try answering in fuller sentences that directly address the question."
        }

        return InterviewTurnResult(
            question: question,
            userAnswer: trimmed.isEmpty ? "(no speech detected)" : trimmed,
            modelAnswer: modelAnswer,
            relevance: relevance,
            fluency: fluency,
            grammar: grammarScore,
            vocabulary: vocabulary,
            overall: overall,
            corrections: corrections,
            improvedAnswer: improved,
            feedback: feedback
        )
    }

    static func buildReport(turns: [InterviewTurnResult], level: String) -> InterviewReport {
        guard !turns.isEmpty else {
            return InterviewReport(
                level: level,
                turns: [],
                overallPercent: 0,
                fluencyAvg: 0,
                grammarAvg: 0,
                vocabularyAvg: 0,
                relevanceAvg: 0,
                strengths: [],
                improvements: ["Complete the interview by speaking your answers."],
                passed: false
            )
        }

        func avg(_ keyPath: KeyPath<InterviewTurnResult, Int>) -> Int {
            Int((Double(turns.map { $0[keyPath: keyPath] }.reduce(0, +)) / Double(turns.count)).rounded())
        }

        let overall = avg(\.overall)
        let fluency = avg(\.fluency)
        let grammar = avg(\.grammar)
        let vocabulary = avg(\.vocabulary)
        let relevance = avg(\.relevance)

        var strengths: [String] = []
        var improvements: [String] = []
        if fluency >= 75 { strengths.append("Fluency / length of answers") }
        else { improvements.append("Speak in longer, connected sentences") }
        if grammar >= 75 { strengths.append("Grammar control") }
        else { improvements.append("Review grammar corrections below") }
        if vocabulary >= 75 { strengths.append("Vocabulary range") }
        else { improvements.append("Reuse week vocabulary more naturally") }
        if relevance >= 75 { strengths.append("Task relevance") }
        else { improvements.append("Answer the examiner question more directly") }

        return InterviewReport(
            level: level,
            turns: turns,
            overallPercent: overall,
            fluencyAvg: fluency,
            grammarAvg: grammar,
            vocabularyAvg: vocabulary,
            relevanceAvg: relevance,
            strengths: strengths,
            improvements: improvements,
            passed: overall >= ProgressStore.passThreshold
        )
    }

    static func bridgePhrase(courseId: String, isLast: Bool) -> String {
        let lang = GrammarCoach.languageCode(forCourseId: courseId)
        if isLast {
            switch lang {
            case "es": return "Gracias. Ahora prepararé tu informe de evaluación."
            case "de": return "Danke. Ich erstelle jetzt Ihren Bewertungsbericht."
            case "fr": return "Merci. Je prépare maintenant votre rapport d’évaluation."
            case "cs": return "Děkuji. Teď připravím hodnoticí zprávu."
            case "fi": return "Kiitos. Valmistelen nyt arviointiraporttisi."
            case "ja": return "ありがとうございます。これから評価レポートを作成します。"
            case "ko": return "감사합니다. 이제 평가 보고서를 준비하겠습니다."
            default: return "Thank you. I will now prepare your evaluation report."
            }
        }
        switch lang {
        case "es": return "Bien, gracias. Siguiente pregunta."
        case "de": return "Gut, danke. Nächste Frage."
        case "fr": return "Bien, merci. Question suivante."
        case "cs": return "Dobře, děkuji. Další otázka."
        case "fi": return "Hyvä, kiitos. Seuraava kysymys."
        case "ja": return "ありがとうございます。次の質問です。"
        case "ko": return "좋아요. 다음 질문입니다."
        default: return "Good, thank you. Next question."
        }
    }

    static func introPhrase(courseId: String, level: String) -> String {
        let lang = GrammarCoach.languageCode(forCourseId: courseId)
        switch lang {
        case "es": return "Hola. Esta es tu entrevista oral de nivel \(level). Responde en voz alta después de cada pregunta."
        case "de": return "Hallo. Das ist Ihr Sprechinterview auf Niveau \(level). Antworten Sie nach jeder Frage laut."
        case "fr": return "Bonjour. Ceci est votre entretien oral de niveau \(level). Répondez à voix haute après chaque question."
        case "cs": return "Dobrý den. Toto je ústní pohovor na úrovni \(level). Odpovídejte nahlas po každé otázce."
        case "fi": return "Hei. Tämä on \(level)-tason suullinen haastattelu. Vastaa ääneen jokaisen kysymyksen jälkeen."
        case "ja": return "こんにちは。これは\(level)レベルのスピーキング面接です。質問の後に声で答えてください。"
        case "ko": return "안녕하세요. 이것은 \(level) 말하기 면접입니다. 질문 후에 소리 내어 답하세요."
        default: return "Hello. This is your \(level) speaking interview. Answer out loud after each question."
        }
    }

    private static func relevanceScore(answer: String, model: String, question: String) -> Int {
        guard !answer.isEmpty else { return 0 }
        let toModel = SpeechPracticeEngine.similarity(answer, model)
        let qWords = Set(normalizeWords(question))
        let aWords = Set(normalizeWords(answer))
        let overlap = qWords.isEmpty ? 0.0 : Double(qWords.intersection(aWords).count) / Double(max(qWords.count, 1))
        let combined = Double(toModel) * 0.75 + overlap * 100.0 * 0.25
        return max(0, min(100, Int(combined.rounded())))
    }

    private static func fluencyScore(answer: String, level: String) -> Int {
        let words = normalizeWords(answer)
        let count = words.count
        let target: Int
        if level.contains("C1") || level.contains("N1") { target = 28 }
        else if level.contains("B2") || level.contains("N2") { target = 20 }
        else if level.contains("B1") || level.contains("N3") { target = 14 }
        else if level.contains("A2") || level.contains("N4") { target = 10 }
        else { target = 6 }

        if count == 0 { return 0 }
        let ratio = min(Double(count) / Double(target), 1.4)
        var score = Int((ratio / 1.4) * 100)
        // Penalize extreme fragmentation
        if count >= 3 && answer.filter({ $0 == "." || $0 == "!" || $0 == "?" }).count > count / 2 {
            score -= 10
        }
        return max(15, min(100, score))
    }

    private static func vocabularyScore(answer: String, model: String) -> Int {
        let a = Set(normalizeWords(answer))
        let m = Set(normalizeWords(model))
        guard !a.isEmpty else { return 0 }
        if m.isEmpty { return min(100, a.count * 8) }
        let overlap = Double(a.intersection(m).count) / Double(max(m.count, 1))
        let richness = min(Double(a.count) / 12.0, 1.0)
        return Int(((overlap * 0.65) + (richness * 0.35)) * 100)
    }

    private static func normalizeWords(_ s: String) -> [String] {
        s.lowercased()
            .folding(options: .diacriticInsensitive, locale: .current)
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { $0.count > 1 }
    }
}
