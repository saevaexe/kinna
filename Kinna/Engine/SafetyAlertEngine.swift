import Foundation

struct SafetyAlert: Codable, Identifiable {
    let id: String
    let monthStart: Int
    let monthEnd: Int
    let severity: String
    let titleTR: String
    let titleEN: String
    let descriptionTR: String
    let descriptionEN: String
    let sourceURL: String
}

enum SafetyAlertEngine {
    static func alertsForAge(_ months: Int) -> [SafetyAlert] {
        let all = loadAlerts()
        return all.filter { months >= $0.monthStart && months <= $0.monthEnd }
    }

    private static func loadAlerts() -> [SafetyAlert] {
        guard let url = Bundle.main.url(forResource: "safety_alerts", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let alerts = try? JSONDecoder().decode([SafetyAlert].self, from: data) else {
            return []
        }
        return alerts
    }
}
