import SwiftUI

struct SourcesView: View {
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
                    Text(isEN ? "TRUST" : "GÜVENİLİRLİK")
                        .font(.kinnaBodyMedium(10))
                        .foregroundStyle(.kMuted)
                        .tracking(2)

                    (
                        Text(isEN ? "Our " : "Kaynak")
                            .font(.kinnaDisplay(26))
                            .foregroundStyle(.kChar)
                        +
                        Text(isEN ? "Sources" : "larımız")
                            .font(.kinnaDisplayItalic(26))
                            .foregroundStyle(.kTerra)
                    )
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 4)

                // Intro
                Text(isEN
                    ? "Every piece of content in Kinna is grounded in evidence-based guidelines. We don't make up milestones or health information — we translate trusted medical sources into a warm, easy-to-follow format for parents."
                    : "Kinna'daki her içerik kanıta dayalı rehberlere dayanır. Gelişim taşlarını veya sağlık bilgilerini kendimiz uydurmuyoruz — güvenilir tıbbi kaynakları ebeveynler için sıcak, takip etmesi kolay bir formata çeviriyoruz.")
                    .font(.kinnaBody(12))
                    .foregroundStyle(.kMid)
                    .lineSpacing(3)
                    .padding(14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.kSage.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.kSage.opacity(0.2), lineWidth: 1)
                    )

                ForEach(sourceItems) { item in
                    sourceCard(item)
                }

                // Disclaimer
                HStack(alignment: .top, spacing: 10) {
                    Text("⚕️")
                        .font(.system(size: 16))
                    VStack(alignment: .leading, spacing: 2) {
                        Text(isEN ? "A reminder" : "Hatırlatma")
                            .font(.kinnaBodyMedium(12))
                            .foregroundStyle(.kChar)
                        Text(isEN
                            ? "Kinna is an informational guide, not a medical tool. Always consult your pediatrician for health decisions about your child."
                            : "Kinna bir bilgilendirme rehberidir, tıbbi bir araç değildir. Çocuğunuzla ilgili sağlık kararlarında her zaman çocuk doktorunuza danışın.")
                            .font(.kinnaBody(11))
                            .foregroundStyle(.kMid)
                            .lineSpacing(2)
                    }
                }
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.kTerraLight.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.kTerra.opacity(0.15), lineWidth: 1)
                )

                Spacer(minLength: 20)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 20)
        }
        .background(Color.kCream.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .onAppear { AnalyticsManager.screenViewed(.sources) }
    }

    // MARK: - Source Card

    private func sourceCard(_ item: SourceItem) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Text(item.badge)
                    .font(.kinnaBodyMedium(9))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(item.badgeColor)
                    .clipShape(Capsule())

                Spacer()
            }

            Text(item.title(isEN: isEN))
                .font(.kinnaBodyMedium(13))
                .foregroundStyle(.kChar)

            Text(item.description(isEN: isEN))
                .font(.kinnaBody(11))
                .foregroundStyle(.kMid)
                .lineSpacing(3)

            // What we use it for
            VStack(alignment: .leading, spacing: 4) {
                Text(isEN ? "Used for:" : "Kullanım alanı:")
                    .font(.kinnaBodyMedium(10))
                    .foregroundStyle(.kLight)
                    .tracking(0.5)

                Text(item.usedFor(isEN: isEN))
                    .font(.kinnaBody(11))
                    .foregroundStyle(.kMid)
                    .lineSpacing(2)
            }
            .padding(.top, 4)
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

    private var sourceItems: [SourceItem] {
        [.who, .tcSaglikBakanligi, .cdc, .aap]
    }
}

// MARK: - Source Item

private struct SourceItem: Identifiable {
    let id: String
    let badge: String
    let badgeColor: Color
    let titleEN: String
    let titleTR: String
    let descriptionEN: String
    let descriptionTR: String
    let usedForEN: String
    let usedForTR: String

    func title(isEN: Bool) -> String { isEN ? titleEN : titleTR }
    func description(isEN: Bool) -> String { isEN ? descriptionEN : descriptionTR }
    func usedFor(isEN: Bool) -> String { isEN ? usedForEN : usedForTR }

    static let who = SourceItem(
        id: "who",
        badge: "WHO",
        badgeColor: .kSageDark,
        titleEN: "World Health Organization",
        titleTR: "Dünya Sağlık Örgütü (WHO)",
        descriptionEN: "The WHO Child Growth Standards and developmental milestone framework provide the scientific foundation for tracking your baby's progress. These standards are based on the Multicentre Growth Reference Study across six countries.",
        descriptionTR: "WHO Çocuk Büyüme Standartları ve gelişim taşı çerçevesi, bebeğinizin ilerlemesini takip etmek için bilimsel temel sağlar. Bu standartlar altı ülkede yapılan Çok Merkezli Büyüme Referans Çalışması'na dayanır.",
        usedForEN: "Growth charts (weight, height percentiles), developmental milestones (0–24 months), and feeding guidelines",
        usedForTR: "Büyüme eğrileri (kilo, boy persentilleri), gelişim taşları (0–24 ay) ve beslenme rehberi"
    )

    static let tcSaglikBakanligi = SourceItem(
        id: "tc-saglik",
        badge: "T.C. SB",
        badgeColor: .kTerra,
        titleEN: "Republic of Turkey Ministry of Health",
        titleTR: "T.C. Sağlık Bakanlığı",
        descriptionEN: "Turkey's national childhood immunization program defines the vaccination schedule used in Kinna for Turkish users. The schedule is updated periodically by the Ministry of Health.",
        descriptionTR: "T.C. Sağlık Bakanlığı Çocukluk Çağı Aşı Programı, Kinna'daki aşı takviminin temelini oluşturur. Takvim, Sağlık Bakanlığı tarafından periyodik olarak güncellenir.",
        usedForEN: "Vaccination schedule, immunization reminders, and vaccine information cards",
        usedForTR: "Aşı takvimi, bağışıklama hatırlatmaları ve aşı bilgi kartları"
    )

    static let cdc = SourceItem(
        id: "cdc",
        badge: "CDC",
        badgeColor: Color(hex: 0x5B7FA5),
        titleEN: "Centers for Disease Control and Prevention",
        titleTR: "ABD Hastalık Kontrol ve Önleme Merkezleri (CDC)",
        descriptionEN: "The CDC's developmental screening milestones and \"Learn the Signs. Act Early.\" program complement WHO data with additional age-specific checkpoints widely used in pediatric practice.",
        descriptionTR: "CDC'nin gelişimsel tarama taşları ve \"Belirtileri Öğrenin. Erken Harekete Geçin.\" programı, WHO verilerini pediatri pratiğinde yaygın kullanılan yaşa özel kontrol noktalarıyla tamamlar.",
        usedForEN: "Developmental screening checkpoints and safety alert content",
        usedForTR: "Gelişimsel tarama kontrol noktaları ve güvenlik uyarı içeriği"
    )

    static let aap = SourceItem(
        id: "aap",
        badge: "AAP",
        badgeColor: Color(hex: 0x6B7A8D),
        titleEN: "American Academy of Pediatrics",
        titleTR: "Amerikan Pediatri Akademisi (AAP)",
        descriptionEN: "AAP guidelines on infant nutrition, sleep safety, and complementary feeding provide additional evidence for Kinna's feeding and sleep tracking features.",
        descriptionTR: "AAP'nin bebek beslenmesi, uyku güvenliği ve ek gıdaya geçiş rehberleri, Kinna'nın beslenme ve uyku takip özelliklerinin ek kanıt dayanağını oluşturur.",
        usedForEN: "Feeding guidelines, sleep safety recommendations, and complementary food introduction",
        usedForTR: "Beslenme rehberi, uyku güvenliği önerileri ve ek gıdaya geçiş"
    )
}

#Preview {
    NavigationStack {
        SourcesView()
    }
}
