import SwiftUI
import SwiftData
import UIKit

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
        .background(Color.kCream.ignoresSafeArea())
        .onAppear {
            setWindowBackground()
            if !hasCompletedOnboarding { preWarmKeyboard() }
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

    /// Sets UIWindow background to cream so iOS app launch/close animations don't show white.
    private func setWindowBackground() {
        let cream = UIColor(red: 250/255, green: 247/255, blue: 242/255, alpha: 1)
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
        windowScene.windows.forEach { $0.backgroundColor = cream }
    }

    /// Pre-warms the text input infrastructure without showing the keyboard.
    /// Creates a UITextField off-screen to force UIKit to load text input classes/fonts,
    /// then removes it — no becomeFirstResponder, so no visible keyboard.
    private func preWarmKeyboard() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else { return }
        let field = UITextField(frame: CGRect(x: -1000, y: -1000, width: 0, height: 0))
        field.autocorrectionType = .no
        field.spellCheckingType = .no
        field.text = " "  // trigger text layout engine
        window.addSubview(field)
        // Force layout so UIKit loads text input classes
        field.layoutIfNeeded()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            field.removeFromSuperview()
        }
    }
}

#Preview {
    ContentView()
        .environment(SubscriptionManager.shared)
        .modelContainer(for: [Baby.self, DailyLog.self, GrowthRecord.self, VaccinationRecord.self, AllergyLog.self, MilestoneProgress.self], inMemory: true)
}
