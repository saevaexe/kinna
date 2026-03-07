import Foundation
import SwiftData

@Model
final class DailyLog {
    var id: UUID
    var date: Date
    var type: LogType
    var note: String
    var createdAt: Date

    // Feeding
    var feedingType: FeedingType?
    var feedingAmount: Double?

    // Sleep
    var sleepDuration: TimeInterval?

    // Diaper
    var diaperType: DiaperType?

    init(date: Date = .now, type: LogType, note: String = "") {
        self.id = UUID()
        self.date = date
        self.type = type
        self.note = note
        self.createdAt = .now
    }

    enum LogType: String, Codable, CaseIterable {
        case feeding
        case sleep
        case diaper
    }

    enum FeedingType: String, Codable, CaseIterable {
        case breast
        case bottle
        case solid
    }

    enum DiaperType: String, Codable, CaseIterable {
        case wet
        case dirty
        case both
    }
}
