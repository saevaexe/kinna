import SwiftUI
import RevenueCat

struct PaywallView: View {
    @Environment(SubscriptionManager.self) private var subscriptionManager
    @Environment(\.dismiss) private var dismiss
    @State private var offering: Offering?
    @State private var selectedPlan: Package?
    @State private var isPurchasing = false
    @State private var errorMessage: String?

    private var monthlyPackage: Package? {
        offering?.availablePackages.first { $0.packageType == .monthly }
    }

    private var yearlyPackage: Package? {
        offering?.availablePackages.first { $0.packageType == .annual }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Trial badge
                HStack(spacing: 6) {
                    Circle()
                        .fill(Color(hex: 0x4CAF50))
                        .frame(width: 7, height: 7)
                    Text("3 gün ücretsiz dene")
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

                Text("Ela'nın her anını\n")
                    .font(.kinnaDisplay(26))
                    .foregroundStyle(.kChar)
                +
                Text("kaçırma.")
                    .font(.kinnaDisplayItalic(26))
                    .foregroundStyle(.kTerra)

                Text("3 gün boyunca her şey ücretsiz.\nSonra istersen devam et.")
                    .font(.kinnaBody(12, weight: .light))
                    .foregroundStyle(.kMid)
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
                    .padding(.top, 6)
                    .padding(.bottom, 20)

                // Plan cards
                HStack(spacing: 8) {
                    planCard(
                        title: "AYLIK",
                        price: monthlyPackage?.localizedPriceString ?? "₺169",
                        unit: "/ ay",
                        saving: nil,
                        badge: nil,
                        isSelected: selectedPlan?.packageType == .monthly
                    ) {
                        selectedPlan = monthlyPackage
                    }

                    planCard(
                        title: "YILLIK",
                        price: yearlyPackage?.localizedPriceString ?? "₺999",
                        unit: "/ yıl",
                        saving: "ayda ₺83",
                        badge: "%34 indirim",
                        isSelected: selectedPlan?.packageType != .monthly
                    ) {
                        selectedPlan = yearlyPackage
                    }
                }
                .padding(.horizontal, 4)
                .padding(.bottom, 14)

                // Per-day reframe
                HStack(spacing: 10) {
                    Text("☕")
                        .font(.system(size: 18))
                    Text("Günde 2,7₺.")
                        .font(.kinnaBody(12, weight: .medium))
                        .foregroundStyle(.kChar)
                    +
                    Text(" Bir kahveden az.")
                        .font(.kinnaBody(12))
                        .foregroundStyle(.kMid)
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

                // Features
                VStack(spacing: 8) {
                    featureRow("Sınırsız gelişim takibi", sub: "0-5 yaş")
                    featureRow("Kişiselleştirilmiş günlük rehberlik", sub: nil)
                    featureRow("Aşı takvimi + hatırlatmalar", sub: nil)
                    featureRow("Besin günlüğü ve geçiş rehberi", sub: nil)
                    featureRow("Tüm veriler cihazında", sub: "gizli & güvenli")
                }
                .padding(.bottom, 20)

                // CTA
                Button {
                    Task { await purchase() }
                } label: {
                    if isPurchasing {
                        ProgressView()
                            .tint(.white)
                            .frame(maxWidth: .infinity)
                            .padding(16)
                    } else {
                        Text("3 gün ücretsiz başla")
                            .font(.kinnaBodyMedium(15))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(16)
                    }
                }
                .background(Color.kTerra)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: .kTerra.opacity(0.4), radius: 14, y: 6)
                .disabled(isPurchasing)
                .padding(.bottom, 8)

                Text("İstediğin zaman iptal edebilirsin.")
                    .font(.kinnaBody(10))
                    .foregroundStyle(.kLight)
                    .padding(.bottom, 6)

                Button {
                    Task { await subscriptionManager.restorePurchases() }
                } label: {
                    Text("Satın almayı geri yükle")
                        .font(.kinnaBody(11))
                        .foregroundStyle(.kLight)
                        .underline()
                }
                .padding(.bottom, 8)

                if let errorMessage {
                    Text(errorMessage)
                        .font(.kinnaBody(11))
                        .foregroundStyle(.red)
                        .padding(.top, 4)
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
        .background(Color.kCream.ignoresSafeArea())
        .task { await loadOffering() }
        .onChange(of: subscriptionManager.hasFullAccess) { _, hasAccess in
            if hasAccess { dismiss() }
        }
        .toolbar {
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
        HStack(spacing: 10) {
            RoundedRectangle(cornerRadius: 6)
                .fill(Color.kSage)
                .frame(width: 18, height: 18)
                .overlay {
                    Text("✓")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(.white)
                }

            Text(text)
                .font(.kinnaBody(12))
                .foregroundStyle(.kChar)

            if let sub {
                Text(sub)
                    .font(.kinnaBody(11))
                    .foregroundStyle(.kLight)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Network

    private func loadOffering() async {
        do {
            let offerings = try await Purchases.shared.offerings()
            offering = offerings.current
            selectedPlan = yearlyPackage ?? monthlyPackage ?? offering?.availablePackages.first
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func purchase() async {
        guard let selectedPlan else { return }
        isPurchasing = true
        defer { isPurchasing = false }

        do {
            let result = try await Purchases.shared.purchase(package: selectedPlan)
            if !result.userCancelled {
                await subscriptionManager.checkSubscriptionStatus()
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

#Preview {
    NavigationStack {
        PaywallView()
    }
    .environment(SubscriptionManager.shared)
}
