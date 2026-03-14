import SwiftUI
import SwiftData
import RevenueCat

struct PaywallView: View {
    enum EntryPoint {
        case modal
        case navigation
        case onboarding
    }

    @Environment(SubscriptionManager.self) private var subscriptionManager
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    @Query(sort: \Baby.createdAt) private var babies: [Baby]
    @Query(sort: \VaccinationRecord.scheduledDate) private var vaccinationRecords: [VaccinationRecord]
    @State private var offering: Offering?
    @State private var selectedPlan: Package?
    @State private var isPurchasing = false
    @State private var errorMessage: String?
    @State private var successMessage: String?
    @State private var presentedLegalPage: LegalWebPage?

    var entryPoint: EntryPoint = .modal

    private var isEN: Bool { Locale.current.language.languageCode?.identifier != "tr" }
    private var canPurchase: Bool { subscriptionManager.canMakePurchases && selectedPlan != nil }
    private var trialDays: Int { MonetizationPolicy.trialLengthDays }
    private var isOnboardingEntry: Bool { entryPoint == .onboarding }
    private var showsDismissButton: Bool { entryPoint != .navigation }
    private var hidesTabBar: Bool { entryPoint == .navigation }
    private var hasActiveAccess: Bool { subscriptionManager.hasFullAccess }
    private var primaryButtonDisabled: Bool { isPurchasing || (!hasActiveAccess && !canPurchase) }
    private var topBadgeText: String {
        hasActiveAccess
        ? (isEN ? "Premium active" : "Premium aktif")
        : trialBadgeText
    }

    private var revenueCatSetupMessage: String {
        isEN
        ? "Premium purchases are not configured in this build yet. Add a RevenueCat public app key to test subscriptions."
        : "Bu build'de premium satın alma henüz ayarlanmış değil. Abonelikleri test etmek için RevenueCat public app key ekleyin."
    }

    private var monthlyPackage: Package? {
        offering?.availablePackages.first { $0.packageType == .monthly }
    }

    private var yearlyPackage: Package? {
        offering?.availablePackages.first { $0.packageType == .annual }
    }

    private var isMonthlySelected: Bool {
        selectedPlan?.identifier == monthlyPackage?.identifier
    }

    private var isYearlySelected: Bool {
        selectedPlan?.identifier == yearlyPackage?.identifier
    }

    private var yearlySavingsFraction: Decimal? {
        guard
            let monthlyPrice = monthlyPackage?.storeProduct.price,
            let yearlyPrice = yearlyPackage?.storeProduct.price
        else {
            return nil
        }

        let annualizedMonthly = monthlyPrice * Decimal(12)
        guard annualizedMonthly > 0, annualizedMonthly > yearlyPrice else {
            return nil
        }

        return (annualizedMonthly - yearlyPrice) / annualizedMonthly
    }

    private var yearlySavingsBadgeText: String? {
        guard let yearlySavingsFraction else { return nil }

        let percent = Int((NSDecimalNumber(decimal: yearlySavingsFraction).doubleValue * 100).rounded())
        guard percent > 0 else { return nil }

        return isEN ? "Save \(percent)%" : "%\(percent) tasarruf"
    }

    private var yearlyMonthlyEquivalentText: String? {
        guard
            let yearlyPackage,
            let pricePerMonth = yearlyPackage.storeProduct.pricePerMonth?.decimalValue,
            let formatted = formatPrice(pricePerMonth, formatter: yearlyPackage.storeProduct.priceFormatter)
        else {
            return nil
        }

        return isEN ? "\(formatted)/mo" : "ayda \(formatted)"
    }

    private var perDayAnchorLine: Text {
        if let formattedPerDayPrice = formattedYearlyPerDayPrice {
            return isEN
            ? Text("Just \(formattedPerDayPrice)/day.")
                .font(.kinnaBody(12, weight: .medium))
                .foregroundStyle(.kChar)
            + Text(" Less than a coffee.")
                .font(.kinnaBody(12))
                .foregroundStyle(.kMid)
            : Text("Günde sadece \(formattedPerDayPrice).")
                .font(.kinnaBody(12, weight: .medium))
                .foregroundStyle(.kChar)
            + Text(" Bir çaydan bile az.")
                .font(.kinnaBody(12))
                .foregroundStyle(.kMid)
        }

        return isEN
        ? Text("Built for the first years.")
            .font(.kinnaBody(12, weight: .medium))
            .foregroundStyle(.kChar)
        + Text(" Keep history, reminders, and guidance in one place.")
            .font(.kinnaBody(12))
            .foregroundStyle(.kMid)
        : Text("İlk yıllar için tasarlandı.")
            .font(.kinnaBody(12, weight: .medium))
            .foregroundStyle(.kChar)
        + Text(" Geçmişi, hatırlatmaları ve rehberliği tek yerde tut.")
            .font(.kinnaBody(12))
            .foregroundStyle(.kMid)
    }

    private var formattedYearlyPerDayPrice: String? {
        guard
            let yearlyPackage,
            let pricePerDay = yearlyPackage.storeProduct.pricePerDay?.decimalValue
        else {
            return nil
        }

        return formatPrice(pricePerDay, formatter: yearlyPackage.storeProduct.priceFormatter)
    }

    private var selectedPlanSubscriptionTerms: String? {
        guard !hasActiveAccess else { return nil }

        guard let package = selectedPlan ?? yearlyPackage ?? monthlyPackage else {
            return nil
        }

        let billingText = billingText(for: package)

        return isEN
        ? "\(trialDays) days free · then \(billingText) · cancel anytime"
        : "\(trialDays) gün ücretsiz · sonra \(billingText) · istediğin zaman iptal"
    }

    private var autoRenewalDisclosure: String? {
        guard !hasActiveAccess else { return nil }

        return isEN
        ? "Payment will be charged to your Apple ID account at confirmation of purchase. Subscription automatically renews unless it is canceled at least 24 hours before the end of the current period. Your account will be charged for renewal within 24 hours prior to the end of the current period. You can manage and cancel your subscriptions in your App Store account settings after purchase."
        : "Ödeme, satın alma onayında Apple Kimliğiniz hesabınıza yansıtılır. Abonelik, mevcut dönemin bitiminden en az 24 saat önce iptal edilmediği sürece otomatik olarak yenilenir. Hesabınızdan mevcut dönemin bitiminden 24 saat önce yenileme ücreti alınır. Satın alma sonrası App Store hesap ayarlarından aboneliklerinizi yönetip iptal edebilirsiniz."
    }

    private var ctaSupportText: String {
        if hasActiveAccess {
            return isEN ? "Your subscription is active" : "Aboneliğiniz aktif"
        }

        return isEN ? "No charge today" : "Bugün ücret alınmaz"
    }

    private var trialBadgeText: String {
        isEN ? "Try \(trialDays) days free" : "\(trialDays) gün ücretsiz dene"
    }

    private var trialDescriptionText: String {
        isEN
        ? "Use every premium feature free for \(trialDays) days.\nThen keep going only if it helps."
        : "\(trialDays) gün boyunca tüm premium özellikler ücretsiz.\nYalnızca sana faydalıysa devam et."
    }

    private var activeDescriptionText: String {
        isEN
        ? "Your premium access is active.\nYou can manage billing, plan changes, and cancellation from App Store settings."
        : "Premium erişimin aktif.\nFaturalandırma, plan değişikliği ve iptali App Store ayarlarından yönetebilirsin."
    }

    private var headerDescriptionText: String {
        hasActiveAccess ? activeDescriptionText : trialDescriptionText
    }

    private var ctaTitle: String {
        if hasActiveAccess {
            return isEN ? "Manage subscription" : "Aboneliği Yönet"
        }

        return isEN ? "Start \(trialDays)-day free trial" : "\(trialDays) gün ücretsiz başla"
    }

    private var headline: some View {
        Group {
            if hasActiveAccess, isEN {
                Text("Premium is\n")
                    .font(.kinnaDisplay(26))
                    .foregroundStyle(.kChar)
                +
                Text("active.")
                    .font(.kinnaDisplayItalic(26))
                    .foregroundStyle(.kTerra)
            } else if hasActiveAccess {
                Text("Kinna Premium\n")
                    .font(.kinnaDisplay(26))
                    .foregroundStyle(.kChar)
                +
                Text("aktif.")
                    .font(.kinnaDisplayItalic(26))
                    .foregroundStyle(.kTerra)
            } else if isEN {
                Text("Don't miss\n")
                    .font(.kinnaDisplay(26))
                    .foregroundStyle(.kChar)
                +
                Text("a moment.")
                    .font(.kinnaDisplayItalic(26))
                    .foregroundStyle(.kTerra)
            } else {
                Text("Bir anı bile\n")
                    .font(.kinnaDisplay(26))
                    .foregroundStyle(.kChar)
                +
                Text("kaçırma.")
                    .font(.kinnaDisplayItalic(26))
                    .foregroundStyle(.kTerra)
            }
        }
    }

    private var activeSummaryCard: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 20))
                .foregroundStyle(.kSageDark)
                .padding(.top, 1)

            VStack(alignment: .leading, spacing: 4) {
                Text(isEN ? "Everything is unlocked" : "Tüm premium özellikler açık")
                    .font(.kinnaBodyMedium(13))
                    .foregroundStyle(.kChar)

                Text(
                    isEN
                    ? "Open App Store subscription settings to change your plan or cancel anytime."
                    : "Planını değiştirmek veya iptal etmek için App Store abonelik ayarlarını aç."
                )
                .font(.kinnaBody(11))
                .foregroundStyle(.kMid)
                .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(
            LinearGradient(colors: [.kBlush, Color.kTerraLight.opacity(0.28)], startPoint: .leading, endPoint: .trailing)
        )
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.kTerra.opacity(0.15), lineWidth: 1)
        )
        .padding(.bottom, 16)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Trial badge
                HStack(spacing: 6) {
                    Circle()
                        .fill(Color(hex: 0x4CAF50))
                        .frame(width: 7, height: 7)
                    Text(topBadgeText)
                        .font(.kinnaBodyMedium(11))
                        .foregroundStyle(.white)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(Color.kChar.opacity(0.75))
                .clipShape(Capsule())
                .padding(.top, 16)
                .padding(.bottom, 20)

                // Headline
                Text("KINNA PREMIUM")
                    .font(.kinnaBodyMedium(10))
                    .foregroundStyle(.kTerra)
                    .tracking(2)
                    .padding(.bottom, 8)

                headline

                Text(headerDescriptionText)
                    .font(.kinnaBody(12, weight: .light))
                    .foregroundStyle(.kMid)
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
                    .padding(.top, 6)
                    .padding(.bottom, 20)

                if hasActiveAccess {
                    activeSummaryCard
                } else {
                    // Plan cards
                    HStack(spacing: 8) {
                        planCard(
                            title: isEN ? "MONTHLY" : "AYLIK",
                            price: monthlyPackage?.localizedPriceString ?? "—",
                            unit: isEN ? "/ mo" : "/ ay",
                            saving: nil,
                            badge: nil,
                            isSelected: isMonthlySelected
                        ) {
                            selectedPlan = monthlyPackage
                        }

                        planCard(
                            title: isEN ? "YEARLY" : "YILLIK",
                            price: yearlyPackage?.localizedPriceString ?? "—",
                            unit: isEN ? "/ yr" : "/ yıl",
                            saving: yearlyMonthlyEquivalentText,
                            badge: yearlySavingsBadgeText,
                            isSelected: isYearlySelected || (!isMonthlySelected && yearlyPackage != nil)
                        ) {
                            selectedPlan = yearlyPackage
                        }
                    }
                    .padding(.horizontal, 4)
                    .padding(.bottom, 14)

                    // Per-day reframe
                    HStack(spacing: 10) {
                        Text("☕️")
                            .font(.system(size: 18))
                        perDayAnchorLine
                    }
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        LinearGradient(colors: [.kBlush, Color.kTerraLight.opacity(0.3)], startPoint: .leading, endPoint: .trailing)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.kTerra.opacity(0.15), lineWidth: 1)
                    )
                    .padding(.bottom, 16)
                }

                // Features
                VStack(spacing: 8) {
                    featureRow(
                        isEN ? "Vaccine reminders + unlimited foods" : "Aşı hatırlatmaları + sınırsız besin",
                        sub: hasActiveAccess ? nil : (isEN ? "Free includes 5 foods and manual vaccines" : "Ücretsiz planda 5 besin ve manuel aşı kaydı")
                    )
                    featureRow(
                        isEN ? "All months + Home cards" : "Tüm aylar ve Home kartları",
                        sub: hasActiveAccess ? nil : (isEN ? "Free includes this month and 1 card" : "Ücretsiz planda yalnızca bu ay ve 1 kart")
                    )
                    featureRow(
                        isEN ? "Full tracking history" : "Tam takip geçmişi",
                        sub: hasActiveAccess ? nil : (isEN ? "Free includes the last 7 days" : "Ücretsiz planda son 7 gün")
                    )
                    featureRow(
                        isEN ? "All data on your device" : "Tüm veriler cihazında",
                        sub: hasActiveAccess ? nil : (isEN ? "Private & secure" : "Özel ve güvenli")
                    )
                }
                .padding(.bottom, 20)

                // CTA
                Button {
                    if hasActiveAccess {
                        manageSubscription()
                    } else {
                        Task { await purchase() }
                    }
                } label: {
                    if isPurchasing {
                        ProgressView()
                            .tint(.white)
                            .frame(maxWidth: .infinity)
                            .padding(16)
                    } else {
                        Text(ctaTitle)
                            .font(.kinnaBodyMedium(15))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(16)
                    }
                }
                .background(Color.kTerra)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: .kTerra.opacity(0.4), radius: 14, y: 6)
                .disabled(primaryButtonDisabled)
                .padding(.bottom, 8)

                Text(ctaSupportText)
                    .font(.kinnaBodyMedium(11))
                    .foregroundStyle(.kSageDark)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 12)
                    .padding(.bottom, 6)

                if let selectedPlanSubscriptionTerms {
                    Text(selectedPlanSubscriptionTerms)
                        .font(.kinnaBody(10))
                        .foregroundStyle(.kMid)
                        .multilineTextAlignment(.center)
                        .lineSpacing(2)
                        .padding(.horizontal, 12)
                        .padding(.bottom, 6)
                }

                if let autoRenewalDisclosure {
                    Text(autoRenewalDisclosure)
                        .font(.kinnaBody(10))
                        .foregroundStyle(.kMid)
                        .multilineTextAlignment(.center)
                        .lineSpacing(2)
                        .padding(.horizontal, 12)
                        .padding(.bottom, 10)
                }

                HStack(spacing: 14) {
                    Button {
                        presentedLegalPage = .terms
                    } label: {
                        Text(isEN ? "Terms of Use" : "Kullanım Koşulları")
                            .font(.kinnaBody(11))
                            .foregroundStyle(.kMid)
                            .underline()
                    }
                    .buttonStyle(.plain)

                    Circle()
                        .fill(Color.kPale)
                        .frame(width: 3, height: 3)

                    Button {
                        presentedLegalPage = .privacy
                    } label: {
                        Text(isEN ? "Privacy Policy" : "Gizlilik Politikası")
                            .font(.kinnaBody(11))
                            .foregroundStyle(.kMid)
                            .underline()
                    }
                    .buttonStyle(.plain)
                }
                .padding(.bottom, 10)

                if isOnboardingEntry {
                    Button {
                        dismiss()
                    } label: {
                        Text(isEN ? "Explore Kinna first" : "Önce Kinna'yı keşfedeyim")
                            .font(.kinnaBody(12))
                            .foregroundStyle(.kMid)
                    }
                    .padding(.bottom, 8)
                }

                if !hasActiveAccess {
                    Button {
                        Task { await restorePurchases() }
                    } label: {
                        Text(isEN ? "Restore purchases" : "Satın almayı geri yükle")
                            .font(.kinnaBodyMedium(11))
                            .foregroundStyle(subscriptionManager.canMakePurchases ? .kTerra : .kMid)
                            .underline()
                    }
                    .disabled(isPurchasing)
                    .padding(.bottom, 20)
                }

                if let successMessage {
                    Text(successMessage)
                        .font(.kinnaBody(11))
                        .foregroundStyle(.kSageDark)
                        .multilineTextAlignment(.center)
                        .padding(.top, 4)
                }

                if let errorMessage {
                    Text(errorMessage)
                        .font(.kinnaBody(11))
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.center)
                        .padding(.top, 4)
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
        .background(Color.kCream.ignoresSafeArea())
        .toolbar(hidesTabBar ? .hidden : .visible, for: .tabBar)
        .sheet(item: $presentedLegalPage) { page in
            LegalWebView(page: page)
        }
        .task {
            await loadOffering()
            await subscriptionManager.checkSubscriptionStatus()
        }
        .onChange(of: subscriptionManager.hasFullAccess) { _, hasAccess in
            Task {
                await syncVaccineReminders()
            }
            if hasAccess { dismiss() }
        }
        .onChange(of: subscriptionManager.lastErrorMessage) { _, newValue in
            guard let newValue else { return }
            successMessage = nil
            errorMessage = newValue
        }
        .toolbar {
            if showsDismissButton {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(.kMid)
                    }
                }
            }
        }
    }

    // MARK: - Plan Card

    private func planCard(
        title: String, price: String, unit: String,
        saving: String?, badge: String?,
        isSelected: Bool, action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(title)
                    .font(.kinnaBodyMedium(10))
                    .foregroundStyle(isSelected ? .kTerra : .kLight)
                    .tracking(1)

                Text(price)
                    .font(.kinnaDisplay(22))
                    .foregroundStyle(.kChar)

                Text(unit)
                    .font(.kinnaBody(10))
                    .foregroundStyle(.kLight)

                if let saving {
                    Text(saving)
                        .font(.kinnaBodyMedium(10))
                        .foregroundStyle(.kSageDark)
                        .padding(.top, 2)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(isSelected ? Color.kTerraLight.opacity(0.3) : .white)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color.kTerra : Color.kPale, lineWidth: 1.5)
            )
            .overlay(alignment: .top) {
                if let badge {
                    Text(badge)
                        .font(.kinnaBodyMedium(9))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 9)
                        .padding(.vertical, 3)
                        .background(Color.kTerra)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .offset(y: -9)
                }
            }
        }
    }

    // MARK: - Feature Row

    private func featureRow(_ text: String, sub: String?) -> some View {
        HStack(alignment: .top, spacing: 10) {
            RoundedRectangle(cornerRadius: 6)
                .fill(Color.kSage)
                .frame(width: 18, height: 18)
                .overlay {
                    Text("✓")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(.white)
                }
                .padding(.top, 2)

            VStack(alignment: .leading, spacing: 1) {
                Text(text)
                    .font(.kinnaBody(12))
                    .foregroundStyle(.kChar)
                    .fixedSize(horizontal: false, vertical: true)

                if let sub {
                    Text(sub)
                        .font(.kinnaBody(11))
                        .foregroundStyle(.kLight)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func formatPrice(_ price: Decimal, formatter: NumberFormatter?) -> String? {
        guard let formatter else {
            return nil
        }

        if let copy = formatter.copy() as? NumberFormatter {
            return copy.string(from: price as NSDecimalNumber)
        }

        return formatter.string(from: price as NSDecimalNumber)
    }

    private func billingText(for package: Package) -> String {
        let price = package.localizedPriceString

        guard let period = package.storeProduct.subscriptionPeriod else {
            return price
        }

        let unitText = localizedBillingUnit(for: period)
        return "\(price)/\(unitText)"
    }

    private func localizedBillingUnit(for period: SubscriptionPeriod) -> String {
        let value = period.value

        switch period.unit {
        case .day:
            return localizedUnit(base: isEN ? "day" : "gün", plural: isEN ? "days" : "gün", value: value)
        case .week:
            return localizedUnit(base: isEN ? "week" : "hafta", plural: isEN ? "weeks" : "hafta", value: value)
        case .month:
            return localizedUnit(base: isEN ? "mo" : "ay", plural: isEN ? "mo" : "ay", value: value)
        case .year:
            return localizedUnit(base: isEN ? "yr" : "yıl", plural: isEN ? "yr" : "yıl", value: value)
        @unknown default:
            return isEN ? "period" : "dönem"
        }
    }

    private func localizedUnit(base: String, plural: String, value: Int) -> String {
        guard value > 1 else { return base }
        return "\(value) \(plural)"
    }

    // MARK: - Network

    private func loadOffering() async {
        guard subscriptionManager.canMakePurchases else {
            errorMessage = revenueCatSetupMessage
            return
        }

        do {
            let offerings = try await Purchases.shared.offerings()
            offering = offerings.current
            selectedPlan = yearlyPackage ?? monthlyPackage ?? offering?.availablePackages.first
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func purchase() async {
        guard subscriptionManager.canMakePurchases else {
            errorMessage = revenueCatSetupMessage
            successMessage = nil
            return
        }

        guard let selectedPlan else { return }
        isPurchasing = true
        defer { isPurchasing = false }
        errorMessage = nil
        successMessage = nil

        let purchaseSucceeded = await subscriptionManager.purchase(selectedPlan)
        await syncVaccineReminders()
        if !purchaseSucceeded && !subscriptionManager.hasFullAccess {
            errorMessage = subscriptionManager.lastErrorMessage
        }
    }

    private func restorePurchases() async {
        guard subscriptionManager.canMakePurchases else {
            errorMessage = revenueCatSetupMessage
            successMessage = nil
            return
        }

        let hadActiveAccessBeforeRestore = subscriptionManager.hasFullAccess
        errorMessage = nil
        successMessage = nil

        let restoreSucceeded = await subscriptionManager.restorePurchases()
        await syncVaccineReminders()
        if restoreSucceeded && subscriptionManager.hasFullAccess {
            successMessage = hadActiveAccessBeforeRestore
                ? (isEN ? "Your subscription is already active." : "Aboneliğiniz zaten aktif.")
                : (isEN ? "Your subscription has been restored." : "Aboneliğiniz geri yüklendi.")
            return
        }

        if !restoreSucceeded && !subscriptionManager.hasFullAccess {
            errorMessage = subscriptionManager.lastErrorMessage ?? (isEN
                ? "No active subscription could be restored."
                : "Aktif bir abonelik geri yüklenemedi.")
        }
    }

    private func manageSubscription() {
        successMessage = nil
        errorMessage = nil
        openURL(AppConstants.Subscription.manageSubscriptionsURL)
    }

    private func syncVaccineReminders() async {
        await NotificationManager.shared.syncVaccineReminders(
            birthDate: babies.first?.birthDate,
            scheduledRecords: vaccinationRecords,
            hasFullAccess: subscriptionManager.hasFullAccess
        )
    }
}

#Preview {
    NavigationStack {
        PaywallView()
    }
    .environment(SubscriptionManager.shared)
}
