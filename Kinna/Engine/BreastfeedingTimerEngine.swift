import Foundation

struct BreastfeedingTimerSummary {
    let latestLogDate: Date
    let elapsedSinceLatest: TimeInterval
}

enum BreastfeedingTimerEngine {
    static func summary(
        logs: [DailyLog],
        referenceDate: Date = .now
    ) -> BreastfeedingTimerSummary? {
        guard let latestLog = latestBreastfeedingLog(in: logs) else { return nil }

        return BreastfeedingTimerSummary(
            latestLogDate: latestLog.date,
            elapsedSinceLatest: max(0, referenceDate.timeIntervalSince(latestLog.date))
        )
    }

    static func latestBreastfeedingLog(in logs: [DailyLog]) -> DailyLog? {
        logs
            .filter { $0.type == .feeding && $0.feedingType == .breast }
            .max(by: { $0.date < $1.date })
    }
}
