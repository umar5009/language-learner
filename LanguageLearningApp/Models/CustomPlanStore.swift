import Foundation
import Combine

final class CustomPlanStore: ObservableObject {
    static let shared = CustomPlanStore()

    @Published private(set) var plans: [CustomStudyPlan] = []

    private let key = "customStudyPlans.v1"

    private init() {
        if let data = UserDefaults.standard.data(forKey: key),
           let decoded = try? JSONDecoder().decode([CustomStudyPlan].self, from: data) {
            plans = decoded
        }
    }

    func plans(for courseId: String) -> [CustomStudyPlan] {
        plans.filter { $0.courseId == courseId }.sorted { $0.created > $1.created }
    }

    func save(_ plan: CustomStudyPlan) {
        plans.removeAll { $0.id == plan.id }
        plans.insert(plan, at: 0)
        persist()
    }

    func delete(_ plan: CustomStudyPlan) {
        plans.removeAll { $0.id == plan.id }
        persist()
    }

    private func persist() {
        if let data = try? JSONEncoder().encode(plans) {
            UserDefaults.standard.set(data, forKey: key)
        }
        objectWillChange.send()
    }
}
