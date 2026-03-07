import Foundation

struct Milestone: Codable, Identifiable {
    let id: String
    let monthStart: Int
    let monthEnd: Int
    let category: String
    let titleTR: String
    let titleEN: String
    let descriptionTR: String
    let descriptionEN: String
}

enum MilestoneEngine {
    static func milestonesForAge(_ months: Int) -> [Milestone] {
        let all = loadMilestones()
        return all.filter { months >= $0.monthStart && months <= $0.monthEnd }
    }

    private static func loadMilestones() -> [Milestone] {
        guard let url = Bundle.main.url(forResource: "milestones", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let milestones = try? JSONDecoder().decode([Milestone].self, from: data) else {
            return []
        }
        return milestones
    }
}
