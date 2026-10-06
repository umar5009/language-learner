import Foundation
import UIKit

struct GrammarIssue: Identifiable, Hashable {
    let id = UUID()
    let kind: Kind
    let message: String
    let suggestion: String?

    enum Kind: String {
        case spelling
        case grammar
        case style
    }
}

struct GrammarReport {
    let issues: [GrammarIssue]
    let correctedText: String
    let scorePercent: Int
}

/// On-device writing/reading coach: spelling via UITextChecker + light grammar heuristics.
enum GrammarCoach {
    static func analyze(
        text: String,
        expected: String? = nil,
        languageCode: String,
        weekGrammarTitle: String?
    ) -> GrammarReport {
        var issues: [GrammarIssue] = []
        var working = text.trimmingCharacters(in: .whitespacesAndNewlines)

        let spelling = spellingIssues(in: working, languageCode: languageCode)
        issues.append(contentsOf: spelling.issues)
        working = spelling.corrected

        issues.append(contentsOf: heuristicGrammar(in: working, languageCode: languageCode, grammarTitle: weekGrammarTitle))

        if let expected, !expected.isEmpty {
            let similarity = SpeechPracticeEngine.similarity(working, expected)
            if similarity < 85 {
                issues.append(GrammarIssue(
                    kind: .grammar,
                    message: "Your wording differs from the model sentence.",
                    suggestion: expected
                ))
            }
            let score = max(similarity - (issues.count * 3), 0)
            return GrammarReport(issues: issues, correctedText: expected, scorePercent: min(100, score))
        }

        let penalty = min(issues.count * 8, 70)
        let score = working.isEmpty ? 0 : max(100 - penalty, 20)
        return GrammarReport(issues: issues, correctedText: working, scorePercent: score)
    }

    private static func spellingIssues(in text: String, languageCode: String) -> (issues: [GrammarIssue], corrected: String) {
        let checker = UITextChecker()
        let ns = text as NSString
        let range = NSRange(location: 0, length: ns.length)
        let lang = preferredLang(languageCode)
        var issues: [GrammarIssue] = []
        var corrected = text
        var offset = 0

        while offset < ns.length {
            let misspelled = checker.rangeOfMisspelledWord(
                in: text,
                range: range,
                startingAt: offset,
                wrap: false,
                language: lang
            )
            if misspelled.location == NSNotFound { break }

            let word = ns.substring(with: misspelled)
            let guesses = checker.guesses(forWordRange: misspelled, in: text, language: lang) ?? []
            let suggestion = guesses.first
            issues.append(GrammarIssue(
                kind: .spelling,
                message: "Check spelling: \"\(word)\"",
                suggestion: suggestion
            ))
            if let suggestion {
                if let swiftRange = Range(misspelled, in: corrected) {
                    corrected.replaceSubrange(swiftRange, with: suggestion)
                }
            }
            offset = misspelled.location + misspelled.length
        }
        return (issues, corrected)
    }

    private static func heuristicGrammar(in text: String, languageCode: String, grammarTitle: String?) -> [GrammarIssue] {
        var issues: [GrammarIssue] = []
        let lower = text.lowercased()
        let code = languageCode.prefix(2).lowercased()

        if text.first?.isLowercase == true, text.count > 1 {
            issues.append(GrammarIssue(
                kind: .grammar,
                message: "Sentences usually start with a capital letter.",
                suggestion: text.prefix(1).uppercased() + text.dropFirst()
            ))
        }

        let enders: Set<Character> = [".", "!", "?", "。", "！", "？"]
        if text.count > 12, let last = text.last, !enders.contains(last), code != "ja" && code != "zh" {
            issues.append(GrammarIssue(
                kind: .style,
                message: "Consider ending the sentence with punctuation.",
                suggestion: text + "."
            ))
        }

        // English-focused common patterns (also useful for IELTS course).
        if code == "en" || languageCode.contains("ielts") {
            let doubles = ["i am am ", "is is ", "are are ", "the the ", "a a ", "to to "]
            for d in doubles where lower.contains(d) {
                issues.append(GrammarIssue(kind: .grammar, message: "Repeated word: \"\(d.trimmingCharacters(in: .whitespaces))\"", suggestion: nil))
            }
            if lower.contains(" i ") == false, lower.hasPrefix("i ") || lower == "i" {
                // ok
            }
            if lower.contains(" i ") || lower.hasPrefix("i ") || lower.hasPrefix("i'") {
                if text.contains(" i ") || text.hasPrefix("i ") || text.hasPrefix("i'") {
                    issues.append(GrammarIssue(kind: .grammar, message: "Capitalize the pronoun \"I\".", suggestion: nil))
                }
            }
            let subjectVerb = [("he go ", "he goes"), ("she go ", "she goes"), ("it go ", "it goes"),
                               ("he do ", "he does"), ("she do ", "she does"), ("he have ", "he has"), ("she have ", "she has")]
            for (bad, good) in subjectVerb where lower.contains(bad) {
                issues.append(GrammarIssue(kind: .grammar, message: "Subject–verb agreement: try \"\(good)\".", suggestion: good))
            }
        }

        if let title = grammarTitle, !title.isEmpty {
            issues.append(GrammarIssue(
                kind: .style,
                message: "This week focuses on: \(title). Try to use it in your answer.",
                suggestion: nil
            ))
        }

        return issues
    }

    private static func preferredLang(_ code: String) -> String {
        switch code.prefix(2).lowercased() {
        case "en": return "en_US"
        case "es": return "es_ES"
        case "fr": return "fr_FR"
        case "de": return "de_DE"
        case "pt": return "pt_PT"
        case "it": return "it_IT"
        case "cs": return "cs_CZ"
        case "fi": return "fi_FI"
        case "ja": return "ja_JP"
        case "ko": return "ko_KR"
        default: return "en_US"
        }
    }

    static func languageCode(forCourseId id: String) -> String {
        switch id {
        case "ielts_english": return "en"
        case "german": return "de"
        case "spanish": return "es"
        case "french": return "fr"
        case "japanese": return "ja"
        case "korean": return "ko"
        case "czech": return "cs"
        case "finnish": return "fi"
        default: return "en"
        }
    }
}
