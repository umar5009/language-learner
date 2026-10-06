import SwiftUI

struct LanguageDetailView: View {
    let entry: LanguageManifestEntry

    @EnvironmentObject var dataStore: LanguageDataStore
    @EnvironmentObject var progressStore: ProgressStore
    @EnvironmentObject var profile: UserProfileStore

    private var course: LanguageCourse? {
        dataStore.course(for: entry.id)
    }

    var body: some View {
        Group {
            if let course {
                List {
                    Section {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(course.description)
                                .font(.subheadline)
                            Label(course.institute, systemImage: "building.columns")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Label(course.framework, systemImage: "chart.bar.doc.horizontal")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 4)
                    }

                    if let fw = course.examFramework {
                        Section(profile.text(.examPapers)) {
                            Text(fw.notes)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(fw.passRule)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                            ForEach(fw.officialLevels) { level in
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(level.label).font(.subheadline.bold())
                                    Text(level.examName).font(.caption).foregroundStyle(.secondary)
                                }
                            }
                            ForEach(["listening", "speaking", "reading", "writing"], id: \.self) { key in
                                if let paper = fw.skillPapers[key] {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(paper.officialName).font(.headline)
                                        if let minutes = paper.minutes?.value, !minutes.isEmpty {
                                            Text(minutes).font(.caption2).foregroundStyle(.secondary)
                                        }
                                        if let parts = paper.parts {
                                            Text(parts.joined(separator: " · "))
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                        }
                                        if let example = paper.example {
                                            Text(example).font(.caption2)
                                        }
                                    }
                                    .padding(.vertical, 4)
                                }
                            }
                        }
                    }

                    ForEach(groupedByLevel(course.weeks), id: \.level) { group in
                        Section(group.level) {
                            ForEach(group.weeks) { week in
                                NavigationLink {
                                    WeekDetailView(languageId: course.id, week: week)
                                } label: {
                                    WeekRow(languageId: course.id, week: week)
                                }
                            }
                        }
                    }
                }
            } else {
                ContentUnavailableView("Couldn't load \(entry.name)", systemImage: "exclamationmark.triangle")
            }
        }
        .navigationTitle("\(entry.flagEmoji) \(entry.name)")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func groupedByLevel(_ weeks: [CourseWeek]) -> [(level: String, weeks: [CourseWeek])] {
        var order: [String] = []
        var buckets: [String: [CourseWeek]] = [:]
        for w in weeks {
            if buckets[w.level] == nil {
                order.append(w.level)
                buckets[w.level] = []
            }
            buckets[w.level]?.append(w)
        }
        return order.map { (level: $0, weeks: buckets[$0] ?? []) }
    }
}

private struct WeekRow: View {
    let languageId: String
    let week: CourseWeek
    @EnvironmentObject var progressStore: ProgressStore

    private var completed: Bool {
        progressStore.isWeekCompleted(languageId: languageId, week: week.week)
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Week \(week.week): \(week.title)")
                    .font(.body)
                Text(week.focus)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
            Spacer()
            Image(systemName: completed ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(completed ? .green : .secondary)
        }
        .padding(.vertical, 2)
    }
}

#Preview {
    NavigationStack {
        LanguageDetailView(entry: LanguageManifestEntry(
            id: "german", name: "German", flagEmoji: "🇩🇪",
            institute: "Goethe-Institut", framework: "CEFR A1 → C1",
            description: "Sample", fileName: "german.json", weekCount: 9))
    }
    .environmentObject(LanguageDataStore.shared)
    .environmentObject(ProgressStore.shared)
    .environmentObject(UserProfileStore.shared)
}
