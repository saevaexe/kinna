import Foundation
import SwiftData

enum ActiveTimerEngine {

    // MARK: - Start

    @discardableResult
    static func startTimer(
        type: DailyLog.LogType,
        feedingType: DailyLog.FeedingType? = nil,
        breastSide: DailyLog.BreastSide? = nil,
        babyID: UUID?,
        context: ModelContext
    ) -> DailyLog {
        let log = DailyLog(date: .now, type: type, babyID: babyID)
        log.timerStartDate = .now
        log.feedingType = feedingType
        log.breastSide = breastSide
        context.insert(log)
        return log
    }

    // MARK: - Stop

    static func stopTimer(_ log: DailyLog) {
        guard log.isTimerRunning else { return }
        log.timerEndDate = .now

        if log.type == .sleep, let duration = log.timerDuration {
            log.sleepDuration = duration
        }
    }

    // MARK: - Cancel

    static func cancelTimer(_ log: DailyLog, context: ModelContext) {
        context.delete(log)
    }

    // MARK: - Query

    static func activeTimers(in logs: [DailyLog]) -> [DailyLog] {
        logs.filter { $0.isTimerRunning }
    }

    static func activeTimer(ofType type: DailyLog.LogType, in logs: [DailyLog]) -> DailyLog? {
        logs.first { $0.isTimerRunning && $0.type == type }
    }

    static func hasActiveTimer(in logs: [DailyLog]) -> Bool {
        logs.contains { $0.isTimerRunning }
    }

    // MARK: - Elapsed

    static func elapsed(for log: DailyLog, referenceDate: Date = .now) -> TimeInterval {
        guard let start = log.timerStartDate else { return 0 }
        let end = log.timerEndDate ?? referenceDate
        return max(0, end.timeIntervalSince(start))
    }

    // MARK: - Formatting

    static func formattedElapsed(_ interval: TimeInterval) -> String {
        let totalSeconds = max(0, Int(interval))
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60

        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        }
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
