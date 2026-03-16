import SwiftUI
import SwiftData

struct SettingsView: View {
    @AppStorage("notificationEnabled") private var notificationEnabled = true
    @AppStorage("showGrowthChartsInTracking") private var showGrowthChartsInTracking = true
    @AppStorage("parentName") private var parentName = ""
    @AppStorage("parentRole") private var parentRoleRaw = "mother"
    @Query(sort: \Baby.createdAt) private var babies: [Baby]
    @Query(sort: \VaccinationRecord.scheduledDate) private var vaccinationRecords: [VaccinationRecord]
    @Environment(SubscriptionManager.self) private var subscriptionManager
    @State private var presentedLegalPage: LegalWebPage?
    @State private var showPaywall = false

    private var baby: Baby? { babies.first }

    private var isEN: Bool { Locale.current.language.languageCode?.identifier != "tr" }

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Back button + Header
                HStack(alignment: .top) {
                    Button { dismiss() } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundStyle(.kMid)
                            .padding(10)
                    }
                    .padding(.leading, -10)

                    Spacer()
                }
                .padding(.bottom, 4)

                VStack(alignment: .leading, spacing: 4) {
                    Text(String(localized: "settings_eyebrow", defaultValue: "ACCOUNT & PREFERENCES"))
                        .font(.kinnaBody(9))
                        .foregroundStyle(.kMuted)
                        .tracking(1.5)

                    Text(String(localized: "settings_title", defaultValue: "Settings"))
                        .font(.kinnaDisplayItalic(26))
                        .foregroundStyle(.kChar)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 20)

                // Baby profile card
                if let baby {
                    profileCard(baby)
                        .padding(.bottom, 16)
                }

                // Parent role
                settingsSection(isEN ? "My Role" : "Rolüm") {
                    settingsRow(icon: "person.fill", title: isEN ? "Role" : "Rol") {
                        Picker("", selection: $parentRoleRaw) {
                            Text(isEN ? "Mother" : "Anne").tag("mother")
                            Text(isEN ? "Father" : "Baba").tag("father")
                            Text(isEN ? "Caregiver" : "Bakıcı").tag("caregiver")
                        }
                        .tint(.kTerra)
                    }
                }
                .padding(.bottom, 10)

                // Notifications
                settingsSection(String(localized: "settings_notifications", defaultValue: "Notifications")) {
                    settingsRow(icon: "bell.fill", title: String(localized: "settings_daily_reminder", defaultValue: "Daily Reminder")) {
                        Toggle("", isOn: $notificationEnabled)
                            .tint(.kSage)
                            .onChange(of: notificationEnabled) { _, newValue in
                                Task {
                                    if newValue {
                                        let granted = await NotificationManager.shared.requestPermission()
                                        if granted {
                                            NotificationManager.shared.scheduleDailyReminder(hour: 9, minute: 0)
                                        } else {
                                            await MainActor.run {
                                                notificationEnabled = false
                                            }
                                        }
                                    } else {
                                        NotificationManager.shared.cancelDailyReminder()
                                    }
                                }
                            }
                    }
                }
                .padding(.bottom, 10)

                settingsSection(isEN ? "Tracking" : "Takip") {
                    settingsRow(
                        icon: "chart.line.uptrend.xyaxis",
                        title: isEN ? "Growth Charts" : "Büyüme Eğrisi"
                    ) {
                        Toggle("", isOn: $showGrowthChartsInTracking)
                            .tint(.kSage)
                    }
                }
                .padding(.bottom, 10)

                // Subscription
                settingsSection(String(localized: "settings_subscription", defaultValue: "Subscription")) {
                    Button {
                        showPaywall = true
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: subscriptionManager.hasFullAccess ? "checkmark.seal.fill" : "star.fill")
                                .font(.system(size: 18))
                                .foregroundStyle(subscriptionManager.hasFullAccess ? .kSageDark : .kTerra)

                            VStack(alignment: .leading, spacing: 1) {
                                Text(subscriptionManager.hasFullAccess
                                     ? "Kinna Premium"
                                     : String(localized: "settings_upgrade", defaultValue: "Upgrade to Premium"))
                                    .font(.kinnaBodyMedium(13))
                                    .foregroundStyle(subscriptionManager.hasFullAccess ? .kChar : .kTerra)

                                Text(subscriptionManager.hasFullAccess
                                     ? String(localized: "settings_pro_active_label", defaultValue: "Active")
                                     : String(localized: "settings_upgrade_sub", defaultValue: "Access all features"))
                                    .font(.kinnaBody(11))
                                    .foregroundStyle(subscriptionManager.hasFullAccess ? .kSageDark : .kMid)
                            }

                            Spacer()

                            Image(systemName: "chevron.right")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(.kLight)
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
                .padding(.bottom, 10)

                // Legal
                settingsSection(String(localized: "settings_legal", defaultValue: "Legal")) {
                    VStack(spacing: 0) {
                        legalWebRow(
                            icon: "doc.text.fill",
                            title: isEN ? "Terms of Use" : "Kullanım Koşulları",
                            page: .terms
                        )

                        Rectangle()
                            .fill(Color.kPale)
                            .frame(height: 1)
                            .padding(.vertical, 12)

                        legalWebRow(
                            icon: "hand.raised.fill",
                            title: isEN ? "Privacy Policy" : "Gizlilik Politikası",
                            page: .privacy
                        )

                        Rectangle()
                            .fill(Color.kPale)
                            .frame(height: 1)
                            .padding(.vertical, 12)

                        legalWebRow(
                            icon: "questionmark.circle.fill",
                            title: isEN ? "Support" : "Destek",
                            page: .support
                        )
                    }
                }
                .padding(.bottom, 10)

                // About
                settingsSection(String(localized: "settings_about", defaultValue: "About")) {
                    VStack(spacing: 0) {
                        HStack {
                            Text(String(localized: "settings_version", defaultValue: "Version"))
                                .font(.kinnaBody(13))
                                .foregroundStyle(.kChar)
                            Spacer()
                            Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0")
                                .font(.kinnaBody(13))
                                .foregroundStyle(.kLight)
                        }
                        .padding(.bottom, 12)

                        Rectangle()
                            .fill(Color.kPale)
                            .frame(height: 1)
                            .padding(.bottom, 12)

                        Text(String(localized: "settings_disclaimer", defaultValue: "This app does not replace medical advice. Always consult your doctor for health concerns."))
                            .font(.kinnaBody(11))
                            .foregroundStyle(.kMid)
                            .lineSpacing(2)
                    }
                }

                // WHO reference
                Text(isEN
                    ? "Content based on WHO guidelines. Vaccination schedule follows the Turkey immunization program."
                    : "İçeriklerimiz WHO rehberleri ve T.C. Sağlık Bakanlığı protokolleri temel alınarak hazırlanmıştır.")
                    .font(.kinnaBody(9))
                    .foregroundStyle(.kMuted)
                    .lineSpacing(2)
                    .padding(.top, 12)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 20)
        }
        .background(Color.kCream.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .task {
            await NotificationManager.shared.checkAuthorization()
            if notificationEnabled && NotificationManager.shared.isDenied {
                notificationEnabled = false
            }
        }
        .onChange(of: parentRoleRaw) { _, _ in
            Task {
                await syncRoleAwareNotifications()
            }
        }
        .sheet(item: $presentedLegalPage) { page in
            LegalWebView(page: page)
        }
        .fullScreenCover(isPresented: $showPaywall) {
            NavigationStack {
                PaywallView()
            }
            .environment(subscriptionManager)
            .presentationBackground(Color.kCream)
        }
    }

    private func legalWebRow(icon: String, title: String, page: LegalWebPage) -> some View {
        Button {
            presentedLegalPage = page
        } label: {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundStyle(.kMid)
                    .frame(width: 20)
                Text(title)
                    .font(.kinnaBody(13))
                    .foregroundStyle(.kChar)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.kLight)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private func syncRoleAwareNotifications() async {
        await NotificationManager.shared.checkAuthorization()

        if notificationEnabled && NotificationManager.shared.isAuthorized {
            NotificationManager.shared.scheduleDailyReminder(hour: 9, minute: 0)
        }

        await NotificationManager.shared.syncVaccineReminders(
            birthDate: baby?.birthDate,
            scheduledRecords: vaccinationRecords,
            hasFullAccess: subscriptionManager.hasFullAccess
        )
    }

    // MARK: - Profile Card

    private func profileCard(_ baby: Baby) -> some View {
        HStack(spacing: 14) {
            RoundedRectangle(cornerRadius: 14)
                .fill(
                    LinearGradient(
                        colors: [Color.kTerraLight.opacity(0.4), Color.kPale.opacity(0.5)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 48, height: 48)
                .overlay {
                    Text(baby.gender == .female ? "👧" : baby.gender == .male ? "👦" : "👶")
                        .font(.system(size: 22))
                }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(baby.name)
                    .font(.kinnaBodyMedium(15))
                    .foregroundStyle(.kChar)
                Text(baby.ageDescription)
                    .font(.kinnaBody(12))
                    .foregroundStyle(.kMid)
            }
            
            Spacer()
        }
        .padding(16)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.kPale, lineWidth: 1)
        )
    }

    // MARK: - Section

    private func settingsSection<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title.uppercased())
                .font(.kinnaBodyMedium(10))
                .foregroundStyle(.kLight)
                .tracking(1.5)

            VStack {
                content()
            }
            .padding(16)
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.kPale, lineWidth: 1)
            )
        }
    }

    // MARK: - Row

    private func settingsRow<Trailing: View>(icon: String, title: String, @ViewBuilder trailing: () -> Trailing) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundStyle(.kMid)
                .frame(width: 20)

            Text(title)
                .font(.kinnaBody(13))
                .foregroundStyle(.kChar)

            Spacer()

            trailing()
        }
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
    .environment(SubscriptionManager.shared)
    .modelContainer(for: [Baby.self], inMemory: true)
}
