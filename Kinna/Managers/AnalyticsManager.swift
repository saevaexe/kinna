import Foundation
import PostHog
import AdServices

enum AnalyticsManager {

    // MARK: - Configuration

    static func configure() {
        let config = PostHogConfig(
            apiKey: "phc_wbnGFzG4r8pnZETApjKiHpy9U6jVxBDSQeVWMBDZMxhK",
            host: "https://eu.i.posthog.com"
        )

        // Privacy: disable everything automatic
        config.captureApplicationLifecycleEvents = false
        config.captureScreenViews = false
        config.personProfiles = .identifiedOnly

        PostHogSDK.shared.setup(config)
    }

    // MARK: - Apple Search Ads Attribution

    static func trackSearchAdsAttribution() {
        Task {
            do {
                let token = try AAAttribution.attributionToken()
                PostHogSDK.shared.capture("search_ads_attribution", properties: [
                    "attribution_token": token
                ])
            } catch {
                // No attribution available (organic install or simulator)
            }
        }
    }

    // MARK: - Screen Views

    static func screenViewed(_ screen: Screen) {
        PostHogSDK.shared.capture("screen_viewed", properties: [
            "screen_name": screen.rawValue
        ])
    }

    // MARK: - Feature Usage

    static func featureUsed(_ feature: Feature) {
        PostHogSDK.shared.capture("feature_used", properties: [
            "feature_name": feature.rawValue
        ])
    }

    // MARK: - Paywall

    static func paywallViewed(source: String) {
        PostHogSDK.shared.capture("paywall_viewed", properties: [
            "source": source
        ])
    }

    static func paywallAction(_ action: PaywallAction) {
        PostHogSDK.shared.capture("paywall_action", properties: [
            "action": action.rawValue
        ])
    }

    // MARK: - Subscription

    static func subscriptionStarted(plan: String, trial: Bool) {
        PostHogSDK.shared.capture("subscription_started", properties: [
            "plan": plan,
            "is_trial": trial
        ])
    }

    // MARK: - Onboarding

    static func onboardingStep(_ step: Int, total: Int) {
        PostHogSDK.shared.capture("onboarding_step", properties: [
            "step": step,
            "total_steps": total
        ])
    }

    static func onboardingCompleted() {
        PostHogSDK.shared.capture("onboarding_completed")
    }

    // MARK: - Enums

    enum Screen: String {
        case home
        case tracking
        case milestones
        case vaccines
        case growthCharts = "growth_charts"
        case foodIntro = "food_intro"
        case settings
        case faq
        case sources
        case paywall
    }

    enum Feature: String {
        case feedingTimer = "feeding_timer"
        case sleepTimer = "sleep_timer"
        case bottleLog = "bottle_log"
        case diaperLog = "diaper_log"
        case noteLog = "note_log"
        case weightLog = "weight_log"
        case heightLog = "height_log"
        case vaccineCheck = "vaccine_check"
        case milestoneCheck = "milestone_check"
        case allergyLog = "allergy_log"
        case foodReaction = "food_reaction"
        case sleepInsight = "sleep_insight"
        case breastfeedingInsight = "breastfeeding_insight"
    }

    enum PaywallAction: String {
        case monthlyTapped = "monthly_tapped"
        case yearlyTapped = "yearly_tapped"
        case restoreTapped = "restore_tapped"
        case dismissed
    }
}
