import Foundation
import SwiftData

@Model
final class MilestoneProgress {
    var id: UUID = UUID()
    var milestoneID: String = ""
    var status: Status = Status.completed
    var completedAt: Date?

    init(milestoneID: String, status: Status = .completed) {
        self.id = UUID()
        self.milestoneID = milestoneID
        self.status = status
        self.completedAt = status == .completed ? .now : nil
    }

    enum Status: String, Codable {
        case completed
        case attention
    }
}
