import Foundation
import SwiftData

@Model
final class VaccinationRecord {
    var id: UUID
    var vaccineName: String
    var scheduledDate: Date
    var administeredDate: Date?
    var isCompleted: Bool
    var note: String
    var createdAt: Date

    init(vaccineName: String, scheduledDate: Date, note: String = "") {
        self.id = UUID()
        self.vaccineName = vaccineName
        self.scheduledDate = scheduledDate
        self.isCompleted = false
        self.note = note
        self.createdAt = .now
    }
}
