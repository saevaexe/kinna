import SwiftUI

struct ContentView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @AppStorage("preferredTheme") private var preferredTheme = 0
    @Environment(SubscriptionManager.self) private var subscriptionManager

    private var colorScheme: ColorScheme? {
        switch preferredTheme {
        case 1: .light
        case 2: .dark
        default: nil
        }
    }

    var body: some View {
        Group {
            if !hasCompletedOnboarding {
                OnboardingView()
            } else {
                HomeView()
            }
        }
        .preferredColorScheme(colorScheme)
    }
}

#Preview {
    ContentView()
        .environment(SubscriptionManager.shared)
        .modelContainer(for: [Baby.self, DailyLog.self, VaccinationRecord.self, AllergyLog.self, MilestoneProgress.self], inMemory: true)
}
