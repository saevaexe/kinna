import Foundation

struct SleepInsightSummary {
    let dailyHours: [SleepDailyHours]
    let trackedDaysCount: Int
    let averageTrackedHours: Double
    let trend: SleepTrend
}

struct SleepDailyHours: Identifiable {
    let date: Date
    let hours: Double

    var id: Date { date }
}

enum SleepTrend: Equatable {
    case increasing
    case decreasing
    case stable
    case insufficientData
}

enum SleepInsightEngine {
    static func summary(
        logs: [DailyLog],
        referenceDate: Date = .now,
        calendar: Calendar = .current
    ) -> SleepInsightSummary? {
        let sleepLogs = logs.filter { $0.type == .sleep && ($0.sleepDuration ?? 0) > 0 }
        guard !sleepLogs.isEmpty else { return nil }

        let startOfToday = calendar.startOfDay(for: referenceDate)
        let windowStart = calendar.date(byAdding: .day, value: -6, to: startOfToday) ?? startOfToday

        var buckets: [Date: Double] = [:]
        for log in sleepLogs {
            let day = calendar.startOfDay(for: log.date)
            guard day >= windowStart && day <= startOfToday else { continue }
            buckets[day, default: 0] += (log.sleepDuration ?? 0) / 3600
        }

        let dailyHours = (0..<7).compactMap { offset -> SleepDailyHours? in
            guard let date = calendar.date(byAdding: .day, value: offset, to: windowStart) else { return nil }
            return SleepDailyHours(date: date, hours: buckets[date, default: 0])
        }

        let tracked = dailyHours.filter { $0.hours > 0 }
        guard !tracked.isEmpty else { return nil }

        let average = tracked.map(\.hours).reduce(0, +) / Double(tracked.count)

        return SleepInsightSummary(
            dailyHours: dailyHours,
            trackedDaysCount: tracked.count,
            averageTrackedHours: average,
            trend: trend(for: tracked)
        )
    }

    private static func trend(for trackedDays: [SleepDailyHours]) -> SleepTrend {
        guard trackedDays.count >= 4 else { return .insufficientData }

        let recent = Array(trackedDays.suffix(3))
        let previous = Array(trackedDays.dropLast(3).suffix(3))

        guard !recent.isEmpty, !previous.isEmpty else { return .insufficientData }

        let recentAverage = recent.map(\.hours).reduce(0, +) / Double(recent.count)
        let previousAverage = previous.map(\.hours).reduce(0, +) / Double(previous.count)
        let difference = recentAverage - previousAverage

        if difference >= 0.75 {
            return .increasing
        }

        if difference <= -0.75 {
            return .decreasing
        }

        return .stable
    }
}
