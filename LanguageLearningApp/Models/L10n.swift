import Foundation

/// UI copy in the learner's regional language. Learning material stays in the target language.
enum L10n {
    static func t(_ key: Key, _ code: String) -> String {
        table[key]?[normalized(code)] ?? table[key]?["en"] ?? key.rawValue
    }

    enum Key: String {
        case appName
        case launchTagline
        case chooseRegionalTitle
        case chooseRegionalSubtitle
        case chooseCourseTitle
        case chooseCourseSubtitle
        case continueButton
        case startLearning
        case dashboard
        case yourCourse
        case weeklyProgress
        case thisWeek
        case weekScores
        case score
        case completed
        case notStarted
        case startWeek
        case continueWeek
        case skills
        case listening
        case speaking
        case reading
        case writing
        case quiz
        case study
        case vocabulary
        case grammar
        case cultureNote
        case overview
        case playAIVoice
        case stop
        case listenAndAnswer
        case yourAnswer
        case checkAnswer
        case next
        case finish
        case speakWithAI
        case tapToSpeak
        case tapToStop
        case aiTutorPrompt
        case yourSpeech
        case accuracy
        case tryAgain
        case saveScore
        case readingArticle
        case startReading
        case rewriteSentence
        case checkGrammar
        case corrections
        case writingPrompt
        case writeHere
        case checkWriting
        case words
        case sentences
        case flashcards
        case startQuiz
        case results
        case saveFinish
        case settings
        case changeCourse
        case changeUILanguage
        case regionalLanguage
        case learningLanguage
        case level
        case week
        case perfect
        case goodJob
        case keepPracticing
        case noCourseLoaded
        case contentError
        case micPermission
        case listeningExam
        case speakingExam
        case weeklyPrepExam
        case skillScores
        case averageScore
        case ofWeeks
        case done
        case hint
        case correct
        case incorrect
        case modelAnswer
        case humanoidCoach
        case playPrompt
        case recordAnswer
        case noIssues
        case spellingIssues
        case grammarTips
        case articleReady
        case typeAsYouRead
        case showTranslation
        case hideTranslation
        case backToDashboard
        case resetCourse
        case nextWord
        case seeResults
        case nextQuestion
        case tapToFlip
        case youScored
        case permissionNeeded
        case currentLevel
        case levels
        case levelPassed
        case speakingInterview
        case knowledgeQuiz
        case quizHub
        case endOfWeekInterview
        case passToUnlock
        case speakingPassHint
        case levelsProgress
        case realtimeInterview
        case realtimeInterviewHint
        case startRealtimeInterview
        case aiAsking
        case yourTurnToSpeak
        case listeningToYou
        case speakNow
        case imDoneSpeaking
        case aiSpeaking
        case pleaseWait
        case aiEvaluating
        case evaluationReport
        case strengths
        case improvements
        case turnByTurn
        case improvedAnswer
        case hearCorrection
        case relevance
        case fluency
        case question
        case examMode
        case timeRemaining
        case reviewAnswers
        case hideScript
        case showScriptAfter
        case listeningOnlyHint
        case submitExam
        case studyPrepPack
        case studyPackIntro
        case exportPDF
        case learningObjectives
        case canDoStatements
        case readingPassage
        case grammarDeepDive
        case keyPhrases
        case worksheet
        case showWorksheetAnswers
        case tryYourselfFirst
        case prepChecklist
        case examTips
        case selfStudyPlan
        case focusWords
        case mockExercises
        case mockPracticeIntro
        case practiceExercises123
        case takeOfficialExam
        case examReadyAfterPrep
        case examLockedHint
        case viewScorecard
        case officialLevelExam
        case examCoversSkills
        case startOfficialExam
        case officialScorecard
        case overallScore
        case awardedLevel
        case targetLevel
        case scorecardFootnote
        case latestOfficialResult
        case officialPapers
        case classroomPractice
        case classroomPracticeHint
        case capstoneExamHint
        case jlptSkillsNote
        case topikIWritingNote
        case examPapers
        case aiCoach
        case coachIntro
        case buildPlan
        case topicPlaceholder
        case planWeeks
        case minutesPerDay
        case generatePlan
        case officialSamples
        case savedPlans
        case questionsOnScreen
        case submitAnswers
        case startPrep
        case prepareSeconds
        case prepareNotes
        case startSpeakingNow
        case speakSecondsLeft
        case cueCard
        case youShouldSay
        case classroomPaperNote
        case openOfficialSample
    }

    private static func normalized(_ code: String) -> String {
        let base = code.split(separator: "-").first.map(String.init) ?? code
        return base.lowercased()
    }

    private static let table: [Key: [String: String]] = [
        .appName: [
            "en": "LinguaPath", "es": "LinguaPath", "fr": "LinguaPath", "de": "LinguaPath",
            "pt": "LinguaPath", "it": "LinguaPath", "cs": "LinguaPath", "fi": "LinguaPath",
            "ja": "LinguaPath", "ko": "LinguaPath", "ar": "LinguaPath", "ur": "LinguaPath",
            "zh": "LinguaPath", "hi": "LinguaPath"
        ],
        .launchTagline: [
            "en": "Your path to the real exam",
            "es": "Tu camino al examen real",
            "fr": "Votre chemin vers l’examen réel",
            "de": "Ihr Weg zur echten Prüfung",
            "pt": "Seu caminho para o exame real",
            "it": "La tua strada verso l’esame vero",
            "cs": "Vaše cesta ke skutečné zkoušce",
            "fi": "Polkusi oikeaan kokeeseen",
            "ja": "本番試験への道",
            "ko": "실제 시험으로 가는 길",
            "ar": "طريقك إلى الامتحان الحقيقي",
            "ur": "اصل امتحان تک آپ کا راستہ",
            "zh": "通往真实考试之路",
            "hi": "असली परीक्षा तक आपका रास्ता"
        ],
        .chooseRegionalTitle: [
            "en": "What's your language?", "es": "¿Cuál es tu idioma?", "fr": "Quelle est votre langue ?",
            "de": "Was ist Ihre Sprache?", "pt": "Qual é o seu idioma?", "it": "Qual è la tua lingua?",
            "cs": "Jaký je váš jazyk?", "fi": "Mikä on kielesi?", "ja": "あなたの言語は？",
            "ko": "사용 언어는 무엇인가요?", "ar": "ما لغتك؟", "ur": "آپ کی زبان کیا ہے؟",
            "zh": "你使用哪种语言？", "hi": "आपकी भाषा क्या है?"
        ],
        .chooseRegionalSubtitle: [
            "en": "We'll show the app in this language. Lessons stay in the language you're learning.",
            "es": "Mostraremos la app en este idioma. Las lecciones seguirán en el idioma que aprendes.",
            "fr": "L'application s'affichera dans cette langue. Les leçons restent dans la langue apprise.",
            "de": "Die App erscheint in dieser Sprache. Lerninhalte bleiben in der Zielsprache.",
            "pt": "O app será neste idioma. As lições ficam no idioma que você está aprendendo.",
            "it": "Mostreremo l'app in questa lingua. Le lezioni restano nella lingua che stai imparando.",
            "cs": "Aplikaci zobrazíme v tomto jazyce. Výuka zůstane v cílovém jazyce.",
            "fi": "Näytämme sovelluksen tällä kielellä. Oppimateriaali pysyy opiskeltavassa kielessä.",
            "ja": "アプリはこの言語で表示します。学習教材は学ぶ言語のままです。",
            "ko": "앱은 이 언어로 표시됩니다. 학습 자료는 배우는 언어로 유지됩니다.",
            "ar": "سنعرض التطبيق بهذه اللغة. تبقى الدروس بلغة التعلم.",
            "ur": "ایپ اس زبان میں دکھائی دے گی۔ سبق سیکھی جانے والی زبان میں رہیں گے۔",
            "zh": "应用将以此语言显示。学习材料仍使用目标语言。",
            "hi": "ऐप इसी भाषा में दिखेगा। पाठ आपकी सीखने वाली भाषा में रहेंगे।"
        ],
        .chooseCourseTitle: [
            "en": "What do you want to learn?", "es": "¿Qué quieres aprender?",
            "fr": "Que voulez-vous apprendre ?", "de": "Was möchten Sie lernen?",
            "pt": "O que você quer aprender?", "it": "Cosa vuoi imparare?",
            "cs": "Co se chcete naučit?", "fi": "Mitä haluat oppia?",
            "ja": "何を学びたいですか？", "ko": "무엇을 배우고 싶나요?",
            "ar": "ماذا تريد أن تتعلم؟", "ur": "آپ کیا سیکھنا چاہتے ہیں؟",
            "zh": "你想学什么？", "hi": "आप क्या सीखना चाहते हैं?"
        ],
        .chooseCourseSubtitle: [
            "en": "You'll follow one full course with weekly listening, speaking, reading, and writing exams.",
            "es": "Seguirás un solo curso con exámenes semanales de listening, speaking, reading y writing.",
            "fr": "Vous suivrez un seul cours avec examens hebdomadaires d'écoute, oral, lecture et écriture.",
            "de": "Sie folgen einem Kurs mit wöchentlichen Hör-, Sprech-, Lese- und Schreibprüfungen.",
            "pt": "Você fará um único curso com provas semanais de escuta, fala, leitura e escrita.",
            "it": "Seguirai un solo corso con esami settimanali di ascolto, parlato, lettura e scrittura.",
            "cs": "Budete mít jeden kurz s týdenními zkouškami poslechu, mluvení, čtení a psaní.",
            "fi": "Seuraat yhtä kurssia viikoittaisilla kuuntelu-, puhe-, luku- ja kirjoituskokeilla.",
            "ja": "毎週の聴く・話す・読む・書く試験がある1つのコースを進めます。",
            "ko": "듣기·말하기·읽기·쓰기 주간 시험이 있는 하나의 코스를 진행합니다.",
            "ar": "ستتبع دورة واحدة مع اختبارات أسبوعية للاستماع والتحدث والقراءة والكتابة.",
            "ur": "آپ ایک کورس کریں گے جس میں ہفتہ وار سننے، بولنے، پڑھنے اور لکھنے کے امتحان ہوں گے۔",
            "zh": "你将学习一门完整课程，含每周听说读写测验。",
            "hi": "आप एक पूरा कोर्स करेंगे जिसमें साप्ताहिक सुनना, बोलना, पढ़ना और लिखना परीक्षा होगी।"
        ],
        .continueButton: [
            "en": "Continue", "es": "Continuar", "fr": "Continuer", "de": "Weiter",
            "pt": "Continuar", "it": "Continua", "cs": "Pokračovat", "fi": "Jatka",
            "ja": "続ける", "ko": "계속", "ar": "متابعة", "ur": "جاری رکھیں",
            "zh": "继续", "hi": "जारी रखें"
        ],
        .startLearning: [
            "en": "Start learning", "es": "Empezar a aprender", "fr": "Commencer", "de": "Lernen starten",
            "pt": "Começar a aprender", "it": "Inizia a imparare", "cs": "Začít se učit", "fi": "Aloita oppiminen",
            "ja": "学習を始める", "ko": "학습 시작", "ar": "ابدأ التعلم", "ur": "سیکھنا شروع کریں",
            "zh": "开始学习", "hi": "सीखना शुरू करें"
        ],
        .dashboard: [
            "en": "Dashboard", "es": "Panel", "fr": "Tableau de bord", "de": "Übersicht",
            "pt": "Painel", "it": "Dashboard", "cs": "Přehled", "fi": "Kojelauta",
            "ja": "ダッシュボード", "ko": "대시보드", "ar": "لوحة التحكم", "ur": "ڈیش بورڈ",
            "zh": "学习主页", "hi": "डैशबोर्ड"
        ],
        .yourCourse: [
            "en": "Your course", "es": "Tu curso", "fr": "Votre cours", "de": "Ihr Kurs",
            "pt": "Seu curso", "it": "Il tuo corso", "cs": "Váš kurz", "fi": "Kurssisi",
            "ja": "あなたのコース", "ko": "내 코스", "ar": "دورتك", "ur": "آپ کا کورس",
            "zh": "你的课程", "hi": "आपका कोर्स"
        ],
        .weeklyProgress: [
            "en": "Weekly progress", "es": "Progreso semanal", "fr": "Progression hebdomadaire", "de": "Wochenfortschritt",
            "pt": "Progresso semanal", "it": "Progresso settimanale", "cs": "Týdenní pokrok", "fi": "Viikon edistyminen",
            "ja": "週間の進捗", "ko": "주간 진도", "ar": "التقدم الأسبوعي", "ur": "ہفتہ وار پیش رفت",
            "zh": "每周进度", "hi": "साप्ताहिक प्रगति"
        ],
        .thisWeek: [
            "en": "This week", "es": "Esta semana", "fr": "Cette semaine", "de": "Diese Woche",
            "pt": "Esta semana", "it": "Questa settimana", "cs": "Tento týden", "fi": "Tämä viikko",
            "ja": "今週", "ko": "이번 주", "ar": "هذا الأسبوع", "ur": "اس ہفتے",
            "zh": "本周", "hi": "इस सप्ताह"
        ],
        .weekScores: [
            "en": "Week scores", "es": "Puntuaciones semanales", "fr": "Scores de la semaine", "de": "Wochenwerte",
            "pt": "Notas da semana", "it": "Punteggi settimanali", "cs": "Týdenní skóre", "fi": "Viikon pisteet",
            "ja": "週のスコア", "ko": "주간 점수", "ar": "درجات الأسبوع", "ur": "ہفتہ وار اسکور",
            "zh": "每周得分", "hi": "सप्ताह स्कोर"
        ],
        .score: [
            "en": "Score", "es": "Puntuación", "fr": "Score", "de": "Punktzahl",
            "pt": "Pontuação", "it": "Punteggio", "cs": "Skóre", "fi": "Pisteet",
            "ja": "スコア", "ko": "점수", "ar": "النتيجة", "ur": "اسکور",
            "zh": "得分", "hi": "स्कोर"
        ],
        .completed: [
            "en": "Completed", "es": "Completado", "fr": "Terminé", "de": "Abgeschlossen",
            "pt": "Concluído", "it": "Completato", "cs": "Dokončeno", "fi": "Valmis",
            "ja": "完了", "ko": "완료", "ar": "مكتمل", "ur": "مکمل",
            "zh": "已完成", "hi": "पूर्ण"
        ],
        .notStarted: [
            "en": "Not started", "es": "Sin empezar", "fr": "Pas commencé", "de": "Nicht begonnen",
            "pt": "Não iniciado", "it": "Non iniziato", "cs": "Nezačato", "fi": "Ei aloitettu",
            "ja": "未開始", "ko": "미시작", "ar": "لم يبدأ", "ur": "شروع نہیں ہوا",
            "zh": "未开始", "hi": "शुरू नहीं"
        ],
        .startWeek: [
            "en": "Start week", "es": "Empezar semana", "fr": "Commencer la semaine", "de": "Woche starten",
            "pt": "Começar semana", "it": "Inizia settimana", "cs": "Začít týden", "fi": "Aloita viikko",
            "ja": "週を始める", "ko": "주 시작", "ar": "ابدأ الأسبوع", "ur": "ہفتہ شروع کریں",
            "zh": "开始本周", "hi": "सप्ताह शुरू करें"
        ],
        .continueWeek: [
            "en": "Continue week", "es": "Continuar semana", "fr": "Continuer la semaine", "de": "Woche fortsetzen",
            "pt": "Continuar semana", "it": "Continua settimana", "cs": "Pokračovat v týdnu", "fi": "Jatka viikkoa",
            "ja": "週を続ける", "ko": "주 이어하기", "ar": "تابع الأسبوع", "ur": "ہفتہ جاری رکھیں",
            "zh": "继续本周", "hi": "सप्ताह जारी रखें"
        ],
        .skills: [
            "en": "Skills", "es": "Habilidades", "fr": "Compétences", "de": "Fertigkeiten",
            "pt": "Habilidades", "it": "Abilità", "cs": "Dovednosti", "fi": "Taidot",
            "ja": "スキル", "ko": "스킬", "ar": "المهارات", "ur": "مہارتیں",
            "zh": "技能", "hi": "कौशल"
        ],
        .listening: [
            "en": "Listening", "es": "Listening", "fr": "Écoute", "de": "Hören",
            "pt": "Escuta", "it": "Ascolto", "cs": "Poslech", "fi": "Kuuntelu",
            "ja": "リスニング", "ko": "듣기", "ar": "الاستماع", "ur": "سننا",
            "zh": "听力", "hi": "सुनना"
        ],
        .speaking: [
            "en": "Speaking", "es": "Speaking", "fr": "Expression orale", "de": "Sprechen",
            "pt": "Fala", "it": "Parlato", "cs": "Mluvení", "fi": "Puhuminen",
            "ja": "スピーキング", "ko": "말하기", "ar": "التحدث", "ur": "بولنا",
            "zh": "口语", "hi": "बोलना"
        ],
        .reading: [
            "en": "Reading", "es": "Reading", "fr": "Lecture", "de": "Lesen",
            "pt": "Leitura", "it": "Lettura", "cs": "Čtení", "fi": "Lukeminen",
            "ja": "リーディング", "ko": "읽기", "ar": "القراءة", "ur": "پڑھنا",
            "zh": "阅读", "hi": "पढ़ना"
        ],
        .writing: [
            "en": "Writing", "es": "Writing", "fr": "Écriture", "de": "Schreiben",
            "pt": "Escrita", "it": "Scrittura", "cs": "Psaní", "fi": "Kirjoittaminen",
            "ja": "ライティング", "ko": "쓰기", "ar": "الكتابة", "ur": "لکھنا",
            "zh": "写作", "hi": "लिखना"
        ],
        .quiz: [
            "en": "Quiz", "es": "Cuestionario", "fr": "Quiz", "de": "Quiz",
            "pt": "Quiz", "it": "Quiz", "cs": "Kvíz", "fi": "Tietovisa",
            "ja": "クイズ", "ko": "퀴즈", "ar": "اختبار", "ur": "کوئز",
            "zh": "测验", "hi": "क्विज़"
        ],
        .study: [
            "en": "Study", "es": "Estudiar", "fr": "Étudier", "de": "Lernen",
            "pt": "Estudar", "it": "Studia", "cs": "Učit se", "fi": "Opiskele",
            "ja": "学習", "ko": "학습", "ar": "دراسة", "ur": "مطالعہ",
            "zh": "学习", "hi": "अध्ययन"
        ],
        .vocabulary: [
            "en": "Vocabulary", "es": "Vocabulario", "fr": "Vocabulaire", "de": "Wortschatz",
            "pt": "Vocabulário", "it": "Vocabolario", "cs": "Slovní zásoba", "fi": "Sanasto",
            "ja": "語彙", "ko": "어휘", "ar": "المفردات", "ur": "الفاظ",
            "zh": "词汇", "hi": "शब्दावली"
        ],
        .grammar: [
            "en": "Grammar", "es": "Gramática", "fr": "Grammaire", "de": "Grammatik",
            "pt": "Gramática", "it": "Grammatica", "cs": "Gramatika", "fi": "Kielioppi",
            "ja": "文法", "ko": "문법", "ar": "القواعد", "ur": "گرامر",
            "zh": "语法", "hi": "व्याकरण"
        ],
        .cultureNote: [
            "en": "Culture note", "es": "Nota cultural", "fr": "Note culturelle", "de": "Kulturhinweis",
            "pt": "Nota cultural", "it": "Nota culturale", "cs": "Kulturní poznámka", "fi": "Kulttuurivihje",
            "ja": "文化メモ", "ko": "문화 노트", "ar": "ملاحظة ثقافية", "ur": "ثقافتی نوٹ",
            "zh": "文化提示", "hi": "सांस्कृतिक नोट"
        ],
        .overview: [
            "en": "Overview", "es": "Resumen", "fr": "Aperçu", "de": "Überblick",
            "pt": "Visão geral", "it": "Panoramica", "cs": "Přehled", "fi": "Yhteenveto",
            "ja": "概要", "ko": "개요", "ar": "نظرة عامة", "ur": "جائزہ",
            "zh": "概览", "hi": "अवलोकन"
        ],
        .playAIVoice: [
            "en": "Play AI tutor voice", "es": "Reproducir voz del tutor IA", "fr": "Lire la voix du tuteur IA",
            "de": "KI-Tutorstimme abspielen", "pt": "Ouvir voz do tutor IA", "it": "Riproduci voce tutor IA",
            "cs": "Přehrát hlas AI tutora", "fi": "Toista AI-tutorin ääni", "ja": "AIチューターの音声を再生",
            "ko": "AI 튜터 음성 재생", "ar": "تشغيل صوت المعلم الذكي", "ur": "AI ٹیوٹر کی آواز چلائیں",
            "zh": "播放 AI 导师语音", "hi": "AI ट्यूटर आवाज़ चलाएँ"
        ],
        .stop: [
            "en": "Stop", "es": "Detener", "fr": "Arrêter", "de": "Stopp",
            "pt": "Parar", "it": "Stop", "cs": "Stop", "fi": "Pysäytä",
            "ja": "停止", "ko": "중지", "ar": "إيقاف", "ur": "روکیں",
            "zh": "停止", "hi": "रोकें"
        ],
        .listenAndAnswer: [
            "en": "Listen & answer", "es": "Escucha y responde", "fr": "Écoutez et répondez", "de": "Hören & antworten",
            "pt": "Ouça e responda", "it": "Ascolta e rispondi", "cs": "Poslouchej a odpovídej", "fi": "Kuuntele ja vastaa",
            "ja": "聞いて答える", "ko": "듣고 답하기", "ar": "استمع وأجب", "ur": "سنیں اور جواب دیں",
            "zh": "听后作答", "hi": "सुनें और उत्तर दें"
        ],
        .yourAnswer: [
            "en": "Your answer", "es": "Tu respuesta", "fr": "Votre réponse", "de": "Ihre Antwort",
            "pt": "Sua resposta", "it": "La tua risposta", "cs": "Vaše odpověď", "fi": "Vastauksesi",
            "ja": "あなたの答え", "ko": "내 답", "ar": "إجابتك", "ur": "آپ کا جواب",
            "zh": "你的答案", "hi": "आपका उत्तर"
        ],
        .checkAnswer: [
            "en": "Check answer", "es": "Comprobar respuesta", "fr": "Vérifier", "de": "Antwort prüfen",
            "pt": "Verificar resposta", "it": "Controlla risposta", "cs": "Zkontrolovat", "fi": "Tarkista vastaus",
            "ja": "答えを確認", "ko": "답 확인", "ar": "تحقق من الإجابة", "ur": "جواب چیک کریں",
            "zh": "检查答案", "hi": "उत्तर जाँचें"
        ],
        .next: [
            "en": "Next", "es": "Siguiente", "fr": "Suivant", "de": "Weiter",
            "pt": "Próximo", "it": "Avanti", "cs": "Další", "fi": "Seuraava",
            "ja": "次へ", "ko": "다음", "ar": "التالي", "ur": "اگلا",
            "zh": "下一步", "hi": "अगला"
        ],
        .finish: [
            "en": "Finish", "es": "Terminar", "fr": "Terminer", "de": "Fertig",
            "pt": "Concluir", "it": "Fine", "cs": "Dokončit", "fi": "Valmis",
            "ja": "完了", "ko": "완료", "ar": "إنهاء", "ur": "ختم",
            "zh": "完成", "hi": "समाप्त"
        ],
        .speakWithAI: [
            "en": "Speak with AI tutor", "es": "Habla con el tutor IA", "fr": "Parlez au tuteur IA",
            "de": "Mit KI-Tutor sprechen", "pt": "Fale com o tutor IA", "it": "Parla con il tutor IA",
            "cs": "Mluvte s AI tutorem", "fi": "Puhu AI-tutorille", "ja": "AIチューターと話す",
            "ko": "AI 튜터와 말하기", "ar": "تحدث مع المعلم الذكي", "ur": "AI ٹیوٹر سے بات کریں",
            "zh": "与 AI 导师对话", "hi": "AI ट्यूटर से बात करें"
        ],
        .tapToSpeak: [
            "en": "Tap to speak", "es": "Toca para hablar", "fr": "Appuyez pour parler", "de": "Tippen zum Sprechen",
            "pt": "Toque para falar", "it": "Tocca per parlare", "cs": "Klepněte pro mluvení", "fi": "Napauta puhuaksesi",
            "ja": "タップして話す", "ko": "탭하여 말하기", "ar": "انقر للتحدث", "ur": "بولنے کے لیے ٹیپ کریں",
            "zh": "点按说话", "hi": "बोलने के लिए टैप करें"
        ],
        .tapToStop: [
            "en": "Tap to stop", "es": "Toca para detener", "fr": "Appuyez pour arrêter", "de": "Tippen zum Stoppen",
            "pt": "Toque para parar", "it": "Tocca per fermare", "cs": "Klepněte pro stop", "fi": "Napauta lopettaaksesi",
            "ja": "タップして停止", "ko": "탭하여 중지", "ar": "انقر للإيقاف", "ur": "روکنے کے لیے ٹیپ کریں",
            "zh": "点按停止", "hi": "रोकने के लिए टैप करें"
        ],
        .aiTutorPrompt: [
            "en": "AI tutor prompt", "es": "Pregunta del tutor IA", "fr": "Invite du tuteur IA",
            "de": "KI-Tutor-Aufforderung", "pt": "Pergunta do tutor IA", "it": "Prompt del tutor IA",
            "cs": "Výzva AI tutora", "fi": "AI-tutorin kehote", "ja": "AIチューターの質問",
            "ko": "AI 튜터 질문", "ar": "سؤال المعلم الذكي", "ur": "AI ٹیوٹر کا سوال",
            "zh": "AI 导师提示", "hi": "AI ट्यूटर प्रश्न"
        ],
        .yourSpeech: [
            "en": "What you said", "es": "Lo que dijiste", "fr": "Ce que vous avez dit", "de": "Was Sie gesagt haben",
            "pt": "O que você disse", "it": "Cosa hai detto", "cs": "Co jste řekli", "fi": "Mitä sanoit",
            "ja": "あなたの発話", "ko": "말한 내용", "ar": "ما قلته", "ur": "آپ نے کیا کہا",
            "zh": "你说的内容", "hi": "आपने क्या कहा"
        ],
        .accuracy: [
            "en": "Accuracy", "es": "Precisión", "fr": "Précision", "de": "Genauigkeit",
            "pt": "Precisão", "it": "Accuratezza", "cs": "Přesnost", "fi": "Tarkkuus",
            "ja": "正確さ", "ko": "정확도", "ar": "الدقة", "ur": "درستگی",
            "zh": "准确度", "hi": "सटीकता"
        ],
        .tryAgain: [
            "en": "Try again", "es": "Intentar de nuevo", "fr": "Réessayer", "de": "Nochmal versuchen",
            "pt": "Tentar de novo", "it": "Riprova", "cs": "Zkusit znovu", "fi": "Yritä uudelleen",
            "ja": "もう一度", "ko": "다시 시도", "ar": "حاول مرة أخرى", "ur": "دوبارہ کوشش",
            "zh": "再试一次", "hi": "फिर कोशिश करें"
        ],
        .saveScore: [
            "en": "Save score", "es": "Guardar puntuación", "fr": "Enregistrer le score", "de": "Punktzahl speichern",
            "pt": "Salvar pontuação", "it": "Salva punteggio", "cs": "Uložit skóre", "fi": "Tallenna pisteet",
            "ja": "スコアを保存", "ko": "점수 저장", "ar": "حفظ النتيجة", "ur": "اسکور محفوظ کریں",
            "zh": "保存得分", "hi": "स्कोर सहेजें"
        ],
        .readingArticle: [
            "en": "Reading article", "es": "Artículo de lectura", "fr": "Article de lecture", "de": "Leseartikel",
            "pt": "Artigo de leitura", "it": "Articolo di lettura", "cs": "Článek ke čtení", "fi": "Lukuartikkeli",
            "ja": "読解文章", "ko": "읽기 지문", "ar": "مقال القراءة", "ur": "پڑھنے کا مضمون",
            "zh": "阅读文章", "hi": "पठन लेख"
        ],
        .startReading: [
            "en": "Start reading practice", "es": "Empezar práctica de lectura", "fr": "Commencer la lecture",
            "de": "Lesepraxis starten", "pt": "Começar leitura", "it": "Inizia lettura",
            "cs": "Začít čtení", "fi": "Aloita lukuharjoitus", "ja": "読解練習を始める",
            "ko": "읽기 연습 시작", "ar": "ابدأ تمرين القراءة", "ur": "پڑھنے کی مشق شروع کریں",
            "zh": "开始阅读练习", "hi": "पठन अभ्यास शुरू करें"
        ],
        .rewriteSentence: [
            "en": "Rewrite this sentence correctly", "es": "Reescribe esta frase correctamente",
            "fr": "Réécrivez cette phrase correctement", "de": "Schreiben Sie diesen Satz korrekt um",
            "pt": "Reescreva esta frase corretamente", "it": "Riscrivi questa frase correttamente",
            "cs": "Přepište tuto větu správně", "fi": "Kirjoita tämä lause oikein",
            "ja": "この文を正しく書き直してください", "ko": "이 문장을 올바르게 다시 쓰세요",
            "ar": "أعد كتابة هذه الجملة بشكل صحيح", "ur": "اس جملے کو درست لکھیں",
            "zh": "请正确改写这句话", "hi": "इस वाक्य को सही लिखें"
        ],
        .checkGrammar: [
            "en": "Check grammar", "es": "Revisar gramática", "fr": "Vérifier la grammaire", "de": "Grammatik prüfen",
            "pt": "Verificar gramática", "it": "Controlla grammatica", "cs": "Zkontrolovat gramatiku", "fi": "Tarkista kielioppi",
            "ja": "文法をチェック", "ko": "문법 확인", "ar": "تحقق من القواعد", "ur": "گرامر چیک کریں",
            "zh": "检查语法", "hi": "व्याकरण जाँचें"
        ],
        .corrections: [
            "en": "Corrections", "es": "Correcciones", "fr": "Corrections", "de": "Korrekturen",
            "pt": "Correções", "it": "Correzioni", "cs": "Opravy", "fi": "Korjaukset",
            "ja": "添削", "ko": "교정", "ar": "التصحيحات", "ur": "تصحیحات",
            "zh": "批改", "hi": "सुधार"
        ],
        .writingPrompt: [
            "en": "Writing prompt", "es": "Tema de escritura", "fr": "Sujet d'écriture", "de": "Schreibaufgabe",
            "pt": "Tema de escrita", "it": "Traccia di scrittura", "cs": "Téma psaní", "fi": "Kirjoitustehtävä",
            "ja": "ライティング課題", "ko": "쓰기 주제", "ar": "موضوع الكتابة", "ur": "لکھنے کا موضوع",
            "zh": "写作题目", "hi": "लेखन विषय"
        ],
        .writeHere: [
            "en": "Write your response here…", "es": "Escribe tu respuesta aquí…", "fr": "Écrivez votre réponse ici…",
            "de": "Schreiben Sie Ihre Antwort hier…", "pt": "Escreva sua resposta aqui…", "it": "Scrivi la tua risposta qui…",
            "cs": "Napište odpověď sem…", "fi": "Kirjoita vastauksesi tähän…", "ja": "ここに書いてください…",
            "ko": "여기에 답변을 쓰세요…", "ar": "اكتب إجابتك هنا…", "ur": "اپنا جواب یہاں لکھیں…",
            "zh": "在此写下你的回答…", "hi": "यहाँ अपना उत्तर लिखें…"
        ],
        .checkWriting: [
            "en": "Check writing", "es": "Revisar escritura", "fr": "Vérifier l'écrit", "de": "Schreiben prüfen",
            "pt": "Verificar escrita", "it": "Controlla scrittura", "cs": "Zkontrolovat psaní", "fi": "Tarkista kirjoitus",
            "ja": "作文をチェック", "ko": "쓰기 확인", "ar": "تحقق من الكتابة", "ur": "تحریر چیک کریں",
            "zh": "检查写作", "hi": "लेखन जाँचें"
        ],
        .words: [
            "en": "Words", "es": "Palabras", "fr": "Mots", "de": "Wörter",
            "pt": "Palavras", "it": "Parole", "cs": "Slova", "fi": "Sanat",
            "ja": "単語", "ko": "단어", "ar": "كلمات", "ur": "الفاظ",
            "zh": "单词", "hi": "शब्द"
        ],
        .sentences: [
            "en": "Sentences", "es": "Frases", "fr": "Phrases", "de": "Sätze",
            "pt": "Frases", "it": "Frasi", "cs": "Věty", "fi": "Lauseet",
            "ja": "文", "ko": "문장", "ar": "جمل", "ur": "جملے",
            "zh": "句子", "hi": "वाक्य"
        ],
        .flashcards: [
            "en": "Flashcards", "es": "Tarjetas", "fr": "Flashcards", "de": "Karteikarten",
            "pt": "Flashcards", "it": "Flashcard", "cs": "Karty", "fi": "Muistikortit",
            "ja": "フラッシュカード", "ko": "플래시카드", "ar": "بطاقات", "ur": "فلیش کارڈز",
            "zh": "闪卡", "hi": "फ्लैशकार्ड"
        ],
        .startQuiz: [
            "en": "Start quiz", "es": "Empezar cuestionario", "fr": "Commencer le quiz", "de": "Quiz starten",
            "pt": "Começar quiz", "it": "Inizia quiz", "cs": "Spustit kvíz", "fi": "Aloita tietovisa",
            "ja": "クイズ開始", "ko": "퀴즈 시작", "ar": "ابدأ الاختبار", "ur": "کوئز شروع کریں",
            "zh": "开始测验", "hi": "क्विज़ शुरू करें"
        ],
        .results: [
            "en": "Results", "es": "Resultados", "fr": "Résultats", "de": "Ergebnisse",
            "pt": "Resultados", "it": "Risultati", "cs": "Výsledky", "fi": "Tulokset",
            "ja": "結果", "ko": "결과", "ar": "النتائج", "ur": "نتائج",
            "zh": "结果", "hi": "परिणाम"
        ],
        .saveFinish: [
            "en": "Save & finish", "es": "Guardar y terminar", "fr": "Enregistrer et terminer", "de": "Speichern & fertig",
            "pt": "Salvar e concluir", "it": "Salva e finisci", "cs": "Uložit a dokončit", "fi": "Tallenna ja lopeta",
            "ja": "保存して完了", "ko": "저장 후 완료", "ar": "حفظ وإنهاء", "ur": "محفوظ کریں اور ختم کریں",
            "zh": "保存并完成", "hi": "सहेजें और समाप्त करें"
        ],
        .settings: [
            "en": "Settings", "es": "Ajustes", "fr": "Réglages", "de": "Einstellungen",
            "pt": "Configurações", "it": "Impostazioni", "cs": "Nastavení", "fi": "Asetukset",
            "ja": "設定", "ko": "설정", "ar": "الإعدادات", "ur": "ترتیبات",
            "zh": "设置", "hi": "सेटिंग्स"
        ],
        .changeCourse: [
            "en": "Change course", "es": "Cambiar curso", "fr": "Changer de cours", "de": "Kurs wechseln",
            "pt": "Trocar curso", "it": "Cambia corso", "cs": "Změnit kurz", "fi": "Vaihda kurssia",
            "ja": "コースを変更", "ko": "코스 변경", "ar": "تغيير الدورة", "ur": "کورس بدلیں",
            "zh": "更换课程", "hi": "कोर्स बदलें"
        ],
        .changeUILanguage: [
            "en": "App language", "es": "Idioma de la app", "fr": "Langue de l'app", "de": "App-Sprache",
            "pt": "Idioma do app", "it": "Lingua dell'app", "cs": "Jazyk aplikace", "fi": "Sovelluksen kieli",
            "ja": "アプリの言語", "ko": "앱 언어", "ar": "لغة التطبيق", "ur": "ایپ کی زبان",
            "zh": "应用语言", "hi": "ऐप भाषा"
        ],
        .regionalLanguage: [
            "en": "Your language", "es": "Tu idioma", "fr": "Votre langue", "de": "Ihre Sprache",
            "pt": "Seu idioma", "it": "La tua lingua", "cs": "Váš jazyk", "fi": "Kielesi",
            "ja": "あなたの言語", "ko": "내 언어", "ar": "لغتك", "ur": "آپ کی زبان",
            "zh": "你的语言", "hi": "आपकी भाषा"
        ],
        .learningLanguage: [
            "en": "Learning", "es": "Aprendiendo", "fr": "Apprentissage", "de": "Lernen",
            "pt": "Aprendendo", "it": "Stai imparando", "cs": "Učíte se", "fi": "Opiskelet",
            "ja": "学習中", "ko": "학습 중", "ar": "تتعلم", "ur": "سیکھ رہے ہیں",
            "zh": "正在学习", "hi": "सीख रहे हैं"
        ],
        .level: [
            "en": "Level", "es": "Nivel", "fr": "Niveau", "de": "Niveau",
            "pt": "Nível", "it": "Livello", "cs": "Úroveň", "fi": "Taso",
            "ja": "レベル", "ko": "레벨", "ar": "المستوى", "ur": "سطح",
            "zh": "级别", "hi": "स्तर"
        ],
        .week: [
            "en": "Week", "es": "Semana", "fr": "Semaine", "de": "Woche",
            "pt": "Semana", "it": "Settimana", "cs": "Týden", "fi": "Viikko",
            "ja": "週", "ko": "주", "ar": "أسبوع", "ur": "ہفتہ",
            "zh": "周", "hi": "सप्ताह"
        ],
        .perfect: [
            "en": "Perfect!", "es": "¡Perfecto!", "fr": "Parfait !", "de": "Perfekt!",
            "pt": "Perfeito!", "it": "Perfetto!", "cs": "Perfektní!", "fi": "Täydellistä!",
            "ja": "完璧！", "ko": "완벽해요!", "ar": "ممتاز!", "ur": "بہترین!",
            "zh": "完美！", "hi": "शानदार!"
        ],
        .goodJob: [
            "en": "Good job!", "es": "¡Bien hecho!", "fr": "Bien joué !", "de": "Gut gemacht!",
            "pt": "Bom trabalho!", "it": "Ottimo lavoro!", "cs": "Dobrá práce!", "fi": "Hyvää työtä!",
            "ja": "よくできました！", "ko": "잘했어요!", "ar": "أحسنت!", "ur": "شاباش!",
            "zh": "做得好！", "hi": "शाबाश!"
        ],
        .keepPracticing: [
            "en": "Keep practicing", "es": "Sigue practicando", "fr": "Continuez à vous entraîner", "de": "Weiter üben",
            "pt": "Continue praticando", "it": "Continua a esercitarti", "cs": "Pokračujte v praxi", "fi": "Jatka harjoittelua",
            "ja": "練習を続けましょう", "ko": "계속 연습하세요", "ar": "واصل التمرين", "ur": "مشق جاری رکھیں",
            "zh": "继续练习", "hi": "अभ्यास जारी रखें"
        ],
        .noCourseLoaded: [
            "en": "Couldn't load course", "es": "No se pudo cargar el curso", "fr": "Impossible de charger le cours",
            "de": "Kurs konnte nicht geladen werden", "pt": "Não foi possível carregar o curso", "it": "Impossibile caricare il corso",
            "cs": "Kurz se nepodařilo načíst", "fi": "Kurssia ei voitu ladata", "ja": "コースを読み込めませんでした",
            "ko": "코스를 불러올 수 없습니다", "ar": "تعذر تحميل الدورة", "ur": "کورس لوڈ نہیں ہو سکا",
            "zh": "无法加载课程", "hi": "कोर्स लोड नहीं हो सका"
        ],
        .contentError: [
            "en": "Couldn't load content", "es": "No se pudo cargar el contenido", "fr": "Impossible de charger le contenu",
            "de": "Inhalt konnte nicht geladen werden", "pt": "Não foi possível carregar o conteúdo", "it": "Impossibile caricare i contenuti",
            "cs": "Obsah se nepodařilo načíst", "fi": "Sisältöä ei voitu ladata", "ja": "コンテンツを読み込めませんでした",
            "ko": "콘텐츠를 불러올 수 없습니다", "ar": "تعذر تحميل المحتوى", "ur": "مواد لوڈ نہیں ہو سکا",
            "zh": "无法加载内容", "hi": "सामग्री लोड नहीं हो सकी"
        ],
        .micPermission: [
            "en": "Microphone access is needed for speaking practice.",
            "es": "Se necesita el micrófono para la práctica de speaking.",
            "fr": "L'accès au micro est nécessaire pour l'oral.",
            "de": "Mikrofonzugriff wird für die Sprechübung benötigt.",
            "pt": "É necessário acesso ao microfone para a prática de fala.",
            "it": "Serve l'accesso al microfono per il parlato.",
            "cs": "Pro mluvení je potřeba přístup k mikrofonu.",
            "fi": "Puheharjoitteluun tarvitaan mikrofonin käyttöoikeus.",
            "ja": "スピーキング練習にはマイクへのアクセスが必要です。",
            "ko": "말하기 연습에는 마이크 권한이 필요합니다.",
            "ar": "يلزم الوصول إلى الميكروفون لتدريب التحدث.",
            "ur": "بولنے کی مشق کے لیے مائیکروفون درکار ہے۔",
            "zh": "口语练习需要麦克风权限。",
            "hi": "बोलने के अभ्यास के लिए माइक्रोफ़ोन की अनुमति चाहिए।"
        ],
        .listeningExam: [
            "en": "Listening exam", "es": "Examen de listening", "fr": "Examen d'écoute", "de": "Hörprüfung",
            "pt": "Prova de escuta", "it": "Esame di ascolto", "cs": "Poslechová zkouška", "fi": "Kuuntelukoe",
            "ja": "リスニング試験", "ko": "듣기 시험", "ar": "اختبار الاستماع", "ur": "سننے کا امتحان",
            "zh": "听力考试", "hi": "सुनना परीक्षा"
        ],
        .speakingExam: [
            "en": "Speaking exam", "es": "Examen de speaking", "fr": "Examen oral", "de": "Sprechprüfung",
            "pt": "Prova de fala", "it": "Esame orale", "cs": "Ústní zkouška", "fi": "Puhekkoe",
            "ja": "スピーキング試験", "ko": "말하기 시험", "ar": "اختبار التحدث", "ur": "بولنے کا امتحان",
            "zh": "口语考试", "hi": "बोलना परीक्षा"
        ],
        .weeklyPrepExam: [
            "en": "Weekly prep exam", "es": "Examen semanal de preparación", "fr": "Examen hebdomadaire",
            "de": "Wöchentliche Vorbereitung", "pt": "Prova semanal", "it": "Esame settimanale",
            "cs": "Týdenní přípravná zkouška", "fi": "Viikon valmistautumiskoe", "ja": "週次対策試験",
            "ko": "주간 준비 시험", "ar": "امتحان التحضير الأسبوعي", "ur": "ہفتہ وار تیاری کا امتحان",
            "zh": "每周备考", "hi": "साप्ताहिक तैयारी परीक्षा"
        ],
        .skillScores: [
            "en": "Skill scores", "es": "Puntuaciones por habilidad", "fr": "Scores par compétence", "de": "Fertigkeitswerte",
            "pt": "Notas por habilidade", "it": "Punteggi per abilità", "cs": "Skóre dovedností", "fi": "Taitopisteet",
            "ja": "スキル別スコア", "ko": "스킬 점수", "ar": "درجات المهارات", "ur": "مہارت کے اسکور",
            "zh": "技能得分", "hi": "कौशल स्कोर"
        ],
        .averageScore: [
            "en": "Average", "es": "Media", "fr": "Moyenne", "de": "Durchschnitt",
            "pt": "Média", "it": "Media", "cs": "Průměr", "fi": "Keskiarvo",
            "ja": "平均", "ko": "평균", "ar": "المتوسط", "ur": "اوسط",
            "zh": "平均", "hi": "औसत"
        ],
        .ofWeeks: [
            "en": "weeks done", "es": "semanas hechas", "fr": "semaines terminées", "de": "Wochen erledigt",
            "pt": "semanas concluídas", "it": "settimane fatte", "cs": "týdnů hotovo", "fi": "viikkoa valmiina",
            "ja": "週完了", "ko": "주 완료", "ar": "أسابيع مكتملة", "ur": "ہفتے مکمل",
            "zh": "周已完成", "hi": "सप्ताह पूर्ण"
        ],
        .done: [
            "en": "Done", "es": "Listo", "fr": "Terminé", "de": "Fertig",
            "pt": "Pronto", "it": "Fatto", "cs": "Hotovo", "fi": "Valmis",
            "ja": "完了", "ko": "완료", "ar": "تم", "ur": "ہو گیا",
            "zh": "完成", "hi": "हो गया"
        ],
        .hint: [
            "en": "Hint", "es": "Pista", "fr": "Indice", "de": "Hinweis",
            "pt": "Dica", "it": "Suggerimento", "cs": "Nápověda", "fi": "Vihje",
            "ja": "ヒント", "ko": "힌트", "ar": "تلميح", "ur": "اشارہ",
            "zh": "提示", "hi": "संकेत"
        ],
        .correct: [
            "en": "Correct", "es": "Correcto", "fr": "Correct", "de": "Richtig",
            "pt": "Correto", "it": "Corretto", "cs": "Správně", "fi": "Oikein",
            "ja": "正解", "ko": "정답", "ar": "صحيح", "ur": "درست",
            "zh": "正确", "hi": "सही"
        ],
        .incorrect: [
            "en": "Incorrect", "es": "Incorrecto", "fr": "Incorrect", "de": "Falsch",
            "pt": "Incorreto", "it": "Errato", "cs": "Nesprávně", "fi": "Väärin",
            "ja": "不正解", "ko": "오답", "ar": "غير صحيح", "ur": "غلط",
            "zh": "不正确", "hi": "गलत"
        ],
        .modelAnswer: [
            "en": "Model answer", "es": "Respuesta modelo", "fr": "Réponse modèle", "de": "Musterantwort",
            "pt": "Resposta modelo", "it": "Risposta modello", "cs": "Vzorová odpověď", "fi": "Mallivastaus",
            "ja": "模範解答", "ko": "모범 답안", "ar": "إجابة نموذجية", "ur": "نمونہ جواب",
            "zh": "参考答案", "hi": "आदर्श उत्तर"
        ],
        .humanoidCoach: [
            "en": "AI humanoid coach", "es": "Coach humanoide IA", "fr": "Coach humanoïde IA",
            "de": "KI-Humanoid-Coach", "pt": "Coach humanoide IA", "it": "Coach umanoide IA",
            "cs": "AI humanoidní kouč", "fi": "AI-humanoidivalmentaja", "ja": "AIヒューマノイドコーチ",
            "ko": "AI 휴머노이드 코치", "ar": "مدرب بشري ذكي", "ur": "AI ہیومنائیڈ کوچ",
            "zh": "AI 人形教练", "hi": "AI ह्यूमनॉइड कोच"
        ],
        .playPrompt: [
            "en": "Play prompt", "es": "Reproducir pregunta", "fr": "Lire la question", "de": "Aufforderung abspielen",
            "pt": "Ouvir pergunta", "it": "Riproduci domanda", "cs": "Přehrát výzvu", "fi": "Toista kehote",
            "ja": "質問を再生", "ko": "질문 재생", "ar": "تشغيل السؤال", "ur": "سوال چلائیں",
            "zh": "播放提示", "hi": "प्रश्न चलाएँ"
        ],
        .recordAnswer: [
            "en": "Record your answer", "es": "Graba tu respuesta", "fr": "Enregistrez votre réponse",
            "de": "Antwort aufnehmen", "pt": "Grave sua resposta", "it": "Registra la risposta",
            "cs": "Nahrajte odpověď", "fi": "Nauhoita vastauksesi", "ja": "答えを録音",
            "ko": "답변 녹음", "ar": "سجّل إجابتك", "ur": "اپنا جواب ریکارڈ کریں",
            "zh": "录制你的回答", "hi": "अपना उत्तर रिकॉर्ड करें"
        ],
        .noIssues: [
            "en": "No issues found. Great work!", "es": "Sin problemas. ¡Excelente!", "fr": "Aucun problème. Super !",
            "de": "Keine Probleme gefunden. Super!", "pt": "Nenhum problema. Ótimo!", "it": "Nessun problema. Ottimo!",
            "cs": "Žádné chyby. Skvělé!", "fi": "Ei ongelmia. Hienoa!", "ja": "問題なし。よくできました！",
            "ko": "문제 없음. 잘했어요!", "ar": "لا توجد مشكلات. رائع!", "ur": "کوئی مسئلہ نہیں۔ شاباش!",
            "zh": "未发现问题。做得好！", "hi": "कोई समस्या नहीं। बहुत अच्छा!"
        ],
        .spellingIssues: [
            "en": "Spelling", "es": "Ortografía", "fr": "Orthographe", "de": "Rechtschreibung",
            "pt": "Ortografia", "it": "Ortografia", "cs": "Pravopis", "fi": "Oikeinkirjoitus",
            "ja": "スペル", "ko": "철자", "ar": "الإملاء", "ur": "ہجے",
            "zh": "拼写", "hi": "वर्तनी"
        ],
        .grammarTips: [
            "en": "Grammar tips", "es": "Consejos de gramática", "fr": "Conseils de grammaire", "de": "Grammatik-Tipps",
            "pt": "Dicas de gramática", "it": "Suggerimenti grammaticali", "cs": "Gramatické tipy", "fi": "Kielioppi­vinkit",
            "ja": "文法のヒント", "ko": "문법 팁", "ar": "نصائح قواعدية", "ur": "گرامر کے مشورے",
            "zh": "语法提示", "hi": "व्याकरण सुझाव"
        ],
        .articleReady: [
            "en": "Read the article in your learning language, then rewrite each line. We'll correct grammar as you go.",
            "es": "Lee el artículo en el idioma que aprendes y reescribe cada línea. Corregiremos la gramática sobre la marcha.",
            "fr": "Lisez l'article dans la langue apprise, puis réécrivez chaque ligne. Nous corrigeons au fur et à mesure.",
            "de": "Lesen Sie den Artikel in der Lernsprache und schreiben Sie jede Zeile um. Wir korrigieren die Grammatik laufend.",
            "pt": "Leia o artigo no idioma que está aprendendo e reescreva cada linha. Corrigimos a gramática no caminho.",
            "it": "Leggi l'articolo nella lingua di studio e riscrivi ogni riga. Correggiamo la grammatica lungo il percorso.",
            "cs": "Přečtěte článek v cílovém jazyce a přepište každý řádek. Gramatiku opravíme průběžně.",
            "fi": "Lue artikkeli opiskeltavalla kielellä ja kirjoita jokainen rivi uudelleen. Korjaamme kieliopin matkan varrella.",
            "ja": "学習言語の文章を読み、各行を書き直してください。文法を随時添削します。",
            "ko": "학습 언어로 글을 읽고 각 줄을 다시 쓰세요. 진행하며 문법을 교정합니다.",
            "ar": "اقرأ المقال بلغة التعلم ثم أعد كتابة كل سطر. سنصحح القواعد أثناء التقدم.",
            "ur": "سیکھنے والی زبان میں مضمون پڑھیں اور ہر سطر دوبارہ لکھیں۔ ہم راستے میں گرامر درست کریں گے۔",
            "zh": "用学习语言阅读文章，然后改写每一行。我们会边做边纠正语法。",
            "hi": "सीखने वाली भाषा में लेख पढ़ें और प्रत्येक पंक्ति फिर लिखें। हम व्याकरण सुधारते रहेंगे।"
        ],
        .typeAsYouRead: [
            "en": "Type as you read", "es": "Escribe mientras lees", "fr": "Écrivez en lisant", "de": "Tippen Sie beim Lesen",
            "pt": "Digite enquanto lê", "it": "Scrivi mentre leggi", "cs": "Pište při čtení", "fi": "Kirjoita lukiessasi",
            "ja": "読みながら入力", "ko": "읽으면서 입력", "ar": "اكتب أثناء القراءة", "ur": "پڑھتے ہوئے لکھیں",
            "zh": "边读边写", "hi": "पढ़ते हुए लिखें"
        ],
        .showTranslation: [
            "en": "Show translation", "es": "Mostrar traducción", "fr": "Afficher la traduction", "de": "Übersetzung zeigen",
            "pt": "Mostrar tradução", "it": "Mostra traduzione", "cs": "Zobrazit překlad", "fi": "Näytä käännös",
            "ja": "翻訳を表示", "ko": "번역 보기", "ar": "إظهار الترجمة", "ur": "ترجمہ دکھائیں",
            "zh": "显示翻译", "hi": "अनुवाद दिखाएँ"
        ],
        .hideTranslation: [
            "en": "Hide translation", "es": "Ocultar traducción", "fr": "Masquer la traduction", "de": "Übersetzung ausblenden",
            "pt": "Ocultar tradução", "it": "Nascondi traduzione", "cs": "Skrýt překlad", "fi": "Piilota käännös",
            "ja": "翻訳を隠す", "ko": "번역 숨기기", "ar": "إخفاء الترجمة", "ur": "ترجمہ چھپائیں",
            "zh": "隐藏翻译", "hi": "अनुवाद छिपाएँ"
        ],
        .backToDashboard: [
            "en": "Back to dashboard", "es": "Volver al panel", "fr": "Retour au tableau", "de": "Zurück zur Übersicht",
            "pt": "Voltar ao painel", "it": "Torna alla dashboard", "cs": "Zpět na přehled", "fi": "Takaisin kojelaudalle",
            "ja": "ダッシュボードへ", "ko": "대시보드로", "ar": "العودة للوحة", "ur": "ڈیش بورڈ پر واپس",
            "zh": "返回主页", "hi": "डैशबोर्ड पर वापस"
        ],
        .resetCourse: [
            "en": "Choose a different course", "es": "Elegir otro curso", "fr": "Choisir un autre cours",
            "de": "Anderen Kurs wählen", "pt": "Escolher outro curso", "it": "Scegli un altro corso",
            "cs": "Vybrat jiný kurz", "fi": "Valitse toinen kurssi", "ja": "別のコースを選ぶ",
            "ko": "다른 코스 선택", "ar": "اختر دورة أخرى", "ur": "دوسرا کورس منتخب کریں",
            "zh": "选择其他课程", "hi": "दूसरा कोर्स चुनें"
        ],
        .nextWord: [
            "en": "Next word", "es": "Siguiente palabra", "fr": "Mot suivant", "de": "Nächstes Wort",
            "pt": "Próxima palavra", "it": "Parola successiva", "cs": "Další slovo", "fi": "Seuraava sana",
            "ja": "次の単語", "ko": "다음 단어", "ar": "الكلمة التالية", "ur": "اگلا لفظ",
            "zh": "下一个词", "hi": "अगला शब्द"
        ],
        .seeResults: [
            "en": "See results", "es": "Ver resultados", "fr": "Voir les résultats", "de": "Ergebnisse ansehen",
            "pt": "Ver resultados", "it": "Vedi risultati", "cs": "Zobrazit výsledky", "fi": "Näytä tulokset",
            "ja": "結果を見る", "ko": "결과 보기", "ar": "عرض النتائج", "ur": "نتائج دیکھیں",
            "zh": "查看结果", "hi": "परिणाम देखें"
        ],
        .nextQuestion: [
            "en": "Next question", "es": "Siguiente pregunta", "fr": "Question suivante", "de": "Nächste Frage",
            "pt": "Próxima pergunta", "it": "Domanda successiva", "cs": "Další otázka", "fi": "Seuraava kysymys",
            "ja": "次の質問", "ko": "다음 문제", "ar": "السؤال التالي", "ur": "اگلا سوال",
            "zh": "下一题", "hi": "अगला प्रश्न"
        ],
        .tapToFlip: [
            "en": "Tap the card to flip", "es": "Toca la tarjeta para voltear", "fr": "Appuyez pour retourner",
            "de": "Tippen zum Umdrehen", "pt": "Toque para virar", "it": "Tocca per girare",
            "cs": "Klepněte pro otočení", "fi": "Napauta kääntääksesi", "ja": "タップして裏返す",
            "ko": "탭하여 뒤집기", "ar": "انقر لقلب البطاقة", "ur": "پلٹنے کے لیے ٹیپ کریں",
            "zh": "点按翻转卡片", "hi": "पलटने के लिए टैप करें"
        ],
        .youScored: [
            "en": "You scored", "es": "Tu puntuación", "fr": "Votre score", "de": "Ihre Punktzahl",
            "pt": "Sua pontuação", "it": "Hai ottenuto", "cs": "Vaše skóre", "fi": "Pisteesi",
            "ja": "あなたのスコア", "ko": "획득 점수", "ar": "نتيجتك", "ur": "آپ کا اسکور",
            "zh": "你的得分", "hi": "आपका स्कोर"
        ],
        .permissionNeeded: [
            "en": "Permission needed", "es": "Permiso necesario", "fr": "Autorisation requise", "de": "Berechtigung erforderlich",
            "pt": "Permissão necessária", "it": "Autorizzazione necessaria", "cs": "Je potřeba oprávnění", "fi": "Käyttöoikeus tarvitaan",
            "ja": "許可が必要です", "ko": "권한이 필요합니다", "ar": "يلزم الإذن", "ur": "اجازت درکار ہے",
            "zh": "需要权限", "hi": "अनुमति आवश्यक"
        ],
        .currentLevel: [
            "en": "Current level", "es": "Nivel actual", "fr": "Niveau actuel", "de": "Aktuelles Niveau",
            "pt": "Nível atual", "it": "Livello attuale", "cs": "Aktuální úroveň", "fi": "Nykyinen taso",
            "ja": "現在のレベル", "ko": "현재 레벨", "ar": "المستوى الحالي", "ur": "موجودہ سطح",
            "zh": "当前级别", "hi": "वर्तमान स्तर"
        ],
        .levels: [
            "en": "Levels", "es": "Niveles", "fr": "Niveaux", "de": "Niveaus",
            "pt": "Níveis", "it": "Livelli", "cs": "Úrovně", "fi": "Tasot",
            "ja": "レベル", "ko": "레벨", "ar": "المستويات", "ur": "سطح",
            "zh": "级别", "hi": "स्तर"
        ],
        .levelPassed: [
            "en": "Level passed", "es": "Nivel aprobado", "fr": "Niveau réussi", "de": "Niveau bestanden",
            "pt": "Nível aprovado", "it": "Livello superato", "cs": "Úroveň splněna", "fi": "Taso läpäisty",
            "ja": "レベル合格", "ko": "레벨 통과", "ar": "تم اجتياز المستوى", "ur": "سطح پاس",
            "zh": "级别已通过", "hi": "स्तर उत्तीर्ण"
        ],
        .speakingInterview: [
            "en": "Speaking interview", "es": "Entrevista oral", "fr": "Entretien oral", "de": "Sprechinterview",
            "pt": "Entrevista oral", "it": "Colloquio orale", "cs": "Ústní pohovor", "fi": "Suullinen haastattelu",
            "ja": "スピーキング面接", "ko": "말하기 면접", "ar": "مقابلة شفهية", "ur": "زبانی انٹرویو",
            "zh": "口语面试", "hi": "बोलने का साक्षात्कार"
        ],
        .knowledgeQuiz: [
            "en": "Knowledge quiz", "es": "Cuestionario", "fr": "Quiz de connaissances", "de": "Wissensquiz",
            "pt": "Quiz de conhecimento", "it": "Quiz di conoscenza", "cs": "Znalostní kvíz", "fi": "Tietovisa",
            "ja": "知識クイズ", "ko": "지식 퀴즈", "ar": "اختبار المعرفة", "ur": "علمی کوئز",
            "zh": "知识测验", "hi": "ज्ञान क्विज़"
        ],
        .quizHub: [
            "en": "Weekly quiz", "es": "Cuestionario semanal", "fr": "Quiz hebdomadaire", "de": "Wochenquiz",
            "pt": "Quiz semanal", "it": "Quiz settimanale", "cs": "Týdenní kvíz", "fi": "Viikon tietovisa",
            "ja": "週次クイズ", "ko": "주간 퀴즈", "ar": "اختبار أسبوعي", "ur": "ہفتہ وار کوئز",
            "zh": "每周测验", "hi": "साप्ताहिक क्विज़"
        ],
        .endOfWeekInterview: [
            "en": "End-of-week prep interview", "es": "Entrevista de preparación de fin de semana",
            "fr": "Entretien de préparation de fin de semaine", "de": "Wochenabschluss-Interview",
            "pt": "Entrevista de preparação semanal", "it": "Colloquio di fine settimana",
            "cs": "Týdenní přípravný pohovor", "fi": "Viikon lopun harjoitushaastattelu",
            "ja": "週末対策面接", "ko": "주간 준비 면접", "ar": "مقابلة تحضير نهاية الأسبوع", "ur": "ہفتے کے آخر کا انٹرویو",
            "zh": "周末备考面试", "hi": "सप्ताहांत तैयारी साक्षात्कार"
        ],
        .passToUnlock: [
            "en": "Pass speaking (≥70%) to tick this level", "es": "Aprueba speaking (≥70%) para marcar este nivel",
            "fr": "Réussissez l'oral (≥70 %) pour valider ce niveau", "de": "Sprechen ≥70 % bestehen, um das Niveau abzuhaken",
            "pt": "Passe na fala (≥70%) para marcar este nível", "it": "Supera lo speaking (≥70%) per spuntare il livello",
            "cs": "Splňte mluvení (≥70 %) pro odškrtnutí úrovně", "fi": "Läpäise puhuminen (≥70 %), niin taso merkitään",
            "ja": "スピーキング≥70%でレベルにチェック", "ko": "말하기 ≥70% 통과 시 레벨 체크",
            "ar": "اجتز التحدث (≥70٪) لتأشير المستوى", "ur": "بولنا (≥70٪) پاس کر کے سطح پر نشان لگائیں",
            "zh": "口语≥70%通过后勾选该级别", "hi": "बोलना (≥70%) पास कर स्तर चिह्नित करें"
        ],
        .speakingPassHint: [
            "en": "Pass this level interview to unlock the next level badge.",
            "es": "Aprueba la entrevista de este nivel para desbloquear la siguiente insignia.",
            "fr": "Réussissez l'entretien de ce niveau pour débloquer le badge suivant.",
            "de": "Bestehen Sie das Niveau-Interview, um das nächste Abzeichen freizuschalten.",
            "pt": "Passe na entrevista deste nível para liberar o próximo selo.",
            "it": "Supera il colloquio di questo livello per sbloccare il badge successivo.",
            "cs": "Splňte pohovor této úrovně a odemknete další odznak.",
            "fi": "Läpäise tämän tason haastattelu avataksesi seuraavan merkin.",
            "ja": "このレベルの面接に合格すると次のバッジが開きます。",
            "ko": "이 레벨 면접을 통과하면 다음 배지가 열립니다.",
            "ar": "اجتز مقابلة هذا المستوى لفتح الشارة التالية.",
            "ur": "اس سطح کا انٹرویو پاس کر کے اگلا بیج کھولیں۔",
            "zh": "通过本级面试即可解锁下一级徽章。",
            "hi": "इस स्तर का साक्षात्कार पास कर अगला बैज खोलें।"
        ],
        .levelsProgress: [
            "en": "Levels progress", "es": "Progreso por niveles", "fr": "Progression des niveaux", "de": "Niveau-Fortschritt",
            "pt": "Progresso por níveis", "it": "Progresso livelli", "cs": "Postup úrovní", "fi": "Tasojen eteneminen",
            "ja": "レベル進捗", "ko": "레벨 진행", "ar": "تقدم المستويات", "ur": "سطح کی پیش رفت",
            "zh": "级别进度", "hi": "स्तर प्रगति"
        ],
        .realtimeInterview: [
            "en": "Realtime AI interview", "es": "Entrevista IA en tiempo real", "fr": "Entretien IA en direct",
            "de": "Echtzeit-KI-Interview", "pt": "Entrevista IA em tempo real", "it": "Colloquio IA in tempo reale",
            "cs": "AI pohovor v reálném čase", "fi": "Reaaliaikainen AI-haastattelu", "ja": "リアルタイムAI面接",
            "ko": "실시간 AI 면접", "ar": "مقابلة ذكية مباشرة", "ur": "ریئل ٹائم AI انٹرویو",
            "zh": "实时 AI 面试", "hi": "रियल-टाइम AI साक्षात्कार"
        ],
        .realtimeInterviewHint: [
            "en": "The AI examiner will ask questions out loud. Answer by speaking. After the interview you get a full evaluation report with corrections.",
            "es": "El examinador IA hará preguntas en voz alta. Responde hablando. Al final recibirás un informe con correcciones.",
            "fr": "L’examinateur IA pose des questions à voix haute. Répondez en parlant. Vous recevrez un rapport avec corrections.",
            "de": "Der KI-Prüfer stellt Fragen laut. Antworten Sie sprechend. Danach erhalten Sie einen Bericht mit Korrekturen.",
            "pt": "O examinador IA fará perguntas em voz alta. Responda falando. No final você recebe um relatório com correções.",
            "it": "L’esaminatore IA farà domande a voce alta. Rispondi parlando. Alla fine riceverai un report con correzioni.",
            "cs": "AI zkoušející položí otázky nahlas. Odpovídejte mluvením. Nakonec dostanete zprávu s opravami.",
            "fi": "AI-tutkija kysyy ääneen. Vastaa puhumalla. Lopuksi saat arviointiraportin korjauksineen.",
            "ja": "AI面接官が声で質問します。声で答えてください。終了後に添削付き評価レポートが出ます。",
            "ko": "AI 면접관이 소리로 질문합니다. 말로 답하세요. 끝나면 교정 포함 평가 보고서가 제공됩니다.",
            "ar": "سيسأل الممتحن الذكي بصوت عالٍ. أجب بالتحدث. ستحصل على تقرير مع التصحيحات.",
            "ur": "AI امتحان لینے والا زور سے سوال پوچھے گا۔ بول کر جواب دیں۔ آخر میں تصحیح کے ساتھ رپورٹ ملے گی۔",
            "zh": "AI 考官会出声提问。请口头作答。结束后会给出带批改的评估报告。",
            "hi": "AI परीक्षक ज़ोर से प्रश्न पूछेगा। बोलकर उत्तर दें। अंत में सुधार सहित रिपोर्ट मिलेगी।"
        ],
        .startRealtimeInterview: [
            "en": "Start realtime interview", "es": "Empezar entrevista en tiempo real", "fr": "Démarrer l’entretien en direct",
            "de": "Echtzeit-Interview starten", "pt": "Iniciar entrevista em tempo real", "it": "Avvia colloquio in tempo reale",
            "cs": "Spustit pohovor v reálném čase", "fi": "Aloita reaaliaikainen haastattelu", "ja": "リアルタイム面接を開始",
            "ko": "실시간 면접 시작", "ar": "بدء المقابلة المباشرة", "ur": "ریئل ٹائم انٹرویو شروع کریں",
            "zh": "开始实时面试", "hi": "रियल-टाइम साक्षात्कार शुरू करें"
        ],
        .aiAsking: [
            "en": "AI examiner is asking…", "es": "El examinador IA pregunta…", "fr": "L’examinateur IA pose la question…",
            "de": "KI-Prüfer fragt…", "pt": "Examinador IA perguntando…", "it": "L’esaminatore IA sta chiedendo…",
            "cs": "AI zkoušející se ptá…", "fi": "AI-tutkija kysyy…", "ja": "AI面接官が質問中…",
            "ko": "AI 면접관이 질문 중…", "ar": "الممتحن الذكي يسأل…", "ur": "AI امتحان لینے والا پوچھ رہا ہے…",
            "zh": "AI 考官提问中…", "hi": "AI परीक्षक पूछ रहे हैं…"
        ],
        .yourTurnToSpeak: [
            "en": "Your turn — speak now", "es": "Tu turno — habla ahora", "fr": "À vous — parlez maintenant",
            "de": "Sie sind dran — jetzt sprechen", "pt": "Sua vez — fale agora", "it": "Tocca a te — parla ora",
            "cs": "Jste na řadě — mluvte", "fi": "Sinun vuorosi — puhu nyt", "ja": "あなたの番です — 話してください",
            "ko": "당신 차례 — 지금 말하세요", "ar": "دورك — تحدّث الآن", "ur": "آپ کی باری — اب بولیں",
            "zh": "轮到你了 — 请开始说", "hi": "आपकी बारी — अब बोलें"
        ],
        .listeningToYou: [
            "en": "Listening to you…", "es": "Escuchándote…", "fr": "Je vous écoute…", "de": "Ich höre zu…",
            "pt": "Ouvindo você…", "it": "Ti sto ascoltando…", "cs": "Poslouchám vás…", "fi": "Kuuntelen…",
            "ja": "聞いています…", "ko": "듣고 있어요…", "ar": "أستمع إليك…", "ur": "آپ کو سن رہا ہوں…",
            "zh": "正在听你说…", "hi": "आपको सुन रहा हूँ…"
        ],
        .speakNow: [
            "en": "Start speaking…", "es": "Empieza a hablar…", "fr": "Commencez à parler…", "de": "Beginnen Sie zu sprechen…",
            "pt": "Comece a falar…", "it": "Inizia a parlare…", "cs": "Začněte mluvit…", "fi": "Ala puhua…",
            "ja": "話し始めてください…", "ko": "말하기 시작하세요…", "ar": "ابدأ بالحديث…", "ur": "بولنا شروع کریں…",
            "zh": "开始说话…", "hi": "बोलना शुरू करें…"
        ],
        .imDoneSpeaking: [
            "en": "I'm done speaking", "es": "He terminado de hablar", "fr": "J’ai fini de parler", "de": "Ich bin fertig",
            "pt": "Terminei de falar", "it": "Ho finito di parlare", "cs": "Dořekl/a jsem", "fi": "Lopetin puhumisen",
            "ja": "話し終わりました", "ko": "말하기 끝", "ar": "انتهيت من التحدث", "ur": "میں بول چکا/چکی ہوں",
            "zh": "我说完了", "hi": "मैं बोलना समाप्त कर चुका/चुकी हूँ"
        ],
        .aiSpeaking: [
            "en": "AI is speaking…", "es": "La IA está hablando…", "fr": "L’IA parle…", "de": "KI spricht…",
            "pt": "IA falando…", "it": "L’IA sta parlando…", "cs": "AI mluví…", "fi": "AI puhuu…",
            "ja": "AIが話しています…", "ko": "AI가 말하는 중…", "ar": "الذكاء الاصطناعي يتحدث…", "ur": "AI بول رہا ہے…",
            "zh": "AI 正在说话…", "hi": "AI बोल रहा है…"
        ],
        .pleaseWait: [
            "en": "Please wait…", "es": "Espera…", "fr": "Veuillez patienter…", "de": "Bitte warten…",
            "pt": "Aguarde…", "it": "Attendi…", "cs": "Prosím čekejte…", "fi": "Odota…",
            "ja": "お待ちください…", "ko": "잠시만 기다리세요…", "ar": "يرجى الانتظار…", "ur": "براہ کرم انتظار کریں…",
            "zh": "请稍候…", "hi": "कृपया प्रतीक्षा करें…"
        ],
        .aiEvaluating: [
            "en": "AI is evaluating…", "es": "La IA está evaluando…", "fr": "L’IA évalue…", "de": "KI bewertet…",
            "pt": "IA avaliando…", "it": "L’IA sta valutando…", "cs": "AI hodnotí…", "fi": "AI arvioi…",
            "ja": "AIが評価中…", "ko": "AI 평가 중…", "ar": "الذكاء الاصطناعي يقيّم…", "ur": "AI جائزہ لے رہا ہے…",
            "zh": "AI 正在评估…", "hi": "AI मूल्यांकन कर रहा है…"
        ],
        .evaluationReport: [
            "en": "Evaluation report", "es": "Informe de evaluación", "fr": "Rapport d’évaluation", "de": "Bewertungsbericht",
            "pt": "Relatório de avaliação", "it": "Report di valutazione", "cs": "Hodnoticí zpráva", "fi": "Arviointiraportti",
            "ja": "評価レポート", "ko": "평가 보고서", "ar": "تقرير التقييم", "ur": "جائزہ رپورٹ",
            "zh": "评估报告", "hi": "मूल्यांकन रिपोर्ट"
        ],
        .strengths: [
            "en": "Strengths", "es": "Fortalezas", "fr": "Points forts", "de": "Stärken",
            "pt": "Pontos fortes", "it": "Punti di forza", "cs": "Silné stránky", "fi": "Vahvuudet",
            "ja": "強み", "ko": "강점", "ar": "نقاط القوة", "ur": "خوبیاں",
            "zh": "优点", "hi": "मज़बूत पक्ष"
        ],
        .improvements: [
            "en": "Improvements", "es": "Mejoras", "fr": "Améliorations", "de": "Verbesserungen",
            "pt": "Melhorias", "it": "Miglioramenti", "cs": "Ke zlepšení", "fi": "Parannettavaa",
            "ja": "改善点", "ko": "개선점", "ar": "تحسينات", "ur": "بہتری",
            "zh": "待改进", "hi": "सुधार"
        ],
        .turnByTurn: [
            "en": "Turn-by-turn review", "es": "Revisión pregunta a pregunta", "fr": "Revue question par question",
            "de": "Frage-für-Frage-Review", "pt": "Revisão pergunta a pergunta", "it": "Revisione domanda per domanda",
            "cs": "Kontrola po otázkách", "fi": "Kysymyskohtainen katsaus", "ja": "質問ごとの振り返り",
            "ko": "질문별 리뷰", "ar": "مراجعة سؤالًا بسؤال", "ur": "سوال بہ سوال جائزہ",
            "zh": "逐题回顾", "hi": "प्रश्न-दर-प्रश्न समीक्षा"
        ],
        .improvedAnswer: [
            "en": "Improved answer", "es": "Respuesta mejorada", "fr": "Réponse améliorée", "de": "Verbesserte Antwort",
            "pt": "Resposta melhorada", "it": "Risposta migliorata", "cs": "Vylepšená odpověď", "fi": "Parannettu vastaus",
            "ja": "改善された答え", "ko": "개선된 답변", "ar": "إجابة محسّنة", "ur": "بہتر جواب",
            "zh": "改进后的答案", "hi": "सुधारा हुआ उत्तर"
        ],
        .hearCorrection: [
            "en": "Hear AI correction", "es": "Escuchar corrección IA", "fr": "Écouter la correction IA",
            "de": "KI-Korrektur anhören", "pt": "Ouvir correção da IA", "it": "Ascolta correzione IA",
            "cs": "Poslechnout AI opravu", "fi": "Kuuntele AI-korjaus", "ja": "AI添削を聞く",
            "ko": "AI 교정 듣기", "ar": "سماع تصحيح الذكاء الاصطناعي", "ur": "AI تصحیح سنیں",
            "zh": "收听 AI 批改", "hi": "AI सुधार सुनें"
        ],
        .relevance: [
            "en": "Relevance", "es": "Relevancia", "fr": "Pertinence", "de": "Relevanz",
            "pt": "Relevância", "it": "Pertinenza", "cs": "Relevance", "fi": "Asiaankuuluvuus",
            "ja": "関連性", "ko": "관련성", "ar": "الصلة", "ur": "مطابقت",
            "zh": "相关性", "hi": "प्रासंगिकता"
        ],
        .fluency: [
            "en": "Fluency", "es": "Fluidez", "fr": "Fluidité", "de": "Flüssigkeit",
            "pt": "Fluência", "it": "Fluenza", "cs": "Plynulost", "fi": "Sujuvuus",
            "ja": "流暢さ", "ko": "유창성", "ar": "الطلاقة", "ur": " روانی",
            "zh": "流利度", "hi": "धाराप्रवाहता"
        ],
        .question: [
            "en": "Question", "es": "Pregunta", "fr": "Question", "de": "Frage",
            "pt": "Pergunta", "it": "Domanda", "cs": "Otázka", "fi": "Kysymys",
            "ja": "質問", "ko": "질문", "ar": "سؤال", "ur": "سوال",
            "zh": "问题", "hi": "प्रश्न"
        ],
        .examMode: [
            "en": "Exam mode", "es": "Modo examen", "fr": "Mode examen", "de": "Prüfungsmodus",
            "pt": "Modo exame", "it": "Modalità esame", "cs": "Zkušební režim", "fi": "Koetilassa",
            "ja": "試験モード", "ko": "시험 모드", "ar": "وضع الامتحان", "ur": "امتحان موڈ",
            "zh": "考试模式", "hi": "परीक्षा मोड"
        ],
        .timeRemaining: [
            "en": "Time left", "es": "Tiempo restante", "fr": "Temps restant", "de": "Restzeit",
            "pt": "Tempo restante", "it": "Tempo rimasto", "cs": "Zbývající čas", "fi": "Aikaa jäljellä",
            "ja": "残り時間", "ko": "남은 시간", "ar": "الوقت المتبقي", "ur": "باقی وقت",
            "zh": "剩余时间", "hi": "शेष समय"
        ],
        .reviewAnswers: [
            "en": "Review & corrections", "es": "Revisión y correcciones", "fr": "Revue et corrections",
            "de": "Überblick & Korrekturen", "pt": "Revisão e correções", "it": "Revisione e correzioni",
            "cs": "Kontrola a opravy", "fi": "Tarkistus ja korjaukset", "ja": "見直しと添削",
            "ko": "검토 및 교정", "ar": "مراجعة وتصحيحات", "ur": "جائزہ اور تصحیحات",
            "zh": "回顾与批改", "hi": "समीक्षा और सुधार"
        ],
        .hideScript: [
            "en": "Audio only — script hidden", "es": "Solo audio — guion oculto", "fr": "Audio seul — script masqué",
            "de": "Nur Audio — Text ausgeblendet", "pt": "Somente áudio — roteiro oculto", "it": "Solo audio — testo nascosto",
            "cs": "Jen audio — text skrytý", "fi": "Vain ääni — teksti piilotettu", "ja": "音声のみ — 台本非表示",
            "ko": "오디오만 — 대본 숨김", "ar": "صوت فقط — النص مخفي", "ur": "صرف آڈیو — سکرپٹ چھپا",
            "zh": "仅音频 — 文稿已隐藏", "hi": "केवल ऑडियो — स्क्रिप्ट छिपी"
        ],
        .showScriptAfter: [
            "en": "Script unlocks after listening exam", "es": "El guion se abre tras el examen", "fr": "Le script s’ouvre après l’écoute",
            "de": "Text nach dem Hörtest sichtbar", "pt": "Roteiro libera após o exame", "it": "Testo disponibile dopo l’ascolto",
            "cs": "Text po poslechové části", "fi": "Teksti aukeaa kuuntelun jälkeen", "ja": "リスニング後に台本表示",
            "ko": "듣기 시험 후 대본 공개", "ar": "يُفتح النص بعد الاستماع", "ur": "سننے کے امتحان کے بعد سکرپٹ",
            "zh": "听力考试后解锁文稿", "hi": "सुनने की परीक्षा के बाद स्क्रिप्ट"
        ],
        .listeningOnlyHint: [
            "en": "Listen carefully. You cannot read the dialogue during the test.",
            "es": "Escucha con atención. No puedes leer el diálogo durante el examen.",
            "fr": "Écoutez attentivement. Le dialogue est masqué pendant le test.",
            "de": "Hören Sie genau zu. Der Dialog ist während des Tests verborgen.",
            "pt": "Ouça com atenção. O diálogo fica oculto durante o teste.",
            "it": "Ascolta con attenzione. Il dialogo è nascosto durante il test.",
            "cs": "Poslouchejte pečlivě. Dialog je během testu skrytý.",
            "fi": "Kuuntele tarkasti. Dialogi on piilotettu kokeen aikana.",
            "ja": "注意して聞いてください。試験中は会話文を読めません。",
            "ko": "집중해서 들으세요. 시험 중에는 대화를 볼 수 없습니다.",
            "ar": "استمع جيدًا. لا يمكنك قراءة الحوار أثناء الاختبار.",
            "ur": "غور سے سنیں۔ امتحان کے دوران مکالمہ نہیں پڑھ سکتے۔",
            "zh": "请仔细听。考试期间无法阅读对话。",
            "hi": "ध्यान से सुनें। परीक्षा के दौरान संवाद नहीं पढ़ सकते।"
        ],
        .submitExam: [
            "en": "Submit exam", "es": "Enviar examen", "fr": "Soumettre l’examen", "de": "Prüfung abgeben",
            "pt": "Enviar exame", "it": "Invia esame", "cs": "Odevzdat zkoušku", "fi": "Lähetä koe",
            "ja": "試験を提出", "ko": "시험 제출", "ar": "تسليم الامتحان", "ur": "امتحان جمع کروائیں",
            "zh": "提交考试", "hi": "परीक्षा जमा करें"
        ],
        .studyPrepPack: [
            "en": "Study prep pack", "es": "Pack de preparación", "fr": "Pack de préparation", "de": "Lernpaket",
            "pt": "Pacote de preparação", "it": "Pacchetto di preparazione", "cs": "Studijní balíček", "fi": "Opiskelupaketti",
            "ja": "学習準備パック", "ko": "학습 준비 팩", "ar": "حزمة التحضير", "ur": "تیاری پیک",
            "zh": "学习备考包", "hi": "अध्ययन तैयारी पैक"
        ],
        .studyPackIntro: [
            "en": "Institute-aligned weekly materials: reading, grammar, phrases, worksheet, checklist and a shareable PDF.",
            "es": "Material semanal alineado con el instituto: lectura, gramática, frases, hoja de trabajo, lista y PDF para compartir.",
            "fr": "Matériel hebdomadaire aligné sur l’institut : lecture, grammaire, phrases, fiche, checklist et PDF partageable.",
            "de": "Institutsnahes Wochenmaterial: Lesen, Grammatik, Wendungen, Arbeitsblatt, Checkliste und teilbares PDF.",
            "pt": "Material semanal alinhado ao instituto: leitura, gramática, frases, exercícios, checklist e PDF.",
            "it": "Materiale settimanale allineato all’istituto: lettura, grammatica, frasi, scheda, checklist e PDF.",
            "cs": "Týdenní materiály podle institutu: čtení, gramatika, fráze, pracovní list, checklist a PDF.",
            "fi": "Instituutin mukaista viikkomateriaalia: lukeminen, kielioppi, fraasit, tehtävät, checklist ja PDF.",
            "ja": "機関準拠の週次教材：読解・文法・表現・ワークシート・チェックリスト・共有可能なPDF。",
            "ko": "기관 연계 주간 자료: 읽기, 문법, 표현, 워크시트, 체크리스트, 공유 PDF.",
            "ar": "مواد أسبوعية وفق المعهد: قراءة وقواعد وعبارات وتمارين وقائمة وملف PDF للمشاركة.",
            "ur": "ادارہ سے ہم آہنگ ہفتہ وار مواد: پڑھائی، گرامر، جملے، ورک شیٹ، چیک لسٹ اور PDF۔",
            "zh": "机构对齐的每周材料：阅读、语法、短语、练习、清单和可分享 PDF。",
            "hi": "संस्थान-संरेखित साप्ताहिक सामग्री: पठन, व्याकरण, वाक्यांश, वर्कशीट, चेकलिस्ट और PDF।"
        ],
        .exportPDF: [
            "en": "Export prep pack PDF", "es": "Exportar PDF de preparación", "fr": "Exporter le PDF de préparation",
            "de": "Lernpaket als PDF teilen", "pt": "Exportar PDF de preparação", "it": "Esporta PDF di preparazione",
            "cs": "Exportovat PDF balíček", "fi": "Vie valmistautumis-PDF", "ja": "準備パックPDFを書き出す",
            "ko": "준비 팩 PDF 내보내기", "ar": "تصدير PDF التحضير", "ur": "تیاری PDF ایکسپورٹ کریں",
            "zh": "导出备考 PDF", "hi": "तैयारी PDF निर्यात करें"
        ],
        .learningObjectives: [
            "en": "Learning objectives", "es": "Objetivos de aprendizaje", "fr": "Objectifs d’apprentissage", "de": "Lernziele",
            "pt": "Objetivos de aprendizagem", "it": "Obiettivi di apprendimento", "cs": "Cíle učení", "fi": "Oppimistavoitteet",
            "ja": "学習目標", "ko": "학습 목표", "ar": "أهداف التعلم", "ur": "سیکھنے کے مقاصد",
            "zh": "学习目标", "hi": "अधिगम उद्देश्य"
        ],
        .canDoStatements: [
            "en": "Can-do statements", "es": "Puedo hacer…", "fr": "Je peux…", "de": "Kann-Beschreibungen",
            "pt": "Consigo…", "it": "Sono in grado di…", "cs": "Umím…", "fi": "Osaan…",
            "ja": "できること", "ko": "할 수 있는 것", "ar": "أستطيع أن…", "ur": "میں کر سکتا/سکتی ہوں…",
            "zh": "能力描述", "hi": "मैं कर सकता/सकती हूँ…"
        ],
        .readingPassage: [
            "en": "Reading passage", "es": "Texto de lectura", "fr": "Texte de lecture", "de": "Lesetext",
            "pt": "Texto de leitura", "it": "Brano di lettura", "cs": "Čtecí text", "fi": "Lukuteksti",
            "ja": "読解文", "ko": "읽기 지문", "ar": "نص القراءة", "ur": "پڑھنے کا متن",
            "zh": "阅读短文", "hi": "पठन अनुच्छेद"
        ],
        .grammarDeepDive: [
            "en": "Grammar deep dive", "es": "Gramática en detalle", "fr": "Grammaire approfondie", "de": "Grammatik vertiefen",
            "pt": "Gramática aprofundada", "it": "Grammatica approfondita", "cs": "Gramatika podrobně", "fi": "Kielioppi syvällisesti",
            "ja": "文法の深掘り", "ko": "문법 심화", "ar": "تعمق في القواعد", "ur": "گرامر کی تفصیل",
            "zh": "语法精讲", "hi": "व्याकरण विस्तार"
        ],
        .keyPhrases: [
            "en": "Key phrases", "es": "Frases clave", "fr": "Expressions clés", "de": "Schlüsselwendungen",
            "pt": "Frases-chave", "it": "Frasi chiave", "cs": "Klíčové fráze", "fi": "Avainfraasit",
            "ja": "重要表現", "ko": "핵심 표현", "ar": "عبارات أساسية", "ur": "اہم جملے",
            "zh": "关键短语", "hi": "मुख्य वाक्यांश"
        ],
        .worksheet: [
            "en": "Worksheet", "es": "Hoja de trabajo", "fr": "Fiche d’exercices", "de": "Arbeitsblatt",
            "pt": "Folha de exercícios", "it": "Scheda di lavoro", "cs": "Pracovní list", "fi": "Tehtäväpaperi",
            "ja": "ワークシート", "ko": "워크시트", "ar": "ورقة تمارين", "ur": "ورک شیٹ",
            "zh": "练习单", "hi": "वर्कशीट"
        ],
        .showWorksheetAnswers: [
            "en": "Show worksheet answers", "es": "Mostrar respuestas", "fr": "Afficher les réponses", "de": "Antworten anzeigen",
            "pt": "Mostrar respostas", "it": "Mostra risposte", "cs": "Zobrazit odpovědi", "fi": "Näytä vastaukset",
            "ja": "解答を表示", "ko": "정답 보기", "ar": "إظهار الإجابات", "ur": "جوابات دکھائیں",
            "zh": "显示练习答案", "hi": "उत्तर दिखाएँ"
        ],
        .tryYourselfFirst: [
            "en": "Try yourself first, then reveal answers.", "es": "Inténtalo primero y luego muestra las respuestas.",
            "fr": "Essayez d’abord, puis affichez les réponses.", "de": "Zuerst selbst versuchen, dann Antworten zeigen.",
            "pt": "Tente primeiro e depois revele as respostas.", "it": "Prova prima, poi mostra le risposte.",
            "cs": "Nejdřív zkuste sami, pak odhalte odpovědi.", "fi": "Kokeile ensin itse, paljasta sitten vastaukset.",
            "ja": "まず自分で取り組み、あとで解答を見てください。", "ko": "먼저 스스로 풀어 본 뒤 정답을 확인하세요.",
            "ar": "حاول أولاً ثم أظهر الإجابات.", "ur": "پہلے خود کوشش کریں، پھر جواب کھولیں۔",
            "zh": "先自己练习，再查看答案。", "hi": "पहले स्वयं प्रयास करें, फिर उत्तर देखें।"
        ],
        .prepChecklist: [
            "en": "Prep checklist", "es": "Lista de preparación", "fr": "Liste de préparation", "de": "Vorbereitungs-Checkliste",
            "pt": "Checklist de preparação", "it": "Checklist di preparazione", "cs": "Checklist přípravy", "fi": "Valmistautumislista",
            "ja": "準備チェックリスト", "ko": "준비 체크리스트", "ar": "قائمة التحضير", "ur": "تیاری چیک لسٹ",
            "zh": "备考清单", "hi": "तैयारी चेकलिस्ट"
        ],
        .examTips: [
            "en": "Exam tips", "es": "Consejos de examen", "fr": "Conseils d’examen", "de": "Prüfungstipps",
            "pt": "Dicas de exame", "it": "Consigli per l’esame", "cs": "Tipy ke zkoušce", "fi": "Koevinkit",
            "ja": "試験のコツ", "ko": "시험 팁", "ar": "نصائح الامتحان", "ur": "امتحان کے مشورے",
            "zh": "考试技巧", "hi": "परीक्षा सुझाव"
        ],
        .selfStudyPlan: [
            "en": "6-day self-study plan", "es": "Plan de autoestudio de 6 días", "fr": "Plan d’auto-apprentissage sur 6 jours",
            "de": "6-Tage-Selbstlernplan", "pt": "Plano de autoestudo de 6 dias", "it": "Piano di autoapprendimento di 6 giorni",
            "cs": "6denní plán samostudia", "fi": "6 päivän itseopiskelusuunnitelma", "ja": "6日間の自習プラン",
            "ko": "6일 自学 계획", "ar": "خطة دراسة ذاتية لـ 6 أيام", "ur": "6 دن کا خود مطالعہ منصوبہ",
            "zh": "6 天自学计划", "hi": "6-दिन स्व-अध्ययन योजना"
        ],
        .focusWords: [
            "en": "Focus words", "es": "Palabras clave", "fr": "Mots clés", "de": "Fokuswörter",
            "pt": "Palavras-foco", "it": "Parole chiave", "cs": "Klíčová slova", "fi": "Avainsanat",
            "ja": "重点語", "ko": "핵심 단어", "ar": "كلمات محورية", "ur": "اہم الفاظ",
            "zh": "重点词", "hi": "मुख्य शब्द"
        ],
        .mockExercises: [
            "en": "Mock exercises", "es": "Ejercicios de práctica", "fr": "Exercices blancs", "de": "Übungsaufgaben",
            "pt": "Exercícios simulados", "it": "Esercizi mock", "cs": "Cvičné úlohy", "fi": "Harjoitustehtävät",
            "ja": "模擬演習", "ko": "모의 연습", "ar": "تمارين تجريبية", "ur": "مشقی مشقیں",
            "zh": "模拟练习", "hi": "मॉक अभ्यास"
        ],
        .mockPracticeIntro: [
            "en": "Classroom papers in official task types: Listening questions on screen (once only), Reading with the passage visible, Writing Task 1/2 word counts, Speaking Parts 1–3 with a Part 2 cue card. Open the official computer/mock sample first.",
            "es": "Practica Listening, Speaking, Reading y Writing — 10 ejercicios por habilidad con feedback en tiempo real. Tras ~2 semanas, haz el examen oficial de nivel.",
            "fr": "Entraînez-vous (écoute, oral, lecture, écrit) — 10 exercices par compétence avec feedback. Après ~2 semaines, passez l’examen officiel.",
            "de": "Üben Sie Hören, Sprechen, Lesen, Schreiben — 10 Übungen pro Fertigkeit mit Echtzeit-Feedback. Nach ~2 Wochen: offizielle Niveau-Prüfung.",
            "pt": "Pratique escuta, fala, leitura e escrita — 10 exercícios por habilidade com feedback. Após ~2 semanas, faça o exame oficial.",
            "it": "Esercitati in ascolto, parlato, lettura e scrittura — 10 esercizi per abilità con feedback. Dopo ~2 settimane, esame ufficiale.",
            "cs": "Procvičte poslech, mluvení, čtení a psaní — 10 cvičení na dovednost. Po ~2 týdnech oficiální zkouška úrovně.",
            "fi": "Harjoittele kuuntelua, puhetta, lukemista ja kirjoittamista — 10 tehtävää per taito. Noin 2 viikon jälkeen virallinen tasokoe.",
            "ja": "聞く・話す・読む・書くを各10問、リアルタイム練習。約2週間後に公式レベル試験へ。",
            "ko": "듣기·말하기·읽기·쓰기 각 10문제 실시간 연습. 약 2주 후 공식 레벨 시험.",
            "ar": "تمرّن على المهارات — 10 تمارين لكل مهارة مع ملاحظات مباشرة. بعد نحو أسبوعين خض الامتحان الرسمي.",
            "ur": "سننا، بولنا، پڑھنا، لکھنا — ہر مہارت کی 10 مشقیں ریئل ٹائم۔ تقریباً 2 ہفتوں بعد آفیشل سطح کا امتحان۔",
            "zh": "练习听说读写——每项技能 10 道练习，含实时反馈。约两周后参加正式级别考试。",
            "hi": "सुनना, बोलना, पढ़ना, लिखना — प्रत्येक कौशल के 10 अभ्यास रियल-टाइम। लगभग 2 सप्ताह बाद आधिकारिक स्तर परीक्षा।"
        ],
        .practiceExercises123: [
            "en": "Exercises 1–10", "es": "Ejercicios 1–10", "fr": "Exercices 1–10", "de": "Übungen 1–10",
            "pt": "Exercícios 1–10", "it": "Esercizi 1–10", "cs": "Cvičení 1–10", "fi": "Tehtävät 1–10",
            "ja": "演習 1–10", "ko": "연습 1–10", "ar": "تمارين 1–10", "ur": "مشق 1–10",
            "zh": "练习 1–10", "hi": "अभ्यास 1–10"
        ],
        .takeOfficialExam: [
            "en": "Take official level exam", "es": "Hacer examen oficial de nivel", "fr": "Passer l’examen officiel",
            "de": "Offizielle Niveau-Prüfung", "pt": "Fazer exame oficial de nível", "it": "Sostieni l’esame ufficiale",
            "cs": "Oficiální zkouška úrovně", "fi": "Virallinen tasokoe", "ja": "公式レベル試験を受ける",
            "ko": "공식 레벨 시험 보기", "ar": "أداء الامتحان الرسمي للمستوى", "ur": "آفیشل سطح کا امتحان دیں",
            "zh": "参加正式级别考试", "hi": "आधिकारिक स्तर परीक्षा दें"
        ],
        .examReadyAfterPrep: [
            "en": "Prep complete — exam unlocked", "es": "Preparación lista — examen desbloqueado",
            "fr": "Préparation terminée — examen débloqué", "de": "Vorbereitung fertig — Prüfung freigeschaltet",
            "pt": "Preparação pronta — exame liberado", "it": "Prep completata — esame sbloccato",
            "cs": "Příprava hotová — zkouška odemčena", "fi": "Valmistautuminen valmis — koe auki",
            "ja": "準備完了 — 試験が解放されました", "ko": "준비 완료 — 시험 잠금 해제",
            "ar": "التحضير مكتمل — الامتحان مفتوح", "ur": "تیاری مکمل — امتحان کھل گیا",
            "zh": "备考完成 — 考试已解锁", "hi": "तैयारी पूर्ण — परीक्षा अनलॉक"
        ],
        .examLockedHint: [
            "en": "Complete several mock exercises across skills in both weeks of this level to unlock the exam.",
            "es": "Completa varios ejercicios de práctica de las habilidades en las 2 semanas del nivel para desbloquear el examen.",
            "fr": "Terminez plusieurs exercices blancs des compétences sur les 2 semaines du niveau pour débloquer l’examen.",
            "de": "Schließen Sie mehrere Übungen in beiden Wochen dieses Niveaus ab, um die Prüfung freizuschalten.",
            "pt": "Conclua vários exercícios simulados nas duas semanas deste nível para liberar o exame.",
            "it": "Completa diversi esercizi mock in entrambe le settimane del livello per sbloccare l’esame.",
            "cs": "Dokončete několik cvičení v obou týdnech úrovně a odemknete zkoušku.",
            "fi": "Tee useita harjoituksia molemmilla tason viikoilla avataksesi kokeen.",
            "ja": "このレベルの両週で各技能の模擬演習を進めると試験が開きます。",
            "ko": "이 레벨의 두 주에서 여러 모의 연습을 완료하면 시험이 열립니다.",
            "ar": "أكمل عدة تمارين تجريبية عبر المهارات في أسبوعي هذا المستوى لفتح الامتحان.",
            "ur": "اس سطح کے دونوں ہفتوں میں کئی مشقی مشقیں مکمل کر کے امتحان کھولیں۔",
            "zh": "完成本级别两周内多项技能模拟练习后解锁考试。",
            "hi": "इस स्तर के दोनों सप्ताह में कई मॉक अभ्यास पूरे कर परीक्षा खोलें।"
        ],
        .viewScorecard: [
            "en": "View official scorecard", "es": "Ver acta oficial", "fr": "Voir le relevé officiel",
            "de": "Offiziellen Scorecard ansehen", "pt": "Ver boletim oficial", "it": "Vedi scorecard ufficiale",
            "cs": "Zobrazit oficiální výsledky", "fi": "Näytä virallinen tuloskortti", "ja": "公式スコアカードを見る",
            "ko": "공식 성적표 보기", "ar": "عرض بطاقة النتائج الرسمية", "ur": "آفیشل اسکور کارڈ دیکھیں",
            "zh": "查看正式成绩单", "hi": "आधिकारिक स्कोरकार्ड देखें"
        ],
        .officialLevelExam: [
            "en": "Official level exam", "es": "Examen oficial de nivel", "fr": "Examen officiel de niveau",
            "de": "Offizielle Niveau-Prüfung", "pt": "Exame oficial de nível", "it": "Esame ufficiale di livello",
            "cs": "Oficiální zkouška úrovně", "fi": "Virallinen tasokoe", "ja": "公式レベル試験",
            "ko": "공식 레벨 시험", "ar": "امتحان المستوى الرسمي", "ur": "آفیشل سطح کا امتحان",
            "zh": "正式级别考试", "hi": "आधिकारिक स्तर परीक्षा"
        ],
        .examCoversSkills: [
            "en": "Covers Listening, Speaking, Reading and Writing under exam conditions.",
            "es": "Incluye Listening, Speaking, Reading y Writing en condiciones de examen.",
            "fr": "Couvre écoute, oral, lecture et écrit en conditions d’examen.",
            "de": "Umfasst Hören, Sprechen, Lesen und Schreiben unter Prüfungsbedingungen.",
            "pt": "Cobre escuta, fala, leitura e escrita em condições de exame.",
            "it": "Copre ascolto, parlato, lettura e scrittura in condizioni d’esame.",
            "cs": "Zahrnuje poslech, mluvení, čtení a psaní ve zkušebních podmínkách.",
            "fi": "Kattaa kuuntelun, puhumisen, lukemisen ja kirjoittamisen koeolosuhteissa.",
            "ja": "試験条件で聞く・話す・読む・書くを実施します。",
            "ko": "시험 조건에서 듣기·말하기·읽기·쓰기를 평가합니다.",
            "ar": "يشمل الاستماع والتحدث والقراءة والكتابة في ظروف الامتحان.",
            "ur": "امتحان حالات میں سننا، بولنا، پڑھنا اور لکھنا شامل ہے۔",
            "zh": "在考试条件下覆盖听说读写。",
            "hi": "परीक्षा परिस्थितियों में सुनना, बोलना, पढ़ना और लिखना।"
        ],
        .startOfficialExam: [
            "en": "Start official exam", "es": "Empezar examen oficial", "fr": "Commencer l’examen officiel",
            "de": "Offizielle Prüfung starten", "pt": "Iniciar exame oficial", "it": "Avvia esame ufficiale",
            "cs": "Spustit oficiální zkoušku", "fi": "Aloita virallinen koe", "ja": "公式試験を開始",
            "ko": "공식 시험 시작", "ar": "بدء الامتحان الرسمي", "ur": "آفیشل امتحان شروع کریں",
            "zh": "开始正式考试", "hi": "आधिकारिक परीक्षा शुरू करें"
        ],
        .officialScorecard: [
            "en": "Official scorecard", "es": "Acta oficial", "fr": "Relevé officiel", "de": "Offizielle Scorecard",
            "pt": "Boletim oficial", "it": "Scorecard ufficiale", "cs": "Oficiální výsledky", "fi": "Virallinen tuloskortti",
            "ja": "公式スコアカード", "ko": "공식 성적표", "ar": "بطاقة النتائج الرسمية", "ur": "آفیشل اسکور کارڈ",
            "zh": "正式成绩单", "hi": "आधिकारिक स्कोरकार्ड"
        ],
        .overallScore: [
            "en": "Overall", "es": "Global", "fr": "Global", "de": "Gesamt",
            "pt": "Geral", "it": "Complessivo", "cs": "Celkem", "fi": "Kokonais",
            "ja": "総合", "ko": "종합", "ar": "الإجمالي", "ur": "مجموعی",
            "zh": "总分", "hi": "समग्र"
        ],
        .awardedLevel: [
            "en": "Awarded level", "es": "Nivel otorgado", "fr": "Niveau attribué", "de": "Verliehenes Niveau",
            "pt": "Nível atribuído", "it": "Livello assegnato", "cs": "Udělená úroveň", "fi": "Myönnetty taso",
            "ja": "認定レベル", "ko": "부여 레벨", "ar": "المستوى الممنوح", "ur": "دی گئی سطح",
            "zh": "授予级别", "hi": "प्रदत्त स्तर"
        ],
        .targetLevel: [
            "en": "Target level", "es": "Nivel objetivo", "fr": "Niveau cible", "de": "Zielniveau",
            "pt": "Nível alvo", "it": "Livello obiettivo", "cs": "Cílová úroveň", "fi": "Tavoitetaso",
            "ja": "目標レベル", "ko": "목표 레벨", "ar": "المستوى المستهدف", "ur": "ہدف سطح",
            "zh": "目标级别", "hi": "लक्ष्य स्तर"
        ],
        .scorecardFootnote: [
            "en": "Classroom mock using each test’s official papers and scoring rules — not a live certificate from the awarding body.",
            "es": "Simulacro de aula con las pruebas y normas oficiales de cada examen; no es un diploma del organismo certificador.",
            "fr": "Mock pédagogique selon les épreuves et barèmes officiels — pas un diplôme de l’organisme certificateur.",
            "de": "Übungsprüfung nach offiziellen Prüfungsteilen und Bewertungsregeln – kein echtes Zertifikat.",
            "pt": "Simulado com as provas e regras oficiais de cada exame — não é certificado da entidade.",
            "it": "Simulazione con le prove e le regole ufficiali di ciascun esame — non è un certificato dell’ente.",
            "cs": "Cvičná zkouška podle oficiálních částí a pravidel — není certifikát vydavatele.",
            "fi": "Harjoituskoe kunkin testin virallisten osioiden ja arvioinnin mukaan — ei myöntäjän todistus.",
            "ja": "各試験の公式技能と採点規則に沿った教室模擬です（実施機関の公式成績ではありません）。",
            "ko": "각 시험의 공식 영역·채점 규칙을 따른 교실 모의입니다(발급 기관 공식 성적이 아닙니다).",
            "ar": "محاكاة صفية وفق أوراق وقواعد كل اختبار الرسمية وليست شهادة من الجهة المانحة.",
            "ur": "ہر ٹیسٹ کے آفیشل پیپرز اور اسکورنگ کے مطابق کلاس روم ماک — جاری کنندہ کا سرٹیفکیٹ نہیں۔",
            "zh": "按各考试官方题型与评分规则的课堂模拟，并非颁发机构的正式证书。",
            "hi": "प्रत्येक परीक्षा के आधिकारिक पेपर और अंक नियमों वाला कक्षा मॉक — जारीकर्ता का प्रमाणपत्र नहीं।"
        ],
        .latestOfficialResult: [
            "en": "Latest official result", "es": "Último resultado oficial", "fr": "Dernier résultat officiel",
            "de": "Letztes offizielles Ergebnis", "pt": "Último resultado oficial", "it": "Ultimo risultato ufficiale",
            "cs": "Poslední oficiální výsledek", "fi": "Viimeisin virallinen tulos", "ja": "最新の公式結果",
            "ko": "최근 공식 결과", "ar": "آخر نتيجة رسمية", "ur": "تازہ ترین آفیشل نتیجہ",
            "zh": "最新正式成绩", "hi": "नवीनतम आधिकारिक परिणाम"
        ],
        .officialPapers: [
            "en": "Official papers", "es": "Pruebas oficiales", "fr": "Épreuves officielles", "de": "Offizielle Prüfungsteile",
            "pt": "Provas oficiais", "it": "Prove ufficiali", "cs": "Oficiální části", "fi": "Viralliset osakokeet",
            "ja": "公式試験科目", "ko": "공식 시험 영역", "ar": "أوراق الامتحان الرسمية", "ur": "آفیشل پیپرز",
            "zh": "官方试卷", "hi": "आधिकारिक पेपर"
        ],
        .classroomPractice: [
            "en": "Classroom practice", "es": "Práctica de aula", "fr": "Pratique en classe", "de": "Unterrichtspraxis",
            "pt": "Prática em sala", "it": "Pratica in classe", "cs": "Cvičení ve třídě", "fi": "Luokkaharjoitus",
            "ja": "教室練習", "ko": "교실 연습", "ar": "تدريب صفي", "ur": "کلاس روم مشق",
            "zh": "课堂练习", "hi": "कक्षा अभ्यास"
        ],
        .classroomPracticeHint: [
            "en": "This skill is classroom Can-do practice — it is not on the official exam paper.",
            "es": "Esta destreza es práctica de aula (Can-do); no forma parte del examen oficial.",
            "fr": "Compétence travaillée en classe (Can-do) — absente de l’épreuve officielle.",
            "de": "Unterrichtspraxis (Can-do) — nicht Teil der offiziellen Prüfung.",
            "pt": "Prática de sala (Can-do) — não entra no exame oficial.",
            "it": "Pratica in classe (Can-do) — non è nella prova ufficiale.",
            "cs": "Cvičení ve třídě (Can-do) — není v oficiální zkoušce.",
            "fi": "Luokan Can-do-harjoitus — ei virallisessa kokeessa.",
            "ja": "教室のCan-do練習です。公式試験には含まれません。",
            "ko": "교실 Can-do 연습입니다. 공식 시험 영역이 아닙니다.",
            "ar": "تدريب صفّي (Can-do) وليس ضمن ورقة الامتحان الرسمية.",
            "ur": "یہ کلاس روم Can-do مشق ہے — آفیشل امتحان میں نہیں۔",
            "zh": "课堂 Can-do 练习，不属于官方试卷。",
            "hi": "यह कक्षा Can-do अभ्यास है — आधिकारिक परीक्षा में नहीं है।"
        ],
        .capstoneExamHint: [
            "en": "Final official paper after you pass the previous level (no extra teaching week).",
            "es": "Última prueba oficial tras aprobar el nivel anterior (sin semana extra).",
            "fr": "Dernière épreuve officielle après le niveau précédent (pas de semaine supplémentaire).",
            "de": "Letzte offizielle Prüfung nach Bestehen der Vorstufe (keine Extra-Woche).",
            "pt": "Prova final após passar o nível anterior (sem semana extra).",
            "it": "Prova finale dopo il livello precedente (nessuna settimana extra).",
            "cs": "Závěrečná zkouška po splnění předchozí úrovně (bez dalšího týdne).",
            "fi": "Viimeinen virallinen koe edellisen tason jälkeen (ei lisäviikkoa).",
            "ja": "前のレベル合格後の最終公式試験（追加週はありません）。",
            "ko": "이전 레벨 합격 후 보는 최종 공식 시험입니다(추가 주차 없음).",
            "ar": "ورقة رسمية أخيرة بعد اجتياز المستوى السابق (بدون أسبوع إضافي).",
            "ur": "پچھلی سطح پاس کرنے کے بعد حتمی آفیشل پیپر (کوئی اضافی ہفتہ نہیں)۔",
            "zh": "通过上一等级后的最终官方试卷（无额外教学周）。",
            "hi": "पिछला स्तर पास करने के बाद अंतिम आधिकारिक पेपर (कोई अतिरिक्त सप्ताह नहीं)।"
        ],
        .jlptSkillsNote: [
            "en": "JLPT official papers are Language Knowledge, Reading and Listening. Speaking and writing here are Japan Foundation Can-do practice only.",
            "es": "El JLPT oficial evalúa conocimiento lingüístico, lectura y audición. El habla y la escritura son práctica Can-do de la Japan Foundation.",
            "fr": "Le JLPT officiel teste connaissances linguistiques, lecture et écoute. Oral et écrit = Can-do Japan Foundation.",
            "de": "JLPT prüft Sprachwissen, Lesen und Hören. Sprechen/Schreiben hier = JF Can-do-Übung.",
            "pt": "O JLPT oficial avalia conhecimento linguístico, leitura e escuta. Fala e escrita são prática Can-do da Japan Foundation.",
            "it": "Il JLPT ufficiale valuta conoscenza linguistica, lettura e ascolto. Parlato e scritto sono pratica Can-do della Japan Foundation.",
            "cs": "Oficiální JLPT zkouší jazykové znalosti, čtení a poslech. Mluvení a psaní je cvičení Can-do Japan Foundation.",
            "fi": "Virallinen JLPT mittaa kielitietoa, lukemista ja kuuntelua. Puhuminen ja kirjoittaminen ovat JF Can-do -harjoitusta.",
            "ja": "JLPTの公式科目は言語知識・読解・聴解です。話す・書くは国際交流基金のCan-do教室練習です。",
            "ko": "JLPT 공식 영역은 언어지식·읽기·듣기입니다. 말하기·쓰기는 국제교류기금 Can-do 교실 연습입니다.",
            "ar": "أوراق JLPT الرسمية: معرفة لغوية وقراءة واستماع. التحدث والكتابة تدريب Can-do من مؤسسة اليابان.",
            "ur": "JLPT کے آفیشل پیپرز زبان کی معلومات، پڑھنا اور سننا ہیں۔ بولنا/لکھنا Japan Foundation Can-do مشق ہے۔",
            "zh": "JLPT 官方科目为语言知识、阅读和听力。说写仅为日本国际交流基金会 Can-do 课堂练习。",
            "hi": "JLPT के आधिकारिक पेपर भाषा ज्ञान, पढ़ना और सुनना हैं। बोलना/लिखना Japan Foundation Can-do अभ्यास है।"
        ],
        .topikIWritingNote: [
            "en": "TOPIK I (levels 1–2) has Listening and Reading only. Writing tasks here are classroom practice; speaking follows the separate TOPIK Speaking test.",
            "es": "TOPIK I (niveles 1–2) solo tiene comprensión oral y lectora. La escritura es práctica de aula; el oral sigue el TOPIK Speaking aparte.",
            "fr": "TOPIK I (niveaux 1–2) : écoute et lecture seulement. L’écrit est une pratique de classe ; l’oral suit le TOPIK Speaking séparé.",
            "de": "TOPIK I (Stufe 1–2) nur Hören und Lesen. Schreiben ist Unterricht; Sprechen folgt dem separaten TOPIK Speaking.",
            "pt": "TOPIK I (níveis 1–2) só tem escuta e leitura. Escrita é prática de sala; fala segue o TOPIK Speaking separado.",
            "it": "TOPIK I (livelli 1–2) ha solo ascolto e lettura. Lo scritto è pratica in classe; l’orale segue il TOPIK Speaking separato.",
            "cs": "TOPIK I (úroveň 1–2) má jen poslech a čtení. Psaní je cvičení; mluvení kopíruje samostatný TOPIK Speaking.",
            "fi": "TOPIK I (tasot 1–2) mittaa vain kuuntelua ja lukemista. Kirjoittaminen on luokkaharjoitus; puhuminen noudattaa erillistä TOPIK Speaking -koetta.",
            "ja": "TOPIK I（1–2級）は聴解と読解のみ。書きは教室練習、話は別試験のTOPIK Speaking形式です。",
            "ko": "TOPIK I(1–2급)은 듣기·읽기만 있습니다. 쓰기는 교실 연습이고, 말하기는 별도 TOPIK Speaking을 따릅니다.",
            "ar": "TOPIK I (المستوى 1–2) استماع وقراءة فقط. الكتابة تدريب صفي والكلام يتبع اختبار TOPIK Speaking المنفصل.",
            "ur": "TOPIK I (1–2) میں صرف سننا اور پڑھنا ہے۔ لکھنا کلاس مشق ہے؛ بولنا الگ TOPIK Speaking کے مطابق ہے۔",
            "zh": "TOPIK I（1–2级）仅考听力和阅读。写作为课堂练习；口语按独立的 TOPIK Speaking。",
            "hi": "TOPIK I (स्तर 1–2) में केवल सुनना और पढ़ना है। लिखना कक्षा अभ्यास है; बोलना अलग TOPIK Speaking के अनुसार है।"
        ],
        .examPapers: [
            "en": "Exam papers", "es": "Pruebas", "fr": "Épreuves", "de": "Prüfungsteile",
            "pt": "Provas", "it": "Prove", "cs": "Části zkoušky", "fi": "Koekokeet",
            "ja": "試験科目", "ko": "시험 영역", "ar": "أوراق الامتحان", "ur": "امتحانی پرچے",
            "zh": "试卷", "hi": "परीक्षा पेपर"
        ],
        .aiCoach: [
            "en": "AI exam coach", "es": "Coach IA del examen", "fr": "Coach IA d’examen", "de": "KI-Prüfungscoach",
            "pt": "Coach IA do exame", "it": "Coach IA d’esame", "cs": "AI kouč ke zkoušce", "fi": "AI-koekoutsi",
            "ja": "AI試験コーチ", "ko": "AI 시험 코치", "ar": "مدرب الامتحان الذكي", "ur": "AI امتحان کوچ",
            "zh": "AI 考试教练", "hi": "AI परीक्षा कोच"
        ],
        .coachIntro: [
            "en": "First open the official computer/mock sample for that paper (same layout as test day). Then do a classroom paper in that exact task type — not a generic quiz.",
            "es": "Plan personal según tus puntos débiles: muestras oficiales y pruebas a medida sobre un tema que elijas.",
            "fr": "Plan perso selon vos points faibles : sujets officiels + épreuves sur un thème choisi.",
            "de": "Persönlicher Plan aus Ihren Schwächen: offizielle Muster plus eigene Aufgaben zu Ihrem Thema.",
            "pt": "Plano pessoal pelas suas fraquezas: amostras oficiais e provas no tema que escolher.",
            "it": "Piano personale dai punti deboli: campioni ufficiali e prove sul tema che scegli.",
            "cs": "Osobní plán podle slabých dovedností: oficiální vzory a vlastní testy na vaše téma.",
            "fi": "Henkilökohtainen suunnitelma heikoista taidoista: viralliset mallit ja oma aihe.",
            "ja": "苦手技能から個人計画を作り、公式サンプルと選んだ話題のカスタム問題を練習します。",
            "ko": "약한 영역을 바탕으로 개인 계획을 만들고, 공식 샘플과 선택한 주제의 맞춤 문제를 연습합니다.",
            "ar": "خطة شخصية من نقاط ضعفك مع نماذج رسمية وتمارين على موضوع تختاره.",
            "ur": "کمزور مہارتوں سے ذاتی پلان، آفیشل نمونے اور آپ کے موضوع پر کسٹم پیپرز۔",
            "zh": "根据弱项生成个人计划，练习官方样题和你自选主题的定制试卷。",
            "hi": "कमज़ोर कौशलों से निजी योजना: आधिकारिक नमूने और आपके विषय पर कस्टम पेपर।"
        ],
        .buildPlan: [
            "en": "Build my plan", "es": "Crear mi plan", "fr": "Créer mon plan", "de": "Meinen Plan erstellen",
            "pt": "Montar meu plano", "it": "Crea il mio piano", "cs": "Sestavit plán", "fi": "Tee suunnitelma",
            "ja": "計画を作る", "ko": "내 계획 만들기", "ar": "إنشاء خطتي", "ur": "میرا پلان بنائیں",
            "zh": "生成我的计划", "hi": "मेरी योजना बनाएँ"
        ],
        .topicPlaceholder: [
            "en": "Topic (e.g. hospitals, remote work)", "es": "Tema (p. ej. hospitales, teletrabajo)",
            "fr": "Thème (ex. hôpitaux, télétravail)", "de": "Thema (z. B. Krankenhaus, Homeoffice)",
            "pt": "Tema (ex. hospitais, home office)", "it": "Tema (es. ospedali, smart working)",
            "cs": "Téma (např. nemocnice, práce z domova)", "fi": "Aihe (esim. sairaala, etätyö)",
            "ja": "話題（例：病院、在宅勤務）", "ko": "주제 (예: 병원, 재택근무)",
            "ar": "موضوع (مثل المستشفيات أو العمل عن بعد)", "ur": "موضوع (جیسے ہسپتال، ریموٹ ورک)",
            "zh": "主题（如医院、远程办公）", "hi": "विषय (जैसे अस्पताल, रिमोट वर्क)"
        ],
        .planWeeks: [
            "en": "Weeks", "es": "Semanas", "fr": "Semaines", "de": "Wochen",
            "pt": "Semanas", "it": "Settimane", "cs": "Týdny", "fi": "Viikot",
            "ja": "週数", "ko": "주 수", "ar": "أسابيع", "ur": "ہفتے",
            "zh": "周数", "hi": "सप्ताह"
        ],
        .minutesPerDay: [
            "en": "Minutes per day", "es": "Minutos al día", "fr": "Minutes par jour", "de": "Minuten pro Tag",
            "pt": "Minutos por dia", "it": "Minuti al giorno", "cs": "Minut denně", "fi": "Minuutteja päivässä",
            "ja": "1日の分数", "ko": "하루 분", "ar": "دقائق يومياً", "ur": "روزانہ منٹ",
            "zh": "每天分钟", "hi": "प्रति दिन मिनट"
        ],
        .generatePlan: [
            "en": "Generate plan & custom papers", "es": "Generar plan y pruebas", "fr": "Générer le plan et les sujets",
            "de": "Plan und Aufgaben erzeugen", "pt": "Gerar plano e provas", "it": "Genera piano e prove",
            "cs": "Vygenerovat plán a testy", "fi": "Luo suunnitelma ja tehtävät",
            "ja": "計画とカスタム問題を生成", "ko": "계획과 맞춤 문제 생성",
            "ar": "إنشاء الخطة والتمارين", "ur": "پلان اور کسٹم پیپرز بنائیں",
            "zh": "生成计划与定制试卷", "hi": "योजना और कस्टम पेपर बनाएँ"
        ],
        .officialSamples: [
            "en": "Official samples that help most", "es": "Muestras oficiales más útiles",
            "fr": "Sujets officiels les plus utiles", "de": "Hilfreichste offizielle Muster",
            "pt": "Amostras oficiais mais úteis", "it": "Campioni ufficiali più utili",
            "cs": "Nejužitečnější oficiální vzory", "fi": "Hyödyllisimmät viralliset mallit",
            "ja": "最も役立つ公式サンプル", "ko": "가장 도움이 되는 공식 샘플",
            "ar": "النماذج الرسمية الأكثر فائدة", "ur": "سب سے مفید آفیشل نمونے",
            "zh": "最有用的官方样题", "hi": "सबसे उपयोगी आधिकारिक नमूने"
        ],
        .questionsOnScreen: [
            "en": "Questions stay on screen while you listen (computer test). The recording plays once.",
            "es": "Las preguntas quedan en pantalla mientras escuchas (examen por ordenador). La grabación se oye una vez.",
            "fr": "Les questions restent à l’écran pendant l’écoute (test sur ordinateur). L’audio passe une seule fois.",
            "de": "Fragen bleiben während des Hörens sichtbar (Computertest). Die Aufnahme läuft einmal.",
            "pt": "As perguntas ficam no ecrã enquanto ouve (teste no computador). A gravação toca uma vez.",
            "it": "Le domande restano a schermo mentre ascolti (test al computer). La registrazione si sente una sola volta.",
            "cs": "Otázky zůstanou na obrazovce při poslechu (počítačový test). Nahrávka jednou.",
            "fi": "Kysymykset pysyvät ruudulla kuunnellessa (konetesti). Nauha soi kerran.",
            "ja": "コンピューター試験と同じく、聞きながら問題を表示します。音声は1回だけです。",
            "ko": "컴퓨터 시험처럼 듣는 동안 문제가 화면에 남습니다. 음원은 한 번만 재생됩니다.",
            "ar": "تبقى الأسئلة على الشاشة أثناء الاستماع (اختبار حاسوب). التسجيل مرة واحدة.",
            "ur": "سنتے وقت سوالات اسکرین پر رہتے ہیں (کمپیوٹر ٹیسٹ)۔ ریکارڈنگ ایک بار۔",
            "zh": "听力播放时题目留在屏幕上（机考）。录音只放一遍。",
            "hi": "सुनते समय प्रश्न स्क्रीन पर रहते हैं (कंप्यूटर टेस्ट)। रिकॉर्डिंग एक बार।"
        ],
        .submitAnswers: [
            "en": "Submit answers", "es": "Enviar respuestas", "fr": "Envoyer les réponses", "de": "Antworten abgeben",
            "pt": "Enviar respostas", "it": "Invia risposte", "cs": "Odeslat odpovědi", "fi": "Lähetä vastaukset",
            "ja": "解答を提出", "ko": "답안 제출", "ar": "تسليم الإجابات", "ur": "جوابات جمع کریں",
            "zh": "提交答案", "hi": "उत्तर जमा करें"
        ],
        .startPrep: [
            "en": "Start 1-minute prep", "es": "Empezar 1 min de notas", "fr": "1 minute de préparation", "de": "1 Minute Vorbereitung",
            "pt": "1 minuto de preparação", "it": "1 minuto di preparazione", "cs": "1 minuta na přípravu", "fi": "1 minuutin valmistelu",
            "ja": "1分の準備を開始", "ko": "1분 준비 시작", "ar": "ابدأ دقيقة التحضير", "ur": "1 منٹ تیاری شروع",
            "zh": "开始 1 分钟准备", "hi": "1 मिनट तैयारी शुरू"
        ],
        .prepareSeconds: [
            "en": "Prep: %d s", "es": "Notas: %d s", "fr": "Préparation : %d s", "de": "Vorbereitung: %d s",
            "pt": "Preparação: %d s", "it": "Prep: %d s", "cs": "Příprava: %d s", "fi": "Valmistelu: %d s",
            "ja": "準備：%d秒", "ko": "준비: %d초", "ar": "تحضير: %d ث", "ur": "تیاری: %d سیکنڈ",
            "zh": "准备：%d 秒", "hi": "तैयारी: %d सेकंड"
        ],
        .prepareNotes: [
            "en": "Make notes. You cannot pause the live test; here you may start speaking early.",
            "es": "Toma notas. En el examen real no puedes pausar; aquí puedes empezar antes.",
            "fr": "Prenez des notes. L’examen réel ne se met pas en pause ; ici vous pouvez parler plus tôt.",
            "de": "Notizen machen. Im echten Test gibt es keine Pause; hier dürfen Sie früher sprechen.",
            "pt": "Faça notas. No exame real não se pausa; aqui pode começar mais cedo.",
            "it": "Prendi appunti. Nel test reale non si mette in pausa; qui puoi iniziare prima.",
            "cs": "Dělejte si poznámky. Na ostře se pauza nedává; tady můžete začít dřív.",
            "fi": "Tee muistiinpanoja. Oikeassa kokeessa ei taukoa; tässä voit aloittaa aiemmin.",
            "ja": "メモを取ってください。本番は止められません。ここでは早めに話し始めても構いません。",
            "ko": "메모하세요. 실제 시험은 멈출 수 없습니다. 여기선 일찍 말하기를 시작해도 됩니다.",
            "ar": "دوّن ملاحظات. الاختبار الحقيقي لا يتوقف؛ هنا يمكنك البدء مبكراً.",
            "ur": "نوٹس بنائیں۔ اصل ٹیسٹ رکا نہیں کرتا؛ یہاں جلدی بول سکتے ہیں۔",
            "zh": "做笔记。正式考试不能暂停；这里可以提前开始说。",
            "hi": "नोट्स बनाएँ। असली टेस्ट रुकता नहीं; यहाँ जल्दी बोल सकते हैं।"
        ],
        .startSpeakingNow: [
            "en": "Please start speaking now", "es": "Empieza a hablar ahora", "fr": "Parlez maintenant", "de": "Bitte jetzt sprechen",
            "pt": "Comece a falar agora", "it": "Inizia a parlare ora", "cs": "Začněte mluvit", "fi": "Aloita puhuminen",
            "ja": "では話してください", "ko": "이제 말하세요", "ar": "ابدأ الكلام الآن", "ur": "اب بولنا شروع کریں",
            "zh": "请开始发言", "hi": "अब बोलना शुरू करें"
        ],
        .speakSecondsLeft: [
            "en": "%d s left", "es": "Quedan %d s", "fr": "%d s restantes", "de": "Noch %d s",
            "pt": "%d s restantes", "it": "%d s rimasti", "cs": "Zbývá %d s", "fi": "%d s jäljellä",
            "ja": "残り%d秒", "ko": "%d초 남음", "ar": "تبقى %d ث", "ur": "%d سیکنڈ باقی",
            "zh": "剩余 %d 秒", "hi": "%d सेकंड शेष"
        ],
        .cueCard: [
            "en": "Cue card", "es": "Tarjeta", "fr": "Carte sujet", "de": "Themenkarte",
            "pt": "Cartão", "it": "Scheda", "cs": "Kartička", "fi": "Aihekortti",
            "ja": "キューカード", "ko": "큐 카드", "ar": "بطاقة الموضوع", "ur": "کیو کارڈ",
            "zh": "提示卡", "hi": "क्यू कार्ड"
        ],
        .youShouldSay: [
            "en": "You should say:", "es": "Debes hablar de:", "fr": "Vous devez parler de :", "de": "Sprechen Sie über:",
            "pt": "Deve falar sobre:", "it": "Dovresti parlare di:", "cs": "Měli byste říct:", "fi": "Kerro:",
            "ja": "次の点について話してください：", "ko": "다음을 말하세요:", "ar": "ينبغي أن تتحدث عن:", "ur": "آپ یہ بتائیں:",
            "zh": "请谈到：",             "hi": "आपको यह कहना चाहिए:"
        ],
        .classroomPaperNote: [
            "en": "Original classroom paper in the official task shape — not live IELTS content.",
            "es": "Ejercicio de aula con el formato oficial — no es contenido IELTS en vivo.",
            "fr": "Sujet de classe au format officiel — pas le contenu IELTS en direct.",
            "de": "Unterrichtsaufgabe im offiziellen Format — kein Live-IELTS-Inhalt.",
            "pt": "Prova de aula no formato oficial — não é conteúdo IELTS ao vivo.",
            "it": "Prova in classe nel formato ufficiale — non è contenuto IELTS dal vivo.",
            "cs": "Cvičná úloha v oficiálním formátu — není živý obsah IELTS.",
            "fi": "Luokkatehtävä virallisessa muodossa — ei live-IELTS-sisältöä.",
            "ja": "公式の出題形式に合わせた教室用問題です。本番のIELTS問題ではありません。",
            "ko": "공식 문항 유형의 교실용 문제이며 실제 IELTS 문항이 아닙니다.",
            "ar": "ورقة صف بنفس شكل المهمة الرسمية وليست محتوى آيلتس مباشر.",
            "ur": "آفیشل ٹاسک کی شکل میں کلاس روم پیپر — لائیو IELTS مواد نہیں۔",
            "zh": "按官方题型编写的课堂卷，并非现场雅思原题。",
            "hi": "आधिकारिक टास्क रूप का कक्षा पेपर — लाइव IELTS सामग्री नहीं।"
        ],
        .openOfficialSample: [
            "en": "Open official sample", "es": "Abrir muestra oficial", "fr": "Ouvrir l’échantillon officiel",
            "de": "Offizielles Muster öffnen", "pt": "Abrir amostra oficial", "it": "Apri campione ufficiale",
            "cs": "Otevřít oficiální vzor", "fi": "Avaa virallinen malli",
            "ja": "公式サンプルを開く", "ko": "공식 샘플 열기", "ar": "فتح النموذج الرسمي", "ur": "آفیشل نمونہ کھولیں",
            "zh": "打开官方样题", "hi": "आधिकारिक नमूना खोलें"
        ],
        .savedPlans: [
            "en": "Saved plans", "es": "Planes guardados", "fr": "Plans enregistrés", "de": "Gespeicherte Pläne",
            "pt": "Planos salvos", "it": "Piani salvati", "cs": "Uložené plány", "fi": "Tallennetut suunnitelmat",
            "ja": "保存した計画", "ko": "저장된 계획", "ar": "الخطط المحفوظة", "ur": "محفوظ پلانز",
            "zh": "已存计划", "hi": "सहेजी योजनाएँ"
        ],
    ]
}

extension UserProfileStore {
    func text(_ key: L10n.Key) -> String {
        L10n.t(key, uiLanguageCode)
    }
}
