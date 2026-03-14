import Foundation

enum MonetizationPolicy {
    static let trialLengthDays = 7
    static let freeTrackingHistoryDays = 7
    static let freeMilestoneTrackingLimit = 5
    static let freeFoodLogLimit = 5
    static let freeHomeGuidanceCardCount = 1

    static func canSaveMilestone(
        hasFullAccess: Bool,
        currentTrackedCount: Int,
        isAlreadyTracked: Bool
    ) -> Bool {
        hasFullAccess || isAlreadyTracked || currentTrackedCount < freeMilestoneTrackingLimit
    }

    static func visibleHomeGuidanceCardCount(hasFullAccess: Bool) -> Int {
        hasFullAccess ? .max : freeHomeGuidanceCardCount
    }

    static func canAccessMilestoneMonth(
        hasFullAccess: Bool,
        selectedMonth: Int,
        currentMonth: Int
    ) -> Bool {
        hasFullAccess || selectedMonth == currentMonth
    }

    static func canAddFoodLog(
        hasFullAccess: Bool,
        currentCount: Int
    ) -> Bool {
        hasFullAccess || currentCount < freeFoodLogLimit
    }

    static func canUseVaccineReminders(hasFullAccess: Bool) -> Bool {
        hasFullAccess
    }

    static func canAccessGrowthCharts(hasFullAccess: Bool) -> Bool {
        hasFullAccess
    }

    static func freeHistoryCutoffDate(
        referenceDate: Date = .now,
        calendar: Calendar = .current
    ) -> Date {
        let startOfToday = calendar.startOfDay(for: referenceDate)
        return calendar.date(byAdding: .day, value: -(freeTrackingHistoryDays - 1), to: startOfToday) ?? startOfToday
    }
}
