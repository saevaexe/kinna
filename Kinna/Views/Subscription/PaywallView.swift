import SwiftUI
import RevenueCat

struct PaywallView: View {
    @Environment(SubscriptionManager.self) private var subscriptionManager
    @Environment(\.dismiss) private var dismiss
    @State private var offering: Offering?
    @State private var selectedPlan: Package?
    @State private var isPurchasing = false
    @State private var errorMessage: String?

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 12) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 50))
                        .foregroundStyle(.kTerra)

                    Text(String(localized: "paywall_title", defaultValue: "Unlock Kinna Pro"))
                        .font(.title.bold())

                    Text(String(localized: "paywall_subtitle", defaultValue: "Everything you need for your baby's journey"))
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 40)

                // Features
                VStack(alignment: .leading, spacing: 16) {
                    featureRow(icon: "chart.bar.fill", title: String(localized: "paywall_feature_growth", defaultValue: "Growth Charts"), subtitle: String(localized: "paywall_feature_growth_desc", defaultValue: "WHO percentile tracking"))
                    featureRow(icon: "brain.head.profile", title: String(localized: "paywall_feature_brain", defaultValue: "Brain Development"), subtitle: String(localized: "paywall_feature_brain_desc", defaultValue: "Science-backed insights"))
                    featureRow(icon: "doc.text.fill", title: String(localized: "paywall_feature_report", defaultValue: "Doctor Reports"), subtitle: String(localized: "paywall_feature_report_desc", defaultValue: "PDF export for pediatrician"))
                    featureRow(icon: "questionmark.circle.fill", title: String(localized: "paywall_feature_ai", defaultValue: "AI Q&A"), subtitle: String(localized: "paywall_feature_ai_desc", defaultValue: "Ask anything about your baby"))
                }
                .padding(.horizontal, 24)

                // Plans
                if let offering {
                    VStack(spacing: 12) {
                        ForEach(offering.availablePackages, id: \.identifier) { package in
                            planCard(package: package, isSelected: selectedPlan?.identifier == package.identifier)
                                .onTapGesture { selectedPlan = package }
                        }
                    }
                    .padding(.horizontal, 24)
                }

                // Purchase button
                Button {
                    Task { await purchase() }
                } label: {
                    if isPurchasing {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text(String(localized: "paywall_subscribe", defaultValue: "Start Free Trial"))
                    }
                }
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(.kTerra)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .disabled(selectedPlan == nil || isPurchasing)
                .padding(.horizontal, 24)

                // Restore
                Button {
                    Task { await subscriptionManager.restorePurchases() }
                } label: {
                    Text(String(localized: "paywall_restore", defaultValue: "Restore Purchases"))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                if let errorMessage {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundStyle(.red)
                }
            }
            .padding(.bottom, 32)
        }
        .task { await loadOffering() }
        .onChange(of: subscriptionManager.hasFullAccess) { _, hasAccess in
            if hasAccess { dismiss() }
        }
    }

    private func featureRow(icon: String, title: String, subtitle: String) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(.kTerra)
                .frame(width: 32)
            VStack(alignment: .leading) {
                Text(title).font(.subheadline.bold())
                Text(subtitle).font(.caption).foregroundStyle(.secondary)
            }
        }
    }

    private func planCard(package: Package, isSelected: Bool) -> some View {
        HStack {
            VStack(alignment: .leading) {
                Text(package.storeProduct.localizedTitle)
                    .font(.headline)
                Text(package.localizedPriceString)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(isSelected ? .kTerra : .kMid)
        }
        .padding()
        .background(isSelected ? Color.kTerraPale : Color.kPale)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func loadOffering() async {
        do {
            let offerings = try await Purchases.shared.offerings()
            offering = offerings.current
            selectedPlan = offering?.availablePackages.first
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
    PaywallView()
        .environment(SubscriptionManager.shared)
}
