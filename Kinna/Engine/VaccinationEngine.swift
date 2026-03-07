import Foundation

struct VaccinationItem: Codable, Identifiable {
    let id: String
    let nameTR: String
    let nameEN: String
    let monthAge: Int
    let descriptionTR: String
    let descriptionEN: String
}

enum VaccinationEngine {
    static func schedule(birthDate: Date) -> [VaccinationItem] {
        let items = loadVaccinations()
        return items.sorted { $0.monthAge < $1.monthAge }
    }

    static func scheduledDate(birthDate: Date, monthAge: Int) -> Date {
        Calendar.current.date(byAdding: .month, value: monthAge, to: birthDate) ?? birthDate
    }

    private static func loadVaccinations() -> [VaccinationItem] {
        guard let url = Bundle.main.url(forResource: "vaccinations", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let items = try? JSONDecoder().decode([VaccinationItem].self, from: data) else {
            return []
        }
        return items
    }
}
