import SwiftUI
import SafariServices

struct LegalDisclaimerView: View {
    enum Focus {
        case full
        case terms
        case privacy
    }

    var focus: Focus = .full

    private var isEN: Bool { Locale.current.language.languageCode?.identifier != "tr" }
    private var sectionItems: [LegalSectionItem] {
        switch focus {
        case .full:
            return [.medicalAdvice, .doctor, .vaccination, .sources, .liability, .privacySummary]
        case .terms:
            return [.medicalAdvice, .doctor, .vaccination, .sources, .liability]
        case .privacy:
            return [.privacyOverview, .localData, .childrenPrivacy, .thirdParties, .analytics, .deletion, .rights, .contact]
        }
    }

    private var showsEmergencyBox: Bool { focus != .privacy }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                VStack(alignment: .leading, spacing: 4) {
                    Text(headerEyebrow)
                        .font(.kinnaBody(9))
                        .foregroundStyle(.kMuted)
                        .tracking(1.5)

                    headerTitle
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 4)

                ForEach(sectionItems) { item in
                    legalSection(number: item.number, title: item.title(isEN: isEN), body: item.body(isEN: isEN))
                }

                // Emergency box
                if showsEmergencyBox {
                    HStack(alignment: .top, spacing: 10) {
                        Text("🚨")
                            .font(.system(size: 16))
                        VStack(alignment: .leading, spacing: 2) {
                            Text(isEN ? "In an emergency" : "Acil durumda")
                                .font(.kinnaBodyMedium(12))
                                .foregroundStyle(Color(hex: 0xC44A4A))
                            Text(isEN
                                ? "If you believe your child needs immediate medical attention, call your local emergency number or go to the nearest emergency room."
                                : "Çocuğunuzun acil tıbbi müdahaleye ihtiyacı olduğunu düşünüyorsanız 112'yi arayın veya en yakın acil servise gidin.")
                                .font(.kinnaBody(11))
                                .foregroundStyle(.kMid)
                                .lineSpacing(2)
                        }
                    }
                    .padding(14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(hex: 0xC44A4A).opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color(hex: 0xC44A4A).opacity(0.2), lineWidth: 1)
                    )
                }

                // Last updated
                Text(isEN ? "Last updated: April 5, 2026" : "Son güncelleme: 5 Nisan 2026")
                    .font(.kinnaBody(9))
                    .foregroundStyle(.kMuted)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 8)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
        }
        .background(Color.kCream.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
    }

    private var headerEyebrow: String {
        switch focus {
        case .full, .terms:
            return isEN ? "LEGAL" : "YASAL"
        case .privacy:
            return isEN ? "PRIVACY" : "GİZLİLİK"
        }
    }

    private var headerTitle: some View {
        Group {
            switch focus {
            case .full:
                (
                    Text(isEN ? "Terms " : "Kullanım ")
                        .font(.kinnaDisplay(26))
                        .foregroundStyle(.kChar)
                    +
                    Text(isEN ? "& Disclaimer" : "koşulları")
                        .font(.kinnaDisplayItalic(26))
                        .foregroundStyle(.kTerra)
                )
            case .terms:
                (
                    Text(isEN ? "Terms " : "Kullanım ")
                        .font(.kinnaDisplay(26))
                        .foregroundStyle(.kChar)
                    +
                    Text(isEN ? "of Use" : "Koşulları")
                        .font(.kinnaDisplayItalic(26))
                        .foregroundStyle(.kTerra)
                )
            case .privacy:
                (
                    Text(isEN ? "Privacy " : "Gizlilik ")
                        .font(.kinnaDisplay(26))
                        .foregroundStyle(.kChar)
                    +
                    Text(isEN ? "Policy" : "Politikası")
                        .font(.kinnaDisplayItalic(26))
                        .foregroundStyle(.kTerra)
                )
            }
        }
    }

    private func legalSection(number: String, title: String, body: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
                Text(number)
                    .font(.kinnaDisplay(16))
                    .foregroundStyle(.kTerra)
                    .frame(width: 24, height: 24)
                    .background(Color.kTerraLight.opacity(0.4))
                    .clipShape(RoundedRectangle(cornerRadius: 6))

                Text(title)
                    .font(.kinnaBodyMedium(13))
                    .foregroundStyle(.kChar)
            }

            Text(body)
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
}

private struct LegalSectionItem: Identifiable {
    let id: String
    let number: String
    let titleEN: String
    let titleTR: String
    let bodyEN: String
    let bodyTR: String

    func title(isEN: Bool) -> String { isEN ? titleEN : titleTR }
    func body(isEN: Bool) -> String { isEN ? bodyEN : bodyTR }

    static let medicalAdvice = LegalSectionItem(
        id: "medical",
        number: "1",
        titleEN: "Not Medical Advice",
        titleTR: "Tıbbi Tavsiye Değildir",
        bodyEN: "Kinna is provided for informational and educational purposes only. The content, including but not limited to developmental milestones, vaccination schedules, feeding information, and parenting tips, does not constitute medical advice, diagnosis, or treatment.\n\nKinna is not intended to be a substitute for professional medical advice, diagnosis, or treatment. Never disregard professional medical advice or delay in seeking it because of something you have read or accessed through Kinna.",
        bodyTR: "Kinna yalnızca bilgilendirme ve eğitim amaçlı sunulmaktadır. Gelişim taşları, aşı takvimi, beslenme bilgileri ve ebeveynlik ipuçları dahil ancak bunlarla sınırlı olmamak üzere içerikler, tıbbi tavsiye, teşhis veya tedavi niteliği taşımaz.\n\nKinna, profesyonel tıbbi tavsiye, teşhis veya tedavinin yerini tutmak amacıyla tasarlanmamıştır. Kinna üzerinden okuduğunuz veya eriştiğiniz bilgiler nedeniyle profesyonel tıbbi tavsiyeyi göz ardı etmeyin veya geciktirmeyin."
    )

    static let doctor = LegalSectionItem(
        id: "doctor",
        number: "2",
        titleEN: "Consult Your Healthcare Provider",
        titleTR: "Sağlık Uzmanınıza Danışın",
        bodyEN: "Always seek the advice of your pediatrician or other qualified health provider with any questions you may have regarding your child's health or medical condition. If you think your child may have a medical emergency, call your doctor or local emergency services immediately.",
        bodyTR: "Çocuğunuzun sağlığı veya tıbbi durumu hakkında herhangi bir sorunuz olduğunda her zaman çocuk doktorunuza veya nitelikli bir sağlık uzmanına danışın. Çocuğunuzun acil tıbbi müdahaleye ihtiyacı olduğunu düşünüyorsanız derhal doktorunuzu veya acil servisi (112) arayın."
    )

    static let vaccination = LegalSectionItem(
        id: "vaccination",
        number: "3",
        titleEN: "Vaccination Schedule Disclaimer",
        titleTR: "Aşı Takvimi Sorumluluk Reddi",
        bodyEN: "The vaccination schedule provided in Kinna is based on WHO guidelines. Vaccination schedules follow national immunization programs and may differ by country. Dates are calculated approximately based on your baby's date of birth and are estimates only.\n\nActual vaccination dates may vary. Always confirm your child's vaccination schedule with your pediatrician.",
        bodyTR: "Kinna'da sunulan aşı takvimi, T.C. Sağlık Bakanlığı Çocukluk Çağı Aşı Programı temel alınarak bebeğinizin doğum tarihine göre yaklaşık olarak hesaplanmaktadır. Bu tarihler yalnızca tahminidir.\n\nGerçek aşı tarihleri farklılık gösterebilir. Çocuğunuzun aşı takvimini her zaman aile hekiminiz veya çocuk doktorunuzla teyit edin."
    )

    static let sources = LegalSectionItem(
        id: "sources",
        number: "4",
        titleEN: "Content Sources",
        titleTR: "İçerik Kaynakları",
        bodyEN: "Our developmental content is prepared based on World Health Organization (WHO) guidelines. Vaccination schedules follow national immunization programs and may differ by country.\n\nWhile we strive to keep information accurate and up-to-date, we make no representations or warranties of any kind, express or implied, about the completeness, accuracy, reliability, or suitability of the information.",
        bodyTR: "İçeriklerimiz Dünya Sağlık Örgütü (WHO) rehberleri ve T.C. Sağlık Bakanlığı protokolleri temel alınarak hazırlanmıştır. Bilgilerin doğru ve güncel olması için çaba göstersek de bilgilerin eksiksizliği, doğruluğu, güvenilirliği veya uygunluğu hakkında açık veya zımni hiçbir garanti vermemekteyiz."
    )

    static let liability = LegalSectionItem(
        id: "liability",
        number: "5",
        titleEN: "Limitation of Liability",
        titleTR: "Sorumluluk Sınırlaması",
        bodyEN: "Kinna and its developers shall not be liable for any direct, indirect, incidental, consequential, or special damages arising out of or in connection with the use of this application or reliance on its content. The application is provided \"as is\" without warranties of any kind.\n\nYour use of Kinna is at your own risk. You are solely responsible for any decisions or actions taken based on information provided by the application.",
        bodyTR: "Kinna ve geliştiricileri, bu uygulamanın kullanımından veya içeriğine güvenilmesinden kaynaklanan veya bunlarla bağlantılı herhangi bir doğrudan, dolaylı, arızi, sonuç olarak ortaya çıkan veya özel zarardan sorumlu tutulamaz. Uygulama herhangi bir garanti olmaksızın \"olduğu gibi\" sunulmaktadır.\n\nKinna'yı kullanımınız kendi sorumluluğunuzdadır. Uygulama tarafından sağlanan bilgilere dayanarak alınan kararlar veya eylemlerden yalnızca siz sorumlusunuz."
    )

    static let privacySummary = LegalSectionItem(
        id: "privacy-summary",
        number: "6",
        titleEN: "Privacy Summary",
        titleTR: "Gizlilik Özeti",
        bodyEN: "Most of the data you enter in Kinna stays on your device. Subscription purchases are verified through Apple and RevenueCat. See the dedicated Privacy Policy screen for the full breakdown.",
        bodyTR: "Kinna'ya girdiğiniz verilerin büyük bölümü cihazınızda kalır. Abonelik satın alımları Apple ve RevenueCat üzerinden doğrulanır. Ayrıntılar için ayrı Gizlilik Politikası ekranına bakın."
    )

    static let privacyOverview = LegalSectionItem(
        id: "privacy-overview",
        number: "1",
        titleEN: "Overview",
        titleTR: "Genel Bakış",
        bodyEN: "Kinna is designed around local-first data storage. Baby profiles, health logs, notes, milestone progress, and most app activity are stored on your device with SwiftData. Kinna does not run its own backend for this content.",
        bodyTR: "Kinna yerel-veri odaklı tasarlanmıştır. Bebek profili, sağlık logları, notlar, gelişim ilerlemesi ve uygulama içi verilerin büyük bölümü SwiftData ile cihazınızda saklanır. Kinna bu içerikler için kendi sunucusunu çalıştırmaz."
    )

    static let localData = LegalSectionItem(
        id: "privacy-local-data",
        number: "2",
        titleEN: "Data Stored on Your Device",
        titleTR: "Cihazınızda Saklanan Veriler",
        bodyEN: "Kinna can store the following locally on your device:\n- baby profile data (name, date of birth, gender)\n- parent role and app preferences\n- daily logs for feeding, sleep, diaper, and notes\n- growth records such as weight and height\n- vaccination schedules and manual vaccine notes\n- food introduction and allergy logs\n- milestone progress\n\nWe cannot read this content from our own servers because it is not uploaded by the app.",
        bodyTR: "Kinna cihazınızda şu verileri yerel olarak saklayabilir:\n- bebek profili (isim, doğum tarihi, cinsiyet)\n- ebeveyn rolü ve uygulama tercihleri\n- beslenme, uyku, bez ve not kayıtları\n- tartı ve boy gibi büyüme ölçümleri\n- aşı takvimi ve manuel aşı notları\n- ek gıda ve reaksiyon kayıtları\n- gelişim ilerlemesi\n\nBu içerik uygulama tarafından kendi sunucularımıza yüklenmediği için bizim tarafımızdan okunamaz."
    )

    static let childrenPrivacy = LegalSectionItem(
        id: "privacy-children",
        number: "3",
        titleEN: "Children's Privacy",
        titleTR: "Çocuk Verisi ve Gizlilik",
        bodyEN: "Kinna is intended for parents and caregivers, not for direct use by children. Child-related data entered into the app may include sensitive health-related notes such as feeding, sleep, vaccines, growth, and food reactions. That information remains under the control of the parent or caregiver on their device. The app does not knowingly collect children's personal information to a Kinna-operated server.",
        bodyTR: "Kinna çocukların doğrudan kullanımı için değil, ebeveynler ve bakım verenler için tasarlanmıştır. Uygulamaya girilen çocuk verisi; beslenme, uyku, aşı, büyüme ve gıda reaksiyonları gibi hassas sağlıkla ilişkili notları içerebilir. Bu bilgiler ebeveynin veya bakım verenin cihazında onun kontrolünde kalır. Uygulama, çocuklara ait kişisel veriyi Kinna tarafından işletilen bir sunucuya bilerek toplamaz."
    )

    static let thirdParties = LegalSectionItem(
        id: "privacy-third-parties",
        number: "4",
        titleEN: "Third-Party Services and Subscriptions",
        titleTR: "Üçüncü Taraf Servisler ve Abonelikler",
        bodyEN: "Kinna uses RevenueCat for subscription purchase, restore, and entitlement verification. When you start, restore, or validate Kinna Premium, Apple and RevenueCat process subscription transaction data, product identifiers, entitlement status, and an app user identifier needed to determine your premium status. Based on the current app code, Kinna does not send your baby's profile, health logs, food history, milestone progress, or notes to RevenueCat.",
        bodyTR: "Kinna, abonelik satın alma, geri yükleme ve yetki doğrulaması için RevenueCat kullanır. Kinna Premium başlatıldığında, geri yüklendiğinde veya doğrulandığında Apple ve RevenueCat premium durumunu belirlemek için abonelik işlem verisini, ürün kimliklerini, entitlement bilgisini ve gerekli bir uygulama kullanıcı tanımlayıcısını işler. Mevcut uygulama koduna göre Kinna, bebeğinizin profilini, sağlık loglarını, besin geçmişini, gelişim ilerlemesini veya notlarını RevenueCat'e göndermez."
    )

    static let analytics = LegalSectionItem(
        id: "privacy-analytics",
        number: "5",
        titleEN: "Analytics",
        titleTR: "Analitik",
        bodyEN: "Kinna uses PostHog, hosted in the EU (Frankfurt), to collect anonymous usage statistics such as which screens are viewed and which features are used. No personal information, baby data, health records, or device identifiers are included in these analytics events. We do not use advertising SDKs or tracking frameworks. We do not ask for location, contacts, photos, microphone access, or advertising identifiers.\n\nApple may still provide its own App Store or device-level analytics if you enable those settings on your Apple account or device; those services are governed by Apple's own terms.",
        bodyTR: "Kinna, hangi ekranların görüntülendiği ve hangi özelliklerin kullanıldığı gibi anonim kullanım istatistiklerini toplamak için AB'de (Frankfurt) barındırılan PostHog hizmetini kullanır. Bu analitik verilerine kişisel bilgi, bebek verisi, sağlık kaydı veya cihaz tanımlayıcısı dahil edilmez. Reklam SDK'sı veya takip framework'ü kullanmıyoruz. Konum, kişiler, fotoğraflar, mikrofon erişimi veya reklam kimlikleri istenmez.\n\nApple, hesabınızda veya cihazınızda bu ayarlar açıksa kendi App Store veya cihaz seviyesindeki analitiğini sağlayabilir; bu servisler Apple'ın kendi koşullarına tabidir."
    )

    static let deletion = LegalSectionItem(
        id: "privacy-deletion",
        number: "6",
        titleEN: "Retention and Deletion",
        titleTR: "Saklama ve Silme",
        bodyEN: "Local Kinna data remains on your device while the app is installed. At this stage, Kinna does not provide a single in-app erase-all screen for every record type. The reliable way to remove all local Kinna data is to delete the app from your device. Subscription transaction records are additionally handled by Apple and RevenueCat under their own systems and policies.",
        bodyTR: "Yerel Kinna verileri uygulama cihazınızda kurulu olduğu sürece cihazınızda kalır. Bu aşamada Kinna, tüm kayıt türleri için tek bir uygulama içi toplu silme ekranı sunmaz. Tüm yerel Kinna verisini kaldırmanın güvenilir yolu uygulamayı cihazınızdan silmektir. Abonelik işlem kayıtları ayrıca Apple ve RevenueCat tarafından kendi sistemleri ve politikaları kapsamında işlenir."
    )

    static let rights = LegalSectionItem(
        id: "privacy-rights",
        number: "7",
        titleEN: "Your Rights",
        titleTR: "Haklarınız",
        bodyEN: "Because most Kinna data is stored locally on your device, you remain in direct control of that information. You may review and update app content from within the app where editing is available, and you can remove all locally stored Kinna data by deleting the app from your device. For subscription transaction records processed by Apple or RevenueCat, your rights and requests are also subject to those providers' policies and support channels.",
        bodyTR: "Kinna verilerinin büyük bölümü cihazınızda yerel olarak saklandığı için bu bilgiler üzerinde doğrudan kontrol sizdedir. Düzenleme imkanı olan alanlarda uygulama içinden verileri gözden geçirebilir veya güncelleyebilirsiniz; cihazınızdaki tüm yerel Kinna verisini kaldırmak için uygulamayı silebilirsiniz. Apple veya RevenueCat tarafından işlenen abonelik işlem kayıtları için haklarınız ve talepleriniz ayrıca bu sağlayıcıların politikaları ve destek kanallarına tabidir."
    )

    static let contact = LegalSectionItem(
        id: "privacy-contact",
        number: "8",
        titleEN: "Contact",
        titleTR: "İletişim",
        bodyEN: "If you have privacy questions about Kinna, contact: osman.seven97@icloud.com",
        bodyTR: "Kinna gizliliği hakkında sorularınız için iletişim: osman.seven97@icloud.com"
    )
}

#Preview {
    NavigationStack {
        LegalDisclaimerView()
    }
}

enum LegalWebPage: String, Identifiable {
    case terms
    case privacy
    case support

    var id: String { rawValue }

    var url: URL {
        switch self {
        case .terms:
            return AppConstants.Legal.termsURL
        case .privacy:
            return AppConstants.Legal.privacyURL
        case .support:
            return AppConstants.Legal.supportURL
        }
    }

    func title(isEN: Bool) -> String {
        switch self {
        case .terms:
            return isEN ? "Terms of Use" : "Kullanım Koşulları"
        case .privacy:
            return isEN ? "Privacy Policy" : "Gizlilik Politikası"
        case .support:
            return isEN ? "Support" : "Destek"
        }
    }
}

struct LegalWebView: UIViewControllerRepresentable {
    let page: LegalWebPage

    func makeUIViewController(context: Context) -> SFSafariViewController {
        let controller = SFSafariViewController(url: page.url)
        controller.preferredControlTintColor = UIColor(Color.kTerra)
        controller.dismissButtonStyle = .close
        return controller
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
}
