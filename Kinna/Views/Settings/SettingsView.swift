import SwiftUI
import SwiftData

struct SettingsView: View {
    @AppStorage("preferredTheme") private var preferredTheme = 0
    @AppStorage("notificationEnabled") private var notificationEnabled = true
    @AppStorage("parentName") private var parentName = ""
    @Query private var babies: [Baby]
    @Environment(SubscriptionManager.self) private var subscriptionManager
    @State private var presentedLegalPage: LegalWebPage?

    private var baby: Baby? { babies.first }

    private var isEN: Bool { Locale.current.language.languageCode?.identifier != "tr" }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Header
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
                .padding(.top, 12)
                .padding(.bottom, 20)

                // Baby profile card
                if let baby {
                    profileCard(baby)
                        .padding(.bottom, 16)
                }

                // Appearance
                settingsSection(String(localized: "settings_appearance", defaultValue: "Appearance")) {
                    settingsRow(icon: "paintpalette.fill", title: String(localized: "settings_theme", defaultValue: "Theme")) {
                        Picker("", selection: $preferredTheme) {
                            Text(String(localized: "settings_theme_system", defaultValue: "System")).tag(0)
                            Text(String(localized: "settings_theme_light", defaultValue: "Light")).tag(1)
                            Text(String(localized: "settings_theme_dark", defaultValue: "Dark")).tag(2)
                        }
                        .tint(.kMid)
                    }
                }
                .padding(.bottom, 10)

                // Notifications
                settingsSection(String(localized: "settings_notifications", defaultValue: "Notifications")) {
                    settingsRow(icon: "bell.fill", title: String(localized: "settings_daily_reminder", defaultValue: "Daily Reminder")) {
                        Toggle("", isOn: $notificationEnabled)
                            .tint(.kSage)
                            .onChange(of: notificationEnabled) { _, newValue in
                                if newValue {
                                    NotificationManager.shared.scheduleDailyReminder(hour: 9, minute: 0)
                                } else {
                                    NotificationManager.shared.cancelDailyReminder()
                                }
                            }
                    }
                }
                .padding(.bottom, 10)

                // Subscription
                settingsSection(String(localized: "settings_subscription", defaultValue: "Subscription")) {
                    NavigationLink {
                        PaywallView(entryPoint: .navigation)
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
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $presentedLegalPage) { page in
            LegalWebView(page: page)
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
