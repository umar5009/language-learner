import SwiftUI

/// Weekly preparation hub: institute-aligned pack + exportable PDF.
struct StudyMaterialsView: View {
    let languageId: String
    let week: CourseWeek

    @EnvironmentObject var profile: UserProfileStore
    @EnvironmentObject var dataStore: LanguageDataStore
    @EnvironmentObject var progressStore: ProgressStore

    @State private var showAnswers = false
    @State private var checked = Set<String>()
    @State private var shareURL: URL?
    @State private var showShare = false
    @State private var exportError: String?

    private var course: LanguageCourse? {
        dataStore.course(for: languageId)
    }

    private var pack: StudyPack {
        week.resolvedStudyPack
    }

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text(pack.title)
                        .font(.headline)
                    Text(pack.instituteSource)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("\(profile.text(.level)): \(pack.level)")
                        .font(.caption.bold())
                        .foregroundStyle(Color.accentColor)
                    Text(profile.text(.studyPackIntro))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 4)

                Button {
                    exportPDF()
                } label: {
                    Label(profile.text(.exportPDF), systemImage: "square.and.arrow.up")
                        .font(.body.bold())
                }
            }

            Section(profile.text(.mockExercises)) {
                NavigationLink {
                    MockPracticeHubView(languageId: languageId, week: week)
                } label: {
                    VStack(alignment: .leading, spacing: 4) {
                        Label(profile.text(.practiceExercises123), systemImage: "list.number")
                            .font(.body.bold())
                        Text(profile.text(.mockPracticeIntro))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                if let course,
                   let exam = course.levelExam(for: week.level) {
                    let ready = progressStore.isPrepReadyForLevelExam(
                        languageId: languageId,
                        course: course,
                        level: week.level
                    )
                    NavigationLink {
                        LevelExamView(languageId: languageId, course: course, exam: exam)
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Label(profile.text(.takeOfficialExam), systemImage: "rosette")
                                .font(.body.bold())
                            Text(ready ? profile.text(.examReadyAfterPrep) : profile.text(.examLockedHint))
                                .font(.caption)
                                .foregroundStyle(ready ? .green : .secondary)
                        }
                    }
                    .disabled(!ready)

                    if let result = progressStore.levelExamResult(languageId: languageId, level: week.level) {
                        NavigationLink {
                            OfficialScorecardView(result: result, courseName: course.name)
                        } label: {
                            HStack {
                                Label(profile.text(.viewScorecard), systemImage: "chart.bar.doc.horizontal")
                                Spacer()
                                Text(result.overallDisplay)
                                    .font(.headline.monospacedDigit())
                                    .foregroundStyle(Color.accentColor)
                            }
                        }
                    }
                }
            }

            Section(profile.text(.learningObjectives)) {
                ForEach(Array(pack.learningObjectives.enumerated()), id: \.offset) { idx, item in
                    Text("\(idx + 1). \(item)")
                        .font(.subheadline)
                }
            }

            Section(profile.text(.canDoStatements)) {
                ForEach(pack.canDoStatements, id: \.self) { item in
                    Label(item, systemImage: "checkmark.circle")
                        .font(.subheadline)
                }
            }

            Section(profile.text(.readingPassage)) {
                NavigationLink {
                    StudyPassageView(passage: pack.readingPassage, courseId: languageId)
                } label: {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(pack.readingPassage.title).font(.subheadline.bold())
                        Text(pack.readingPassage.body)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(3)
                    }
                }
            }

            Section(profile.text(.grammarDeepDive)) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(pack.grammarDeepDive.title).font(.subheadline.bold())
                    Text(pack.grammarDeepDive.explanation).font(.subheadline)
                    Text(pack.grammarDeepDive.example)
                        .font(.subheadline.italic())
                        .foregroundStyle(.secondary)
                    Text(pack.grammarDeepDive.practiceHint)
                        .font(.caption)
                        .foregroundStyle(Color.accentColor)
                }
                .padding(.vertical, 2)
            }

            Section(profile.text(.keyPhrases)) {
                ForEach(pack.keyPhrases) { phrase in
                    VStack(alignment: .leading, spacing: 2) {
                        HStack {
                            Text(phrase.phrase).font(.body.bold())
                            Spacer()
                            Text(phrase.meaning).font(.caption).foregroundStyle(.secondary)
                        }
                        Text(phrase.usage)
                            .font(.caption)
                            .italic()
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 2)
                }
            }

            Section {
                Toggle(profile.text(.showWorksheetAnswers), isOn: $showAnswers)
                ForEach(Array(pack.worksheet.enumerated()), id: \.offset) { idx, item in
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(profile.text(.worksheet)) \(idx + 1) · \(item.type)")
                            .font(.caption.bold())
                            .foregroundStyle(.secondary)
                        Text(item.prompt).font(.subheadline)
                        if showAnswers {
                            Text("→ \(item.answer)")
                                .font(.caption)
                                .foregroundStyle(Color.accentColor)
                        } else {
                            Text(profile.text(.tryYourselfFirst))
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 2)
                }
            } header: {
                Text(profile.text(.worksheet))
            }

            Section(profile.text(.prepChecklist)) {
                ForEach(pack.prepChecklist, id: \.self) { item in
                    Button {
                        if checked.contains(item) {
                            checked.remove(item)
                        } else {
                            checked.insert(item)
                        }
                    } label: {
                        Label(item, systemImage: checked.contains(item) ? "checkmark.square.fill" : "square")
                            .foregroundStyle(.primary)
                    }
                }
            }

            Section(profile.text(.examTips)) {
                ForEach(pack.examTips, id: \.self) { tip in
                    Text("• \(tip)").font(.subheadline)
                }
            }

            Section(profile.text(.selfStudyPlan)) {
                Text(pack.selfStudyPlan)
                    .font(.subheadline)
                    .padding(.vertical, 2)
            }

            Section(profile.text(.cultureNote)) {
                Text(week.cultureNote).font(.subheadline)
            }
        }
        .navigationTitle(profile.text(.studyPrepPack))
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showShare) {
            if let shareURL {
                ShareSheet(items: [shareURL])
            }
        }
        .alert(profile.text(.contentError), isPresented: Binding(
            get: { exportError != nil },
            set: { if !$0 { exportError = nil } }
        )) {
            Button(profile.text(.done), role: .cancel) { exportError = nil }
        } message: {
            Text(exportError ?? "")
        }
    }

    private func exportPDF() {
        let courseName = course?.name ?? languageId
        let institute = course?.institute ?? pack.instituteSource
        let data = StudyPDFExporter.makePDF(
            courseName: courseName,
            institute: institute,
            languageId: languageId,
            week: week
        )
        let name = StudyPDFExporter.suggestedFileName(courseId: languageId, week: week.week)
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(name)
        do {
            try data.write(to: url, options: .atomic)
            shareURL = url
            showShare = true
        } catch {
            exportError = error.localizedDescription
        }
    }
}

struct StudyPassageView: View {
    let passage: StudyPassage
    let courseId: String

    @EnvironmentObject var profile: UserProfileStore
    @ObservedObject private var voice = VoiceCoach.shared

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                Text(passage.title).font(.title2.bold())
                Text(passage.body)
                    .font(.body)
                    .lineSpacing(4)
                if let focus = passage.focusWords, !focus.isEmpty {
                    Text("\(profile.text(.focusWords)): \(focus)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Text(passage.sourceNote)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Button {
                    if voice.isSpeaking {
                        voice.stop()
                    } else {
                        voice.speak(passage.body, courseId: courseId, rate: 0.45)
                    }
                } label: {
                    Label(
                        voice.isSpeaking ? profile.text(.stop) : profile.text(.playAIVoice),
                        systemImage: voice.isSpeaking ? "stop.fill" : "speaker.wave.2.fill"
                    )
                    .font(.body.bold())
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            .padding()
        }
        .navigationTitle(profile.text(.readingPassage))
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear { voice.stop() }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
