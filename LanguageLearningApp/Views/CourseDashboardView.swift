import SwiftUI

struct CourseDashboardView: View {
    let courseId: String

    @EnvironmentObject var profile: UserProfileStore
    @EnvironmentObject var dataStore: LanguageDataStore
    @EnvironmentObject var progressStore: ProgressStore

    @State private var showSettings = false

    private var course: LanguageCourse? {
        dataStore.course(for: courseId)
    }

    var body: some View {
        NavigationStack {
            Group {
                if let course {
                    dashboardContent(course)
                        .onAppear {
                            progressStore.refreshLevelProgress(languageId: course.id, course: course)
                        }
                } else {
                    ContentUnavailableView(profile.text(.noCourseLoaded), systemImage: "exclamationmark.triangle")
                }
            }
            .navigationTitle(profile.text(.dashboard))
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                    }
                    .accessibilityLabel(profile.text(.settings))
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
        }
    }

    @ViewBuilder
    private func dashboardContent(_ course: LanguageCourse) -> some View {
        let completed = progressStore.completedCount(languageId: course.id, totalWeeks: course.weeks.count)
        let currentWeekNum = progressStore.currentWeekNumber(languageId: course.id, totalWeeks: course.weeks.count)
        let currentWeek = course.weeks.first { $0.week == currentWeekNum }
        let avg = progressStore.courseAverage(languageId: course.id, totalWeeks: course.weeks.count)
        let currentLevel = progressStore.currentLevel(languageId: course.id, course: course)
        let passedLevels = progressStore.passedLevelCount(languageId: course.id, course: course)

        List {
            Section {
                VStack(alignment: .leading, spacing: 12) {
                    HStack(alignment: .top) {
                        Text(course.flagEmoji).font(.system(size: 44))
                        VStack(alignment: .leading, spacing: 4) {
                            Text(profile.text(.yourCourse))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(course.name)
                                .font(.title2.bold())
                            Text(course.institute)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            Text(course.framework)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            if let test = course.examFramework?.testName {
                                Text(test)
                                    .font(.caption.weight(.semibold))
                            }
                        }
                    }

                    HStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(profile.text(.currentLevel))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(currentLevel)
                                .font(.title3.bold())
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 2) {
                            Text(profile.text(.averageScore))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(avg.map { "\($0)%" } ?? "—")
                                .font(.title3.bold().monospacedDigit())
                        }
                    }

                    ProgressView(value: Double(completed), total: Double(max(course.weeks.count, 1)))
                        .tint(.accentColor)

                    HStack {
                        Label("\(completed)/\(course.weeks.count) \(profile.text(.ofWeeks))", systemImage: "checkmark.seal")
                        Spacer()
                        Label("\(passedLevels)/\(course.levelsInOrder.count) \(profile.text(.levels))", systemImage: "flag.checkered")
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }
                .padding(.vertical, 6)
            }

            Section(profile.text(.aiCoach)) {
                NavigationLink {
                    CustomCoachView(course: course)
                } label: {
                    VStack(alignment: .leading, spacing: 4) {
                        Label(profile.text(.buildPlan), systemImage: "sparkles")
                            .font(.headline)
                        Text(profile.text(.coachIntro))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(3)
                    }
                    .padding(.vertical, 4)
                }
            }

            Section(profile.text(.levelsProgress)) {
                ForEach(course.levelsInOrder, id: \.self) { level in
                    let passed = progressStore.isLevelPassed(languageId: course.id, level: level)
                    let speakingAvg = progressStore.levelSpeakingAverage(languageId: course.id, course: course, level: level)
                    let overall = progressStore.levelOverallAverage(languageId: course.id, course: course, level: level)
                    let levelWeeks = course.weeks(forLevel: level)
                    let firstWeek = levelWeeks.first
                    let examResult = progressStore.levelExamResult(languageId: course.id, level: level)
                    let exam = course.levelExam(for: level)
                    let ready = progressStore.isPrepReadyForLevelExam(languageId: course.id, course: course, level: level)

                    VStack(alignment: .leading, spacing: 8) {
                        Group {
                            if let firstWeek {
                                NavigationLink {
                                    WeekDetailView(languageId: course.id, week: firstWeek)
                                } label: {
                                    levelRow(level: level, passed: passed, speakingAvg: speakingAvg, overall: overall, weekCount: levelWeeks.count, examResult: examResult)
                                }
                            } else {
                                levelRow(level: level, passed: passed, speakingAvg: speakingAvg, overall: overall, weekCount: 0, examResult: examResult)
                            }
                        }

                        if levelWeeks.isEmpty {
                            Text(profile.text(.capstoneExamHint))
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }

                        if let exam {
                            if let examResult {
                                NavigationLink {
                                    OfficialScorecardView(result: examResult, courseName: course.name)
                                } label: {
                                    Label("\(profile.text(.officialScorecard)): \(examResult.overallDisplay) → \(examResult.awardedLevel)", systemImage: "rosette")
                                        .font(.caption.bold())
                                }
                            } else if ready {
                                NavigationLink {
                                    LevelExamView(languageId: course.id, course: course, exam: exam)
                                } label: {
                                    Label(profile.text(.takeOfficialExam), systemImage: "pencil.and.list.clipboard")
                                        .font(.caption.bold())
                                }
                            } else {
                                Text(profile.text(.examLockedHint))
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .padding(.vertical, 2)
                }
            }

            if let latest = progressStore.latestOfficialResult(languageId: course.id, course: course) {
                Section(profile.text(.latestOfficialResult)) {
                    NavigationLink {
                        OfficialScorecardView(result: latest, courseName: course.name)
                    } label: {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("\(latest.scoreSystem) · \(latest.level)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            HStack {
                                scoreChip(profile.text(.listening), latest.listeningDisplay)
                                scoreChip(profile.text(.speaking), latest.speakingDisplay)
                                scoreChip(profile.text(.reading), latest.readingDisplay)
                                scoreChip(profile.text(.writing), latest.writingDisplay)
                            }
                            Text("\(profile.text(.overallScore)): \(latest.overallDisplay)  ·  \(profile.text(.awardedLevel)): \(latest.awardedLevel)")
                                .font(.subheadline.bold())
                        }
                        .padding(.vertical, 4)
                    }
                }
            }

            if let currentWeek {
                Section(profile.text(.thisWeek)) {
                    NavigationLink {
                        WeekDetailView(languageId: course.id, week: currentWeek)
                    } label: {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("\(profile.text(.week)) \(currentWeek.week): \(currentWeek.title)")
                                .font(.headline)
                            Text("\(profile.text(.level)): \(currentWeek.level)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(currentWeek.focus)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .lineLimit(2)
                            HStack {
                                Text(progressStore.isWeekCompleted(languageId: course.id, week: currentWeek.week)
                                     ? profile.text(.completed)
                                     : profile.text(.continueWeek))
                                    .font(.caption.bold())
                                    .foregroundStyle(Color.accentColor)
                                Spacer()
                                if progressStore.didPassSpeaking(languageId: course.id, week: currentWeek.week) {
                                    Label(profile.text(.speaking), systemImage: "checkmark.circle.fill")
                                        .font(.caption)
                                        .foregroundStyle(.green)
                                }
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }

            Section(profile.text(.weekScores)) {
                ForEach(course.weeks) { week in
                    NavigationLink {
                        WeekDetailView(languageId: course.id, week: week)
                    } label: {
                        WeekScoreRow(languageId: course.id, week: week)
                    }
                }
            }
        }
    }

    private func levelRow(level: String, passed: Bool, speakingAvg: Int?, overall: Int?, weekCount: Int, examResult: OfficialExamResult?) -> some View {
        HStack(spacing: 12) {
            Image(systemName: passed ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(passed ? .green : .secondary)
                .font(.title3)
            VStack(alignment: .leading, spacing: 2) {
                Text(level)
                    .font(.headline)
                if let examResult {
                    Text("\(profile.text(.officialScorecard)): \(examResult.overallDisplay)")
                        .font(.caption2)
                        .foregroundStyle(Color.accentColor)
                } else {
                    Text(passed ? profile.text(.levelPassed) : profile.text(.passToUnlock))
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                if let examResult {
                    Text(examResult.awardedLevel)
                        .font(.headline)
                        .foregroundStyle(.green)
                } else if let overall {
                    Text("\(overall)%")
                        .font(.headline.monospacedDigit())
                        .foregroundStyle(overall >= ProgressStore.passThreshold ? .green : .primary)
                } else {
                    Text(profile.text(.notStarted))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                if let speakingAvg {
                    Text("\(profile.text(.speaking)) \(speakingAvg)%")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                } else {
                    Text("\(weekCount) \(profile.text(.week).lowercased())")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }

    private func scoreChip(_ title: String, _ value: String) -> some View {
        VStack(spacing: 2) {
            Text(title).font(.caption2).foregroundStyle(.secondary)
            Text(value).font(.caption.bold().monospacedDigit())
        }
        .frame(maxWidth: .infinity)
    }
}

private struct WeekScoreRow: View {
    let languageId: String
    let week: CourseWeek
    @EnvironmentObject var profile: UserProfileStore
    @EnvironmentObject var progressStore: ProgressStore

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text("\(profile.text(.week)) \(week.week) · \(week.level)")
                    .font(.subheadline.bold())
                Text(week.title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            Spacer()
            if let avg = progressStore.weekAverage(languageId: languageId, week: week.week) {
                Text("\(avg)%")
                    .font(.headline.monospacedDigit())
                    .foregroundStyle(avg >= ProgressStore.passThreshold ? .green : .primary)
            } else {
                Text(profile.text(.notStarted))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Image(systemName: progressStore.isWeekCompleted(languageId: languageId, week: week.week)
                  ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(progressStore.isWeekCompleted(languageId: languageId, week: week.week) ? .green : .secondary)
        }
        .padding(.vertical, 2)
    }
}
