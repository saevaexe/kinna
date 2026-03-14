import Foundation
import Observation
import OSLog
import RevenueCat

@MainActor
@Observable
final class SubscriptionManager {
    static let shared = SubscriptionManager()
    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "com.osmanseven.kinna",
        category: "Subscription"
    )

    private(set) var isSubscribed = false
    private(set) var isTrialActive = false
    private(set) var isLoading = false
    private(set) var isRevenueCatAvailable = false
    private(set) var lastErrorMessage: String?

    var hasFullAccess: Bool { isSubscribed || isTrialActive }
    var canMakePurchases: Bool { isRevenueCatAvailable }

    var trialDaysRemaining: Int {
        guard isTrialActive, let expirationDate = trialExpirationDate else { return 0 }
        let remaining = Int(ceil(expirationDate.timeIntervalSinceNow / 86400))
        return max(0, remaining)
    }

    @ObservationIgnored private var trialExpirationDate: Date?
    @ObservationIgnored private var isConfigured = false
    @ObservationIgnored private var customerInfoUpdatesTask: Task<Void, Never>?

    private init() {}

    deinit {
        customerInfoUpdatesTask?.cancel()
    }

    // MARK: - Configuration

    func configure() {
        guard !isConfigured else { return }
        guard AppConstants.Subscription.hasValidRevenueCatAPIKey else {
            isRevenueCatAvailable = false
            lastErrorMessage = nil
            return
        }

        #if DEBUG
        Purchases.logLevel = .debug
        #endif
        Purchases.configure(withAPIKey: AppConstants.Subscription.revenueCatAPIKey)
        isConfigured = true
        isRevenueCatAvailable = true
        lastErrorMessage = nil
        startCustomerInfoUpdates()
    }

    // MARK: - Check Subscription

    func checkSubscriptionStatus() async {
        guard canMakePurchases else { return }
        lastErrorMessage = nil
        isLoading = true
        defer { isLoading = false }

        do {
            let customerInfo = try await Purchases.shared.customerInfo()
            applyCustomerInfo(customerInfo)
        } catch {
            lastErrorMessage = error.localizedDescription
            logger.error("Failed to check subscription: \(error.localizedDescription, privacy: .public)")
        }
    }

    // MARK: - Purchase

    func purchase(_ package: Package) async -> Bool {
        guard canMakePurchases else { return false }
        lastErrorMessage = nil
        isLoading = true
        defer { isLoading = false }

        do {
            let result = try await Purchases.shared.purchase(package: package)

            guard !result.userCancelled else { return false }

            applyCustomerInfo(result.customerInfo)

            if hasFullAccess {
                return true
            }

            return await refreshCustomerInfoAfterTransaction(shouldSyncPurchases: false)
        } catch {
            lastErrorMessage = error.localizedDescription
            logger.error("Failed to purchase subscription: \(error.localizedDescription, privacy: .public)")
            return false
        }
    }

    // MARK: - Restore

    func restorePurchases() async -> Bool {
        guard canMakePurchases else { return false }
        lastErrorMessage = nil
        isLoading = true
        defer { isLoading = false }

        do {
            let customerInfo = try await Purchases.shared.restorePurchases()
            applyCustomerInfo(customerInfo)

            if hasFullAccess {
                return true
            }

            return await refreshCustomerInfoAfterTransaction(shouldSyncPurchases: true)
        } catch {
            lastErrorMessage = error.localizedDescription
            logger.error("Failed to restore purchases: \(error.localizedDescription, privacy: .public)")
            return false
        }
    }

    private func startCustomerInfoUpdates() {
        guard customerInfoUpdatesTask == nil else { return }

        customerInfoUpdatesTask = Task { [weak self] in
            for await customerInfo in Purchases.shared.customerInfoStream {
                guard !Task.isCancelled else { return }
                self?.applyCustomerInfo(customerInfo)
            }
        }
    }

    private func refreshCustomerInfoAfterTransaction(shouldSyncPurchases: Bool) async -> Bool {
        let retryDelays: [UInt64] = [0, 500_000_000, 1_000_000_000]

        for (index, delay) in retryDelays.enumerated() {
            if delay > 0 {
                try? await Task.sleep(nanoseconds: delay)
            }

            do {
                let customerInfo: CustomerInfo

                if shouldSyncPurchases && index == 0 {
                    customerInfo = try await Purchases.shared.syncPurchases()
                } else {
                    customerInfo = try await Purchases.shared.customerInfo()
                }

                applyCustomerInfo(customerInfo)

                if hasFullAccess {
                    return true
                }
            } catch {
                lastErrorMessage = error.localizedDescription
                logger.error("Failed to refresh subscription state: \(error.localizedDescription, privacy: .public)")
            }
        }

        return hasFullAccess
    }

    private func applyCustomerInfo(_ customerInfo: CustomerInfo) {
        lastErrorMessage = nil
        let entitlement = customerInfo.entitlements[AppConstants.Subscription.entitlementID]
        let activeKnownProducts = customerInfo.activeSubscriptions
            .intersection(AppConstants.Subscription.productIDs)
        let activeProductID = activeKnownProducts.first
        let fallbackSubscriptionInfo = activeProductID.flatMap { customerInfo.subscriptionsByProductIdentifier[$0] }

        let isActive = entitlement?.isActive == true || !activeKnownProducts.isEmpty
        let periodType = entitlement?.periodType ?? fallbackSubscriptionInfo?.periodType
        let expirationDate = entitlement?.expirationDate ?? activeProductID.flatMap {
            customerInfo.expirationDate(forProductIdentifier: $0)
        }
        let isTrial = isActive && periodType == .trial

        isTrialActive = isTrial
        isSubscribed = isActive && !isTrial
        trialExpirationDate = isTrial ? expirationDate : nil
    }
}
