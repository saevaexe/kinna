import Foundation
import SwiftData

@Model
final class Baby {
    var id: UUID = UUID()
    var name: String = ""
    var birthDate: Date = Date()
    var gender: Gender = Gender.other
    var createdAt: Date = Date()

    init(name: String, birthDate: Date, gender: Gender) {
        self.id = UUID()
        self.name = name
        self.birthDate = birthDate
        self.gender = gender
        self.createdAt = .now
    }

    var ageInDays: Int {
        Calendar.current.dateComponents([.day], from: birthDate, to: .now).day ?? 0
    }

    var ageInMonths: Int {
        Calendar.current.dateComponents([.month], from: birthDate, to: .now).month ?? 0
    }

    var ageDescription: String {
        let components = Calendar.current.dateComponents([.year, .month, .day], from: birthDate, to: .now)
        let years = components.year ?? 0
        let months = components.month ?? 0
        let days = components.day ?? 0
        let isEN = Locale.current.language.languageCode?.identifier != "tr"

        if isEN {
            if years > 0 {
                return "\(years) yr \(months) mo"
            } else if months > 0 {
                return "\(months) mo \(days) days"
            } else {
                return "\(days) days"
            }
        } else {
            if years > 0 {
                return "\(years) yıl \(months) ay"
            } else if months > 0 {
                return "\(months) ay \(days) gün"
            } else {
                return "\(days) gün"
            }
        }
    }

    enum Gender: String, Codable, CaseIterable {
        case male
        case female
        case other
    }
}
