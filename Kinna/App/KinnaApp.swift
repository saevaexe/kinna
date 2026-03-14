import SwiftUI
import SwiftData

@main
struct KinnaApp: App {
    @State private var subscriptionManager = SubscriptionManager.shared

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
