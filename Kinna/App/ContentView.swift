import SwiftUI
import SwiftData

struct ContentView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @Environment(SubscriptionManager.self) private var subscriptionManager
    @Query(sort: \Baby.createdAt) private var babies: [Baby]
    @Query(sort: \VaccinationRecord.scheduledDate) private var vaccinationRecords: [VaccinationRecord]

    var body: some View {
        Group {
            if !hasCompletedOnboarding {
                OnboardingView()
            } else {
                HomeView()
            }
        }
        .task(id: vaccineReminderSyncKey) {
            await NotificationManager.shared.syncVaccineReminders(
                birthDate: babies.first?.birthDate,
                scheduledRecords: vaccinationRecords,
                hasFullAccess: subscriptionManager.hasFullAccess
            )
        }
    }

    private var vaccineReminderSyncKey: String {
        "\(subscriptionManager.hasFullAccess)-\(babies.first?.birthDate.timeIntervalSinceReferenceDate ?? 0)"
    }
}

#Preview {
    ContentView()
        .environment(SubscriptionManager.shared)
        .modelContainer(for: [Baby.self, DailyLog.self, GrowthRecord.self, VaccinationRecord.self, AllergyLog.self, MilestoneProgress.self], inMemory: true)
}
