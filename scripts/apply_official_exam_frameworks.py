#!/usr/bin/env python3
"""Stamp official exam levels + skill papers onto each language course.

Sources (classroom mocks, not live exam papers):
- IELTS: ielts.org test format + Cambridge CEFR mapping
- Goethe-Zertifikat: goethe.de exam regulations
- DELE: examenes.cervantes.es guides
- DELF/DALF: French Ministry / France Éducation international
- JLPT: jlpt.jp test sections (no speaking/writing)
- TOPIK: NIIED (TOPIK I/II + separate Speaking)
- YKI: Finnish National Agency for Education
- CCE: ÚJOP Charles University (A1–C1; grammar/lexical from B2)
"""
from __future__ import annotations

import copy
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1] / "LanguageLearningApp" / "Resources" / "Languages"

CEFR_ORDER = ["A1", "A2", "B1", "B2", "C1", "C2"]


def cefr(level: str) -> str:
    for key in ("C2", "C1", "B2", "B1", "A2", "A1"):
        if key in (level or ""):
            return key
    return "A1"


def skill_papers(listening, speaking, reading, writing, extra=None):
    papers = {
        "listening": listening,
        "speaking": speaking,
        "reading": reading,
        "writing": writing,
    }
    if extra:
        papers.update(extra)
    return papers


FRAMEWORKS = {
    "ielts_english": {
        "testName": "IELTS Academic / General Training",
        "awardingBody": "British Council, IDP IELTS, Cambridge University Press & Assessment",
        "scoreSystem": "IELTS Band 0–9",
        "scoreSystemId": "ieltsBand",
        "isLevelExam": False,
        "notes": (
            "IELTS is not a pass/fail CEFR exam. Candidates receive a band 0–9 (half bands) "
            "for Listening, Reading, Writing and Speaking; overall is the average rounded to the nearest 0.5. "
            "Cambridge maps overall bands approximately: 2.0–2.5≈A1, 3.0–3.5≈A2, 4.0–5.0≈B1, "
            "5.5–6.5≈B2, 7.0–8.0≈C1, 8.5–9.0≈C2. Band 6.5 is borderline C1; band 8 is borderline C2. "
            "Listening is heard once. Academic and General Training share Listening and Speaking; "
            "Reading texts and Writing Task 1 differ."
        ),
        "officialLevels": [
            {"id": "A1", "label": "A1 · Band 2.0–2.5", "cefr": "A1", "examName": "IELTS (pre-test / Life Skills A1)", "weeks": [1, 2]},
            {"id": "A2", "label": "A2 · Band 3.0–3.5", "cefr": "A2", "examName": "IELTS (early band)", "weeks": [3, 4]},
            {"id": "B1", "label": "B1 · Band 4.0–5.0", "cefr": "B1", "examName": "IELTS / UKVI Life Skills B1", "weeks": [5, 6]},
            {"id": "B2", "label": "B2 · Band 5.5–6.5", "cefr": "B2", "examName": "IELTS Academic / GT", "weeks": [7, 8]},
            {"id": "C1", "label": "C1 · Band 7.0–8.0", "cefr": "C1", "examName": "IELTS Academic / GT", "weeks": [9]},
            {"id": "C2", "label": "C2 · Band 8.5–9.0", "cefr": "C2", "examName": "IELTS Academic / GT", "weeks": []},
        ],
        "officialSkills": ["listening", "speaking", "reading", "writing"],
        "classroomSkills": [],
        "skillPapers": skill_papers(
            {
                "officialName": "Listening",
                "minutes": 30,
                "playCount": 1,
                "parts": [
                    "Part 1 — everyday conversation (10 questions)",
                    "Part 2 — social monologue (10 questions)",
                    "Part 3 — training/academic discussion (10 questions)",
                    "Part 4 — academic lecture (10 questions)",
                ],
                "example": "A conversation about travel arrangements, then a talk about local facilities, a seminar discussion, and a lecture. Heard once; 40 questions in recording order.",
            },
            {
                "officialName": "Speaking",
                "minutes": "11–14",
                "parts": [
                    "Part 1 — introduction and interview (4–5 min)",
                    "Part 2 — long turn with 1 min notes (3–4 min)",
                    "Part 3 — two-way discussion on Part 2 theme (4–5 min)",
                ],
                "example": "Familiar topics (home, work, study), then a 2-minute cue-card talk, then abstract follow-up questions.",
            },
            {
                "officialName": "Reading",
                "minutes": 60,
                "parts": [
                    "Academic: 3 long passages (2150–2750 words, 40 questions)",
                    "General Training: Section 1 short notices, Section 2 workplace texts, Section 3 longer general-interest text",
                ],
                "example": "Multiple choice, True/False/Not Given, matching headings, summary/note completion.",
            },
            {
                "officialName": "Writing",
                "minutes": 60,
                "parts": [
                    "Task 1 Academic: describe a graph/table/chart/diagram (≥150 words, ~20 min)",
                    "Task 1 General Training: letter (≥150 words)",
                    "Task 2: discursive essay (≥250 words, ~40 min; counts more)",
                ],
                "example": "Describe a bar chart of energy use, then discuss whether governments should tax unhealthy food.",
            },
        ),
        "passRule": "No pass mark. Overall band = mean of four skills, rounded to nearest 0.5.",
        "frameworkLine": "IELTS bands 0–9 mapped to CEFR A1 → C2",
        "description": (
            "A 9-week IELTS pathway using the official four papers (Listening, Reading, Writing, Speaking). "
            "Weeks 1–2 target A1 / bands ~2.0–2.5, 3–4 A2 / 3.0–3.5, 5–6 B1 / 4.0–5.0, 7–8 B2 / 5.5–6.5, "
            "week 9 C1 / 7.0–8.0, with a C2 / 8.5–9.0 mock after week 9. Classroom scores are practice estimates, not British Council results."
        ),
    },
    "german": {
        "testName": "Goethe-Zertifikat",
        "awardingBody": "Goethe-Institut",
        "scoreSystem": "Goethe points / 100",
        "scoreSystemId": "goethe100",
        "isLevelExam": True,
        "notes": (
            "Separate certificates A1–C2. A1 (Start Deutsch 1) and A2 are full exams (Lesen, Hören, Schreiben, Sprechen). "
            "B1–C2 are modular. A1: ~60/100 to pass (75 written + 25 oral). Recommended order: Hören → Lesen → Schreiben, then Sprechen."
        ),
        "officialLevels": [
            {"id": "A1", "label": "A1 · Goethe-Zertifikat A1", "cefr": "A1", "examName": "Goethe-Zertifikat A1: Start Deutsch 1", "weeks": [1, 2]},
            {"id": "A2", "label": "A2 · Goethe-Zertifikat A2", "cefr": "A2", "examName": "Goethe-Zertifikat A2", "weeks": [3, 4]},
            {"id": "B1", "label": "B1 · Goethe-Zertifikat B1", "cefr": "B1", "examName": "Goethe-Zertifikat B1", "weeks": [5, 6]},
            {"id": "B2", "label": "B2 · Goethe-Zertifikat B2", "cefr": "B2", "examName": "Goethe-Zertifikat B2", "weeks": [7, 8]},
            {"id": "C1", "label": "C1 · Goethe-Zertifikat C1", "cefr": "C1", "examName": "Goethe-Zertifikat C1", "weeks": [9]},
            {"id": "C2", "label": "C2 · Goethe-Zertifikat C2 (GDS)", "cefr": "C2", "examName": "Goethe-Zertifikat C2: Großes Deutsches Sprachdiplom", "weeks": []},
        ],
        "officialSkills": ["listening", "reading", "writing", "speaking"],
        "classroomSkills": [],
        "skillPapers": skill_papers(
            {
                "officialName": "Hören",
                "minutes": "20–40 depending on level",
                "playCount": 2,
                "parts": ["Teil 1–3 (A1) or Teil 1–4 (A2+): dialogues, announcements, interviews"],
                "example": "A1: short everyday talks and tannoy announcements; some texts once, some twice.",
            },
            {
                "officialName": "Sprechen",
                "minutes": "10–16",
                "parts": ["Teil 1 introduce yourself", "Teil 2 ask/answer everyday questions", "Teil 3 request something / discuss (pair or group at A1)"],
                "example": "A1 group exam: introduce, ask daily questions from cards, make a simple request.",
            },
            {
                "officialName": "Lesen",
                "minutes": "25–70",
                "parts": ["A1 Teil 1–3 short notices/ads", "B1+ Teil 1–5 longer texts and matching"],
                "example": "Read a noticeboard, classified ads, and a short email, then choose the correct statement.",
            },
            {
                "officialName": "Schreiben",
                "minutes": "20–80",
                "parts": ["A1: form + short message", "B1: email/forum + statement of opinion", "B2–C2: formal texts / essays"],
                "example": "Fill in a hotel form, then write a 30-word note arranging a meeting.",
            },
        ),
        "passRule": "Typically 60/100 overall (modules may be certified separately from B1).",
        "frameworkLine": "Goethe-Zertifikat A1 → C2 (CEFR)",
        "description": (
            "A Goethe-Institut pathway: weeks 1–2 Start Deutsch 1 (A1), 3–4 A2, 5–6 B1, 7–8 B2, week 9 C1, "
            "plus a C2 GDS mock. Each level trains Lesen, Hören, Schreiben and Sprechen in the official paper order."
        ),
    },
    "spanish": {
        "testName": "DELE",
        "awardingBody": "Instituto Cervantes (Spanish Ministry of Education)",
        "scoreSystem": "DELE / 100 (Apto)",
        "scoreSystemId": "dele100",
        "isLevelExam": True,
        "notes": (
            "Six independent diplomas A1–C2. A1–B2: four tests in two groups "
            "(reading+writing / listening+speaking). Need 30/50 in each group. "
            "C1 uses integrated skills; C2 uses three tests including mediation."
        ),
        "officialLevels": [
            {"id": "A1", "label": "A1 · DELE A1", "cefr": "A1", "examName": "Diploma de Español A1", "weeks": [1, 2]},
            {"id": "A2", "label": "A2 · DELE A2", "cefr": "A2", "examName": "Diploma de Español A2", "weeks": [3, 4]},
            {"id": "B1", "label": "B1 · DELE B1", "cefr": "B1", "examName": "Diploma de Español B1", "weeks": [5, 6]},
            {"id": "B2", "label": "B2 · DELE B2", "cefr": "B2", "examName": "Diploma de Español B2", "weeks": [7, 8]},
            {"id": "C1", "label": "C1 · DELE C1", "cefr": "C1", "examName": "Diploma de Español C1", "weeks": [9]},
            {"id": "C2", "label": "C2 · DELE C2", "cefr": "C2", "examName": "Diploma de Español C2", "weeks": []},
        ],
        "officialSkills": ["reading", "writing", "listening", "speaking"],
        "classroomSkills": [],
        "skillPapers": skill_papers(
            {
                "officialName": "Comprensión auditiva",
                "minutes": "25–50",
                "playCount": 2,
                "parts": ["Short dialogues and announcements", "Longer interviews / news (higher levels)", "C1: listening + use of language"],
                "example": "Listen twice to a shop dialogue and choose the product the speakers buy.",
            },
            {
                "officialName": "Expresión e interacción orales",
                "minutes": "10–20 + preparation",
                "parts": ["Personal interview", "Describe a photo / present a topic", "Conversation / negotiation with examiner"],
                "example": "A1: introduce yourself, describe a photo of a family meal, then ask the examiner simple questions.",
            },
            {
                "officialName": "Comprensión de lectura",
                "minutes": "45–90",
                "parts": ["Notices and emails", "Longer articles and opinion texts", "C1/C2: reading + use of language / mediation"],
                "example": "Match four short ads to the person who needs each service.",
            },
            {
                "officialName": "Expresión e interacción escritas",
                "minutes": "25–150",
                "parts": ["A1–B2: form/message + short text", "C1: listen then write + independent writing", "C2: mediation of oral and written sources"],
                "example": "Write a 60-word email to a classmate to arrange studying together.",
            },
        ),
        "passRule": "A1–C1: Apto with ≥30/50 in both skill groups. C2: ≥20 points on each of three tests.",
        "frameworkLine": "DELE A1 → C2 (Instituto Cervantes)",
        "description": (
            "An Instituto Cervantes / DELE pathway: A1–B2 four-skill diplomas, C1 integrated skills, "
            "and a C2 mock with mediation. Passing follows the official grouped-score rule in classroom form."
        ),
    },
    "french": {
        "testName": "DELF / DALF",
        "awardingBody": "France Éducation international / Alliance Française centres",
        "scoreSystem": "DELF-DALF / 100",
        "scoreSystemId": "delf100",
        "isLevelExam": True,
        "notes": (
            "DELF A1–B2 and DALF C1–C2 are independent diplomas. Each skill /25; pass 50/100 with at least 5/25 per skill "
            "(DALF C2 uses two integrated papers /50). Collective written exam then individual oral."
        ),
        "officialLevels": [
            {"id": "A1", "label": "A1 · DELF A1", "cefr": "A1", "examName": "DELF A1", "weeks": [1, 2]},
            {"id": "A2", "label": "A2 · DELF A2", "cefr": "A2", "examName": "DELF A2", "weeks": [3, 4]},
            {"id": "B1", "label": "B1 · DELF B1", "cefr": "B1", "examName": "DELF B1", "weeks": [5, 6]},
            {"id": "B2", "label": "B2 · DELF B2", "cefr": "B2", "examName": "DELF B2", "weeks": [7, 8]},
            {"id": "C1", "label": "C1 · DALF C1", "cefr": "C1", "examName": "DALF C1", "weeks": [9]},
            {"id": "C2", "label": "C2 · DALF C2", "cefr": "C2", "examName": "DALF C2", "weeks": []},
        ],
        "officialSkills": ["listening", "reading", "writing", "speaking"],
        "classroomSkills": [],
        "skillPapers": skill_papers(
            {
                "officialName": "Compréhension de l’oral",
                "minutes": "20–40",
                "playCount": 2,
                "parts": ["A1: 3–4 very short daily recordings (max 3 min, two listens)", "B2: news/interview (one listen) + talk (two listens)", "C1: long interview + short radio clips"],
                "example": "A1: listen twice to a weather and shopping dialogue, then tick the correct picture.",
            },
            {
                "officialName": "Production orale",
                "minutes": "5–20 + preparation",
                "parts": ["Guided interview", "Interactive task / role play", "Monologue / presentation (B1+)"],
                "example": "DELF A1: introduce yourself, then act out buying a ticket.",
            },
            {
                "officialName": "Compréhension des écrits",
                "minutes": "30–50",
                "parts": ["A1: 4–5 short daily texts", "B2: informative + argumentative texts", "C1: long literary/journalistic text"],
                "example": "Read a café menu and a postcard, then answer comprehension items.",
            },
            {
                "officialName": "Production écrite",
                "minutes": "30–210",
                "parts": ["A1: form + 40-word message", "B1–B2: essay / formal letter", "C1: synthesis 220–240 words + 250-word essay", "C2: integrated reading+writing 3h30"],
                "example": "Complete a registration form, then write a postcard about your town.",
            },
        ),
        "passRule": "50/100 overall and ≥5/25 in each skill (C2: ≥10/50 on each integrated paper).",
        "frameworkLine": "DELF A1–B2 / DALF C1–C2",
        "description": (
            "An Alliance Française / DELF-DALF pathway: A1–B2 (DELF), C1 (DALF), plus a DALF C2 mock. "
            "Each diploma trains compréhension orale, compréhension des écrits, production écrite and production orale."
        ),
    },
    "japanese": {
        "testName": "JLPT",
        "awardingBody": "Japan Foundation / JEES",
        "scoreSystem": "JLPT scaled score",
        "scoreSystemId": "jlpt",
        "isLevelExam": True,
        "notes": (
            "JLPT has five levels N5 (easiest) to N1. Official papers are Language Knowledge (vocabulary/grammar), "
            "Reading, and Listening only — no speaking or writing. Japan Foundation CEFR references on score reports: "
            "N5≥80≈A1, N4≥90≈A2, N3 95–103≈A2 / ≥104≈B1, N2 90–111≈B1 / ≥112≈B2, N1 100–141≈B2 / ≥142≈C1. "
            "Speaking and writing in this app follow JF Standard Can-do practice and are not part of the official JLPT."
        ),
        "officialLevels": [
            {"id": "A1", "label": "N5 (A1)", "cefr": "A1", "examName": "JLPT N5", "weeks": [1, 2]},
            {"id": "A2", "label": "N4 (A2)", "cefr": "A2", "examName": "JLPT N4", "weeks": [3, 4]},
            {"id": "B1", "label": "N3 (A2–B1)", "cefr": "B1", "examName": "JLPT N3", "weeks": [5, 6]},
            {"id": "B2", "label": "N2 (B1–B2)", "cefr": "B2", "examName": "JLPT N2", "weeks": [7, 8]},
            {"id": "C1", "label": "N1 (B2–C1)", "cefr": "C1", "examName": "JLPT N1", "weeks": [9]},
        ],
        "officialSkills": ["languageKnowledge", "reading", "listening"],
        "classroomSkills": ["speaking", "writing"],
        "skillPapers": skill_papers(
            {
                "officialName": "聴解 Listening",
                "minutes": "30–55",
                "playCount": 1,
                "parts": ["Task-based comprehension", "Key points", "Outline (N3–N1)", "Verbal expressions (N5–N3)", "Quick response"],
                "example": "Hear a short shop dialogue once and choose what the customer will buy.",
            },
            {
                "officialName": "JF Can-do Speaking (not on JLPT)",
                "minutes": "classroom",
                "parts": ["Self-introduction", "Simple Q&A", "Describe a picture", "Opinion (N2–N1 Can-do)"],
                "example": "Classroom speaking aligned to JF Standard for Japanese-Language Education.",
            },
            {
                "officialName": "読解 Reading",
                "minutes": "40–110 combined with language knowledge at N1/N2",
                "parts": ["Kanji/vocabulary items", "Grammar form selection and sentence composition", "Short, mid-size, and long comprehension"],
                "example": "Choose the correct particle, then answer questions on a short notice and a newspaper paragraph.",
            },
            {
                "officialName": "JF Can-do Writing (not on JLPT)",
                "minutes": "classroom",
                "parts": ["Short messages", "Diary / email", "Opinion paragraph at higher Can-do levels"],
                "example": "Write a です/ます self-introduction. Not scored as JLPT.",
            },
            extra={
                "languageKnowledge": {
                    "officialName": "言語知識 Vocabulary / Grammar",
                    "minutes": "20–30 standalone at N5–N3; combined with reading at N2–N1",
                    "parts": ["Kanji reading", "Contextually defined expressions", "Sentential grammar", "Text grammar"],
                    "example": "Choose the correct 漢字 reading and the grammar form that completes the sentence.",
                }
            },
        ),
        "passRule": "Pass requires both a total scaled-score cut-off and a minimum in each official section.",
        "frameworkLine": "JLPT N5 → N1 (CEFR A1 → C1; no official C2 paper)",
        "description": (
            "A Japan Foundation / JLPT pathway: N5–N1. Official mocks score Language Knowledge, Reading and Listening. "
            "Speaking and writing are JF Can-do classroom practice because JLPT does not test production."
        ),
    },
    "korean": {
        "testName": "TOPIK I / II + TOPIK Speaking",
        "awardingBody": "NIIED / King Sejong Institute pathway",
        "scoreSystem": "TOPIK levels 1–6",
        "scoreSystemId": "topik",
        "isLevelExam": True,
        "notes": (
            "TOPIK I (levels 1–2): Listening + Reading only, 200 points PBT. "
            "TOPIK II (levels 3–6): Listening + Writing + Reading, 300 points PBT. "
            "CEFR link used by TOPIK partners: 1급=A1, 2급=A2, 3급=B1, 4급=B2, 5급=C1, 6급=C2. "
            "TOPIK Speaking is a separate 6-task / 200-point test, not a section of TOPIK I or II."
        ),
        "officialLevels": [
            {"id": "A1", "label": "TOPIK 1급 (A1)", "cefr": "A1", "examName": "TOPIK I", "weeks": [1, 2]},
            {"id": "A2", "label": "TOPIK 2급 (A2)", "cefr": "A2", "examName": "TOPIK I", "weeks": [3, 4]},
            {"id": "B1", "label": "TOPIK 3급 (B1)", "cefr": "B1", "examName": "TOPIK II", "weeks": [5, 6]},
            {"id": "B2", "label": "TOPIK 4급 (B2)", "cefr": "B2", "examName": "TOPIK II", "weeks": [7, 8]},
            {"id": "C1", "label": "TOPIK 5급 (C1)", "cefr": "C1", "examName": "TOPIK II", "weeks": [9]},
            {"id": "C2", "label": "TOPIK 6급 (C2)", "cefr": "C2", "examName": "TOPIK II", "weeks": []},
        ],
        "officialSkills": ["listening", "reading", "writing", "speaking"],
        "classroomSkills": [],
        "skillPapers": skill_papers(
            {
                "officialName": "듣기 Listening",
                "minutes": "40 (I) / 60 (II PBT)",
                "playCount": 1,
                "parts": ["TOPIK I: 30 items", "TOPIK II: 50 items — dialogues, broadcasts, lectures"],
                "example": "Hear a station announcement and choose the correct platform.",
            },
            {
                "officialName": "TOPIK Speaking (separate test)",
                "minutes": 30,
                "parts": [
                    "Task 1 answer a simple question",
                    "Task 2 role-play from images",
                    "Task 3 tell a story from pictures",
                    "Task 4 complete a dialogue",
                    "Task 5 interpret a chart/material",
                    "Task 6 give an opinion",
                ],
                "example": "Look at four pictures, tell the story, then give your opinion on a social topic (levels 5–6).",
            },
            {
                "officialName": "읽기 Reading",
                "minutes": "60 (I) / 70 (II PBT)",
                "parts": ["TOPIK I: 40 items — signs, notices, short paragraphs", "TOPIK II: 50 items — articles, graphs, academic texts"],
                "example": "Read a café notice and choose why it is closed on Monday.",
            },
            {
                "officialName": "쓰기 Writing (TOPIK II only)",
                "minutes": 50,
                "parts": [
                    "Q51–52 short completions (PBT)",
                    "Q53 descriptive paragraph (~200–300 characters)",
                    "Q54 argumentative essay (~600–700 characters)",
                ],
                "example": "Levels 1–2 practise writing in class only. From 3급, write a chart description then an opinion essay.",
            },
        ),
        "passRule": "PBT: TOPIK I level 1 ≥80/200, level 2 ≥140/200; TOPIK II level 3 ≥120, 4 ≥150, 5 ≥190, 6 ≥230 / 300.",
        "frameworkLine": "TOPIK 1급 → 6급 (≈ CEFR A1 → C2)",
        "description": (
            "A King Sejong / TOPIK pathway: 1–2급 (TOPIK I: listening+reading), 3–5급 on weeks 5–9 (TOPIK II adds writing), "
            "6급 mock after week 9. Speaking follows the separate TOPIK Speaking 6-task format."
        ),
    },
    "finnish": {
        "testName": "YKI (Yleinen kielitutkinto)",
        "awardingBody": "Finnish National Agency for Education (OPH)",
        "scoreSystem": "YKI grades 1–6",
        "scoreSystemId": "yki",
        "isLevelExam": True,
        "notes": (
            "Three test sittings: perustaso (grades 1–2), keskitaso (3–4), ylin taso (5–6). "
            "Four independent subtests: listening, speaking, reading, writing. Each skill receives its own grade. "
            "1=A1, 2=A2, 3=B1, 4=B2, 5=C1, 6=C2. Finnish citizenship typically needs at least grade 3 in one oral and one written subtest."
        ),
        "officialLevels": [
            {"id": "A1", "label": "YKI 1 · A1 (perustaso)", "cefr": "A1", "examName": "YKI perustaso", "weeks": [1, 2]},
            {"id": "A2", "label": "YKI 2 · A2 (perustaso)", "cefr": "A2", "examName": "YKI perustaso", "weeks": [3, 4]},
            {"id": "B1", "label": "YKI 3 · B1 (keskitaso)", "cefr": "B1", "examName": "YKI keskitaso", "weeks": [5, 6]},
            {"id": "B2", "label": "YKI 4 · B2 (keskitaso)", "cefr": "B2", "examName": "YKI keskitaso", "weeks": [7, 8]},
            {"id": "C1", "label": "YKI 5 · C1 (ylin taso)", "cefr": "C1", "examName": "YKI ylin taso", "weeks": [9]},
            {"id": "C2", "label": "YKI 6 · C2 (ylin taso)", "cefr": "C2", "examName": "YKI ylin taso", "weeks": []},
        ],
        "officialSkills": ["listening", "speaking", "reading", "writing"],
        "classroomSkills": [],
        "skillPapers": skill_papers(
            {
                "officialName": "Puheen ymmärtäminen",
                "minutes": "level-dependent",
                "playCount": 2,
                "parts": ["Short everyday dialogues", "Public announcements", "Longer interviews / radio (higher grades)"],
                "example": "Listen to a health-centre phone message and note the opening hours.",
            },
            {
                "officialName": "Puhuminen",
                "minutes": "recorded / interview",
                "parts": ["Respond to everyday prompts", "Describe a situation", "Give an opinion (keski- and ylin taso)"],
                "example": "Record answers about your work, then explain a picture of a bus station.",
            },
            {
                "officialName": "Tekstin ymmärtäminen",
                "minutes": "level-dependent",
                "parts": ["Notices and messages", "Newspaper / official texts", "Longer argumentation at ylin taso"],
                "example": "Read a Kela letter and choose the correct next step for the applicant.",
            },
            {
                "officialName": "Kirjoittaminen",
                "minutes": "level-dependent",
                "parts": ["Message / email", "Formal letter or opinion (keskitaso+)", "Nuanced argumentation (ylin taso)"],
                "example": "Write a message to a neighbour about a parcel, then (grade 3+) a short opinion on remote work.",
            },
        ),
        "passRule": "Each subtest is graded independently: 1–2 (basic), 3–4 (intermediate), 5–6 (advanced).",
        "frameworkLine": "YKI 1–6 = CEFR A1–C2",
        "description": (
            "A YKI pathway: perustaso 1–2, keskitaso 3–4, ylin taso 5 on week 9, plus a grade-6 mock. "
            "Listening, speaking, reading and writing are scored as separate subtests, matching OPH rules."
        ),
    },
    "czech": {
        "testName": "CCE (Czech Language Certificate Exam)",
        "awardingBody": "ÚJOP Charles University",
        "scoreSystem": "CCE CEFR certificate",
        "scoreSystemId": "cce",
        "isLevelExam": True,
        "notes": (
            "Official levels A1–C1 (no C2 paper). Four subtests: reading, listening, writing, speaking. "
            "From B2, a grammar/lexical test is added. A1–B1 usually one day; B2–C1 speaking the next day. "
            "From 2026 speaking is individual (video call)."
        ),
        "officialLevels": [
            {"id": "A1", "label": "CCE A1", "cefr": "A1", "examName": "CCE–A1", "weeks": [1, 2]},
            {"id": "A2", "label": "CCE A2", "cefr": "A2", "examName": "CCE–A2", "weeks": [3, 4]},
            {"id": "B1", "label": "CCE B1", "cefr": "B1", "examName": "CCE–B1", "weeks": [5, 6]},
            {"id": "B2", "label": "CCE B2", "cefr": "B2", "examName": "CCE–B2", "weeks": [7, 8]},
            {"id": "C1", "label": "CCE C1", "cefr": "C1", "examName": "CCE–C1", "weeks": [9]},
        ],
        "officialSkills": ["reading", "listening", "writing", "speaking"],
        "classroomSkills": [],
        "skillPapers": skill_papers(
            {
                "officialName": "Poslech s porozuměním",
                "minutes": "20–55",
                "playCount": 2,
                "parts": ["Short everyday dialogues", "Announcements / instructions", "Longer authentic radio (C1)"],
                "example": "Hear a shop dialogue twice and choose the price and opening time.",
            },
            {
                "officialName": "Mluvení",
                "minutes": "8–15 individual",
                "parts": ["A1–B1: personal questions + picture / situation", "C1: two tasks — monologue on a complex topic + discussion"],
                "example": "Introduce yourself, describe a photo of a Prague café, then answer follow-up questions.",
            },
            {
                "officialName": "Čtení s porozuměním",
                "minutes": "40–70",
                "parts": ["Notices and factual texts", "Opinion / narrative", "B1: four tasks including multiple choice A–D"],
                "example": "Read a school notice and a short article, then answer multiple-choice items.",
            },
            {
                "officialName": "Psaní",
                "minutes": "40–90",
                "parts": ["A1–B1: message + short connected text", "C1: one well-organised text on a complex topic"],
                "example": "Write an email to a language school asking about an evening course.",
            },
            extra={
                "grammarLexical": {
                    "officialName": "Gramaticko-lexikální test (B2–C1)",
                    "minutes": 30,
                    "parts": ["Grammar and vocabulary in context"],
                    "example": "Choose the correct aspect, case ending, or connector in an authentic paragraph.",
                }
            },
        ),
        "passRule": "Certificate for the CEFR level taken (A1–C1). B2 and C1 also require the grammar/lexical paper.",
        "frameworkLine": "CCE A1 → C1 (ÚJOP; no official C2)",
        "description": (
            "A CCE pathway used by Czech institutes: A1–C1 with reading, listening, writing and speaking. "
            "From B2 the mock also includes the official grammar/lexical paper."
        ),
    },
}


LEVEL_LABELS = {
    course_id: {lvl["cefr"]: lvl["label"] for lvl in spec["officialLevels"]}
    for course_id, spec in FRAMEWORKS.items()
}

MIN_WORDS = {"A1": 40, "A2": 60, "B1": 100, "B2": 150, "C1": 220, "C2": 280}

MOCK_TITLES = {
    "ielts_english": {
        "listening": [
            "Listening Part 1 — Everyday conversation",
            "Listening Part 2 — Social monologue",
            "Listening Part 3 — Academic discussion",
            "Listening Part 4 — Lecture (once only)",
            "Listening Part 1 — Booking / arrangements",
            "Listening Part 2 — Local facilities talk",
            "Listening Part 3 — Tutorial discussion",
            "Listening Part 4 — Academic lecture",
            "Listening mixed question types",
            "Listening form / note completion",
        ],
        "speaking": [
            "Speaking Part 1 — Interview",
            "Speaking Part 2 — Cue card long turn",
            "Speaking Part 3 — Discussion",
            "Speaking Part 1 — Home and work",
            "Speaking Part 2 — Describe an experience",
            "Speaking Part 3 — Abstract follow-up",
            "Speaking Part 1 — Familiar topics",
            "Speaking Part 2 — 2-minute talk",
            "Speaking Part 3 — Opinion and evaluation",
            "Speaking fluency under timing",
        ],
        "reading": [
            "Reading Passage 1",
            "Reading Passage 2",
            "Reading Passage 3",
            "True / False / Not Given",
            "Matching headings",
            "Summary completion",
            "Multiple choice (passage)",
            "Matching information",
            "Sentence completion",
            "Short-answer reading",
        ],
        "writing": [
            "Writing Task 1 — Chart / letter (150+)",
            "Writing Task 2 — Essay (250+)",
            "Task 1 overview and data",
            "Task 2 discuss both views",
            "Task 1 process / map",
            "Task 2 problem–solution",
            "Task 1 comparison",
            "Task 2 advantage–disadvantage",
            "Task 2 opinion essay",
            "Coherence and cohesive devices",
        ],
    },
    "german": {
        "listening": [
            "Hören Teil 1 — Alltagdialoge",
            "Hören Teil 2 — Durchsagen",
            "Hören Teil 3 — Nachrichten / Gespräch",
            "Hören Teil 4 — Interview (A2+)",
            "Hören — selektive Informationen",
            "Hören — globale Aussage",
            "Hören — Telefonnotiz",
            "Hören — Bahnhof / Amt",
            "Hören — Meinungen verstehen",
            "Hören — Prüfungsstrategie",
        ],
        "speaking": [
            "Sprechen Teil 1 — Sich vorstellen",
            "Sprechen Teil 2 — Fragen stellen und beantworten",
            "Sprechen Teil 3 — Bitte / Diskussion",
            "Sprechen — Kartenaufgabe",
            "Sprechen — Alltagssituation",
            "Sprechen — Meinung begründen (B1+)",
            "Sprechen — Gemeinsam planen",
            "Sprechen — Bildbeschreibung",
            "Sprechen — Formelle Situation",
            "Sprechen — Freies Sprechen",
        ],
        "reading": [
            "Lesen Teil 1 — Aushänge / Anzeigen",
            "Lesen Teil 2 — E-Mails / Infos",
            "Lesen Teil 3 — Zuordnung",
            "Lesen Teil 4 — Längerer Text",
            "Lesen Teil 5 — Stellungnahme (B1+)",
            "Lesen — Kleinanzeigen",
            "Lesen — Formulare und Hinweise",
            "Lesen — Zeitungsbericht",
            "Lesen — Meinungstext",
            "Lesen — Detailfragen",
        ],
        "writing": [
            "Schreiben Teil 1 — Formular",
            "Schreiben Teil 2 — Kurznachricht / E-Mail",
            "Schreiben — Forumbeitrag (B1)",
            "Schreiben — Meinung äußern",
            "Schreiben — Formeller Brief (B2+)",
            "Schreiben — Bericht",
            "Schreiben — Beschwerde",
            "Schreiben — Erörterung",
            "Schreiben — Kohärenz üben",
            "Schreiben — Register anpassen",
        ],
    },
    "spanish": {
        "listening": [
            "Comprensión auditiva — Diálogo cotidiano",
            "Comprensión auditiva — Anuncio",
            "Comprensión auditiva — Entrevista",
            "Comprensión auditiva — Noticia",
            "Escucha y uso de la lengua (C1)",
            "Audición — datos concretos",
            "Audición — idea principal",
            "Audición — intención del hablante",
            "Audición — variedades del español (B1+)",
            "Audición — estrategia DELE",
        ],
        "speaking": [
            "Expresión oral — Presentación personal",
            "Expresión oral — Foto / tema",
            "Interacción oral — Conversación",
            "Negociación con el examinador",
            "Describir una imagen",
            "Opinión justificada (B2+)",
            "Mediación oral (C1–C2)",
            "Entrevista sobre el tema",
            "Conversación informal",
            "Fluidez y corrección",
        ],
        "reading": [
            "Comprensión de lectura — Avisos",
            "Comprensión de lectura — Correos",
            "Comprensión de lectura — Artículo",
            "Lectura y uso de la lengua (C1)",
            "Relacionar textos y personas",
            "Verdadero / falso",
            "Opción múltiple",
            "Inferencia",
            "Textos de opinión",
            "Mediación lectora (C2)",
        ],
        "writing": [
            "Expresión escrita — Formulario / mensaje",
            "Interacción escrita — Correo",
            "Texto narrativo / descriptivo",
            "Opinión argumentada (B1+)",
            "Escuchar y escribir (C1 Tarea 1)",
            "Mediación escrita (C2)",
            "Carta formal",
            "Ensayo",
            "Cohesión y conectores",
            "Adecuación al destinatario",
        ],
    },
    "french": {
        "listening": [
            "CO — Documents très courts (A1)",
            "CO — Dialogue quotidien",
            "CO — Annonce / flash info",
            "CO — Interview (une ou deux écoutes)",
            "CO — Exposé / documentaire (B2+)",
            "CO — Repérer une information",
            "CO — Sens global",
            "CO — Point de vue",
            "CO — DALF document long (C1)",
            "CO — Stratégie DELF",
        ],
        "speaking": [
            "PO — Entretien dirigé",
            "PO — Exercice en interaction",
            "PO — Monologue suivi (B1+)",
            "PO — Jeu de rôle",
            "PO — Présentation avec préparation",
            "PO — Défendre un point de vue (B2)",
            "PO — DALF exposé (C1)",
            "PO — Médiation orale (C2)",
            "PO — Aisance et correction",
            "PO — Se présenter clairement",
        ],
        "reading": [
            "CE — Documents de la vie quotidienne",
            "CE — Annonces et messages",
            "CE — Texte informatif",
            "CE — Texte argumentatif (B2)",
            "CE — Texte long DALF (C1)",
            "CE — QCM de compréhension",
            "CE — Vrai / faux",
            "CE — Inférences",
            "CE — Organisation du texte",
            "CE — Synthèse de documents (C1–C2)",
        ],
        "writing": [
            "PE — Fiche / formulaire",
            "PE — Message / carte (40+ mots A1)",
            "PE — Lettre / e-mail",
            "PE — Essai argumenté (B1–B2)",
            "PE — Synthèse 220–240 mots (C1)",
            "PE — Essai 250+ mots (C1)",
            "PE — Production intégrée (C2)",
            "PE — Cohérence et connecteurs",
            "PE — Registre formel",
            "PE — Rédiger un avis",
        ],
    },
    "japanese": {
        "listening": [
            "聴解 — 課題理解",
            "聴解 — ポイント理解",
            "聴解 — 概要理解 (N3–N1)",
            "聴解 — 発話表現 (N5–N3)",
            "聴解 — 即時応答",
            "聴解 — 会話の流れ",
            "聴解 — 案内・店",
            "聴解 — 講義・ニュース (N2–N1)",
            "聴解 — 一度だけ聞く練習",
            "聴解 — JLPT形式",
        ],
        "speaking": [
            "JF Can-do 話す — 自己紹介 (JLPT外)",
            "JF Can-do 話す — 質問に答える",
            "JF Can-do 話す — 絵の説明",
            "JF Can-do 話す — 日常のやりとり",
            "JF Can-do 話す — 意見 (N2–N1)",
            "JF Can-do 話す — 丁寧体",
            "JF Can-do 話す — 理由を述べる",
            "JF Can-do 話す — ロールプレイ",
            "JF Can-do 話す — 抽象話題",
            "JF Can-do 話す — 教室練習",
        ],
        "reading": [
            "読解 — 短文",
            "読解 — 中文",
            "読解 — 長文 (N2–N1)",
            "言語知識 — 漢字読み",
            "言語知識 — 文脈規定",
            "文法 — 文の文法1",
            "文法 — 文の文法2（配列）",
            "文法 — 文章の文法",
            "読解 — 内容理解",
            "読解 — 主張と根拠",
        ],
        "writing": [
            "JF Can-do 書く — 自己紹介 (JLPT外)",
            "JF Can-do 書く — 短いメッセージ",
            "JF Can-do 書く — 日記・メール",
            "JF Can-do 書く — 意見段落",
            "JF Can-do 書く — です・ます",
            "JF Can-do 書く — 理由",
            "JF Can-do 書く — 丁寧な依頼",
            "JF Can-do 書く — 要約",
            "JF Can-do 書く — 比較",
            "JF Can-do 書く — 教室練習",
        ],
    },
    "korean": {
        "listening": [
            "듣기 — 짧은 대화",
            "듣기 — 안내 방송",
            "듣기 — 인터뷰",
            "듣기 — 강연 (TOPIK II)",
            "듣기 — 세부 정보",
            "듣기 — 주제 파악",
            "듣기 — 도표/뉴스",
            "듣기 — 태도·의도",
            "듣기 — TOPIK I 형식",
            "듣기 — TOPIK II 형식",
        ],
        "speaking": [
            "TOPIK Speaking 과제 1 — 간단한 질문",
            "TOPIK Speaking 과제 2 — 역할극",
            "TOPIK Speaking 과제 3 — 그림 이야기",
            "TOPIK Speaking 과제 4 — 대화 완성",
            "TOPIK Speaking 과제 5 — 자료 해석",
            "TOPIK Speaking 과제 6 — 의견 제시",
            "말하기 — 자기소개",
            "말하기 — 일상 상황",
            "말하기 — 사회 문제 (5–6급)",
            "말하기 — 발음·유창성",
        ],
        "reading": [
            "읽기 — 안내문·표지",
            "읽기 — 짧은 글",
            "읽기 — 실용문",
            "읽기 — 도표",
            "읽기 — 기사 (TOPIK II)",
            "읽기 — 빈칸 넣기",
            "읽기 — 순서 배열",
            "읽기 — 중심 생각",
            "읽기 — 세부 내용",
            "읽기 — 학술 텍스트 (5–6급)",
        ],
        "writing": [
            "쓰기 — 교실 연습 (TOPIK I는 미출제)",
            "쓰기 Q51 — 짧은 완성 (II)",
            "쓰기 Q52 — 짧은 완성 (II)",
            "쓰기 Q53 — 설명문 200–300자",
            "쓰기 Q54 — 논설문 600–700자",
            "쓰기 — 이메일",
            "쓰기 — 그래프 설명",
            "쓰기 — 장단점",
            "쓰기 — 의견과 근거",
            "쓰기 — 격식 문체",
        ],
    },
    "finnish": {
        "listening": [
            "Puheen ymmärtäminen — arkikeskustelu",
            "Puheen ymmärtäminen — kuulutus",
            "Puheen ymmärtäminen — puhelinviesti",
            "Puheen ymmärtäminen — haastattelu",
            "Kuuntelu — konkreettinen tieto",
            "Kuuntelu — pääasia",
            "Kuuntelu — asenne",
            "Kuuntelu — ylin taso, nopea puhe",
            "Kuuntelu — virallinen tiedote",
            "Kuuntelu — YKI-strategia",
        ],
        "speaking": [
            "Puhuminen — arjen kysymykset",
            "Puhuminen — kuvatehtävä",
            "Puhuminen — tilanne / viesti",
            "Puhuminen — mielipide (keskitaso+)",
            "Puhuminen — perustelu",
            "Puhuminen — muodollinen tilanne",
            "Puhuminen — ylin taso, nyanssit",
            "Puhuminen — äänite / haastattelu",
            "Puhuminen — sujuvuus",
            "Puhuminen — ääntäminen",
        ],
        "reading": [
            "Tekstin ymmärtäminen — ilmoitukset",
            "Tekstin ymmärtäminen — viestit",
            "Tekstin ymmärtäminen — virallinen kirje",
            "Tekstin ymmärtäminen — uutinen",
            "Lukeminen — pääkohta",
            "Lukeminen — yksityiskohta",
            "Lukeminen — päätellä",
            "Lukeminen — mielipideteksti",
            "Lukeminen — ylin taso, pitkä teksti",
            "Lukeminen — YKI-tehtävätyypit",
        ],
        "writing": [
            "Kirjoittaminen — viesti / sähköposti",
            "Kirjoittaminen — ilmoitus",
            "Kirjoittaminen — mielipide (3–4)",
            "Kirjoittaminen — muodollinen kirje",
            "Kirjoittaminen — argumentointi (5–6)",
            "Kirjoittaminen — ohjeet",
            "Kirjoittaminen — tarina / kokemus",
            "Kirjoittaminen — rekisteri",
            "Kirjoittaminen — sidosteisuus",
            "Kirjoittaminen — tarkkuus",
        ],
    },
    "czech": {
        "listening": [
            "Poslech — krátké dialogy",
            "Poslech — oznámení",
            "Poslech — instrukce",
            "Poslech — delší nahrávka (2×)",
            "Poslech — konkrétní údaj",
            "Poslech — hlavní myšlenka",
            "Poslech — C1 autentické rádio",
            "Poslech — přiřazení",
            "Poslech — výběr z A–C/D",
            "Poslech — CCE strategie",
        ],
        "speaking": [
            "Mluvení — osobní otázky",
            "Mluvení — popis obrázku / situace",
            "Mluvení — samostatný projev (C1)",
            "Mluvení — diskuse",
            "Mluvení — individuální zkouška",
            "Mluvení — každodenní situace",
            "Mluvení — názor (B1+)",
            "Mluvení — složité téma (C1)",
            "Mluvení — plynulost",
            "Mluvení — výslovnost",
        ],
        "reading": [
            "Čtení — oznámení",
            "Čtení — faktografický text",
            "Čtení — e-mail / zpráva",
            "Čtení — úloha 1–4 (B1)",
            "Čtení — výběr z A–D",
            "Čtení — hlavní závěr",
            "Čtení — B2/C1 delší text",
            "Gramaticko-lexikální test (B2–C1)",
            "Čtení — slovní zásoba v kontextu",
            "Čtení — CCE formát",
        ],
        "writing": [
            "Psaní — zpráva / e-mail",
            "Psaní — souvislý text",
            "Psaní — formální dopis",
            "Psaní — C1 jeden dobře uspořádaný text",
            "Psaní — vyprávění",
            "Psaní — názor",
            "Psaní — argumentace",
            "Psaní — soudržnost",
            "Psaní — spisovnost",
            "Psaní — zadání a rozsah",
        ],
    },
}


def official_skills_for_level(course_id: str, level_cefr: str) -> list[str]:
    if course_id == "japanese":
        return ["listening", "reading"]  # language knowledge folded into reading paper
    if course_id == "korean" and level_cefr in ("A1", "A2"):
        return ["listening", "reading", "speaking"]
    return ["listening", "speaking", "reading", "writing"]


def classroom_skills_for_level(course_id: str, level_cefr: str) -> list[str]:
    if course_id == "japanese":
        return ["speaking", "writing"]
    if course_id == "korean" and level_cefr in ("A1", "A2"):
        return ["writing"]
    return []


def relabel_week(week: dict, course_id: str) -> None:
    base = cefr(week.get("level", "A1"))
    label = LEVEL_LABELS[course_id].get(base, week.get("level", base))
    week["level"] = label
    pack = week.get("studyPack")
    if isinstance(pack, dict):
        pack["level"] = label
    for prompt in week.get("speakingInterview") or []:
        if isinstance(prompt, dict) and "level" in prompt:
            prompt["level"] = label


def retitle_mocks(week: dict, course_id: str) -> None:
    mocks = week.get("mockExercises") or {}
    titles = MOCK_TITLES.get(course_id, {})
    for skill, items in mocks.items():
        if not isinstance(items, list):
            continue
        skill_titles = titles.get(skill, [])
        for i, item in enumerate(items):
            if skill_titles:
                item["title"] = skill_titles[i % len(skill_titles)]
            if skill == "listening":
                item["playLimit"] = 1 if course_id in ("ielts_english", "japanese", "korean") else 2
            if skill == "writing" and course_id == "korean" and cefr(week.get("level", "")) in ("A1", "A2"):
                item["instruction"] = (
                    "TOPIK I (1–2급) has no writing paper. This is classroom writing practice only."
                )
            if skill in ("speaking", "writing") and course_id == "japanese":
                item["instruction"] = (
                    "JLPT does not test this skill. Japan Foundation Can-do classroom practice."
                )


def restyle_level_exam(exam: dict, course_id: str, spec: dict, level_cefr: str) -> None:
    label = LEVEL_LABELS[course_id].get(level_cefr, level_cefr)
    level_meta = next((x for x in spec["officialLevels"] if x["cefr"] == level_cefr), None)
    exam_name = level_meta["examName"] if level_meta else spec["testName"]
    exam["id"] = f"{course_id}-{level_cefr}"
    exam["level"] = label
    exam["title"] = f"{exam_name} mock"
    papers = spec["skillPapers"]
    official = official_skills_for_level(course_id, level_cefr)
    classroom = classroom_skills_for_level(course_id, level_cefr)
    exam["officialSkills"] = official
    exam["classroomSkills"] = classroom
    exam["scoreSystemId"] = spec["scoreSystemId"]
    extra = ""
    if course_id == "czech" and level_cefr in ("B2", "C1"):
        extra = " Includes the CCE grammar/lexical paper mixed into reading items."
    exam["description"] = (
        f"Classroom mock of {exam_name}. Official papers: {', '.join(official)}. "
        f"{spec['passRule']}"
        + (f" Extra classroom skills (not on the official paper): {', '.join(classroom)}." if classroom else "")
        + extra
    )

    play = 1 if course_id in ("ielts_english", "japanese", "korean") else 2
    listening = exam.get("listening") or {}
    listening["playLimit"] = play
    listening["title"] = papers["listening"]["officialName"]
    listening["instruction"] = (
        f"{papers['listening'].get('example', '')} "
        f"Play limit: {play}. Parts: {'; '.join(papers['listening'].get('parts', [])[:3])}"
    )
    exam["listening"] = listening

    reading = exam.get("reading") or {}
    reading["title"] = papers["reading"]["officialName"]
    reading["instruction"] = papers["reading"].get("example") or reading.get("instruction")
    exam["reading"] = reading

    writing = exam.get("writing") or {}
    writing["title"] = papers["writing"]["officialName"]
    writing["minWords"] = MIN_WORDS.get(level_cefr, 80)
    writing["instruction"] = papers["writing"].get("example") or writing.get("instruction")
    if "writing" not in official:
        writing["instruction"] = (
            "Not part of the official exam at this level. Classroom production practice only. "
            + (writing.get("instruction") or "")
        )
    exam["writing"] = writing

    speaking = exam.get("speaking") or []
    parts = papers["speaking"].get("parts") or []
    # Official speaking: IELTS 3 parts; Goethe often 3; TOPIK Speaking 6 tasks; keep 3–6.
    target_n = 3
    if course_id == "korean":
        target_n = 6
    elif course_id == "ielts_english":
        target_n = 3
    if speaking:
        speaking = speaking[: max(target_n, 1)]
        while len(speaking) < target_n:
            speaking.append(copy.deepcopy(speaking[-1]))
            speaking[-1]["id"] = f"{level_cefr}-exam-S{len(speaking)}"
        for i, item in enumerate(speaking):
            item["title"] = parts[i] if i < len(parts) else f"Speaking {i + 1}"
            if "speaking" not in official:
                item["instruction"] = "Classroom Can-do practice — not an official exam paper."
            else:
                item["instruction"] = papers["speaking"].get("example") or item.get("instruction")
        exam["speaking"] = speaking


def add_capstone_exam(course: dict, course_id: str, spec: dict, cap_cefr: str) -> None:
    exams = course.get("levelExams") or []
    if any(cefr(e.get("level", "")) == cap_cefr for e in exams):
        return
    source = None
    for candidate in reversed(exams):
        if cefr(candidate.get("level", "")) in ("C1", "B2", "A1"):
            source = copy.deepcopy(candidate)
            break
    if source is None and exams:
        source = copy.deepcopy(exams[-1])
    if source is None:
        return
    restyle_level_exam(source, course_id, spec, cap_cefr)
    source["requiredWeeks"] = [9]
    writing = source.get("writing") or {}
    writing["minWords"] = MIN_WORDS.get(cap_cefr, 280)
    source["writing"] = writing
    exams.append(source)
    course["levelExams"] = exams


def compact_framework(spec: dict) -> dict:
    """JSON payload stored on the course for the app."""
    return {
        "testName": spec["testName"],
        "awardingBody": spec["awardingBody"],
        "scoreSystem": spec["scoreSystem"],
        "scoreSystemId": spec["scoreSystemId"],
        "isLevelExam": spec["isLevelExam"],
        "notes": spec["notes"],
        "passRule": spec["passRule"],
        "officialLevels": spec["officialLevels"],
        "officialSkills": spec["officialSkills"],
        "classroomSkills": spec["classroomSkills"],
        "skillPapers": spec["skillPapers"],
    }


def process(course_id: str, filename: str) -> None:
    path = ROOT / filename
    spec = FRAMEWORKS[course_id]
    with path.open(encoding="utf-8") as f:
        course = json.load(f)

    course["examFramework"] = compact_framework(spec)
    course["framework"] = spec["frameworkLine"]
    course["description"] = spec["description"]
    course["institute"] = spec["awardingBody"] if course_id != "korean" else course.get("institute", spec["awardingBody"])

    for week in course.get("weeks", []):
        relabel_week(week, course_id)
        retitle_mocks(week, course_id)

    for exam in course.get("levelExams") or []:
        restyle_level_exam(exam, course_id, spec, cefr(exam.get("level", "A1")))

    has_c2 = any(lvl["cefr"] == "C2" for lvl in spec["officialLevels"])
    if has_c2:
        add_capstone_exam(course, course_id, spec, "C2")

    with path.open("w", encoding="utf-8") as f:
        json.dump(course, f, ensure_ascii=False, indent=2)
        f.write("\n")

    labels = [w["level"] for w in course["weeks"]]
    exam_levels = [e["level"] for e in course.get("levelExams") or []]
    print(f"{filename}: week_levels={labels}")
    print(f"  exams={exam_levels}")


def update_manifest() -> None:
    path = ROOT / "manifest.json"
    with path.open(encoding="utf-8") as f:
        manifest = json.load(f)
    file_to_id = {e["fileName"]: e["id"] for e in manifest}
    for entry in manifest:
        spec = FRAMEWORKS[entry["id"]]
        entry["framework"] = spec["frameworkLine"]
        entry["description"] = spec["description"]
        if entry["id"] != "korean":
            entry["institute"] = spec["awardingBody"]
        else:
            entry["institute"] = "King Sejong Institute / NIIED TOPIK"
    with path.open("w", encoding="utf-8") as f:
        json.dump(manifest, f, ensure_ascii=False, indent=2)
        f.write("\n")
    print("manifest.json updated")
    _ = file_to_id


def main() -> None:
    files = {
        "ielts_english": "ielts_english.json",
        "german": "german.json",
        "spanish": "spanish.json",
        "french": "french.json",
        "japanese": "japanese.json",
        "korean": "korean.json",
        "finnish": "finnish.json",
        "czech": "czech.json",
    }
    for course_id, name in files.items():
        process(course_id, name)
    update_manifest()
    print("Done.")


if __name__ == "__main__":
    main()
