import SwiftUI
import SwiftData
import UIKit
import CoreText

@main
struct KinnaApp: App {
    @State private var subscriptionManager = SubscriptionManager.shared

    init() {
        // kCream = 0xFAF7F2
        let creamColor = UIColor(red: 250/255, green: 247/255, blue: 242/255, alpha: 1)

        let navAppearance = UINavigationBarAppearance()
        navAppearance.configureWithOpaqueBackground()
        navAppearance.backgroundColor = creamColor
        navAppearance.shadowColor = .clear
        UINavigationBar.appearance().standardAppearance = navAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navAppearance
        UINavigationBar.appearance().compactAppearance = navAppearance

        // Fix: Default nav-bar button tint — prevents gray flash on sheet toolbar items
        UINavigationBar.appearance().tintColor = UIColor(red: 196/255, green: 120/255, blue: 90/255, alpha: 1) // kTerra

        // Pre-warm custom fonts to avoid typing freeze on first use
        for fontName in ["DM Sans", "Fraunces"] {
            if let font = UIFont(name: fontName, size: 14) {
                let _ = font.lineHeight // force font metrics to load
            }
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(subscriptionManager)
                .task {
                    subscriptionManager.configure()
                    await subscriptionManager.checkSubscriptionStatus()
                }
        }
        .modelContainer(for: [
            Baby.self,
            DailyLog.self,
            GrowthRecord.self,
            VaccinationRecord.self,
            AllergyLog.self,
            MilestoneProgress.self
        ])
    }
}
