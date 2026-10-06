import Foundation

/// Official sample sources that actually help: same task types, timing, audio rules, and mark schemes.
struct OfficialPracticeItem: Identifiable, Hashable {
    let id: String
    let title: String
    let whyItHelps: String
    let url: URL?
    let skill: ExamSkill?
}

enum OfficialPracticeCatalog {
    static func items(for courseId: String, skill: ExamSkill) -> [OfficialPracticeItem] {
        let all = items(for: courseId)
        let matched = all.filter { $0.skill == skill }
        return matched.isEmpty ? all : matched
    }

    static func items(for courseId: String) -> [OfficialPracticeItem] {
        switch courseId {
        case "ielts_english":
            return [
                .init(id: "ielts-l-computer",
                      title: "Listening — Academic computer / online sample",
                      whyItHelps: "This is the real computer layout: 4 recordings, 40 questions, heard ONCE, questions stay on screen. Use form/note/table completion, MCQ, matching, and map labelling — not ‘listen then a vocab quiz’.",
                      url: URL(string: "https://ielts.org/take-a-test/preparation-resources/sample-test-questions/academic-test#AcademicComputerorOnlineSampleTests"),
                      skill: .listening),
                .init(id: "ielts-r-inspera",
                      title: "Reading — Academic computer player (Inspera)",
                      whyItHelps: "Official split view: passage stays visible while you answer. Practise True/False/Not Given, matching headings, summary/note completion, and MCQ on the same screen as the text.",
                      url: URL(string: "https://ielts.inspera.com/player/?assessmentRunId=189732223&context=exam#/section/145445178/question/145436122/scorableItem/3"),
                      skill: .reading),
                .init(id: "ielts-w-gt",
                      title: "Writing — British Council GT mock (Task 1 letter + Task 2 essay)",
                      whyItHelps: "One 60-minute paper: Task 1 letter (≥150 words, ~20 min) then Task 2 essay (≥250 words, ~40 min, worth more). Word count on screen. This is the format to copy, not a 40-word email labelled as Task 2.",
                      url: URL(string: "https://takeielts.britishcouncil.org/prepare/ielts-free-practice-mock-tests/general-training/writing"),
                      skill: .writing),
                .init(id: "ielts-s-ac",
                      title: "Speaking — British Council Academic mock (Parts 1–3)",
                      whyItHelps: "Full interview: Part 1 familiar questions (4–5 min), Part 2 cue card with 1 minute notes + up to 2 minutes speaking, Part 3 discussion (4–5 min). A one-line ‘tell me your name’ prompt is not Part 2.",
                      url: URL(string: "https://takeielts.britishcouncil.org/prepare/ielts-free-practice-mock-tests/academic/speaking"),
                      skill: .speaking),
                .init(id: "ielts-academic",
                      title: "IELTS Academic sample task types (ielts.org)",
                      whyItHelps: "PDF/computer extracts for every official item type, with answer keys and listening transcripts. Use after the computer familiarisation tests.",
                      url: URL(string: "https://ielts.org/take-a-test/preparation-resources/sample-test-questions/academic-test"),
                      skill: nil),
                .init(id: "ielts-gt",
                      title: "IELTS General Training sample tasks",
                      whyItHelps: "Needed if you sit GT: workplace/social reading and Task 1 letters. Listening and Speaking are the same as Academic.",
                      url: URL(string: "https://ielts.org/take-a-test/preparation-resources/sample-test-questions/general-training-test"),
                      skill: nil),
                .init(id: "ielts-bands",
                      title: "Public band descriptors (Writing & Speaking)",
                      whyItHelps: "Examiners mark fluency, coherence, lexical resource, grammar, and pronunciation. Practising without the descriptors trains the wrong habits.",
                      url: URL(string: "https://ielts.org/take-a-test/preparation-resources"),
                      skill: nil),
            ]
        case "german":
            return [
                .init(id: "goethe-model", title: "Goethe-Zertifikat Modellsatz + Übungssätze",
                      whyItHelps: "The model paper and practice sets include Hören audio, Sprechen videos, and the exact Teil structure for your level. This is the closest legal replica of test day.",
                      url: URL(string: "https://www.goethe.de/en/spr/prf.html"), skill: nil),
                .init(id: "goethe-grids", title: "Goethe assessment grids (Schreiben / Sprechen)",
                      whyItHelps: "A1 needs ~60/100. Higher levels are modular. Using the official grids beats generic ‘write an essay’ practice.",
                      url: URL(string: "https://www.goethe.de/en/spr/prf.html"), skill: nil),
            ]
        case "spanish":
            return [
                .init(id: "dele-modelos", title: "DELE modelos de examen (Cervantes)",
                      whyItHelps: "Real past papers with audio and answer keys. Train the two scoring groups (lectura+escritura / audición+oral) because you must pass both.",
                      url: URL(string: "https://examenes.cervantes.es/es/dele/preparar-prueba/modelos-examen"), skill: nil),
                .init(id: "dele-guias", title: "Guías de examen A1–C2",
                      whyItHelps: "Shows task counts, timing, and C1/C2 mediation. Unofficial apps often miss integrated skills.",
                      url: URL(string: "https://examenes.cervantes.es/es/dele/preparar-prueba"), skill: nil),
            ]
        case "french":
            return [
                .init(id: "delf-sujets", title: "DELF/DALF exemples de sujets (France Éducation international)",
                      whyItHelps: "Official sujets 0 use the real CO/CE/PE/PO timing and the 5/25 per-skill floor. Practice with two listens at A1–B1 and mixed listen counts at B2–C1.",
                      url: URL(string: "https://www.france-education-international.fr/diplome/delf-tout-public"), skill: nil),
                .init(id: "dalf-c1c2", title: "DALF C1–C2 sample papers",
                      whyItHelps: "C1 needs a synthesis + essay; C2 integrates comprehension and production. Random B2 essays will not prepare those papers.",
                      url: URL(string: "https://www.france-education-international.fr/diplome/dalf-tout-public"), skill: nil),
            ]
        case "japanese":
            return [
                .init(id: "jlpt-samples", title: "JLPT sample questions (jlpt.jp)",
                      whyItHelps: "One item per official question type (kanji, grammar, reading, listening). Use these before any third-party mock.",
                      url: URL(string: "https://www.jlpt.jp/e/samples/forlearners.html"), skill: nil),
                .init(id: "jlpt-workbook", title: "Official Practice Workbook Vol. 1 & 2",
                      whyItHelps: "Almost a full past paper per level, with audio. This is the only official full-length practice. JLPT has no speaking/writing paper — do not treat those as JLPT score.",
                      url: URL(string: "https://www.jlpt.jp/e/samples/sampleindex.html"), skill: nil),
            ]
        case "korean":
            return [
                .init(id: "topik-past", title: "NIIED / TOPIK released past papers",
                      whyItHelps: "TOPIK I is listening+reading only; TOPIK II adds 쓰기. Past papers teach the real item types (insert sentence, chart, Q53–Q54 essays).",
                      url: URL(string: "https://www.topik.go.kr"), skill: nil),
                .init(id: "topik-speaking", title: "TOPIK Speaking practice set",
                      whyItHelps: "Speaking is a separate 6-task / 30-minute test. Practising TOPIK II writing will not raise a Speaking score.",
                      url: URL(string: "https://www.topik.go.kr"), skill: nil),
            ]
        case "finnish":
            return [
                .init(id: "yki-demo", title: "YKI demonstration tasks (University of Jyväskylä)",
                      whyItHelps: "OPH points candidates here for real question types. Each subtest is graded alone — a weak writing grade is not saved by strong listening.",
                      url: URL(string: "https://www.oph.fi/en/education-and-qualifications/yki-test"), skill: nil),
                .init(id: "yki-yle", title: "Yle Ykitreenit (B1 topic pack)",
                      whyItHelps: "Uses the official YKI themes: home, services, work, health, society. Useful extra input; still pair with timed subtests.",
                      url: URL(string: "https://yle.fi/aihe/osasto/oppiminen/suomen-kielen-yki-harjoituksia"), skill: nil),
            ]
        case "czech":
            return [
                .init(id: "cce-model", title: "CCE modelová varianta (ÚJOP 2026)",
                      whyItHelps: "Current speaking is individual (not pairs). B2–C1 add the grammar/lexical paper. Older pair-speaking mocks are outdated.",
                      url: URL(string: "https://ujop.cuni.cz/UJOP-307.html"), skill: nil),
            ]
        default:
            return []
        }
    }
}
