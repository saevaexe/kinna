import Foundation
import SwiftData

@Model
final class DailyLog {
    var id: UUID = UUID()
    var date: Date = Date()
    var type: LogType = LogType.note
    var note: String = ""
    var createdAt: Date = Date()
    var babyID: UUID?

    // Feeding
    var feedingType: FeedingType?
    var feedingAmount: Double?

    // Sleep
    var sleepDuration: TimeInterval?

    // Diaper
    var diaperType: DiaperType?

    init(date: Date = .now, type: LogType, note: String = "", babyID: UUID? = nil) {
        self.id = UUID()
        self.date = date
        self.type = type
        self.note = note
        self.createdAt = .now
        self.babyID = babyID
    }

    enum LogType: String, Codable, CaseIterable {
        case feeding
        case sleep
        case diaper
        case note
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
