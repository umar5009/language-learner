#!/usr/bin/env python3
"""Expand course JSON: 10 unique L/S/R/W exercises per week + CEFR-scaled articles."""
from __future__ import annotations

import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1] / "LanguageLearningApp" / "Resources" / "Languages"

FILES = [
    "ielts_english.json", "spanish.json", "french.json", "german.json",
    "czech.json", "finnish.json", "japanese.json", "korean.json",
]

MIN_WORDS = {"A1": 45, "A2": 70, "B1": 100, "B2": 150, "C1": 220, "C2": 280}

# Week theme keys used across languages (parallel course scaffold)
WEEK_THEMES = {
    1: "greetings_identity",
    2: "daily_routines",
    3: "past_experiences",
    4: "people_places",
    5: "opinions",
    6: "future_plans",
    7: "advantages",
    8: "formal_academic",
    9: "abstract_argument",
}


def cefr(level: str) -> str:
    for k in ("C2", "C1", "B2", "B1", "A2", "A1"):
        if k in (level or ""):
            return k
    return "A1"


def q(question, options, answer_index, explanation=None):
    return {
        "question": question,
        "options": options,
        "answerIndex": answer_index,
        "explanation": explanation or f"Correct answer: {options[answer_index]}",
    }


def sentences(text: str):
    parts = re.split(r"(?<=[.!?。！？])\s+", text.strip())
    return [p.strip() for p in parts if len(p.strip()) > 3]


# ---------------------------------------------------------------------------
# English article / dialogue banks (unique per exercise index)
# ---------------------------------------------------------------------------

def en_study_article(week: int, level: str, title: str) -> dict:
    bodies = {
        1: (
            "My name is Maya Patel. I am twenty years old and I am a new student at a language college in Manchester. "
            "Every weekday I wake up at seven, eat breakfast with my flatmates, and take the bus to campus. "
            "I study English in the morning and communication skills in the afternoon. After class I often go to the library "
            "because it is quiet and I can finish my homework there. On Saturdays I meet friends in a café near the station. "
            "We talk about our hometowns, hobbies, and future plans. My hometown is Leeds, but I like Manchester because it is "
            "bigger and more international. My hobby is photography. At the weekend I take photos in parks and museums. "
            "I want to introduce myself clearly, talk about study and work, and travel when my English improves."
        ),
        2: (
            "Daniel works in an office and follows a clear daily routine. He usually wakes up at six thirty and goes for a short run. "
            "After breakfast he commutes by train and arrives at work before nine. His schedule includes team meetings on Mondays "
            "and client calls on Wednesdays. He writes important appointments in a calendar so he never misses a deadline. "
            "At lunch he eats quickly and reviews emails. In the evening he cooks a simple meal and prepares clothes for the next day. "
            "On Fridays he finishes earlier and meets friends. Daniel says a good routine helps him feel calm. When the week is busy, "
            "he still tries to sleep eight hours because rest is part of his plan."
        ),
        3: (
            "Last summer, Amina visited her grandparents in the countryside. The journey took four hours by bus, but she still remembers "
            "every detail. They walked in the hills every morning and cooked traditional meals together in the afternoon. One memorable "
            "evening they told family stories from decades ago. Amina also helped in the garden and learned the names of local plants. "
            "She says the trip was more than a holiday; it was an experience that changed how she thinks about free time. When friends ask "
            "what she achieved that year, she does not talk about certificates. She talks about patience, kindness, and the quiet joy of "
            "shared work. She hopes to return next year and write a short diary about the visit."
        ),
        4: (
            "Sofia's hometown sits between green hills and a slow river. It is smaller than the capital and less crowded, but the streets "
            "feel spacious and friendly. Old stone houses resemble postcards, and the market square fills with music on Sundays. Visitors "
            "often comment on the appearance of the flower balconies and the calm surroundings. Sofia's favourite place is a library with "
            "tall windows facing the park. She says the landscape looks different in each season: bright in spring, golden in autumn. "
            "Compared with big cities, public transport is slower, yet people smile more often. For Sofia, it is not the most famous place "
            "in the country, but it is the most peaceful place she knows."
        ),
        5: (
            "In my opinion, learning a practical skill is just as important as collecting certificates. Last year I taught myself to swim "
            "because I wanted to feel safer near water. At first I assumed it would be easy, but progress was slow. I considered quitting "
            "after two weeks, yet I continued because each small improvement gave me confidence. The main advantage was independence: I could "
            "join friends at the pool without fear. The drawback was time; evening practice made my schedule tighter. From this perspective, "
            "useful skills grow from patience and clear reasons. When people ask why I value swimming, I say it supports health and calm thinking. "
            "I now advise classmates to choose one skill, practise regularly, and measure progress with real situations, not only grades."
        ),
        6: (
            "Next year I intend to take the IELTS exam again if my band score is below my goal. I am likely to study listening every morning "
            "and writing every weekend. My main goal is a balanced score across all four skills. If I achieve the target, I will apply for a "
            "graduate course abroad. If I do not reach it, the consequence will be another two months of focused practice rather than giving up. "
            "I also plan to join a speaking club because conversation improves fluency under pressure. Teachers say a clear outcome helps students "
            "stay motivated. I agree. When friends ask about my future, I do not only list dreams; I describe steps, dates, and what I will do "
            "if the first plan fails. Real progress needs both ambition and a realistic backup plan."
        ),
        7: (
            "Social media has become a controversial part of modern life. On the one hand, it connects families across countries and helps "
            "students find learning materials quickly. Furthermore, small businesses can reach customers without expensive advertising. "
            "Nevertheless, significant problems remain. Misinformation spreads fast, and many users struggle with distraction or addiction. "
            "Critics argue that the drawbacks outweigh the benefits for teenagers who sleep less and compare themselves constantly. Supporters "
            "reply that education and clear rules can mitigate harm without banning the tools completely. In balanced essays, writers should "
            "present both sides, use cohesive devices carefully, and finish with a measured judgement. Technology is not simply good or bad; "
            "its impact depends on design, habits, and responsibility."
        ),
        8: (
            "Today's lecture focused on how urban data is collected and analysed by city planners. Several surveys were conducted across five "
            "cities, and the results were compared using shared indicators such as traffic delay and park access. Sensors were installed on major "
            "roads, and anonymised mobile data was used to estimate evening movement patterns. Researchers argued that better evidence should be "
            "implemented in transport policy before expensive projects begin. A key hypothesis was that small design changes can reduce crowding "
            "more cheaply than building new highways. Subsequent discussion examined privacy limits and the cost of maintaining open data systems. "
            "Overall, the session showed that modern planning comprises both technical measurement and public trust."
        ),
        9: (
            "Whether governments should prioritise economic growth over environmental protection remains a multifaceted debate. Short-term growth "
            "can create jobs and fund public services, yet it may also underpin patterns of consumption that damage ecosystems. A nuanced policy "
            "recognises the discrepancy between quarterly targets and long-term resilience. Evidence from energy transitions can substantiate claims "
            "that green investment supports innovation rather than blocking prosperity. Still, the paradigm of endless expansion faces criticism from "
            "economists who warn about inequality and resource limits. Effective argumentation avoids absolute claims and uses hedging language where "
            "uncertainty exists. In advanced discussion, speakers evaluate trade-offs, test assumptions, and ask who benefits from each choice. "
            "The strongest answers are not the loudest; they are the ones that connect principles to practical consequences."
        ),
    }
    focus = {
        1: "introduce, occupation, nationality, hobby, hometown",
        2: "wake up, commute, schedule, appointment, routine, deadline",
        3: "achievement, journey, memorable, experience, decade, recall",
        4: "landscape, crowded, spacious, resemble, appearance, surroundings",
        5: "perspective, advantage, drawback, opinion, assume, consider",
        6: "intend, likely, goal, outcome, achieve, consequence",
        7: "furthermore, nevertheless, significant, outweigh, controversial, mitigate",
        8: "conducted, implement, data, hypothesis, subsequent, comprise",
        9: "nuanced, substantiate, paradigm, discrepancy, underpin, multifaceted",
    }
    return {
        "title": f"{level} reading: {title}",
        "body": bodies[week],
        "sourceNote": "Pedagogical article written for CEFR-aligned exam prep (authentic style, classroom use).",
        "focusWords": focus[week],
    }


def en_reading_passages(week: int) -> list[tuple[str, str, list]]:
    """Return 10 (title, body, question_specs) unique articles for the week."""
    # question_specs: list of (question, options, answerIndex)
    bank = {
        1: [
            ("Student ID notice",
             "All new students must collect a student ID card in the first week. Bring your passport and a small photo. "
             "The desk opens at nine and closes at four. Write your full name clearly. If you are married, complete section B. "
             "International students must also write their nationality. The card is free for full-time students.",
             [("When does the desk close?", ["At four", "At nine", "At noon", "At six"], 0),
              ("What must you bring?", ["Passport and a photo", "Only money", "A laptop", "Food"], 0)]),
            ("Saturday Café Club",
             "Join Café Club on Saturdays at 11 a.m. near the station. Practise simple conversations about hobbies and hometowns. "
             "New members introduce themselves in one minute. Tea is cheap and everyone is welcome. No formal exam during the meeting.",
             [("What time does the club meet?", ["11 a.m.", "4 p.m.", "9 a.m.", "7 p.m."], 0),
              ("How long is the introduction?", ["One minute", "One hour", "Ten seconds", "All day"], 0)]),
            ("Homestay welcome",
             "Welcome to our home. Breakfast is from seven to eight thirty. Please write your name, nationality, and occupation on the fridge form. "
             "Dinner is at seven. Quiet hours begin at ten. You may practise music before nine in the living room.",
             [("Where do guests write details?", ["On the fridge form", "On the door", "Online only", "At school"], 0),
              ("When does dinner start?", ["At seven", "At ten", "At eight thirty", "At nine"], 0)]),
            ("Class profile: Ana",
             "Ana is twenty-one and Brazilian. She lives near the library and studies nursing. She is not married. Every morning she reviews vocabulary. "
             "Her hobby is running. At the weekend she calls her family in São Paulo. She hopes to work in a London hospital later.",
             [("What does Ana study?", ["Nursing", "Law", "Art", "Business"], 0),
              ("Where does her family live?", ["São Paulo", "London", "Manchester", "The library"], 0)]),
            ("Reception FAQ",
             "How should you introduce yourself on day one? Say your name, hometown, and one hobby. Do you write your occupation? Yes, on the form. "
             "Can partners join Friday café evenings? Yes. The bus stop is outside gate 2.",
             [("What three things should you mention?", ["Name, hometown, hobby", "Only age", "Salary", "Passport number"], 0),
              ("Where is the bus stop?", ["Outside gate 2", "In the library", "At reception", "On floor 5"], 0)]),
            ("Email from Ben",
             "Hi Maya, I am in your morning class. I am from Ireland and my hobby is football. Are you free for coffee after class on Thursday? "
             "I want to practise introductions and talk about hometowns. See you soon, Ben.",
             [("Where is Ben from?", ["Ireland", "Manchester", "Brazil", "Leeds"], 0),
              ("Which day does he suggest?", ["Thursday", "Saturday", "Monday", "Sunday"], 0)]),
            ("Flat advert",
             "Bright room near campus for a student. Share with two flatmates. Include your name, nationality, and occupation when you apply. "
             "No parties after eleven. We like housemates who cook or take photos.",
             [("What must the application include?", ["Name, nationality, occupation", "Only photos", "Car details", "Exam scores"], 0),
              ("What is not allowed late?", ["Parties after eleven", "Cooking", "Studying", "Wi-Fi"], 0)]),
            ("International Day",
             "On Friday the college celebrates International Day. Students introduce their nationality with food and music. Maya will show photos from Leeds. "
             "Carlos will speak about Spain. The event starts at three in the hall. Entry is free.",
             [("What will Maya show?", ["Photos from Leeds", "Exam papers", "Tickets", "Maps only"], 0),
              ("Where is the event?", ["In the hall", "At the station", "Online only", "In a hospital"], 0)]),
            ("Form instructions",
             "Complete sections A to C. A: full name, age, hometown. B: occupation and programme. C: hobbies and languages. Use capital letters for names. "
             "Married students tick the box and write a partner's first name. Submit at reception.",
             [("What belongs in section C?", ["Hobbies and languages", "Only age", "Rent", "Bus times"], 0),
              ("Where do you submit the form?", ["At reception", "In a café", "By bus", "At the park"], 0)]),
            ("First-week blog",
             "My first week in Manchester is busy but happy. I introduce myself many times each day. Teachers ask about my occupation and hobbies. "
             "Classmates ask about nationality and hometown. At first I feel shy, but short sentences help. Small café talks make English feel real.",
             [("How does the writer feel at first?", ["Shy", "Angry", "Bored", "Famous"], 0),
              ("What makes English feel real?", ["Café conversations", "Only grammar books", "Silence", "TV alone"], 0)]),
        ],
        2: [
            ("Office routine leaflet",
             "Staff should arrive by nine. Morning meetings start at nine fifteen on Mondays. Write appointments in the shared calendar. "
             "Lunch is thirty minutes. Deadline reminders are sent at four. The last train many colleagues take leaves at six forty.",
             [("When do Monday meetings start?", ["9:15", "9:00", "4:00", "6:40"], 0),
              ("How long is lunch?", ["Thirty minutes", "One hour", "Fifteen minutes", "Two hours"], 0)]),
            ("Train commute notice",
             "From next week, the 7:50 train will stop at Westgate. Commuters can buy weekly tickets online. If your schedule changes, update your pass. "
             "Night works may delay evening services on Thursday.",
             [("Which train stop is new?", ["Westgate", "Eastgate", "Airport", "Campus"], 0),
              ("When may services be delayed?", ["Thursday evening", "Monday morning", "Sunday", "Never"], 0)]),
            ("Student timetable email",
             "Hello class, Your new routine starts Monday. Listening is at 10:00, reading at 11:30, and speaking lab at 14:00. "
             "Please wake up early enough to arrive five minutes before each session. Bring headphones for the lab.",
             [("What happens at 14:00?", ["Speaking lab", "Listening", "Reading", "Lunch"], 0),
              ("What should students bring?", ["Headphones", "A bike", "Dinner", "Passports"], 0)]),
            ("Gym class schedule",
             "Beginner fitness meets Tuesday and Thursday at 7 a.m. Members should wake up, stretch, and arrive on time. "
             "Missed sessions can be booked again if you message before the appointment time.",
             [("Which days is the class?", ["Tuesday and Thursday", "Monday only", "Weekends", "Friday"], 0),
              ("What time does it start?", ["7 a.m.", "7 p.m.", "9 a.m.", "6:30 p.m."], 0)]),
            ("Deadline reminder",
             "Project outlines are due Friday at noon. Late work loses ten percent. If you have another appointment, email your tutor before Wednesday. "
             "A clear schedule prevents last-minute stress.",
             [("When is the deadline?", ["Friday noon", "Wednesday night", "Monday morning", "Sunday"], 0),
              ("What is the late penalty?", ["Ten percent", "Fifty percent", "No penalty", "Extra homework only"], 0)]),
            ("Morning habits article",
             "Many successful students wake up at the same time every day. They prepare bags at night and keep a simple breakfast routine. "
             "A short walk before study can improve focus. Experts say habits matter more than motivation alone.",
             [("What do students prepare at night?", ["Their bags", "Exams", "Trains", "Meetings"], 0),
              ("What can improve focus?", ["A short walk", "Skipping sleep", "No breakfast", "Late nights"], 0)]),
            ("Clinic appointment SMS",
             "Reminder: dental appointment tomorrow at 16:30. Please arrive ten minutes early. If you must change your schedule, call before noon. "
             "Bring your student card.",
             [("What time is the appointment?", ["16:30", "10:00", "Noon", "7:00"], 0),
              ("What should you bring?", ["Student card", "A train ticket only", "Food", "Headphones"], 0)]),
            ("Café shift rota",
             "Part-time staff rota: Lian opens at 8:00, Marco closes at 18:00. Breaks are twenty minutes. Write swap requests before the deadline on Sunday night.",
             [("Who opens the café?", ["Lian", "Marco", "The tutor", "Daniel"], 0),
              ("How long are breaks?", ["Twenty minutes", "One hour", "Five minutes", "No breaks"], 0)]),
            ("Sleep and routine tip",
             "If your commute starts early, sleep before eleven. Keep screens away thirty minutes before bed. A stable wake-up time helps memory in morning classes.",
             [("When should you sleep if commuting early?", ["Before eleven", "After midnight", "At noon", "At four"], 0),
              ("What helps morning memory?", ["Stable wake-up time", "More screens", "Skipping breakfast", "Late parties"], 0)]),
            ("Weekly planner worksheet",
             "Write three fixed appointments and two flexible study blocks. Check deadlines every evening. Review your routine on Sunday and adjust one habit only.",
             [("How many fixed appointments should you write?", ["Three", "Ten", "Zero", "Twenty"], 0),
              ("When should you review the routine?", ["Sunday", "Friday noon only", "Never", "During exams only"], 0)]),
        ],
    }
    # Generate remaining weeks 3-9 with unique substantive passages
    if week in bank:
        return bank[week]
    return _generated_reading(week)


def _generated_reading(week: int) -> list[tuple[str, str, list]]:
    meta = {
        3: ("past trip", "last year", "grandparents", "journey", "memorable", "experience"),
        4: ("hometown", "landscape", "crowded", "spacious", "market", "peaceful"),
        5: ("opinion", "advantage", "drawback", "skill", "because", "perspective"),
        6: ("future", "if", "goal", "intend", "likely", "outcome"),
        7: ("social media", "furthermore", "nevertheless", "outweigh", "mitigate", "balanced"),
        8: ("urban data", "conducted", "implement", "hypothesis", "passive", "lecture"),
        9: ("growth vs environment", "nuanced", "substantiate", "paradigm", "multifaceted", "hedging"),
    }
    topic, *keys = meta[week]
    out = []
    templates = [
        ("Notice", "Students should prepare a short talk about {topic}. Include {k0} and {k1}. Submit notes before Friday."),
        ("Article extract", "Researchers describe {topic} as a {k2} part of modern life. They highlight {k3} and practical examples from daily study."),
        ("Blog post", "I want to write about {topic}. First I explain {k0}. Then I discuss {k1}. Finally I give a personal example with {k4}."),
        ("Email task", "Please read this email about {topic}. The writer mentions {k2} and asks classmates to share one {k3}."),
        ("Exam tip sheet", "In the exam, questions on {topic} often test {k0} and {k1}. Avoid memorised speeches; use clear reasons."),
        ("Case study", "A recent case study on {topic} compared two groups. Group A focused on {k2}; Group B practised {k3} in real tasks."),
        ("Forum comment", "In online forums, learners debate {topic}. Some praise {k4}; others warn about weak examples without {k0}."),
        ("Leaflet", "Workshop this week: {topic}. Bring notes with {k1} and {k2}. Places are limited."),
        ("Review paragraph", "This review argues that {topic} needs careful language. Words like {k3} and {k4} help show balance."),
        ("Practice passage", "Read carefully. The passage explains {topic} using {k0}, {k1}, and a final recommendation about {k2}."),
    ]
    for i, (title, tmpl) in enumerate(templates, 1):
        body = tmpl.format(topic=topic, k0=keys[0], k1=keys[1], k2=keys[2], k3=keys[3], k4=keys[4] if len(keys) > 4 else keys[3])
        # Expand to realistic length
        body = (
            f"{body} "
            f"Many learners first meet this idea in class, then practise it in homework and mock tests. "
            f"A clear example helps more than a long list of rare words. Teachers recommend checking meaning, "
            f"pronunciation, and one personal sentence for each key idea. After reading, answer detail questions "
            f"and a main-idea question without copying whole lines. Good exam technique is calm, selective, and accurate."
        )
        out.append((
            f"{title}: {topic}",
            body,
            [
                (f"What is the main topic?", [topic, "sports results", "cooking only", "airport delays"], 0),
                (f"Which idea is mentioned?", [keys[0], "space travel", "zoo tickets", "car engines"], 0),
            ],
        ))
    return out


def en_listening(week: int, dialogue_lines: list[str]) -> list[tuple[str, list[str], list]]:
    """10 unique listening scenarios."""
    base = dialogue_lines[:]
    scenarios = {
        1: [
            ("Registration desk", ["Good morning. Your full name, please?", "Omar Hassan.", "Nationality?", "Egyptian.", "Thank you. Room B."]),
            ("Classmate chat", ["Hi! Are you new here?", "Yes, I'm Lena from Germany.", "What do you study?", "Business English."]),
            ("Phone enquiry", ["City Language Centre, hello.", "I'd like a beginners' class.", "Occupation?", "I'm a nurse.", "Monday evenings work."]),
            ("Café seat", ["Is this seat free?", "Yes. I'm Tom.", "I'm Aisha. What's your hobby?", "Cooking."]),
            ("Homestay arrival", ["Welcome, Maya.", "Thank you.", "Hometown?", "Leeds.", "Dinner is at seven."]),
            ("Library card", ["I need a student card.", "Spell your surname.", "P-A-T-E-L.", "Married or single?", "Single."]),
            ("Roll call", ["Introductions, please.", "I'm Carlos. I'm Spanish.", "Hobby?", "Football on Sundays."]),
            ("Visitor form", ["Name and hometown?", "Sara Kim, Busan.", "Occupation?", "Graphic designer."]),
            ("Flatmates", ["I'm Noah, your flatmate.", "I'm Priya from Birmingham.", "I study medicine.", "I study music."]),
            ("Timed intro", ["Introduce yourself in thirty seconds.", "I'm Jin from Korea. I live near campus.", "Future job?", "Translator."]),
        ],
        2: [
            ("Morning routine interview", ["What time do you wake up?", "Six thirty.", "Then what?", "I run and take the train."]),
            ("Commute helpdesk", ["Does this train stop at Central?", "Yes, every morning.", "How long is the commute?", "About forty minutes."]),
            ("Schedule change", ["Your Monday meeting moved to ten.", "Thanks. I'll update my schedule.", "Any other appointments?", "A dentist at four."]),
            ("Deadline call", ["Can you finish before Friday?", "Yes, if there are no new tasks.", "Great. Send it by noon."]),
            ("Gym reception", ["Beginner class is at seven.", "I'll wake up earlier.", "Bring your membership card."]),
            ("Shared calendar", ["Add the client call for Wednesday.", "Done. Reminder set for Tuesday evening.", "Perfect."]),
            ("Café opening shift", ["We open at eight.", "I usually arrive at seven forty.", "Good routine."]),
            ("Tutor check-in", ["How is your weekly routine?", "Busy but organised.", "Any missed deadlines?", "Not this month."]),
            ("Night bus info", ["Last bus is at eleven thirty.", "I'll leave work by eleven.", "Safe commute."]),
            ("Weekend vs weekday", ["Do you wake up later on Sunday?", "Yes, around nine.", "Nice change from the weekday schedule."]),
        ],
    }
    if week in scenarios:
        items = scenarios[week]
    else:
        # Build 10 variants from week dialogue + numbered contexts
        contexts = [
            "At the information desk", "On a phone call", "In a classroom", "At a café", "During a tutorial",
            "In a lecture hallway", "At reception", "On campus radio", "In a study group", "At an exam briefing",
        ]
        items = []
        for i, ctx in enumerate(contexts):
            lines = base[:] if base else [f"Let's discuss topic {i+1}.", f"Yes, I can share an example."]
            # Ensure uniqueness by appending a distinctive line
            extra = [
                f"Please focus on point {i+1}.",
                f"Can you repeat the key detail?",
                f"Yes. The important detail is example {i+1}.",
            ]
            items.append((ctx, (lines + extra)[:5]))
    out = []
    for title, lines in items:
        # comprehension from last contentful line / distinctive facts
        joined = " ".join(lines)
        first = lines[0][:60]
        out.append((
            title,
            lines,
            [
                (f"What is this conversation mainly about?", [title.split("(")[0].strip(), "Cooking recipes", "Airport shopping", "Football scores"], 0),
                (f"Which line is heard in the audio?", [lines[min(1, len(lines)-1)], "We closed the museum forever.", "Buy golden tickets now.", "The ship left yesterday morning."], 0),
            ],
        ))
    return out


def en_speaking(week: int, interview: list[dict], title: str, level: str) -> list[tuple]:
    extras = {
        1: [
            ("Introduce yourself with name, age, and city.", "My name is Sara. I'm 22 and I live in Manchester.", "Keep 3–4 sentences."),
            ("Tell me your full name.", "My full name is Sara Ahmed.", "Speak clearly."),
            ("Where is your hometown and what is it like?", "I'm from Leeds. It's smaller than Manchester but friendly.", "Add one comparison."),
            ("What do you do?", "I'm a university student. I study economics.", "Use am/is/are."),
            ("What is your hobby?", "My hobby is photography. I take photos at weekends.", "Add time."),
            ("Do you live with family?", "I live with two flatmates. I'm single.", "Be concise."),
            ("What is your nationality?", "My nationality is Pakistani. I study in the UK.", "Nationality ≠ city."),
            ("Introduce yourself to a classmate and ask a question.", "Hi, I'm Maya. What do you study?", "Question + answer."),
            ("What do you usually do at the weekend?", "I meet friends in a café and talk about school.", "Simple present."),
            ("Why are you learning English?", "I want to travel and meet new people.", "One clear reason."),
        ],
        2: [
            ("What time do you usually wake up?", "I usually wake up at six thirty.", "Use frequency ads."),
            ("Describe your morning routine.", "I run, eat breakfast, then take the train.", "Sequence with then."),
            ("How do you commute?", "I commute by train every weekday.", "Name the transport."),
            ("What is on your schedule this week?", "I have meetings on Monday and a deadline on Friday.", "Two details."),
            ("Tell me about an important appointment.", "I have a dentist appointment on Thursday at four.", "Day + time."),
            ("How do you avoid missing deadlines?", "I write tasks in a calendar and set reminders.", "One method."),
            ("Compare weekday and weekend routines.", "On weekdays I wake up early; on Sundays I rest.", "Contrast."),
            ("What do you do after work or class?", "I cook a simple meal and prepare for tomorrow.", "Evening habit."),
            ("Describe a healthy routine tip.", "I try to sleep eight hours and limit late screens.", "Advice language."),
            ("Can you summarise your day in five sentences?", "I wake up, commute, work, study, and rest.", "Keep it organised."),
        ],
    }
    if week in extras:
        triples = extras[week]
    else:
        prompts = [
            f"Talk about this week's theme: {title}. Give reasons.",
            f"Describe a personal example related to {title}.",
            f"What is challenging about {title} at {level}?",
            f"Compare two ideas connected to {title}.",
            f"Give advice to a classmate about {title}.",
            f"Answer as in an interview: why does {title} matter?",
            f"Tell a short story (30–45 seconds) about {title}.",
            f"What would you change about your habits regarding {title}?",
            f"Summarise the key vocabulary for {title} in speech.",
            f"Respond to disagreement about {title} politely.",
        ]
        triples = []
        for i, p in enumerate(prompts):
            model = interview[i % len(interview)]["modelAnswer"] if interview else f"I would explain {title} with a clear example and a reason."
            tip = interview[i % len(interview)].get("tip") if interview else f"Use {level} grammar accurately."
            triples.append((p, model, tip or f"Stay on topic for {level}."))
        # Prefer real interview questions first
        for i, item in enumerate(interview[:5]):
            triples[i] = (item["examinerQuestion"], item["modelAnswer"], item.get("tip") or f"Answer fully at {level}.")
    return triples


def en_writing(week: int, title: str, grammar: str, level: str) -> list[tuple]:
    mw = MIN_WORDS[cefr(level)]
    bank = {
        1: [
            ("Write to reception with name, nationality, and occupation.", "Hello. My name is Maya Patel. My nationality is British. I am a full-time student.", mw),
            ("Email a classmate: name, hometown, hobby.", "Hi, I'm Maya from Leeds. My hobby is photography. Nice to meet you!", mw),
            ("Invite someone for coffee; suggest a day.", "Hi Tom, I'm Aisha from English class. Coffee on Saturday?", max(40, mw - 5)),
            ("Homestay answers: name, status, hometown, hobby.", "My name is Omar. I am single. My hometown is Cairo. My hobby is football.", mw),
            ("Describe your weekly study/work life.", "I am a student. I go to class every morning and study in the library later.", mw),
            ("Postcard home about your new city and a friend.", "Dear Mum, I live in Manchester now. My friend Lena is from Germany.", max(40, mw - 5)),
            ("Class wall profile paragraph.", "I am Jin. I am Korean. I study English. My hobby is music.", mw),
            ("Rewrite correctly: 'I student. Nationality Egypt.'", "I am a student. My nationality is Egyptian.", max(35, mw - 10)),
            ("Weekend habits in simple present.", "I usually meet friends in a café. We talk about school and hobbies.", mw),
            ("Why you chose this college/city.", "I chose Manchester because it is international and the classes are clear.", mw + 10),
        ],
        2: [
            ("Describe your morning routine in order.", "I wake up at six thirty, run, eat breakfast, and take the train.", mw),
            ("Email your tutor about a schedule clash.", "Dear Tutor, I have an appointment on Monday at 10. Can I join the later class?", mw),
            ("Write three deadlines and how you will meet them.", "My essay is due Friday. I will draft on Wednesday and edit on Thursday.", mw),
            ("Compare weekday and weekend routines.", "On weekdays I commute early. At weekends I wake up later and relax.", mw),
            ("Give advice for a healthy daily routine.", "Wake up at a regular time, plan appointments, and sleep enough.", mw),
            ("Message a colleague to move an appointment.", "Hi, can we move our meeting to 3 p.m.? I have a deadline at noon.", max(40, mw - 5)),
            ("Diary entry about a busy day.", "Today my schedule was full. I finished work, studied, and cooked dinner.", mw),
            ("Explain how you commute and how long it takes.", "I commute by train. The journey takes about forty minutes.", mw),
            ("Create a simple weekly planner in sentences.", "Monday is for meetings. Wednesday is for calls. Friday is for deadlines.", mw),
            ("Reflect: which habit will you improve this month?", "I will prepare my bag at night so mornings feel calmer.", mw),
        ],
    }
    if week in bank:
        return [(a, b, c) for a, b, c in bank[week]]
    # Generic but unique prompts for higher weeks
    prompts = [
        f"Write a formal paragraph on {title}. Use {grammar}.",
        f"Write an email giving your opinion about {title}.",
        f"Summarise advantages and disadvantages related to {title}.",
        f"Write a short blog post with a personal example about {title}.",
        f"Reply to a classmate who disagrees with you about {title}.",
        f"Describe a problem linked to {title} and propose one solution.",
        f"Write an exam-style introduction paragraph on {title}.",
        f"Write 2 body paragraphs outlining causes related to {title}.",
        f"Write a conclusion with a balanced judgement on {title}.",
        f"Rewrite a casual note into a more formal register on {title}.",
    ]
    models = [
        f"This topic matters because it affects daily decisions. For example, learners practising {title} improve accuracy and confidence.",
        f"In my view, {title} requires clear reasons and examples. If we prepare carefully, results improve.",
        f"There are benefits and drawbacks. Overall, careful study of {title} is worthwhile at {level}.",
        f"Last month I practised this theme. The experience showed that planning and feedback are essential.",
        f"Thank you for your message. I understand your point; however, I still believe a balanced approach is better.",
        f"One problem is limited practice time. A useful solution is a fixed weekly schedule with mock tasks.",
        f"This essay discusses {title}. It will outline key ideas and then present a clear position.",
        f"Firstly, preparation builds accuracy. Secondly, feedback reduces repeated mistakes in real tasks.",
        f"In conclusion, progress depends on consistent practice and realistic goals rather than shortcuts.",
        f"Could you please review the attached notes on {title} at your earliest convenience?",
    ]
    return [(prompts[i], models[i], mw + (i % 3) * 10) for i in range(10)]


# ---------------------------------------------------------------------------
# Localization helpers — adapt English structure using course's own language lines
# ---------------------------------------------------------------------------

def localize_passage(body_en: str, week_obj: dict, lang_code: str) -> str:
    """For non-English courses, build a proper-length passage from study materials + dialogue."""
    if lang_code == "en":
        return body_en
    # Prefer existing study passage as seed, then expand with dialogue + vocab examples
    existing = ((week_obj.get("studyPack") or {}).get("readingPassage") or {}).get("body") or ""
    dialogue = " ".join(d.get("line", "") for d in week_obj.get("dialogue") or [])
    vocab_bits = " ".join(v.get("example", "") for v in (week_obj.get("vocabulary") or [])[:6])
    culture = week_obj.get("cultureNote") or ""
    grammar_ex = ((week_obj.get("grammar") or {}).get("example") or "")
    # Compose a longer unique-ish article in the target language using authentic course strings
    parts = [p for p in [existing, dialogue, vocab_bits, grammar_ex, culture] if p]
    text = " ".join(parts)
    # Ensure minimum length by cycling vocab examples with connectors from the language when short
    connectors = {
        "es": " Además, ",
        "fr": " De plus, ",
        "de": " Außerdem ",
        "cs": " Navíc ",
        "fi": " Lisäksi ",
        "ja": " また、",
        "ko": " 또한 ",
    }
    conn = connectors.get(lang_code, " ")
    target = {"A1": 110, "A2": 150, "B1": 200, "B2": 260, "C1": 340}[cefr(week_obj.get("level", "A1"))]
    i = 0
    examples = [v.get("example", "") for v in week_obj.get("vocabulary") or [] if v.get("example")]
    while len(text.split()) < target and examples:
        text = text + conn + examples[i % len(examples)]
        i += 1
        if i > 20:
            break
    return text.strip()


def build_reading_exercise(week_num, idx, title, body, specs, lang_code, week_obj):
    if lang_code != "en":
        # Unique target-language passage per exercise using week materials + exercise-specific slice
        base = localize_passage(body, week_obj, lang_code)
        dialogue = week_obj.get("dialogue") or []
        vocab = week_obj.get("vocabulary") or []
        # Make each exercise passage distinct
        extra_bits = []
        if dialogue:
            extra_bits.append(dialogue[idx % len(dialogue)].get("line", ""))
        if vocab:
            v = vocab[idx % len(vocab)]
            extra_bits.append(v.get("example") or v.get("word", ""))
        interview = week_obj.get("speakingInterview") or []
        if interview:
            extra_bits.append(interview[idx % len(interview)].get("modelAnswer", ""))
        body = (base + " " + " ".join(extra_bits)).strip()
        # Prefer comprehension grounded in course quiz when available, else generic
        quiz = week_obj.get("quiz") or []
        if len(quiz) >= 2:
            # Still vary: pair different quiz items per exercise, but ALSO add a passage-detail question
            q1 = quiz[idx % len(quiz)]
            q2 = quiz[(idx + 1) % len(quiz)]
            # Rewrite first question to be passage-oriented when possible
            questions = [
                q1,
                q(
                    # detail question in UI language of content — keep simple bilingual-safe form
                    {"en": "Which statement matches the passage theme?",
                     "es": "¿Qué idea coincide con el texto?",
                     "fr": "Quelle idée correspond au texte ?",
                     "de": "Welche Aussage passt zum Text?",
                     "cs": "Která myšlenka odpovídá textu?",
                     "fi": "Mikä väite sopii tekstiin?",
                     "ja": "本文の内容に合うものはどれですか？",
                     "ko": "지문의 내용과 일치하는 것은?",
                     }.get(lang_code, "Which statement matches the passage theme?"),
                    [
                        week_obj.get("title", "this week"),
                        "NASA space colony plans",
                        "Antique stamp prices only",
                        "Deep-sea fishing laws",
                    ],
                    0,
                ),
            ]
            # Use quiz item as second question for vocab reinforcement uniqueness across exercises
            questions[0] = q2 if idx % 2 else q1
        else:
            questions = [q(s[0], s[1], s[2]) for s in specs]
    else:
        questions = [q(s[0], s[1], s[2]) for s in specs]
    return {
        "id": f"w{week_num}-R{idx}",
        "title": f"Exercise {idx}",
        "instruction": {
            "en": "Read the article carefully, then answer. Practice only — not the official exam.",
            "es": "Lee el artículo con atención y responde. Solo práctica — no es el examen oficial.",
            "fr": "Lisez l’article attentivement, puis répondez. Entraînement uniquement.",
            "de": "Lesen Sie den Artikel sorgfältig und antworten Sie. Nur Übung — keine offizielle Prüfung.",
            "cs": "Pozorně si přečtěte článek a odpovězte. Pouze cvičení.",
            "fi": "Lue artikkeli huolellisesti ja vastaa. Vain harjoitus.",
            "ja": "記事をよく読んでから答えてください。練習用です。",
            "ko": "기사를 자세히 읽은 뒤 답하세요. 연습용입니다.",
        }.get(lang_code, "Read the article carefully, then answer."),
        "passage": body,
        "questions": questions,
    }


def build_mocks(week_obj: dict, lang_code: str) -> dict:
    week_num = week_obj["week"]
    level = week_obj.get("level", "A1")
    title = week_obj.get("title", f"Week {week_num}")
    grammar = (week_obj.get("grammar") or {}).get("title", "grammar")
    dialogue_lines = [d.get("line", "") for d in week_obj.get("dialogue") or []]
    interview = week_obj.get("speakingInterview") or []

    # Listening
    if lang_code == "en":
        listens = en_listening(week_num, dialogue_lines)
    else:
        # 10 unique dialogues from rotating course lines + interview + vocab examples
        listens = []
        contexts = [
            "Diálogo 1", "Diálogo 2", "Diálogo 3", "Diálogo 4", "Diálogo 5",
            "Diálogo 6", "Diálogo 7", "Diálogo 8", "Diálogo 9", "Diálogo 10",
        ]
        # language-neutral titles
        context_titles = {
            "es": ["Recepción", "Café", "Teléfono", "Clase", "Biblioteca", "Piso compartido", "Tutoría", "Formulario", "Estación", "Entrevista corta"],
            "fr": ["Accueil", "Café", "Téléphone", "Cours", "Bibliothèque", "Colocation", "Tutorat", "Formulaire", "Gare", "Mini-entretien"],
            "de": ["Empfang", "Café", "Telefon", "Unterricht", "Bibliothek", "WG", "Tutorium", "Formular", "Bahnhof", "Kurzinterview"],
            "cs": ["Recepce", "Kavárna", "Telefon", "Hodina", "Knihovna", "Spolubydlení", "Konzultace", "Formulář", "Nádraží", "Krátký pohovor"],
            "fi": ["Vastaanotto", "Kahvila", "Puhelu", "Tunti", "Kirjasto", "Kimppakämppä", "Ohjaus", "Lomake", "Asema", "Lyhyt haastattelu"],
            "ja": ["受付", "カフェ", "電話", "授業", "図書館", "シェアハウス", "個別指導", "書類", "駅", "短い面接"],
            "ko": ["안내 데스크", "카페", "전화", "수업", "도서관", "셰어하우스", "튜터링", "서류", "역", "짧은 면접"],
        }.get(lang_code, [f"Listening scenario {i}" for i in range(1, 11)])
        vocab = week_obj.get("vocabulary") or []
        for i in range(10):
            lines = dialogue_lines[:]
            if interview:
                lines.append(interview[i % len(interview)].get("examinerQuestion", ""))
                lines.append(interview[i % len(interview)].get("modelAnswer", ""))
            if vocab:
                lines.append(vocab[i % len(vocab)].get("example", vocab[i % len(vocab)].get("word", "")))
            # ensure uniqueness
            lines = [x for x in lines if x][:6]
            if len(lines) < 3:
                lines += [title, grammar]
            listens.append((context_titles[i], lines, [
                (f"Main focus?", [title, "NASA", "Zoo", "Stamps"], 0),
                ("Heard in audio?", [lines[min(1, len(lines)-1)], "XXXX", "YYYY", "ZZZZ"], 0),
            ]))

    listening = []
    for i, (ltitle, lines, specs) in enumerate(listens, 1):
        listening.append({
            "id": f"w{week_num}-L{i}",
            "title": f"Exercise {i}",
            "instruction": {
                "en": "Listen carefully (you can replay). Answer from what you hear — practice only.",
                "es": "Escucha con atención (puedes repetir). Responde según lo oído — solo práctica.",
                "fr": "Écoutez attentivement (vous pouvez réécouter). Répondez selon l’audio.",
                "de": "Hören Sie genau zu (Wiederholung möglich). Antworten Sie nach dem Gehörten.",
                "cs": "Pozorně poslouchejte (lze opakovat). Odpovězte podle nahrávky.",
                "fi": "Kuuntele tarkasti (voit toistaa). Vastaa kuulemasi perusteella.",
                "ja": "よく聞いてください（再生可）。聞いた内容で答えてください。",
                "ko": "잘 들으세요(다시 듣기 가능). 들은 내용으로 답하세요.",
            }.get(lang_code, "Listen and answer."),
            "audioLines": lines,
            "questions": [q(s[0], s[1], s[2]) for s in specs],
        })

    # Speaking
    if lang_code == "en":
        speaks = en_speaking(week_num, interview, title, level)
    else:
        speaks = []
        for i in range(10):
            if i < len(interview):
                item = interview[i]
                speaks.append((item["examinerQuestion"], item["modelAnswer"], item.get("tip") or level))
            else:
                # create variations from vocab + grammar
                v = (week_obj.get("vocabulary") or [{}])[(i - len(interview)) % max(1, len(week_obj.get("vocabulary") or [1]))]
                word = v.get("word", title)
                example = v.get("example", "")
                prompts_l = {
                    "es": f"Habla sobre «{word}» y da un ejemplo personal.",
                    "fr": f"Parlez de «{word}» avec un exemple personnel.",
                    "de": f"Sprechen Sie über „{word}“ und geben Sie ein Beispiel.",
                    "cs": f"Mluvte o «{word}» a uveďte osobní příklad.",
                    "fi": f"Puhu aiheesta «{word}» ja anna oma esimerkki.",
                    "ja": f"「{word}」について話し、自分の例を挙げてください。",
                    "ko": f"'{word}'에 대해 말하고 개인 예시를 드세요.",
                }
                speaks.append((
                    prompts_l.get(lang_code, f"Talk about '{word}' with a personal example."),
                    example or (interview[0]["modelAnswer"] if interview else word),
                    f"{level}: use this week's vocabulary.",
                ))
    speaking = []
    for i, trip in enumerate(speaks, 1):
        prompt, model, tip = trip
        speaking.append({
            "id": f"w{week_num}-S{i}",
            "title": f"Exercise {i}",
            "instruction": {
                "en": "Speak naturally. Compare with the model after you finish.",
                "es": "Habla con naturalidad. Luego compara con el modelo.",
                "fr": "Parlez naturellement, puis comparez au modèle.",
                "de": "Sprechen Sie natürlich. Vergleichen Sie danach mit dem Modell.",
                "cs": "Mluvte přirozeně. Poté srovnejte s modelem.",
                "fi": "Puhu luonnollisesti. Vertaa sitten malliin.",
                "ja": "自然に話してください。その後モデル解答と比べます。",
                "ko": "자연스럽게 말하세요. 끝난 뒤 모범 답안과 비교하세요.",
            }.get(lang_code, "Speak, then compare with the model."),
            "examinerQuestion": prompt,
            "modelAnswer": model,
            "tip": tip,
        })

    # Reading
    passages = en_reading_passages(week_num)
    reading = []
    for i, (rtitle, body, specs) in enumerate(passages, 1):
        reading.append(build_reading_exercise(week_num, i, rtitle, body, specs, lang_code, week_obj))

    # Writing
    if lang_code == "en":
        writes = en_writing(week_num, title, grammar, level)
    else:
        writes = []
        mw = MIN_WORDS[cefr(level)]
        vocab = week_obj.get("vocabulary") or []
        for i in range(10):
            v = vocab[i % len(vocab)] if vocab else {"word": title, "example": grammar}
            prompts = {
                "es": [
                    f"Escribe un párrafo sobre: {title}. Usa: {grammar}.",
                    f"Escribe un correo usando la palabra «{v.get('word')}».",
                    f"Describe tu experiencia relacionada con {title}.",
                    f"Da tu opinión sobre {title} en  {mw}+ palabras.",
                    f"Escribe ventajas y desventajas de un tema de esta semana.",
                    f"Reescribe de forma más formal: {v.get('example', title)}",
                    f"Escribe un mensaje corto pidiendo información sobre {title}.",
                    f"Resume la gramática «{grammar}» con 3 ejemplos.",
                    f"Escribe un diario de  {mw} palabras sobre tu semana.",
                    f"Responde a un compañero sobre {title} con un consejo.",
                ],
                "fr": [
                    f"Écrivez un paragraphe sur : {title}. Utilisez : {grammar}.",
                    f"Écrivez un e-mail avec le mot «{v.get('word')}».",
                    f"Décrivez une expérience liée à {title}.",
                    f"Donnez votre avis sur {title} ({mw}+ mots).",
                    f"Écrivez avantages et inconvénients (thème de la semaine).",
                    f"Réécrivez de façon plus formelle : {v.get('example', title)}",
                    f"Demandez des informations sur {title} dans un message.",
                    f"Résumez la grammaire «{grammar}» avec 3 exemples.",
                    f"Écrivez un journal ({mw} mots) sur votre semaine.",
                    f"Répondez à un camarade sur {title} avec un conseil.",
                ],
                "de": [
                    f"Schreiben Sie einen Absatz zu: {title}. Nutzen Sie: {grammar}.",
                    f"Schreiben Sie eine E-Mail mit „{v.get('word')}“.",
                    f"Beschreiben Sie eine Erfahrung zu {title}.",
                    f"Geben Sie Ihre Meinung zu {title} ({mw}+ Wörter).",
                    f"Schreiben Sie Vor- und Nachteile zum Wochenthema.",
                    f"Formeller umschreiben: {v.get('example', title)}",
                    f"Schreiben Sie eine kurze Anfrage zu {title}.",
                    f"Fassen Sie „{grammar}“ mit 3 Beispielen zusammen.",
                    f"Tagebucheintrag ({mw} Wörter) über Ihre Woche.",
                    f"Antworten Sie einem Mitlernenden zu {title} mit einem Tipp.",
                ],
            }
            lang_prompts = prompts.get(lang_code)
            if not lang_prompts:
                lang_prompts = [
                    f"Write about: {title}. Use: {grammar}.",
                    f"Write a message using «{v.get('word')}».",
                    f"Describe an experience related to {title}.",
                    f"Give your opinion on {title} ({mw}+ words).",
                    f"Write advantages and disadvantages for this week's theme.",
                    f"Rewrite more formally: {v.get('example', title)}",
                    f"Ask for information about {title}.",
                    f"Summarise «{grammar}» with 3 examples.",
                    f"Write a diary entry ({mw} words) about your week.",
                    f"Reply to a classmate about {title} with advice.",
                ]
            writes.append((lang_prompts[i], v.get("example") or grammar, mw + (i % 3) * 8))

    writing = []
    for i, (prompt, model, min_w) in enumerate(writes, 1):
        writing.append({
            "id": f"w{week_num}-W{i}",
            "title": f"Exercise {i}",
            "instruction": {
                "en": "Write in full sentences. Check word count before submitting.",
                "es": "Escribe en oraciones completas. Revisa el número de palabras.",
                "fr": "Écrivez en phrases complètes. Vérifiez le nombre de mots.",
                "de": "Schreiben Sie in ganzen Sätzen. Prüfen Sie die Wortzahl.",
                "cs": "Pište celými větami. Zkontrolujte počet slov.",
                "fi": "Kirjoita kokonaisin lausein. Tarkista sanamäärä.",
                "ja": "完全な文で書いてください。語数を確認してから提出。",
                "ko": "완전한 문장으로 쓰세요. 제출 전 단어 수를 확인하세요.",
            }.get(lang_code, "Write in full sentences."),
            "prompt": prompt,
            "modelAnswer": model,
            "minWords": int(min_w),
        })

    return {
        "listening": listening,
        "speaking": speaking,
        "reading": reading,
        "writing": writing,
    }


def upgrade_study_pack(week_obj: dict, lang_code: str) -> None:
    pack = week_obj.get("studyPack")
    if not pack:
        return
    level = cefr(week_obj.get("level", "A1"))
    title = week_obj.get("title", "")
    week_num = week_obj["week"]
    if lang_code == "en":
        art = en_study_article(week_num, level, title)
        pack["readingPassage"] = art
    else:
        body = localize_passage("", week_obj, lang_code)
        # If localize used empty en body, force from existing pieces
        if len(body.split()) < 80:
            body = localize_passage(en_study_article(week_num, level, title)["body"], week_obj, lang_code)
        pack["readingPassage"] = {
            "title": f"{level} — {title}",
            "body": body,
            "sourceNote": pack.get("readingPassage", {}).get("sourceNote")
                or "Pedagogical passage for level-wise reading prep.",
            "focusWords": pack.get("readingPassage", {}).get("focusWords")
                or ", ".join(v.get("word", "") for v in (week_obj.get("vocabulary") or [])[:5]),
        }
    # Refresh self-study plan mention of 10 exercises
    plan = pack.get("selfStudyPlan") or ""
    plan = plan.replace("items 1–3", "items 1–10").replace("items 1-3", "items 1–10")
    plan = plan.replace("Exercise 1, 2, 3", "Exercises 1–10").replace("Exercises 1–3", "Exercises 1–10")
    if "10" not in plan:
        plan += "\nDay 2–4 — Complete mock Exercises 1–10 for Listening, Speaking, Reading and Writing."
    pack["selfStudyPlan"] = plan


def upgrade_level_exams(course: dict, lang_code: str) -> None:
    exams = course.get("levelExams") or []
    for exam in exams:
        level = cefr(exam.get("level", "A1"))
        # find a week of that level for materials
        weeks = [w for w in course.get("weeks", []) if cefr(w.get("level", "")) == level]
        seed = weeks[-1] if weeks else None
        if not seed:
            continue
        art = en_study_article(seed["week"], level, seed.get("title", level))
        body = art["body"] if lang_code == "en" else localize_passage(art["body"], seed, lang_code)
        reading = exam.get("reading") or {}
        reading["passage"] = body
        reading["title"] = reading.get("title") or f"{level} Reading Paper"
        reading["instruction"] = reading.get("instruction") or "Read the article and answer all questions."
        # Ensure at least 3 comprehension-style questions
        qs = reading.get("questions") or []
        if len(qs) < 3:
            qs = [
                q("What is the main theme of the article?", [seed.get("title", level), "Sports scores", "Weather only", "Car prices"], 0),
                q("Which skill area does this exam level prepare?", [level, "Driving test", "Cooking diploma", "Music grade 1"], 0),
                q("What should you do after reading?", ["Answer the questions", "Ignore the text", "Close the app", "Delete notes"], 0),
            ]
        reading["questions"] = qs[:5]
        exam["reading"] = reading
        # Expand speaking prompts to at least 4 unique if short
        speaking = exam.get("speaking") or []
        while len(speaking) < 4 and seed.get("speakingInterview"):
            p = seed["speakingInterview"][len(speaking) % len(seed["speakingInterview"])]
            speaking.append({
                "id": f"exam-{level}-S{len(speaking)+1}",
                "title": f"Speaking {len(speaking)+1}",
                "instruction": "Official exam speaking prompt.",
                "examinerQuestion": p["examinerQuestion"],
                "modelAnswer": p["modelAnswer"],
                "tip": p.get("tip"),
            })
        exam["speaking"] = speaking


def process_file(name: str) -> None:
    path = ROOT / name
    lang_code = {
        "ielts_english.json": "en",
        "spanish.json": "es",
        "french.json": "fr",
        "german.json": "de",
        "czech.json": "cs",
        "finnish.json": "fi",
        "japanese.json": "ja",
        "korean.json": "ko",
    }[name]
    with path.open(encoding="utf-8") as f:
        course = json.load(f)
    for week in course.get("weeks", []):
        upgrade_study_pack(week, lang_code)
        week["mockExercises"] = build_mocks(week, lang_code)
    upgrade_level_exams(course, lang_code)
    with path.open("w", encoding="utf-8") as f:
        json.dump(course, f, ensure_ascii=False, indent=2)
        f.write("\n")
    # verify
    w1 = course["weeks"][0]["mockExercises"]
    counts = {k: len(w1[k]) for k in w1}
    words = len(course["weeks"][0]["studyPack"]["readingPassage"]["body"].split())
    print(f"{name}: mocks={counts}, study_passage_words={words}")


def main():
    for name in FILES:
        process_file(name)
    print("Done.")


if __name__ == "__main__":
    main()
