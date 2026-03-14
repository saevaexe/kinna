import Foundation

struct ReviewPromptMetrics: Equatable {
    let engagedDayCount: Int
    let meaningfulActionCount: Int
    let firstMeaningfulActivityAt: Date?
}

enum ReviewPromptManager {
    private static let lastRequestedVersionKey = "reviewPrompt.lastRequestedVersion"
    private static let lastRequestedAtKey = "reviewPrompt.lastRequestedAt"
    private static let requestedCountKey = "reviewPrompt.requestedCount"

    static func shouldRequestReview(
        metrics: ReviewPromptMetrics,
        now: Date = .now,
        defaults: UserDefaults = .standard,
        currentVersion: String = currentAppVersion
    ) -> Bool {
        guard metrics.engagedDayCount >= AppConstants.ReviewPrompt.minimumEngagedDays else {
            return false
        }

        guard metrics.meaningfulActionCount >= AppConstants.ReviewPrompt.minimumMeaningfulActions else {
            return false
        }

        guard let firstActivityAt = metrics.firstMeaningfulActivityAt else {
            return false
        }

        let minimumSeconds = TimeInterval(AppConstants.ReviewPrompt.minimumDaysSinceFirstActivity * 86_400)
        guard now.timeIntervalSince(firstActivityAt) >= minimumSeconds else {
            return false
        }

        if defaults.string(forKey: lastRequestedVersionKey) == currentVersion {
            return false
        }

        if defaults.integer(forKey: requestedCountKey) >= AppConstants.ReviewPrompt.maximumPromptCount {
            return false
        }

        if let lastRequestedAt = defaults.object(forKey: lastRequestedAtKey) as? Date {
            let cooldown = TimeInterval(AppConstants.ReviewPrompt.cooldownDays * 86_400)
            guard now.timeIntervalSince(lastRequestedAt) >= cooldown else {
                return false
            }
        }

        return true
    }

    static func recordRequest(
        now: Date = .now,
        defaults: UserDefaults = .standard,
        currentVersion: String = currentAppVersion
    ) {
        defaults.set(now, forKey: lastRequestedAtKey)
        defaults.set(currentVersion, forKey: lastRequestedVersionKey)
        defaults.set(defaults.integer(forKey: requestedCountKey) + 1, forKey: requestedCountKey)
    }

    private static var currentAppVersion: String {
        let shortVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
        return shortVersion?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
            ? shortVersion!
            : "unknown"
    }
}
