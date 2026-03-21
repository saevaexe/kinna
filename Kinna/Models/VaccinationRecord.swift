import Foundation
import SwiftData

@Model
final class VaccinationRecord {
    var id: UUID = UUID()
    var vaccineName: String = ""
    var scheduledDate: Date = Date()
    var administeredDate: Date?
    var isCompleted: Bool = false
    var note: String = ""
    var createdAt: Date = Date()
    var isManual: Bool?
    var nextDoseDate: Date?
    var doctorName: String?
    var lotNumber: String?

    /// Auto-generated from TR schedule
    init(vaccineName: String, scheduledDate: Date, note: String = "") {
        self.id = UUID()
        self.vaccineName = vaccineName
        self.scheduledDate = scheduledDate
        self.isCompleted = false
        self.note = note
        self.createdAt = .now
        self.isManual = nil
        self.nextDoseDate = nil
        self.doctorName = nil
        self.lotNumber = nil
    }

    /// Manual entry
    init(vaccineName: String, administeredDate: Date, nextDoseDate: Date? = nil, note: String = "", doctorName: String = "", lotNumber: String = "") {
        self.id = UUID()
        self.vaccineName = vaccineName
        self.scheduledDate = administeredDate
        self.administeredDate = administeredDate
        self.isCompleted = true
        self.note = note
        self.createdAt = .now
        self.isManual = true
        self.nextDoseDate = nextDoseDate
        self.doctorName = doctorName.isEmpty ? nil : doctorName
        self.lotNumber = lotNumber.isEmpty ? nil : lotNumber
    }
}
