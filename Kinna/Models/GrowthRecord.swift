import Foundation
import SwiftData

@Model
final class GrowthRecord {
    var id: UUID
    var measuredAt: Date
    var weightKilograms: Double?
    var heightCentimeters: Double?
    var note: String
    var createdAt: Date
    var babyID: UUID?

    init(
        measuredAt: Date = .now,
        weightKilograms: Double? = nil,
        heightCentimeters: Double? = nil,
        note: String = "",
        babyID: UUID? = nil
    ) {
        self.id = UUID()
        self.measuredAt = measuredAt
        self.weightKilograms = weightKilograms
        self.heightCentimeters = heightCentimeters
        self.note = note
        self.createdAt = .now
        self.babyID = babyID
    }
}
