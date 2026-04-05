import SwiftUI

struct FAQView: View {
    @Environment(\.dismiss) private var dismiss

    private var isEN: Bool { Locale.current.language.languageCode?.identifier != "tr" }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
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
                .padding(.bottom, 4)

                // Header
                VStack(alignment: .leading, spacing: 4) {
                    Text(isEN ? "HELP" : "YARDIM")
                        .font(.kinnaBodyMedium(10))
                        .foregroundStyle(.kMuted)
                        .tracking(2)

                    (
                        Text(isEN ? "Frequently " : "Sık Sorulan ")
                            .font(.kinnaDisplay(26))
                            .foregroundStyle(.kChar)
                        +
                        Text(isEN ? "Asked" : "Sorular")
                            .font(.kinnaDisplayItalic(26))
                            .foregroundStyle(.kTerra)
                    )
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 4)

                ForEach(faqItems) { item in
                    faqCard(item)
                }

                // Contact
                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: "envelope.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(.kSageDark)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(isEN ? "Still have questions?" : "Hâlâ sorunuz mu var?")
                            .font(.kinnaBodyMedium(12))
                            .foregroundStyle(.kChar)
                        Text(isEN
                            ? "Reach us anytime at osman.seven97@icloud.com"
                            : "Bize istediğiniz zaman osman.seven97@icloud.com adresinden ulaşabilirsiniz.")
                            .font(.kinnaBody(11))
                            .foregroundStyle(.kMid)
                            .lineSpacing(2)
                    }
                }
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.kSage.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.kSage.opacity(0.2), lineWidth: 1)
                )

                Spacer(minLength: 20)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 20)
        }
        .background(Color.kCream.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .onAppear { AnalyticsManager.screenViewed(.faq) }
    }

    // MARK: - FAQ Card

    private func faqCard(_ item: FAQItem) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: item.icon)
                    .font(.system(size: 13))
                    .foregroundStyle(.kTerra)
                    .frame(width: 24, height: 24)
                    .background(Color.kTerraLight.opacity(0.4))
                    .clipShape(RoundedRectangle(cornerRadius: 6))

                Text(item.question(isEN: isEN))
                    .font(.kinnaBodyMedium(13))
                    .foregroundStyle(.kChar)
            }

            Text(item.answer(isEN: isEN))
                .font(.kinnaBody(11))
                .foregroundStyle(.kMid)
                .lineSpacing(3)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.kPale, lineWidth: 1)
        )
    }

    // MARK: - Data

    private var faqItems: [FAQItem] {
        [.whatIsPremium, .freeTrial, .restorePurchase, .cancelSubscription, .freeVsPremium, .dataSafety]
    }
}

// MARK: - FAQ Item

private struct FAQItem: Identifiable {
    let id: String
    let icon: String
    let questionEN: String
    let questionTR: String
    let answerEN: String
    let answerTR: String

    func question(isEN: Bool) -> String { isEN ? questionEN : questionTR }
    func answer(isEN: Bool) -> String { isEN ? answerEN : answerTR }

    static let whatIsPremium = FAQItem(
        id: "what-is-premium",
        icon: "star.fill",
        questionEN: "What is Kinna Premium?",
        questionTR: "Kinna Premium nedir?",
        answerEN: "Kinna Premium unlocks the full experience: WHO growth charts, official vaccination reminders, unlimited daily logs, feeding & sleep insights, and all future premium features. You can use the free version with limited features for as long as you like.",
        answerTR: "Kinna Premium tüm deneyimin kilidini açar: WHO büyüme eğrileri, resmi aşı hatırlatmaları, sınırsız günlük kayıt, beslenme & uyku analizleri ve gelecekteki tüm premium özellikler. Ücretsiz sürümü sınırlı özelliklerle istediğiniz kadar kullanabilirsiniz."
    )

    static let freeTrial = FAQItem(
        id: "free-trial",
        icon: "clock.fill",
        questionEN: "How does the 7-day free trial work?",
        questionTR: "7 günlük ücretsiz deneme nasıl çalışır?",
        answerEN: "When you subscribe, you get 7 days of full Premium access at no cost. You won't be charged during the trial period. If you cancel before the trial ends, you won't be charged at all. After the trial, your subscription continues at the plan you selected ($4.99/month or $39.99/year).",
        answerTR: "Abone olduğunuzda 7 gün boyunca tüm Premium özelliklere ücretsiz erişirsiniz. Deneme süresi boyunca ücret alınmaz. Deneme bitmeden iptal ederseniz hiç ücretlendirilmezsiniz. Deneme sonrası aboneliğiniz seçtiğiniz planla devam eder (₺179,99/ay veya ₺1.449,99/yıl)."
    )

    static let restorePurchase = FAQItem(
        id: "restore-purchase",
        icon: "arrow.clockwise",
        questionEN: "How do I restore my purchase?",
        questionTR: "Satın almamı nasıl geri yüklerim?",
        answerEN: "Open the paywall screen from Settings and tap \"Restore Purchases\". Make sure you're signed in with the same Apple ID you used for the original purchase. Your subscription will be restored automatically.",
        answerTR: "Ayarlar'dan paywall ekranını açın ve \"Satın Alımları Geri Yükle\" butonuna dokunun. Orijinal satın alma için kullandığınız Apple ID ile giriş yaptığınızdan emin olun. Aboneliğiniz otomatik olarak geri yüklenecektir."
    )

    static let cancelSubscription = FAQItem(
        id: "cancel-subscription",
        icon: "xmark.circle.fill",
        questionEN: "How do I cancel my subscription?",
        questionTR: "Aboneliğimi nasıl iptal ederim?",
        answerEN: "Go to Settings > Apple ID > Subscriptions on your iPhone, find Kinna, and tap Cancel. You'll keep Premium access until the end of your current billing period. Deleting the app does not cancel your subscription.",
        answerTR: "iPhone'unuzda Ayarlar > Apple ID > Abonelikler bölümüne gidin, Kinna'yı bulun ve İptal Et'e dokunun. Mevcut fatura döneminizin sonuna kadar Premium erişiminiz devam eder. Uygulamayı silmek aboneliğinizi iptal etmez."
    )

    static let freeVsPremium = FAQItem(
        id: "free-vs-premium",
        icon: "lock.open.fill",
        questionEN: "What's included in Free vs Premium?",
        questionTR: "Ücretsiz ve Premium'da neler var?",
        answerEN: "Free includes basic milestone tracking, limited daily logs, safety alerts, and complementary food guide. Premium adds WHO growth charts with percentiles, official vaccination schedule with reminders, unlimited daily tracking history, feeding & sleep insights, and priority access to new features.",
        answerTR: "Ücretsiz sürüm temel gelişim takibi, sınırlı günlük kayıt, güvenlik uyarıları ve ek gıda rehberini içerir. Premium ile WHO büyüme eğrileri ve persentiller, resmi aşı takvimi ve hatırlatmalar, sınırsız günlük takip geçmişi, beslenme & uyku analizleri ve yeni özelliklere öncelikli erişim açılır."
    )

    static let dataSafety = FAQItem(
        id: "data-safety",
        icon: "lock.shield.fill",
        questionEN: "Is my baby's data safe?",
        questionTR: "Bebeğimin verileri güvende mi?",
        answerEN: "Yes. All your baby's data (profile, logs, milestones, growth records) is stored on your device and synced via your personal iCloud account. Kinna does not run its own server for this data. We don't use third-party analytics or advertising SDKs. Only subscription status is verified through Apple and RevenueCat.",
        answerTR: "Evet. Bebeğinizin tüm verileri (profil, kayıtlar, gelişim, büyüme ölçümleri) cihazınızda saklanır ve kişisel iCloud hesabınız üzerinden senkronize edilir. Kinna bu veriler için kendi sunucusunu çalıştırmaz. Üçüncü taraf analitik veya reklam SDK'sı kullanmıyoruz. Yalnızca abonelik durumu Apple ve RevenueCat üzerinden doğrulanır."
    )
}

#Preview {
    NavigationStack {
        FAQView()
    }
}
