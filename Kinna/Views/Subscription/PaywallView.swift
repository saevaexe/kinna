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

    private var babyNameForHeadline: String {
        let name = babies.first?.name ?? ""
        return name.isEmpty ? (isEN ? "Baby" : "Bebek") : name
    }

    private var revenueCatSetupMessage: String {
        isEN
        ? "Premium purchases are not configured in this build yet. Add a RevenueCat public app key to test subscriptions."
        : "Bu build'de premium satın alma henüz ayarlanmış değil. Abonelikleri test etmek için RevenueCat public app key ekleyin."
    }

    private var noOfferingMessage: String {
        isEN
        ? "Subscriptions are temporarily unavailable right now. Please try again in a moment."
        : "Abonelikler şu anda geçici olarak kullanılamıyor. Biraz sonra tekrar dene."
    }

    private var missingPlanMessage: String {
        isEN
        ? "A subscription plan could not be selected. Please refresh and try again."
        : "Bir abonelik planı seçilemedi. Sayfayı yenileyip tekrar dene."
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
        else { return nil }

        let annualizedMonthly = monthlyPrice * Decimal(12)
        guard annualizedMonthly > 0, annualizedMonthly > yearlyPrice else { return nil }

        return (annualizedMonthly - yearlyPrice) / annualizedMonthly
    }

    private var yearlySavingsBadgeText: String? {
        guard let yearlySavingsFraction else { return nil }
        let percent = Int((NSDecimalNumber(decimal: yearlySavingsFraction).doubleValue * 100).rounded())
        guard percent > 0 else { return nil }
        return isEN ? "SAVE \(percent)%" : "%\(percent) TASARRUF"
    }

    private var yearlyMonthlyEquivalentText: String? {
        guard
            let yearlyPackage,
            let pricePerMonth = yearlyPackage.storeProduct.pricePerMonth?.decimalValue,
            let formatted = formatPrice(pricePerMonth, formatter: yearlyPackage.storeProduct.priceFormatter)
        else { return nil }

        return isEN ? "\(formatted)/mo" : "\(formatted)/ay"
    }

    private var formattedYearlyPerDayPrice: String? {
        guard
            let yearlyPackage,
            let pricePerDay = yearlyPackage.storeProduct.pricePerDay?.decimalValue
        else { return nil }

        return formatPrice(pricePerDay, formatter: yearlyPackage.storeProduct.priceFormatter)
    }

    private var selectedPlanSubscriptionTerms: String? {
        guard !hasActiveAccess else { return nil }
        guard let package = selectedPlan ?? yearlyPackage ?? monthlyPackage else { return nil }

        let billing = billingText(for: package)
        return isEN
        ? "\(trialDays) days free · then \(billing) · cancel anytime"
        : "\(trialDays) gün ücretsiz · sonra \(billing) · istediğin zaman iptal"
    }

    private var autoRenewalDisclosure: String? {
        guard !hasActiveAccess else { return nil }
        return isEN
        ? "Payment will be charged to your Apple ID account at confirmation of purchase. Subscription automatically renews unless it is canceled at least 24 hours before the end of the current period. Your account will be charged for renewal within 24 hours prior to the end of the current period. You can manage and cancel your subscriptions in your App Store account settings after purchase."
        : "Ödeme, satın alma onayında Apple Kimliğinize yansıtılır. Abonelik, mevcut dönem bitmeden en az 24 saat önce iptal edilmediğinde otomatik olarak yenilenir. App Store hesap ayarlarından yönetebilir veya iptal edebilirsiniz."
    }

    private var ctaTitle: String {
        if hasActiveAccess {
            return isEN ? "Manage subscription" : "Aboneliği Yönet"
        }
        return isEN ? "Start \(trialDays)-Day Free Trial" : "\(trialDays) Gün Ücretsiz Dene"
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Hero gradient + BrandIcon + close button
                heroImage

                if hasActiveAccess {
                    activeContent
                } else {
                    purchaseContent
                }

                // Footer
                footerSection
            }
        }
        .background(Color.kCream.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .toolbar(hidesTabBar ? .hidden : .visible, for: .tabBar)
        .sheet(item: $presentedLegalPage) { page in
            LegalWebView(page: page)
        }
        .task {
            AnalyticsManager.paywallViewed(source: entryPoint == .onboarding ? "onboarding" : "settings")
            await subscriptionManager.checkSubscriptionStatus()
            if !subscriptionManager.hasFullAccess {
                await loadOffering()
            }
        }
        .onChange(of: subscriptionManager.hasFullAccess) { _, hasAccess in
            Task { await syncVaccineReminders() }
            if hasAccess { dismiss() }
        }
        .onChange(of: subscriptionManager.lastErrorMessage) { _, newValue in
            guard let newValue else { return }
            successMessage = nil
            errorMessage = newValue
        }
    }

    // MARK: - Hero Image

    private var heroImage: some View {
        ZStack(alignment: .topTrailing) {
            // Hero image or gradient fallback
            if let img = UIImage(named: "paywall_hero") {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity)
                    .frame(height: 280)
                    .clipped()
                    .overlay(
                        LinearGradient(
                            colors: [.clear, .clear, Color.kCream.opacity(0.6), Color.kCream],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            } else {
                LinearGradient(
                    colors: [
                        Color(red: 0.82, green: 0.78, blue: 0.72),
                        Color(red: 0.88, green: 0.84, blue: 0.78),
                        Color.kCream
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 280)
                .overlay(alignment: .center) {
                    Image("BrandIcon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.08), radius: 20, y: 8)
                        .offset(y: -10)
                }
            }

            // Close button (top-right)
            if showsDismissButton {
                Button {
                    dismiss()
                } label: {
                    Circle()
                        .fill(.white.opacity(0.9))
                        .frame(width: 36, height: 36)
                        .overlay {
                            Image(systemName: "xmark")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(.kChar)
                        }
                        .shadow(color: .black.opacity(0.08), radius: 4, y: 2)
                }
                .padding(.top, 56)
                .padding(.trailing, 20)
            }
        }
        .ignoresSafeArea(edges: .top)
    }

    // MARK: - Hero Text

    private var heroTextSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Headline
            Text(isEN ? "Move through the early years" : "İlk yıllarda")
                .font(.kinnaDisplay(36, weight: .regular))
                .foregroundStyle(.kChar)

            Text(isEN ? "more calmly." : "daha sakin ilerle.")
                .font(.kinnaDisplayItalic(36, weight: .regular))
                .foregroundStyle(.kTerra)
                .padding(.bottom, 12)

            // Subtitle
            (
                Text(isEN
                    ? "Kinna Premium unlocks daily guidance, growth charts, and deeper tracking tools in one place.\n"
                    : "Kinna Premium; günlük rehberlik, büyüme eğrileri ve daha derin takip araçlarını tek yerde açar.\n")
                    .font(.kinnaBody(15))
                    .foregroundStyle(.kMid)
                +
                Text(isEN
                    ? "Try free for \(trialDays) days — only keep going if it helps \(babyNameForHeadline)."
                    : "\(trialDays) gün ücretsiz dene — sadece \(babyNameForHeadline) için faydalıysa devam et.")
                    .font(.kinnaBodyMedium(15))
                    .foregroundStyle(.kChar)
            )
            .lineSpacing(4)
            .padding(.bottom, 20)

            // Feature bullets
            VStack(alignment: .leading, spacing: 14) {
                featureBulletCircle(isEN ? "Daily personalized guidance" : "Günlük kişiselleştirilmiş rehber")
                featureBulletCircle(isEN ? "WHO growth charts" : "WHO büyüme eğrileri")
                featureBulletCircle(isEN ? "Unlimited history & deeper tracking" : "Sınırsız geçmiş ve daha derin takip")
                featureBulletCircle(isEN ? "Official vaccine reminders" : "Resmi aşı hatırlatmaları")
                featureBulletCircle(isEN ? "Feeding & sleep insights" : "Beslenme ve uyku takip özetleri")
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 24)
        .padding(.top, 16)
        .padding(.bottom, 24)
    }

    private func featureBulletCircle(_ text: String) -> some View {
        HStack(spacing: 12) {
            Circle()
                .stroke(Color.kTerra, lineWidth: 1.5)
                .frame(width: 26, height: 26)
                .overlay {
                    Image(systemName: "checkmark")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(.kTerra)
                }

            Text(text)
                .font(.kinnaBody(15))
                .foregroundStyle(.kMid)
        }
    }

    // MARK: - Purchase Content

    private var purchaseContent: some View {
        VStack(spacing: 0) {
            heroTextSection

            // Plan cards
            planCards
                .padding(.horizontal, 20)
                .padding(.bottom, 14)

            // Coffee row
            coffeeRow
                .padding(.horizontal, 20)
                .padding(.bottom, 16)

            // Comparison table
            comparisonTable
                .padding(.horizontal, 20)
                .padding(.bottom, 14)

            // Trust signals
            trustSignals
                .padding(.horizontal, 20)
                .padding(.bottom, 20)

            // CTA
            ctaSection
                .padding(.horizontal, 20)
                .padding(.bottom, 10)

            // No charge today
            Text(isEN ? "No charge today" : "Bugün ücret alınmaz")
                .font(.kinnaBodyMedium(13))
                .foregroundStyle(.kSageDark)
                .padding(.bottom, 2)

            Text(isEN
                 ? "Cancel before the trial ends and you won't be charged."
                 : "Deneme bitmeden iptal edersen ücret ödemezsin.")
                .font(.kinnaBody(11))
                .foregroundStyle(.kMid)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
                .padding(.bottom, 4)

            // Subscription terms
            if let selectedPlanSubscriptionTerms {
                Text(selectedPlanSubscriptionTerms)
                    .font(.kinnaBody(11))
                    .foregroundStyle(.kMid)
                    .multilineTextAlignment(.center)
                    .lineSpacing(2)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 10)
            }

            // Auto-renewal disclosure
            if let autoRenewalDisclosure {
                Text(autoRenewalDisclosure)
                    .font(.kinnaBody(10))
                    .foregroundStyle(.kMuted)
                    .multilineTextAlignment(.center)
                    .lineSpacing(2)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 12)
            }
        }
    }

    // MARK: - Plan Cards

    private var planCards: some View {
        VStack(spacing: 10) {
            // Yearly (default selected)
            planCard(
                label: isEN ? "YEARLY GUIDE" : "YILLIK REHBER",
                description: isEN
                    ? "Billed yearly"
                    : "Yıllık faturalandırma",
                price: yearlyPackage?.localizedPriceString ?? "$39.99",
                equivalent: yearlyMonthlyEquivalentText,
                badge: yearlySavingsBadgeText,
                isSelected: isYearlySelected || (!isMonthlySelected && yearlyPackage != nil)
            ) {
                selectedPlan = yearlyPackage
            }

            // Monthly
            planCard(
                label: isEN ? "MONTHLY" : "AYLIK",
                description: isEN ? "Flexible monthly billing" : "Esnek aylık faturalama",
                price: monthlyPackage?.localizedPriceString ?? "$4.99",
                equivalent: nil,
                badge: nil,
                isSelected: isMonthlySelected
            ) {
                selectedPlan = monthlyPackage
            }
        }
    }

    private func planCard(
        label: String,
        description: String,
        price: String,
        equivalent: String?,
        badge: String?,
        isSelected: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                // Radio button
                Circle()
                    .fill(isSelected ? Color.kTerra : .clear)
                    .frame(width: 20, height: 20)
                    .overlay {
                        Circle()
                            .stroke(isSelected ? Color.clear : Color.kTerra, lineWidth: 2)
                        if isSelected {
                            Circle()
                                .fill(.white)
                                .frame(width: 8, height: 8)
                        }
                    }

                // Info
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 8) {
                        Text(label)
                            .font(.kinnaBodyMedium(11))
                            .foregroundStyle(isSelected ? .kTerra : .kMid)
                            .tracking(0.5)

                        if let badge {
                            Text(badge)
                                .font(.kinnaBodyMedium(9))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 7)
                                .padding(.vertical, 2)
                                .background(Color.kTerra)
                                .clipShape(Capsule())
                        }
                    }

                    Text(description)
                        .font(.kinnaBody(12))
                        .foregroundStyle(isSelected ? Color.kTerra.opacity(0.7) : .kMid)
                }

                Spacer()

                // Price
                VStack(alignment: .trailing, spacing: 2) {
                    Text(price)
                        .font(.kinnaDisplay(24, weight: .medium))
                        .foregroundStyle(isSelected ? .kTerra : .kChar)

                    if let equivalent {
                        Text(equivalent)
                            .font(.kinnaBodyMedium(11))
                            .foregroundStyle(.kSageDark)
                    } else {
                        Text(isEN ? "/mo" : "/ay")
                            .font(.kinnaBody(11))
                            .foregroundStyle(.kMid)
                    }
                }
            }
            .padding(16)
            .background(isSelected ? Color(red: 0.94, green: 0.91, blue: 0.86) : .white.opacity(0.9))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(content: {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color.kTerra : Color.kPale, lineWidth: 1.5)
            })
        }
    }

    // MARK: - Coffee Row

    private var coffeeRow: some View {
        HStack(spacing: 10) {
            Text("☕")
                .font(.system(size: 18))

            if let price = formattedYearlyPerDayPrice {
                (
                    Text(isEN ? "Just \(price)/day." : "Günde yalnızca \(price).")
                        .font(.kinnaBodyMedium(13))
                        .foregroundStyle(.kTerra)
                    +
                    Text(isEN ? " Less than a coffee." : " Bir çaydan bile az.")
                        .font(.kinnaBody(13))
                        .foregroundStyle(.kMid)
                )
            } else {
                Text(isEN ? "Less than a coffee a day." : "Günde bir çaydan bile az.")
                    .font(.kinnaBody(13))
                    .foregroundStyle(.kMid)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white.opacity(0.9))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.kPale, lineWidth: 1)
        )
    }

    // MARK: - Comparison Table

    private var comparisonTable: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("")
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(isEN ? "FREE" : "ÜCRETSİZ")
                    .frame(width: 70)
                    .font(.kinnaBodyMedium(10))
                    .foregroundStyle(.kMid)
                    .tracking(0.5)
                Text("PREMIUM")
                    .frame(width: 80)
                    .font(.kinnaBodyMedium(10))
                    .foregroundStyle(.kTerra)
                    .tracking(0.5)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)

            Divider().foregroundStyle(Color.kPale)

            comparisonRow(
                feature: isEN ? "Tracking history" : "Takip geçmişi",
                free: isEN ? "7 days" : "7 gün",
                isPremiumCheck: true
            )
            Divider().foregroundStyle(Color.kPale)

            comparisonRow(
                feature: isEN ? "Food logs" : "Besin kaydı",
                free: isEN ? "5 logs" : "5 kayıt",
                isPremiumCheck: true
            )
            Divider().foregroundStyle(Color.kPale)

            comparisonRow(
                feature: isEN ? "Milestone saves" : "Gelişim taşı kaydı",
                free: isEN ? "5 logs" : "5 kayıt",
                isPremiumCheck: true
            )
            Divider().foregroundStyle(Color.kPale)

            comparisonRow(
                feature: isEN ? "Vaccine reminders" : "Aşı hatırlatmaları",
                free: "—",
                isPremiumCheck: true
            )
            Divider().foregroundStyle(Color.kPale)

            comparisonRow(
                feature: isEN ? "Growth curves" : "Büyüme eğrileri",
                free: "—",
                isPremiumCheck: true
            )
            Divider().foregroundStyle(Color.kPale)

            comparisonRow(
                feature: isEN ? "Daily guidance" : "Günlük rehberlik",
                free: isEN ? "1 card" : "1 kart",
                isPremiumCheck: true
            )
        }
        .background(.white.opacity(0.9))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.kPale, lineWidth: 1)
        )
    }

    private func comparisonRow(feature: String, free: String, isPremiumCheck: Bool) -> some View {
        HStack {
            Text(feature)
                .font(.kinnaBody(13))
                .foregroundStyle(.kChar)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(free)
                .font(.kinnaBody(12))
                .foregroundStyle(.kMid)
                .frame(width: 70)

            // Premium checkmark
            RoundedRectangle(cornerRadius: 6)
                .fill(Color.kSageDark)
                .frame(width: 20, height: 20)
                .overlay {
                    Image(systemName: "checkmark")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.white)
                }
                .frame(width: 80)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }

    // MARK: - Trust Signals

    private var trustSignals: some View {
        VStack(alignment: .leading, spacing: 7) {
            HStack(spacing: 8) {
                Text("🏛️")
                    .font(.system(size: 14))
                    .frame(width: 20)
                Text(isEN
                    ? "Based on WHO & Ministry of Health protocols"
                    : "WHO ve T.C. Sağlık Bakanlığı protokollerine dayalı")
                    .font(.kinnaBody(12))
                    .foregroundStyle(.kMid)
            }

            HStack(spacing: 8) {
                Text("🔒")
                    .font(.system(size: 14))
                    .frame(width: 20)
                Text(isEN
                    ? "Your data stays on your device — private & secure"
                    : "Verilerin cihazında kalır — özel ve güvenli")
                    .font(.kinnaBody(12))
                    .foregroundStyle(.kMid)
            }

            HStack(spacing: 8) {
                Text("✨")
                    .font(.system(size: 14))
                    .frame(width: 20)
                Text(isEN
                    ? "No ads, no distractions — a calm experience"
                    : "Reklamsız, dikkat dağıtmayan sakin deneyim")
                    .font(.kinnaBody(12))
                    .foregroundStyle(.kMid)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - CTA

    private var ctaSection: some View {
        Button {
            Task { await purchase() }
        } label: {
            if isPurchasing {
                ProgressView()
                    .tint(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 17)
            } else {
                Text(ctaTitle)
                    .font(.kinnaBodyMedium(16))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 17)
            }
        }
        .background(Color.kTerra)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .kTerra.opacity(0.3), radius: 12, y: 6)
        .disabled(primaryButtonDisabled)
    }

    // MARK: - Active Content

    private var activeContent: some View {
        VStack(spacing: 0) {
            heroTextSection

            HStack(alignment: .top, spacing: 12) {
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(.kSageDark)
                    .padding(.top, 1)

                VStack(alignment: .leading, spacing: 4) {
                    Text(isEN ? "Everything is unlocked" : "Tüm premium özellikler açık")
                        .font(.kinnaBodyMedium(13))
                        .foregroundStyle(.kChar)

                    Text(isEN
                        ? "Open App Store subscription settings to change your plan or cancel anytime."
                        : "Planını değiştirmek veya iptal etmek için App Store abonelik ayarlarını aç.")
                        .font(.kinnaBody(11))
                        .foregroundStyle(.kMid)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(14)
            .background(Color.kBlush.opacity(0.5))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.kTerra.opacity(0.15), lineWidth: 1)
            )
            .padding(.horizontal, 20)
            .padding(.bottom, 16)

            Button {
                manageSubscription()
            } label: {
                Text(ctaTitle)
                    .font(.kinnaBodyMedium(15))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
            }
            .background(Color.kTerra)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .padding(.horizontal, 20)
            .padding(.bottom, 10)
        }
    }

    // MARK: - Footer

    private var footerSection: some View {
        VStack(spacing: 8) {
            // Terms + Privacy
            HStack(spacing: 24) {
                Button {
                    presentedLegalPage = .terms
                } label: {
                    Text(isEN ? "Terms of Use" : "Kullanım Şartları")
                        .font(.kinnaBody(12))
                        .foregroundStyle(.kMid)
                        .underline()
                }
                .buttonStyle(.plain)

                Button {
                    presentedLegalPage = .privacy
                } label: {
                    Text(isEN ? "Privacy Policy" : "Gizlilik Politikası")
                        .font(.kinnaBody(12))
                        .foregroundStyle(.kMid)
                        .underline()
                }
                .buttonStyle(.plain)
            }
            .padding(.top, 10)

            // Restore
            if !hasActiveAccess {
                Button {
                    Task { await restorePurchases() }
                } label: {
                    Text(isEN ? "Restore purchases" : "Satın almaları geri yükle")
                        .font(.kinnaBody(12))
                        .foregroundStyle(.kTerra)
                }
                .disabled(isPurchasing)
            }

            // Onboarding skip
            if isOnboardingEntry {
                Button {
                    dismiss()
                } label: {
                    Text(isEN ? "Continue with free for now" : "Şimdilik ücretsiz devam et")
                        .font(.kinnaBody(13))
                        .foregroundStyle(.kChar.opacity(0.7))
                        .underline()
                        .padding(.vertical, 12)
                }
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
        .padding(.bottom, 24)
    }

    // MARK: - Helpers

    private func formatPrice(_ price: Decimal, formatter: NumberFormatter?) -> String? {
        guard let formatter else { return nil }
        if let copy = formatter.copy() as? NumberFormatter {
            return copy.string(from: price as NSDecimalNumber)
        }
        return formatter.string(from: price as NSDecimalNumber)
    }

    private func billingText(for package: Package) -> String {
        let price = package.localizedPriceString
        guard let period = package.storeProduct.subscriptionPeriod else { return price }
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

            if offering?.availablePackages.isEmpty != false {
                errorMessage = noOfferingMessage
            }
        } catch {
            errorMessage = friendlyPaywallErrorMessage(from: error, fallback: error.localizedDescription)
        }
    }

    private func purchase() async {
        guard subscriptionManager.canMakePurchases else {
            errorMessage = revenueCatSetupMessage
            successMessage = nil
            return
        }

        guard let selectedPlan else {
            errorMessage = missingPlanMessage
            successMessage = nil
            return
        }
        isPurchasing = true
        defer { isPurchasing = false }
        errorMessage = nil
        successMessage = nil

        let planType = selectedPlan.storeProduct.subscriptionPeriod?.unit == .month ? "monthly" : "yearly"
        AnalyticsManager.paywallAction(planType == "monthly" ? .monthlyTapped : .yearlyTapped)

        let purchaseSucceeded = await subscriptionManager.purchase(selectedPlan)
        if purchaseSucceeded {
            AnalyticsManager.subscriptionStarted(plan: planType, trial: true)
        }
        await syncVaccineReminders()
        if !purchaseSucceeded && !subscriptionManager.hasFullAccess {
            errorMessage = friendlyPaywallErrorMessage(
                from: nil,
                fallback: subscriptionManager.lastErrorMessage
            )
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

        AnalyticsManager.paywallAction(.restoreTapped)
        let restoreSucceeded = await subscriptionManager.restorePurchases()
        await syncVaccineReminders()
        if restoreSucceeded && subscriptionManager.hasFullAccess {
            successMessage = hadActiveAccessBeforeRestore
                ? (isEN ? "Your subscription is already active." : "Aboneliğiniz zaten aktif.")
                : (isEN ? "Your subscription has been restored." : "Aboneliğiniz geri yüklendi.")
            return
        }

        if !restoreSucceeded && !subscriptionManager.hasFullAccess {
            errorMessage = friendlyPaywallErrorMessage(
                from: nil,
                fallback: subscriptionManager.lastErrorMessage ?? (isEN
                ? "No active subscription could be restored."
                : "Aktif bir abonelik geri yüklenemedi.")
            )
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

    private func friendlyPaywallErrorMessage(from error: Error?, fallback: String?) -> String {
        let rawMessage = (fallback ?? error?.localizedDescription ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let lowercased = rawMessage.lowercased()

        if lowercased.contains("network")
            || lowercased.contains("internet")
            || lowercased.contains("offline")
            || lowercased.contains("timed out")
        {
            return isEN
            ? "We couldn't reach the App Store. Check your connection and try again."
            : "App Store'a ulaşılamadı. Bağlantını kontrol edip tekrar dene."
        }

        if rawMessage.isEmpty {
            return isEN
            ? "Something went wrong while checking subscriptions. Please try again."
            : "Abonelikler kontrol edilirken bir sorun oluştu. Lütfen tekrar dene."
        }

        return rawMessage
    }
}

#Preview {
    NavigationStack {
        PaywallView()
    }
    .environment(SubscriptionManager.shared)
}
