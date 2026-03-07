import SwiftUI

struct SettingsView: View {
    @AppStorage("preferredTheme") private var preferredTheme = 0
    @AppStorage("notificationEnabled") private var notificationEnabled = true
    @AppStorage("notificationHour") private var notificationHour = 9
    @AppStorage("notificationMinute") private var notificationMinute = 0
    @Environment(SubscriptionManager.self) private var subscriptionManager

    var body: some View {
        List {
            Section(String(localized: "settings_appearance", defaultValue: "Appearance")) {
                Picker(String(localized: "settings_theme", defaultValue: "Theme"), selection: $preferredTheme) {
                    Text(String(localized: "settings_theme_system", defaultValue: "System")).tag(0)
                    Text(String(localized: "settings_theme_light", defaultValue: "Light")).tag(1)
                    Text(String(localized: "settings_theme_dark", defaultValue: "Dark")).tag(2)
                }
            }

            Section(String(localized: "settings_notifications", defaultValue: "Notifications")) {
                Toggle(String(localized: "settings_daily_reminder", defaultValue: "Daily Reminder"), isOn: $notificationEnabled)
                    .onChange(of: notificationEnabled) { _, newValue in
                        if newValue {
                            NotificationManager.shared.scheduleDailyReminder(hour: notificationHour, minute: notificationMinute)
                        } else {
                            NotificationManager.shared.cancelDailyReminder()
                        }
                    }
            }

            Section(String(localized: "settings_subscription", defaultValue: "Subscription")) {
                if subscriptionManager.hasFullAccess {
                    Label(String(localized: "settings_pro_active", defaultValue: "Kinna Pro Active"), systemImage: "checkmark.seal.fill")
                        .foregroundStyle(.kSage)
                } else {
                    NavigationLink {
                        PaywallView()
                    } label: {
                        Label(String(localized: "settings_upgrade", defaultValue: "Upgrade to Pro"), systemImage: "star.fill")
                            .foregroundStyle(.kTerra)
                    }
                }
            }

            Section(String(localized: "settings_about", defaultValue: "About")) {
                HStack {
                    Text(String(localized: "settings_version", defaultValue: "Version"))
                    Spacer()
                    Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0")
                        .foregroundStyle(.secondary)
                }

                Text(String(localized: "settings_disclaimer", defaultValue: "This app does not replace medical advice. Always consult your doctor for health concerns."))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle(String(localized: "settings_title", defaultValue: "Settings"))
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
    .environment(SubscriptionManager.shared)
}
