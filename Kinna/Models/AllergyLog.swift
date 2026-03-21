import Foundation
import SwiftData

@Model
final class AllergyLog {
    var id: UUID = UUID()
    var foodName: String = ""
    var introducedDate: Date = Date()
    var reaction: ReactionType = ReactionType.none
    var reactionNote: String = ""
    var createdAt: Date = Date()

    init(foodName: String, introducedDate: Date = .now, reaction: ReactionType = .none, reactionNote: String = "") {
        self.id = UUID()
        self.foodName = foodName
        self.introducedDate = introducedDate
        self.reaction = reaction
        self.reactionNote = reactionNote
        self.createdAt = .now
    }

    enum ReactionType: String, Codable, CaseIterable {
        case none
        case mild
        case moderate
        case severe
    }
}
