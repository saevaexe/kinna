import SwiftUI

struct LegalDisclaimerView: View {
    private var isEN: Bool { Locale.current.language.languageCode?.identifier != "tr" }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                VStack(alignment: .leading, spacing: 4) {
                    Text(isEN ? "LEGAL" : "YASAL")
                        .font(.kinnaBody(9))
                        .foregroundStyle(.kMuted)
                        .tracking(1.5)

                    (
                        Text(isEN ? "Terms " : "Kullanım ")
                            .font(.kinnaDisplay(26))
                            .foregroundStyle(.kChar)
                        +
                        Text(isEN ? "& Disclaimer" : "koşulları")
                            .font(.kinnaDisplayItalic(26))
                            .foregroundStyle(.kTerra)
                    )
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 4)

                // Section 1: Not Medical Advice
                legalSection(
                    number: "1",
                    title: isEN ? "Not Medical Advice" : "Tıbbi Tavsiye Değildir",
                    body: isEN
                        ? "Kinna is provided for informational and educational purposes only. The content, including but not limited to developmental milestones, vaccination schedules, feeding information, and parenting tips, does not constitute medical advice, diagnosis, or treatment.\n\nKinna is not intended to be a substitute for professional medical advice, diagnosis, or treatment. Never disregard professional medical advice or delay in seeking it because of something you have read or accessed through Kinna."
                        : "Kinna yalnızca bilgilendirme ve eğitim amaçlı sunulmaktadır. Gelişim taşları, aşı takvimi, beslenme bilgileri ve ebeveynlik ipuçları dahil ancak bunlarla sınırlı olmamak üzere içerikler, tıbbi tavsiye, teşhis veya tedavi niteliği taşımaz.\n\nKinna, profesyonel tıbbi tavsiye, teşhis veya tedavinin yerini tutmak amacıyla tasarlanmamıştır. Kinna üzerinden okuduğunuz veya eriştiğiniz bilgiler nedeniyle profesyonel tıbbi tavsiyeyi göz ardı etmeyin veya geciktirmeyin."
                )

                // Section 2: Consult Your Doctor
                legalSection(
                    number: "2",
                    title: isEN ? "Consult Your Healthcare Provider" : "Sağlık Uzmanınıza Danışın",
                    body: isEN
                        ? "Always seek the advice of your pediatrician or other qualified health provider with any questions you may have regarding your child's health or medical condition. If you think your child may have a medical emergency, call your doctor or emergency services (112) immediately."
                        : "Çocuğunuzun sağlığı veya tıbbi durumu hakkında herhangi bir sorunuz olduğunda her zaman çocuk doktorunuza veya nitelikli bir sağlık uzmanına danışın. Çocuğunuzun acil tıbbi müdahaleye ihtiyacı olduğunu düşünüyorsanız derhal doktorunuzu veya acil servisi (112) arayın."
                )

                // Section 3: Vaccination Schedule
                legalSection(
                    number: "3",
                    title: isEN ? "Vaccination Schedule Disclaimer" : "Aşı Takvimi Sorumluluk Reddi",
                    body: isEN
                        ? "The vaccination schedule provided in Kinna is based on the Republic of Turkey Ministry of Health Childhood Vaccination Program and is calculated approximately based on your baby's date of birth. These dates are estimates only.\n\nActual vaccination dates may vary. Always confirm your child's vaccination schedule with your family physician or pediatrician."
                        : "Kinna'da sunulan aşı takvimi, T.C. Sağlık Bakanlığı Çocukluk Çağı Aşı Programı temel alınarak bebeğinizin doğum tarihine göre yaklaşık olarak hesaplanmaktadır. Bu tarihler yalnızca tahminidir.\n\nGerçek aşı tarihleri farklılık gösterebilir. Çocuğunuzun aşı takvimini her zaman aile hekiminiz veya çocuk doktorunuzla teyit edin."
                )

                // Section 4: Content Sources
                legalSection(
                    number: "4",
                    title: isEN ? "Content Sources" : "İçerik Kaynakları",
                    body: isEN
                        ? "Our content is prepared based on World Health Organization (WHO) guidelines and Republic of Turkey Ministry of Health protocols. While we strive to keep information accurate and up-to-date, we make no representations or warranties of any kind, express or implied, about the completeness, accuracy, reliability, or suitability of the information."
                        : "İçeriklerimiz Dünya Sağlık Örgütü (WHO) rehberleri ve T.C. Sağlık Bakanlığı protokolleri temel alınarak hazırlanmıştır. Bilgilerin doğru ve güncel olması için çaba göstersek de bilgilerin eksiksizliği, doğruluğu, güvenilirliği veya uygunluğu hakkında açık veya zımni hiçbir garanti vermemekteyiz."
                )

                // Section 5: Limitation of Liability
                legalSection(
                    number: "5",
                    title: isEN ? "Limitation of Liability" : "Sorumluluk Sınırlaması",
                    body: isEN
                        ? "Kinna and its developers shall not be liable for any direct, indirect, incidental, consequential, or special damages arising out of or in connection with the use of this application or reliance on its content. The application is provided \"as is\" without warranties of any kind.\n\nYour use of Kinna is at your own risk. You are solely responsible for any decisions or actions taken based on information provided by the application."
                        : "Kinna ve geliştiricileri, bu uygulamanın kullanımından veya içeriğine güvenilmesinden kaynaklanan veya bunlarla bağlantılı herhangi bir doğrudan, dolaylı, arızi, sonuç olarak ortaya çıkan veya özel zarardan sorumlu tutulamaz. Uygulama herhangi bir garanti olmaksızın \"olduğu gibi\" sunulmaktadır.\n\nKinna'yı kullanımınız kendi sorumluluğunuzdadır. Uygulama tarafından sağlanan bilgilere dayanarak alınan kararlar veya eylemlerden yalnızca siz sorumlusunuz."
                )

                // Section 6: Data Privacy
                legalSection(
                    number: "6",
                    title: isEN ? "Data Privacy" : "Veri Gizliliği",
                    body: isEN
                        ? "All data you enter in Kinna stays on your device. We do not collect, store, or transmit any personal information to external servers. No third-party analytics or tracking SDKs are used."
                        : "Kinna'ya girdiğiniz tüm veriler cihazınızda kalır. Kişisel bilgilerinizi harici sunuculara toplamaz, saklamaz veya iletmeyiz. Üçüncü taraf analitik veya takip SDK'ları kullanılmamaktadır."
                )

                // Emergency box
                HStack(alignment: .top, spacing: 10) {
                    Text("🚨")
                        .font(.system(size: 16))
                    VStack(alignment: .leading, spacing: 2) {
                        Text(isEN ? "In an emergency" : "Acil durumda")
                            .font(.kinnaBodyMedium(12))
                            .foregroundStyle(Color(hex: 0xC44A4A))
                        Text(isEN
                            ? "If you believe your child needs immediate medical attention, call 112 or go to the nearest emergency room."
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

                // Last updated
                Text(isEN ? "Last updated: March 2026" : "Son güncelleme: Mart 2026")
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

#Preview {
    NavigationStack {
        LegalDisclaimerView()
    }
}
