import Foundation

struct CustomPracticePack: Codable, Hashable {
    let listening: ListeningExercise
    let speaking: SpeakingExercise
    let reading: ReadingExercise
    let writing: WritingExercise
}

struct CustomPlanDay: Codable, Hashable, Identifiable {
    let id: String
    let dayIndex: Int
    let title: String
    let skill: ExamSkill
    let officialFocus: String
    let officialSampleTitle: String
    let officialSampleURL: String
    let whyItHelps: String
    let tasks: [String]
    let pack: CustomPracticePack
}

struct CustomStudyPlan: Codable, Hashable, Identifiable {
    let id: String
    let courseId: String
    let topic: String
    let targetLevel: String
    let weeks: Int
    let minutesPerDay: Int
    let focusSkills: [ExamSkill]
    let diagnosis: String
    let days: [CustomPlanDay]
    let created: Date
}

/// On-device exam coach: diagnoses weak skills, builds a timed plan, and writes topic-specific papers
/// in the official task shapes (not live exam content).
enum CustomPlanEngine {
    static func diagnose(course: LanguageCourse, progress: ProgressStore) -> (skills: [ExamSkill], summary: String) {
        var scores: [(ExamSkill, Int)] = []
        for skill in ExamSkill.allCases {
            let values = course.weeks.compactMap { progress.skillScore(languageId: course.id, week: $0.week, skill: SkillKind(rawValue: skill.rawValue) ?? .quiz) }
            if let avg = values.isEmpty ? nil : values.reduce(0, +) / values.count {
                scores.append((skill, avg))
            }
        }
        let official = Set(course.examFramework?.officialSkills ?? ExamSkill.allCases.map(\.rawValue))
        let ranked = scores.filter { official.contains($0.0.rawValue) }.sorted { $0.1 < $1.1 }
        if ranked.isEmpty {
            let fallback = (course.examFramework?.officialSkills ?? ["listening", "speaking", "reading", "writing"])
                .compactMap { ExamSkill(rawValue: $0) }
            return (Array(fallback.prefix(2)), "No skill scores yet — the plan starts with the official papers for this exam.")
        }
        let weak = ranked.prefix(2).map(\.0)
        let bits = ranked.map { "\($0.0.rawValue) \($0.1)%" }.joined(separator: ", ")
        return (weak, "Weakest official skills from your mocks: \(bits). Extra days go there.")
    }

    static func build(
        course: LanguageCourse,
        progress: ProgressStore,
        topic: String,
        targetLevel: String,
        weeks: Int,
        minutesPerDay: Int,
        extraFocus: [ExamSkill]
    ) -> CustomStudyPlan {
        let diagnosis = diagnose(course: course, progress: progress)
        var focus = extraFocus
        for skill in diagnosis.skills where !focus.contains(skill) {
            focus.append(skill)
        }
        let officialSkills = (course.examFramework?.officialSkills ?? []).compactMap { ExamSkill(rawValue: $0) }
        let rotation = officialSkills.isEmpty ? ExamSkill.allCases : officialSkills
        if focus.isEmpty { focus = Array(rotation.prefix(2)) }

        let dayCount = max(weeks * 4, 6)
        let papers = course.examFramework?.skillPapers ?? [:]
        let seedWeek = course.weeks(forLevel: targetLevel).last ?? course.weeks.last
        let topicClean = topic.trimmingCharacters(in: .whitespacesAndNewlines)
        let topicOrDefault = topicClean.isEmpty ? defaultTopic(course.id) : topicClean

        var days: [CustomPlanDay] = []
        for i in 0..<dayCount {
            let skill: ExamSkill
            if i % 3 == 0, let weak = focus[safe: (i / 3) % focus.count] {
                skill = weak
            } else {
                skill = rotation[i % rotation.count]
            }
            let sample = OfficialPracticeCatalog.items(for: course.id, skill: skill).first
                ?? OfficialPracticeCatalog.items(for: course.id).first
            let paper = papers[skill.rawValue]
            let pack = makePack(
                course: course,
                level: targetLevel,
                topic: topicOrDefault,
                day: i + 1,
                seed: seedWeek,
                minutes: minutesPerDay
            )
            let tasks = dayTasks(skill: skill, minutes: minutesPerDay, paper: paper, topic: topicOrDefault, courseId: course.id)
            days.append(CustomPlanDay(
                id: "\(course.id)-d\(i + 1)-\(skill.rawValue)",
                dayIndex: i + 1,
                title: "Day \(i + 1) · \(paper?.officialName ?? skill.rawValue.capitalized)",
                skill: skill,
                officialFocus: paper?.parts?.first ?? skill.rawValue,
                officialSampleTitle: sample?.title ?? "",
                officialSampleURL: sample?.url?.absoluteString ?? "",
                whyItHelps: sample?.whyItHelps ?? "",
                tasks: tasks,
                pack: pack
            ))
        }

        return CustomStudyPlan(
            id: UUID().uuidString,
            courseId: course.id,
            topic: topicOrDefault,
            targetLevel: targetLevel,
            weeks: weeks,
            minutesPerDay: minutesPerDay,
            focusSkills: focus,
            diagnosis: diagnosis.summary,
            days: days,
            created: Date()
        )
    }

    static func makePack(
        course: LanguageCourse,
        level: String,
        topic: String,
        day: Int,
        seed: CourseWeek?,
        minutes: Int
    ) -> CustomPracticePack {
        let lang = languageCode(course.id)
        let play = ["ielts_english", "japanese", "korean"].contains(course.id) ? 1 : 2
        let minWords = writingMin(level, courseId: course.id)
        let lines = listeningLines(lang: lang, topic: topic, seed: seed)
        let listenQs = listeningQuestions(topic: topic, lines: lines, courseId: course.id)
        let speak = speakingPair(lang: lang, topic: topic, courseId: course.id, level: level, seed: seed)
        let passage = readingPassage(lang: lang, topic: topic, seed: seed, level: level, courseId: course.id)
        let write = writingTask(lang: lang, topic: topic, courseId: course.id, level: level, minWords: minWords)
        let listenInstruction = course.id == "ielts_english"
            ? "Computer sample: questions stay on screen. The recording plays ONCE. Complete the notes as you listen. Topic: \(topic)."
            : (play == 1
                ? "Official rule: play once. Questions stay on screen. Topic: \(topic)."
                : "Official rule: you may listen twice. Questions stay on screen. Topic: \(topic).")

        return CustomPracticePack(
            listening: ListeningExercise(
                id: "custom-\(course.id)-L\(day)",
                title: listeningTitle(course.id),
                instruction: listenInstruction,
                audioLines: lines,
                questions: listenQs,
                playLimit: play
            ),
            speaking: SpeakingExercise(
                id: "custom-\(course.id)-S\(day)",
                title: speakingTitle(course.id, level: level),
                instruction: speak.instruction,
                examinerQuestion: speak.question,
                modelAnswer: speak.answer,
                tip: "Stay on \(topic). Use this level’s grammar: \(seed?.grammar.title ?? level).",
                cueBullets: speak.bullets,
                prepSeconds: speak.prep,
                speakSeconds: speak.limit
            ),
            reading: ReadingExercise(
                id: "custom-\(course.id)-R\(day)",
                title: readingTitle(course.id),
                instruction: course.id == "ielts_english"
                    ? "Computer sample (Inspera style): keep the passage visible. Use True/False/Not Given and detail questions. ~\(max(8, minutes / 2)) min."
                    : "Keep the passage visible under exam timing (~\(max(8, minutes / 2)) min), then answer.",
                passage: passage.body,
                questions: passage.questions
            ),
            writing: WritingExercise(
                id: "custom-\(course.id)-W\(day)",
                title: writingTitle(course.id, level: level),
                instruction: write.instruction,
                prompt: write.prompt,
                modelAnswer: write.model,
                minWords: minWords,
                minutes: write.minutes
            )
        )
    }

    private static func defaultTopic(_ courseId: String) -> String {
        switch courseId {
        case "finnish": return "koti ja työ"
        case "czech": return "škola a město"
        case "korean": return "일상과 직장"
        case "japanese": return "学校と旅行"
        case "german": return "Wohnen und Arbeit"
        case "french": return "la ville et le travail"
        case "spanish": return "la ciudad y el trabajo"
        default: return "study and daily life"
        }
    }

    private static func writingMin(_ level: String, courseId: String = "") -> Int {
        let cefr = ExamScoreMapper.cefrBase(from: level)
        if courseId == "ielts_english" {
            switch cefr {
            case "A1": return 80
            case "A2": return 120
            default: return 250
            }
        }
        switch cefr {
        case "A1": return 40
        case "A2": return 60
        case "B1": return 120
        case "B2": return 180
        case "C1": return 250
        default: return 300
        }
    }

    private static func languageCode(_ courseId: String) -> String {
        ["ielts_english": "en", "spanish": "es", "french": "fr", "german": "de",
         "czech": "cs", "finnish": "fi", "japanese": "ja", "korean": "ko"][courseId] ?? "en"
    }

    private static func listeningTitle(_ courseId: String) -> String {
        switch courseId {
        case "german": return "Hören — custom topic"
        case "french": return "CO — sujet personnalisé"
        case "spanish": return "Comprensión auditiva — tema propio"
        case "japanese": return "聴解 — カスタム話題"
        case "korean": return "듣기 — 맞춤 주제"
        case "finnish": return "Puheen ymmärtäminen — oma aihe"
        case "czech": return "Poslech — vlastní téma"
        default: return "Listening Part 1 — note completion on your topic"
        }
    }

    private static func speakingTitle(_ courseId: String, level: String) -> String {
        if courseId == "korean" { return "TOPIK Speaking task — your topic" }
        if courseId == "japanese" { return "JF Can-do speaking (not on JLPT)" }
        if courseId == "ielts_english" { return "Speaking Part 2 cue card — your topic" }
        return "Speaking — \(level)"
    }

    private static func readingTitle(_ courseId: String) -> String {
        switch courseId {
        case "japanese": return "読解 — カスタム短文"
        case "korean": return "읽기 — 맞춤 지문"
        default: return "Reading — passage stays visible"
        }
    }

    private static func writingTitle(_ courseId: String, level: String) -> String {
        if courseId == "ielts_english" {
            return ExamScoreMapper.cefrBase(from: level) == "A1" || ExamScoreMapper.cefrBase(from: level) == "A2"
                ? "Writing Task 1 — GT letter on your topic"
                : "Writing Task 2 — essay (≥250 words, ~40 min)"
        }
        if courseId == "korean", ["A1", "A2"].contains(ExamScoreMapper.cefrBase(from: level)) {
            return "Classroom writing (not on TOPIK I)"
        }
        if courseId == "japanese" { return "JF Can-do writing (not on JLPT)" }
        return "Writing — your topic"
    }

    private static func dayTasks(skill: ExamSkill, minutes: Int, paper: SkillPaperSpec?, topic: String, courseId: String) -> [String] {
        let warm = max(5, minutes / 6)
        let main = max(10, minutes / 2)
        let review = max(5, minutes - warm - main)
        var tasks = [
            "\(warm) min — review official task type: \(paper?.parts?.first ?? skill.rawValue)",
            "\(main) min — timed custom paper on “\(topic)”",
            "\(review) min — check against the model and note 3 phrases to reuse",
        ]
        if courseId == "ielts_english", skill == .listening {
            tasks.insert("Open the official computer Listening sample first (questions on screen, once only).", at: 0)
        }
        if courseId == "ielts_english", skill == .reading {
            tasks.insert("Open the Inspera Academic Reading sample — passage stays beside the questions.", at: 0)
        }
        if courseId == "ielts_english", skill == .writing {
            tasks.insert("Open the British Council GT Writing mock: Task 1 letter 150 words, Task 2 essay 250 words.", at: 0)
        }
        if courseId == "ielts_english", skill == .speaking {
            tasks.insert("Open the British Council Academic Speaking mock: Part 1, cue card + 1 min notes, Part 3.", at: 0)
        }
        if courseId == "japanese", skill == .speaking || skill == .writing {
            tasks.append("This skill is classroom Can-do only — it is not scored on JLPT.")
        }
        return tasks
    }

    private static func listeningLines(lang: String, topic: String, seed: CourseWeek?) -> [String] {
        let seedLines = seed?.dialogue.map(\.line) ?? []
        let custom: [String]
        switch lang {
        case "de":
            custom = [
                "Guten Tag. Ich möchte Informationen zu \(topic).",
                "Natürlich. \(topic) ist wichtig für den Alltag.",
                "Wann können wir darüber sprechen?",
                "Heute Nachmittag um drei, wenn das passt.",
            ]
        case "fr":
            custom = [
                "Bonjour, je cherche des informations sur \(topic).",
                "Bien sûr. \(topic) concerne beaucoup de gens ici.",
                "On peut en parler aujourd’hui ?",
                "Oui, cet après-midi à quinze heures.",
            ]
        case "es":
            custom = [
                "Hola, necesito información sobre \(topic).",
                "Claro. \(topic) es un tema habitual en la ciudad.",
                "¿Podemos hablar de eso hoy?",
                "Sí, esta tarde a las tres.",
            ]
        case "cs":
            custom = [
                "Dobrý den, chtěl bych informace o tématu \(topic).",
                "Samozřejmě. \(topic) je v každodenním životě důležité.",
                "Můžeme si o tom promluvit dnes?",
                "Ano, odpoledne ve tři.",
            ]
        case "fi":
            custom = [
                "Hei, tarvitsen tietoa aiheesta \(topic).",
                "Totta kai. \(topic) liittyy arkeen.",
                "Voidaanko puhua siitä tänään?",
                "Kyllä, iltapäivällä kello kolme.",
            ]
        case "ja":
            custom = [
                "こんにちは。\(topic)について教えてください。",
                "はい。\(topic)は毎日の生活に関係があります。",
                "今日話せますか。",
                "午後三時はどうですか。",
            ]
        case "ko":
            custom = [
                "안녕하세요. \(topic)에 대해 알고 싶어요.",
                "네. \(topic)은 일상에서 자주 나와요.",
                "오늘 이야기할 수 있을까요?",
                "오후 세 시는 어때요?",
            ]
        default:
            custom = [
                "Hello, I need information about \(topic).",
                "Of course. \(topic) comes up a lot in daily life.",
                "Can we talk about it today?",
                "Yes, this afternoon at three if that works.",
            ]
        }
        if seedLines.count >= 2 {
            return custom + [seedLines[0], seedLines[min(1, seedLines.count - 1)]]
        }
        return custom
    }

    private static func listeningQuestions(topic: String, lines: [String], courseId: String) -> [QuizQuestion] {
        if courseId == "ielts_english" {
            return [
                QuizQuestion(
                    question: "Complete the notes. Topic of the enquiry:",
                    options: [topic, "Sports results only", "Airline tickets", "Weather for sailors"],
                    answerIndex: 0,
                    explanation: "The speakers ask for information about \(topic).",
                    taskType: "noteCompletion"
                ),
                QuizQuestion(
                    question: "Complete the notes. Suggested time:",
                    options: ["this afternoon at three", "midnight only", "next year", "never"],
                    answerIndex: 0,
                    explanation: "They arrange to talk later the same day.",
                    taskType: "noteCompletion"
                ),
                QuizQuestion(
                    question: "The first speaker wants information.",
                    options: ["True", "False", "Not Given"],
                    answerIndex: 0,
                    explanation: "The opening line asks for information.",
                    taskType: "tfng"
                ),
            ]
        }
        return [
            QuizQuestion(question: "What is the conversation mainly about?",
                         options: [topic, "Sports results only", "Airline tickets", "Weather for sailors"],
                         answerIndex: 0,
                         explanation: "The speakers ask for and give information about \(topic)."),
            QuizQuestion(question: "What is said first?",
                         options: [lines[0], lines[min(1, lines.count - 1)], topic, "…"],
                         answerIndex: 0,
                         explanation: "Listen for the opening line."),
            QuizQuestion(question: "When do they suggest talking?",
                         options: ["In the afternoon", "Next year only", "Never", "At midnight only"],
                         answerIndex: 0,
                         explanation: "The arrangement is later the same day."),
        ]
    }

    private static func speakingPair(lang: String, topic: String, courseId: String, level: String, seed: CourseWeek?) -> (instruction: String, question: String, answer: String, bullets: [String]?, prep: Int?, limit: Int?) {
        if courseId == "ielts_english" {
            return (
                "British Council Academic mock style: 1 minute to make notes, then speak for up to 2 minutes. Do not stop until the time is up if you can keep going.",
                "Describe \(topic).",
                "I’d like to talk about \(topic). It is part of my daily life. I will say what it is, why it matters, and how it might change. For example, I deal with it every week, so I can give a clear reason and a short story.",
                ["what \(topic) is", "why it is important to you", "how it might change in the future", "and explain how you feel about it"],
                60,
                120
            )
        }
        if courseId == "korean" {
            return (
                "TOPIK Speaking-style: answer, then give a short opinion.",
                "\(topic)에 대해 간단히 설명하고, 좋은 점과 어려운 점을 말해 보세요.",
                "\(topic)은 제 일상과 관련이 있어요. 장점은 실용적이고, 어려운 점은 시간이 필요하다는 점이에요.",
                nil, nil, nil
            )
        }
        let bullets: [String]? = nil
        switch lang {
        case "de":
            return ("Goethe Sprechen: answer in full sentences.",
                    "Erzählen Sie von \(topic). Warum ist das Thema wichtig?",
                    "\(topic) ist für mich wichtig, weil ich es im Alltag brauche. Ich übe, klar und höflich zu antworten.",
                    bullets, nil, nil)
        case "fr":
            return ("DELF production orale.",
                    "Parlez de \(topic). Pourquoi ce sujet est-il important pour vous ?",
                    "\(topic) est important dans ma vie quotidienne. Je donne un exemple et une raison simple.",
                    bullets, nil, nil)
        case "es":
            return ("DELE expresión oral.",
                    "Hable de \(topic). ¿Por qué le interesa?",
                    "\(topic) me interesa porque forma parte de mi día a día. Puedo dar un ejemplo concreto.",
                    bullets, nil, nil)
        case "cs":
            return ("CCE mluvení.",
                    "Mluvte o tématu \(topic). Proč je důležité?",
                    "Téma \(topic) je pro mě důležité v běžném životě. Uvedu krátký příklad.",
                    bullets, nil, nil)
        case "fi":
            return ("YKI puhuminen.",
                    "Kerro aiheesta \(topic). Miksi se on sinulle tärkeä?",
                    "\(topic) liittyy arkeeni. Kerron lyhyen esimerkin ja perustelun.",
                    bullets, nil, nil)
        case "ja":
            return ("JF Can-do speaking (not an official JLPT paper).",
                    "\(topic)について話してください。なぜ大切ですか。",
                    "\(topic)は毎日の生活に関係があります。理由と例を一つ言います。",
                    bullets, nil, nil)
        default:
            let q = seed?.interviewPrompts.first?.examinerQuestion
            return ("Answer in full sentences at \(level).",
                    q ?? "Tell me about \(topic) and why it matters.",
                    "\(topic) matters in my routine. I can give a short reason and one example.",
                    bullets, nil, nil)
        }
    }

    private static func readingPassage(lang: String, topic: String, seed: CourseWeek?, level: String, courseId: String) -> (body: String, questions: [QuizQuestion]) {
        let extra = seed?.resolvedStudyPack.readingPassage.body ?? ""
        let body: String
        switch lang {
        case "de":
            body = "Heute geht es um \(topic). Viele Menschen brauchen klare Informationen, um Entscheidungen zu treffen. Ein kurzer Text erklärt den Nutzen, mögliche Probleme und einen nächsten Schritt. \(extra.prefix(280))"
        case "fr":
            body = "Ce texte présente \(topic). On y trouve un exemple concret, un avantage et une difficulté. L’objectif est de comprendre l’idée principale et un détail. \(extra.prefix(280))"
        case "es":
            body = "Este texto trata de \(topic). Describe una situación cotidiana, un beneficio y un problema. Lea con atención la idea principal. \(extra.prefix(280))"
        case "cs":
            body = "Text se týká tématu \(topic). Najdete tu hlavní myšlenku, jeden detail a krátký závěr. \(extra.prefix(280))"
        case "fi":
            body = "Tämä teksti käsittelee aihetta \(topic). Siinä on pääasia, yksi yksityiskohta ja lyhyt johtopäätös. \(extra.prefix(280))"
        case "ja":
            body = "この文章は\(topic)についてです。主な内容と一つの理由を読み取ってください。 \(extra.prefix(200))"
        case "ko":
            body = "이 글의 주제는 \(topic)입니다. 중심 생각과 세부 정보를 찾아 보세요. \(extra.prefix(200))"
        default:
            body = "This short exam-style text is about \(topic). It explains why the topic appears in daily life, one benefit, and one difficulty. After reading, you should be able to name the main idea and a supporting detail. \(extra.prefix(320))"
        }
        let qs: [QuizQuestion]
        if courseId == "ielts_english" {
            qs = [
                QuizQuestion(
                    question: "The text is mainly about \(topic).",
                    options: ["True", "False", "Not Given"],
                    answerIndex: 0,
                    explanation: "The passage is built around \(topic).",
                    taskType: "tfng"
                ),
                QuizQuestion(
                    question: "The writer gives an exact price for \(topic).",
                    options: ["True", "False", "Not Given"],
                    answerIndex: 2,
                    explanation: "No price is stated, so the answer is Not Given.",
                    taskType: "tfng"
                ),
                QuizQuestion(
                    question: "Which heading best fits the passage?",
                    options: ["Why \(topic) matters in daily life", "A football match report", "Airline safety rules", "A cooking recipe"],
                    answerIndex: 0,
                    explanation: "Match the heading to the main idea, as on the computer reading paper.",
                    taskType: "matching"
                ),
            ]
        } else {
            qs = [
                QuizQuestion(question: "Main topic of the text?",
                             options: [topic, "A football score", "A train delay only", "A cooking recipe only"],
                             answerIndex: 0, explanation: "The passage is built around your chosen topic."),
                QuizQuestion(question: "What should you do after reading?",
                             options: ["Answer the questions from the text", "Ignore the passage", "Delete your notes", "Change the exam date"],
                             answerIndex: 0, explanation: "Official reading papers always ask you to use the text."),
                QuizQuestion(question: "Which level is this drill targeting?",
                             options: [ExamScoreMapper.cefrBase(from: level), "Driving test", "Music grade", "First aid"],
                             answerIndex: 0, explanation: "The plan is locked to your selected exam level."),
            ]
        }
        return (String(body), qs)
    }

    private static func writingTask(lang: String, topic: String, courseId: String, level: String, minWords: Int) -> (instruction: String, prompt: String, model: String, minutes: Int?) {
        let cefr = ExamScoreMapper.cefrBase(from: level)
        if courseId == "ielts_english" {
            if cefr == "A1" || cefr == "A2" {
                return (
                    "GT Writing Task 1 style (British Council mock): write a letter. Aim for the word count. You should spend about 20 minutes on Task 1 in the full test.",
                    "You are starting a course related to \(topic). Write a letter to the school. In your letter:\n• say who you are\n• explain why you need the course\n• ask two questions about times or fees\nWrite at least \(minWords) words.",
                    "Dear Sir or Madam, My name is Sara Ahmed and I would like to join a class about \(topic). I need this course because it is part of my daily life and I must explain it clearly in English. Could you tell me which days the class meets and whether I need to bring a photo for a student card? I look forward to your reply. Yours faithfully, Sara Ahmed",
                    20
                )
            }
            return (
                "British Council mock style: Task 2 essay. Spend about 40 minutes. Write at least 250 words and give a clear position.",
                "Some people think schools should teach \(topic). Others say families should deal with it at home. Discuss both views and give your own opinion. Write at least \(minWords) words.",
                "\(topic) affects daily decisions, so schools can teach it with examples and timed practice. Others argue families should lead because the topic is personal. I believe both sides matter if the goal is real communication, not only test scores. A short classroom task plus discussion at home is a practical way to prepare for the Writing paper.",
                40
            )
        }
        switch lang {
        case "de":
            return ("Schreiben Sie in ganzen Sätzen.",
                    "Schreiben Sie eine E-Mail zum Thema \(topic) (mindestens \(minWords) Wörter).",
                    "Liebe Frau Müller, ich schreibe wegen \(topic). Können wir nächsten Dienstag darüber sprechen? Mit freundlichen Grüßen",
                    nil)
        case "fr":
            return ("Rédigez en phrases complètes.",
                    "Écrivez un message sur \(topic) (\(minWords)+ mots).",
                    "Bonjour, je vous écris au sujet de \(topic). Pouvez-vous m’aider demain après-midi ? Merci.",
                    nil)
        case "es":
            return ("Escriba oraciones completas.",
                    "Escriba un correo sobre \(topic) (\(minWords)+ palabras).",
                    "Hola, le escribo por \(topic). ¿Podemos hablar el martes? Gracias.",
                    nil)
        case "cs":
            return ("Pište celými větami.",
                    "Napište e-mail na téma \(topic) (min. \(minWords) slov).",
                    "Dobrý den, píšu kvůli tématu \(topic). Můžeme se sejít v úterý? Děkuji.",
                    nil)
        case "fi":
            return ("Kirjoita kokonaisin lausein.",
                    "Kirjoita viesti aiheesta \(topic) (vähintään \(minWords) sanaa).",
                    "Hei, kirjoitan aiheesta \(topic). Voimmeko puhua huomenna? Terveisin",
                    nil)
        case "ja":
            return ("JLPTには作文がありません。教室用Can-doです。",
                    "\(topic)について短いメールを書いてください。",
                    "お疲れさまです。\(topic)について相談したいです。明日話せますか。",
                    nil)
        case "ko":
            return (cefr == "A1" || cefr == "A2"
                    ? "TOPIK I has no writing paper. Classroom practice only."
                    : "TOPIK II 쓰기: 설명 후 의견을 쓰세요.",
                    "\(topic)에 대해 \(minWords)자/단어 이상으로 쓰세요.",
                    "\(topic)은 일상과 관련이 있습니다. 장점과 이유를 짧게 설명합니다.",
                    nil)
        default:
            return ("Write in full sentences.",
                    "Write about \(topic) (\(minWords)+ words).",
                    "I want to write about \(topic) because it appears in my daily life. I will give one reason and one example.",
                    nil)
        }
    }
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
