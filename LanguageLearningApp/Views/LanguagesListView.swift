import SwiftUI

struct LanguagesListView: View {
    @EnvironmentObject var dataStore: LanguageDataStore
    @EnvironmentObject var progressStore: ProgressStore

    var body: some View {
        NavigationStack {
            Group {
                if let error = dataStore.loadError {
                    ContentUnavailableView("Couldn't load content", systemImage: "exclamationmark.triangle", description: Text(error))
                } else {
                    List(dataStore.manifest) { entry in
                        NavigationLink(value: entry) {
                            LanguageRow(entry: entry)
                        }
                    }
                    .navigationDestination(for: LanguageManifestEntry.self) { entry in
                        LanguageDetailView(entry: entry)
                    }
                }
            }
            .navigationTitle("Learn a Language")
        }
    }
}

private struct LanguageRow: View {
    let entry: LanguageManifestEntry
    @EnvironmentObject var progressStore: ProgressStore

    private var completed: Int {
        progressStore.completedCount(languageId: entry.id, totalWeeks: entry.weekCount)
    }

    var body: some View {
        HStack(spacing: 14) {
            Text(entry.flagEmoji)
                .font(.system(size: 34))

            VStack(alignment: .leading, spacing: 4) {
                Text(entry.name)
                    .font(.headline)
                Text(entry.institute)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text(entry.framework)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                ProgressView(value: Double(completed), total: Double(entry.weekCount))
                    .tint(.accentColor)
                    .padding(.top, 2)
            }

            Spacer()

            Text("\(completed)/\(entry.weekCount)")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 6)
    }
}

#Preview {
    LanguagesListView()
        .environmentObject(LanguageDataStore.shared)
        .environmentObject(ProgressStore.shared)
}
