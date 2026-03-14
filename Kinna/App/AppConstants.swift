import Foundation

enum AppConstants {
    enum Subscription {
        static var revenueCatAPIKey: String {
            let rawValue = (Bundle.main.object(forInfoDictionaryKey: "RevenueCatAPIKey") as? String) ?? ""
            return rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        }

        static let entitlementID = "pro"
        static let monthlyProductID = "com.osmanseven.kinna.pro.monthly"
        static let yearlyProductID = "com.osmanseven.kinna.pro.yearly"
        static let productIDs: Set<String> = [monthlyProductID, yearlyProductID]
        static let manageSubscriptionsURL = URL(string: "https://apps.apple.com/account/subscriptions")!

        static var hasValidRevenueCatAPIKey: Bool {
            let key = revenueCatAPIKey
            return !key.isEmpty
                && key != "REPLACE_WITH_REVENUECAT_API_KEY"
                && !key.contains("$(")
        }
    }

    enum Legal {
        static let baseURL = URL(string: "https://saevaexe.github.io/kinna")!
        static let termsURL = baseURL.appendingPathComponent("terms.html")
        static let privacyURL = baseURL.appendingPathComponent("privacy.html")
        static let supportURL = baseURL.appendingPathComponent("support.html")
    }
}
