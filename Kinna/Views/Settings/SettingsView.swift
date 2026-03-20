import SwiftUI
import SwiftData

struct SettingsView: View {
    @AppStorage("notificationEnabled") private var notificationEnabled = true
    @AppStorage("showGrowthChartsInTracking") private var showGrowthChartsInTracking = true
    @AppStorage("parentName") private var parentName = ""
    @AppStorage("parentRole") private var parentRoleRaw = "mother"
    @AppStorage("useMetricUnits") private var useMetricUnits = true
    @Query(sort: \Baby.createdAt) private var babies: [Baby]
    @Query(sort: \VaccinationRecord.scheduledDate) private var vaccinationRecords: [VaccinationRecord]
    @Environment(SubscriptionManager.self) private var subscriptionManager
    @State private var presentedLegalPage: LegalWebPage?
    @State private var showPaywall = false

    private var baby: Baby? { babies.first }

    private var isEN: Bool { Locale.current.language.languageCode?.identifier != "tr" }

    private var parentRoleLabel: String {
        switch parentRoleRaw {
        case "mother": return isEN ? "Mother" : "Anne"
        case "father": return isEN ? "Father" : "Baba"
        case "caregiver": return isEN ? "Caregiver" : "Bakıcı"
        default: return ""
        }
    }

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Back button
                HStack {
                    Button { dismiss() } label: {
                        Circle()
                            .fill(Color.kChar.opacity(0.06))
                            .frame(width: 36, height: 36)
                            .overlay {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(.kChar)
                            }
                    }
                    Spacer()
                }
                .padding(.bottom, 12)

                // Header
                VStack(alignment: .leading, spacing: 4) {
                    Text(isEN ? "SETTINGS" : "AYARLAR")
                        .font(.kinnaBodyMedium(10))
                        .foregroundStyle(.kMuted)
                        .tracking(2)

                    Text(isEN ? "Settings" : "Ayarlar")
                        .font(.kinnaDisplayItalic(28))
                        .foregroundStyle(.kChar)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 20)

                // Profile card
                if let baby {
                    profileCard(baby)
                        .padding(.bottom, 16)
                }

                // Subscription
                subscriptionCard
                    .padding(.bottom, 12)

                // Preferences
                settingsSection(isEN ? "Preferences" : "Tercihler") {
                    VStack(spacing: 0) {
                        iconRow(
                            icon: "person.fill",
                            iconBg: Color.kTerraLight.opacity(0.5),
                            iconColor: .kTerra,
                            title: isEN ? "Role" : "Rol"
                        ) {
                            Picker("", selection: $parentRoleRaw) {
                                Text(isEN ? "Mother" : "Anne").tag("mother")
                                Text(isEN ? "Father" : "Baba").tag("father")
                                Text(isEN ? "Caregiver" : "Bakıcı").tag("caregiver")
                            }
                            .tint(.kTerra)
                        }

                        sectionDivider

                        iconRow(
                            icon: "bell.fill",
                            iconBg: Color.kSage.opacity(0.15),
                            iconColor: .kSageDark,
                            title: isEN ? "Daily Reminder" : "Günlük Hatırlatma"
                        ) {
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

                        sectionDivider

                        iconRow(
                            icon: "chart.line.uptrend.xyaxis",
                            iconBg: Color.kBlush.opacity(0.6),
                            iconColor: .kTerra,
                            title: isEN ? "Growth Charts" : "Büyüme Eğrisi"
                        ) {
                            Toggle("", isOn: $showGrowthChartsInTracking)
                                .tint(.kSage)
                        }

                        sectionDivider

                        iconRow(
                            icon: "ruler.fill",
                            iconBg: Color.kChar.opacity(0.08),
                            iconColor: .kChar,
                            title: isEN ? "Units" : "Birim"
                        ) {
                            Picker("", selection: $useMetricUnits) {
                                Text("kg / cm").tag(true)
                                Text("lb / in").tag(false)
                            }
                            .tint(.kTerra)
                        }
                    }
                }
                .padding(.bottom, 12)

                // Legal
                settingsSection("LEGAL") {
                    VStack(spacing: 0) {
                        legalRow(
                            icon: "doc.text.fill",
                            title: isEN ? "Terms of Use" : "Kullanım Koşulları",
                            page: .terms
                        )

                        sectionDivider

                        legalRow(
                            icon: "hand.raised.fill",
                            title: isEN ? "Privacy Policy" : "Gizlilik Politikası",
                            page: .privacy
                        )

                        sectionDivider

                        legalRow(
                            icon: "questionmark.circle.fill",
                            title: isEN ? "Support" : "Destek",
                            page: .support
                        )
                    }
                }
                .padding(.bottom, 12)

                // About
                settingsSection(isEN ? "ABOUT" : "HAKKINDA") {
                    VStack(spacing: 0) {
                        HStack {
                            Text(isEN ? "Version" : "Sürüm")
                                .font(.kinnaBody(13))
                                .foregroundStyle(.kChar)
                            Spacer()
                            Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0")
                                .font(.kinnaBodyMedium(13))
                                .foregroundStyle(.kLight)
                        }

                        sectionDivider

                        Text(isEN
                            ? "This app does not replace medical advice. Always consult your doctor for health concerns."
                            : "Bu uygulama doktor tavsiyesinin yerini tutmaz. Sağlık endişeleriniz için her zaman doktorunuza danışın.")
                            .font(.kinnaBody(11))
                            .foregroundStyle(.kMid)
                            .lineSpacing(2)
                    }
                }

                Spacer(minLength: 20)
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

    // MARK: - Profile Card

    private var birthDateFormatted: String {
        guard let baby else { return "" }
        return baby.birthDate.formatted(.dateTime.day().month(.wide).year())
    }

    private var ageSincebirthText: String {
        guard let baby else { return "" }
        let components = Calendar.current.dateComponents([.day], from: baby.birthDate, to: .now)
        let days = components.day ?? 0
        return isEN ? "Born \(days) days ago" : "\(days) gün önce doğdu"
    }

    private var milestoneBadgeText: String {
        guard let baby else { return "" }
        let components = Calendar.current.dateComponents([.year, .month, .day], from: baby.birthDate, to: .now)
        let months = components.month ?? 0
        let days = components.day ?? 0

        let ageLabel = isEN ? "\(months) mo \(days) days" : "\(months) ay \(days) gün"

        if months < 1 {
            return isEN ? "✦ Newborn · \(ageLabel)" : "✦ Yeni bebek · \(ageLabel)"
        } else if months < 6 {
            return isEN ? "✦ Infant · \(ageLabel)" : "✦ Bebek · \(ageLabel)"
        } else if months < 12 {
            return isEN ? "✦ Baby · \(ageLabel)" : "✦ Bebek · \(ageLabel)"
        } else {
            return isEN ? "✦ Toddler · \(ageLabel)" : "✦ Yürümeye başlayan · \(ageLabel)"
        }
    }

    private func profileCard(_ baby: Baby) -> some View {
        HStack(spacing: 16) {
            // Avatar
            RoundedRectangle(cornerRadius: 18)
                .fill(
                    LinearGradient(
                        colors: [Color.kTerraLight.opacity(0.3), Color.kBlush.opacity(0.4)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 64, height: 64)
                .overlay {
                    Text(baby.gender == .female ? "👧" : baby.gender == .male ? "👦" : "👶")
                        .font(.system(size: 30))
                }

            VStack(alignment: .leading, spacing: 4) {
                Text(baby.name)
                    .font(.kinnaDisplay(22, weight: .medium))
                    .foregroundStyle(.kChar)

                HStack(spacing: 6) {
                    Image(systemName: "calendar")
                        .font(.system(size: 11))
                        .foregroundStyle(.kMid)
                    Text("\(birthDateFormatted) · \(ageSincebirthText)")
                        .font(.kinnaBody(12))
                        .foregroundStyle(.kMid)
                }

                Text(milestoneBadgeText)
                    .font(.kinnaBodyMedium(11))
                    .foregroundStyle(.kSageDark)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.kSage.opacity(0.12))
                    .clipShape(Capsule())
            }

            Spacer()
        }
        .padding(18)
        .background(
            LinearGradient(
                colors: [.white, Color.kBlush.opacity(0.15)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.kPale, lineWidth: 1)
        )
    }

    // MARK: - Subscription Card

    private var subscriptionCard: some View {
        Button {
            showPaywall = true
        } label: {
            HStack(spacing: 14) {
                Circle()
                    .fill(subscriptionManager.hasFullAccess
                        ? Color.kSage.opacity(0.15)
                        : Color.kTerraLight.opacity(0.5))
                    .frame(width: 36, height: 36)
                    .overlay {
                        Image(systemName: subscriptionManager.hasFullAccess
                            ? "checkmark.seal.fill"
                            : "star.fill")
                            .font(.system(size: 16))
                            .foregroundStyle(subscriptionManager.hasFullAccess
                                ? .kSageDark
                                : .kTerra)
                    }

                VStack(alignment: .leading, spacing: 2) {
                    Text(subscriptionManager.hasFullAccess
                         ? "Kinna Premium"
                         : (isEN ? "Upgrade to Premium" : "Premium'a Yükselt"))
                        .font(.kinnaBodyMedium(14))
                        .foregroundStyle(subscriptionManager.hasFullAccess ? .kChar : .kTerra)

                    Text(subscriptionManager.hasFullAccess
                         ? (isEN ? "Active" : "Aktif")
                         : (isEN ? "Unlock all features" : "Tüm özelliklere eriş"))
                        .font(.kinnaBody(12))
                        .foregroundStyle(subscriptionManager.hasFullAccess ? .kSageDark : .kMid)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.kLight)
            }
            .padding(16)
            .background(
                subscriptionManager.hasFullAccess
                ? AnyShapeStyle(
                    LinearGradient(
                        colors: [.white, Color.kSage.opacity(0.08)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                : AnyShapeStyle(
                    LinearGradient(
                        colors: [Color.kTerraLight.opacity(0.15), Color.kBlush.opacity(0.3)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(subscriptionManager.hasFullAccess
                        ? Color.kSage.opacity(0.2)
                        : Color.kTerra.opacity(0.2),
                        lineWidth: 1)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    // MARK: - Icon Row

    private func iconRow<Trailing: View>(
        icon: String,
        iconBg: Color,
        iconColor: Color,
        title: String,
        @ViewBuilder trailing: () -> Trailing
    ) -> some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 8)
                .fill(iconBg)
                .frame(width: 30, height: 30)
                .overlay {
                    Image(systemName: icon)
                        .font(.system(size: 13))
                        .foregroundStyle(iconColor)
                }

            Text(title)
                .font(.kinnaBody(14))
                .foregroundStyle(.kChar)

            Spacer()

            trailing()
        }
    }

    // MARK: - Legal Row

    private func legalRow(icon: String, title: String, page: LegalWebPage) -> some View {
        Button {
            presentedLegalPage = page
        } label: {
            HStack(spacing: 12) {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.kChar.opacity(0.05))
                    .frame(width: 30, height: 30)
                    .overlay {
                        Image(systemName: icon)
                            .font(.system(size: 13))
                            .foregroundStyle(.kMid)
                    }

                Text(title)
                    .font(.kinnaBody(14))
                    .foregroundStyle(.kChar)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.kLight)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
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

    // MARK: - Divider

    private var sectionDivider: some View {
        Rectangle()
            .fill(Color.kPale.opacity(0.7))
            .frame(height: 1)
            .padding(.vertical, 12)
            .padding(.leading, 42)
    }

    // MARK: - Helpers

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
}

#Preview {
    NavigationStack {
        SettingsView()
    }
    .environment(SubscriptionManager.shared)
    .modelContainer(for: [Baby.self], inMemory: true)
}
