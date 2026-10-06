import SwiftUI

struct CustomCoachView: View {
    let course: LanguageCourse

    @EnvironmentObject var profile: UserProfileStore
    @EnvironmentObject var progressStore: ProgressStore
    @EnvironmentObject var planStore: CustomPlanStore

    @State private var topic = ""
    @State private var level = ""
    @State private var weeks = 4
    @State private var minutes = 30
    @State private var selectedSkills: Set<ExamSkill> = []
    @State private var built: CustomStudyPlan?

    var body: some View {
        Form {
            Section {
                Text(profile.text(.coachIntro))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text(CustomPlanEngine.diagnose(course: course, progress: progressStore).summary)
                    .font(.caption)
            }

            Section(profile.text(.buildPlan)) {
                TextField(profile.text(.topicPlaceholder), text: $topic)
                Picker(profile.text(.targetLevel), selection: $level) {
                    ForEach(course.levelsInOrder, id: \.self) { Text($0).tag($0) }
                }
                Picker(profile.text(.planWeeks), selection: $weeks) {
                    Text("2").tag(2)
                    Text("4").tag(4)
                    Text("6").tag(6)
                    Text("9").tag(9)
                }
                Picker(profile.text(.minutesPerDay), selection: $minutes) {
                    Text("15").tag(15)
                    Text("30").tag(30)
                    Text("45").tag(45)
                    Text("60").tag(60)
                }
                ForEach(ExamSkill.allCases, id: \.self) { skill in
                    Toggle(isOn: Binding(
                        get: { selectedSkills.contains(skill) },
                        set: { on in
                            if on { selectedSkills.insert(skill) } else { selectedSkills.remove(skill) }
                        }
                    )) {
                        Label(profile.text(skill.l10nKey), systemImage: skill.icon)
                    }
                }
                Button(profile.text(.generatePlan)) {
                    let plan = CustomPlanEngine.build(
                        course: course,
                        progress: progressStore,
                        topic: topic,
                        targetLevel: level.isEmpty ? (course.levelsInOrder.first ?? "A1") : level,
                        weeks: weeks,
                        minutesPerDay: minutes,
                        extraFocus: Array(selectedSkills)
                    )
                    planStore.save(plan)
                    built = plan
                }
                .buttonStyle(.borderedProminent)
            }

            Section(profile.text(.officialSamples)) {
                ForEach(OfficialPracticeCatalog.items(for: course.id)) { item in
                    if let url = item.url {
                        Link(destination: url) {
                            sampleRow(item)
                        }
                    } else {
                        sampleRow(item)
                    }
                }
            }

            let saved = planStore.plans(for: course.id)
            if !saved.isEmpty {
                Section(profile.text(.savedPlans)) {
                    ForEach(saved) { plan in
                        NavigationLink {
                            CustomPlanDetailView(plan: plan, course: course)
                        } label: {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(plan.topic).font(.headline)
                                Text("\(plan.targetLevel) · \(plan.weeks)w · \(plan.minutesPerDay) min")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .onDelete { index in
                        index.map { saved[$0] }.forEach(planStore.delete)
                    }
                }
            }
        }
        .navigationTitle(profile.text(.aiCoach))
        .onAppear {
            if level.isEmpty {
                level = progressStore.currentLevel(languageId: course.id, course: course)
            }
            if selectedSkills.isEmpty {
                selectedSkills = Set(CustomPlanEngine.diagnose(course: course, progress: progressStore).skills)
            }
        }
        .navigationDestination(item: $built) { plan in
            CustomPlanDetailView(plan: plan, course: course)
        }
    }

    private func sampleRow(_ item: OfficialPracticeItem) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: item.skill?.icon ?? "link")
                .foregroundStyle(Color.accentColor)
                .frame(width: 22)
            VStack(alignment: .leading, spacing: 4) {
                Text(item.title).font(.subheadline.bold())
                Text(item.whyItHelps).font(.caption).foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 2)
    }
}

struct CustomPlanDetailView: View {
    let plan: CustomStudyPlan
    let course: LanguageCourse

    @EnvironmentObject var profile: UserProfileStore

    var body: some View {
        List {
            Section {
                Text(plan.diagnosis).font(.subheadline)
                Text("\(profile.text(.topicPlaceholder)): \(plan.topic)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            ForEach(plan.days) { day in
                Section(day.title) {
                    Text(day.whyItHelps).font(.caption).foregroundStyle(.secondary)
                    ForEach(day.tasks, id: \.self) { task in
                        Label(task, systemImage: "checkmark.circle")
                            .font(.caption)
                    }
                    if let url = URL(string: day.officialSampleURL), !day.officialSampleURL.isEmpty {
                        Link(destination: url) {
                            Label(day.officialSampleTitle.isEmpty ? profile.text(.openOfficialSample) : day.officialSampleTitle, systemImage: "arrow.up.right.square")
                        }
                    }
                    Text(profile.text(.classroomPaperNote))
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    dayPaperLink(day)
                }
            }
        }
        .navigationTitle(plan.topic)
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private func dayPaperLink(_ day: CustomPlanDay) -> some View {
        switch day.skill {
        case .listening:
            NavigationLink {
                ListeningExerciseView(languageId: course.id, week: 0, exercise: day.pack.listening)
            } label: {
                Label(day.pack.listening.title, systemImage: "ear")
            }
        case .speaking:
            NavigationLink {
                SpeakingExerciseView(
                    languageId: course.id,
                    weekNumber: 0,
                    level: plan.targetLevel,
                    exercise: day.pack.speaking
                )
            } label: {
                Label(day.pack.speaking.title, systemImage: "mic.fill")
            }
        case .reading:
            NavigationLink {
                ReadingExerciseView(languageId: course.id, week: 0, exercise: day.pack.reading)
            } label: {
                Label(day.pack.reading.title, systemImage: "book.fill")
            }
        case .writing:
            NavigationLink {
                WritingExerciseView(
                    languageId: course.id,
                    week: 0,
                    level: plan.targetLevel,
                    grammarTitle: "",
                    exercise: day.pack.writing
                )
            } label: {
                Label(day.pack.writing.title, systemImage: "pencil.line")
            }
        }
    }
}
