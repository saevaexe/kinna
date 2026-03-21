import SwiftUI
import SwiftData
import UIKit

struct ContentView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @Environment(SubscriptionManager.self) private var subscriptionManager
    @Query(sort: \Baby.createdAt) private var babies: [Baby]
    @Query(sort: \VaccinationRecord.scheduledDate) private var vaccinationRecords: [VaccinationRecord]

    @State private var showSplash = true
    @State private var onboardingStarted = false

    var body: some View {
        ZStack {
            Group {
                if !hasCompletedOnboarding {
                    OnboardingView()
                        .onAppear { onboardingStarted = true }
                } else {
                    HomeView()
                }
            }
            if showSplash {
                splashView
                    .transition(.opacity)
            }
        }
        .background(Color.kCream.ignoresSafeArea())
        .onAppear {
            setWindowBackground()
            if !hasCompletedOnboarding { preWarmKeyboard() }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                if !hasCompletedOnboarding && !babies.isEmpty {
                    hasCompletedOnboarding = true
                }
                withAnimation(.easeOut(duration: 0.5)) {
                    showSplash = false
                }
            }
        }
        .onChange(of: babies.isEmpty) { _, isEmpty in
            // iCloud sync: baby data arrived after splash — skip onboarding only if user hasn't started it
            if !hasCompletedOnboarding && !isEmpty && !onboardingStarted {
                hasCompletedOnboarding = true
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

    // MARK: - Splash

    private var splashView: some View {
        VStack(spacing: 14) {
            Spacer()

            Image("BrandIcon")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .clipShape(RoundedRectangle(cornerRadius: 20))

            Text("Kinna")
                .font(.kinnaDisplay(28, weight: .semibold))
                .foregroundStyle(.kChar)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.kCream.ignoresSafeArea())
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
    private func preWarmKeyboard() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else { return }
        let field = UITextField(frame: CGRect(x: -1000, y: -1000, width: 0, height: 0))
        field.autocorrectionType = .no
        field.spellCheckingType = .no
        field.text = " "
        window.addSubview(field)
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
