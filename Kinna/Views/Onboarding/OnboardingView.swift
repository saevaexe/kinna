import SwiftUI
import SwiftData

struct OnboardingView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @Environment(\.modelContext) private var modelContext

    @State private var currentStep = 0
    @State private var babyName = ""
    @State private var birthDate = Date()
    @State private var selectedGender: Baby.Gender? = nil
    @State private var selectedRole: ParentRole = .mother
    @State private var notificationRequested = false

    private let totalSteps = 6

    enum ParentRole: String {
        case mother, father, other
    }

    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $currentStep) {
                splashStep.tag(0)
                roleStep.tag(1)
                profileStep.tag(2)
                valueStep.tag(3)
                notificationStep.tag(4)
                readyStep.tag(5)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .scrollDisabled(true)
            .animation(.easeInOut(duration: 0.3), value: currentStep)
        }
        .background(Color.kCream.ignoresSafeArea())
    }

    // MARK: - Step 0: Splash

    private var splashStep: some View {
        VStack(spacing: 0) {
            Spacer()

            // Logo
            HStack(spacing: 10) {
                RoundedRectangle(cornerRadius: 13)
                    .fill(Color.kTerra)
                    .frame(width: 40, height: 40)
                    .overlay {
                        Text("K")
                            .font(.kinnaDisplay(22))
                            .foregroundStyle(.white)
                            .italic()
                    }
                    .shadow(color: .kTerra.opacity(0.4), radius: 10, y: 4)

                Text("Kinna")
                    .font(.kinnaDisplay(26))
                    .foregroundStyle(.kChar)
            }
            .padding(.bottom, 40)

            // Headline
            Text("Bebek buyutmek\nzor. Sen ")
                .font(.kinnaDisplay(34))
                .foregroundStyle(.kChar)
            +
            Text("yalniz\n")
                .font(.kinnaDisplayItalic(34))
                .foregroundStyle(.kTerra)
            +
            Text("degilsin.")
                .font(.kinnaDisplay(34))
                .foregroundStyle(.kChar)

            Text("Yanlis bilgiden degil, bilimden beslenen.\nForum gurultusu degil, sana ozel rehberlik.")
                .font(.kinnaBody(13, weight: .light))
                .foregroundStyle(.kMid)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.top, 12)
                .padding(.bottom, 20)

            // Privacy promise
            HStack(spacing: 8) {
                Text("🔒")
                    .font(.system(size: 14))
                Text("Veriler sadece sende kalir.")
                    .font(.kinnaBody(11))
                    .foregroundStyle(.kMid)
                +
                Text(" Hicbir yere gonderilmez.")
                    .font(.kinnaBody(11, weight: .medium))
                    .foregroundStyle(.kChar)
            }
            .padding(12)
            .background(Color.kSage.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.bottom, 20)

            Spacer()

            Button {
                withAnimation { currentStep = 1 }
            } label: {
                Text("Baslayalim")
                    .font(.kinnaBodyMedium(15))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(16)
                    .background(Color.kTerra)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: .kTerra.opacity(0.35), radius: 12, y: 6)
            }

            // Trust strip
            HStack(spacing: 16) {
                trustItem("WHO onayili")
                trustItem("T.C. Asi takvimi")
                trustItem("Ucretsiz dene")
            }
            .padding(.top, 14)
            .padding(.bottom, 16)
        }
        .padding(.horizontal, 28)
    }

    // MARK: - Step 1: Role

    private var roleStep: some View {
        VStack(spacing: 0) {
            stepProgress(current: 1)

            Text("Bu yolculukta\n")
                .font(.kinnaDisplay(26))
                .foregroundStyle(.kChar)
            +
            Text("kim olarak ")
                .font(.kinnaDisplayItalic(26))
                .foregroundStyle(.kTerra)
            +
            Text("geciyorsun?")
                .font(.kinnaDisplay(26))
                .foregroundStyle(.kChar)

            Text("Kinna sana ozel bir deneyim hazirlasin.")
                .font(.kinnaBody(13, weight: .light))
                .foregroundStyle(.kMid)
                .padding(.top, 6)
                .padding(.bottom, 24)

            VStack(spacing: 10) {
                roleCard(
                    emoji: "🤱", title: "Annesiyim",
                    feel: "\"Bugun ne kadar iyi gittigini gormek istiyorum.\"",
                    desc: "Motivasyon, aktiviteler ve gunluk rehberlik",
                    role: .mother, bg: Color.kTerraLight.opacity(0.3)
                )
                roleCard(
                    emoji: "👨‍👧", title: "Babasiyim",
                    feel: "\"Takip edip destek olmak istiyorum.\"",
                    desc: "Saglik verileri, paylasim ve bilgi",
                    role: .father, bg: Color.kSage.opacity(0.1)
                )
                roleCard(
                    emoji: "🫶", title: "Yakin biriyim",
                    feel: "\"Ona destek olmak istiyorum.\"",
                    desc: "Buyukanne, buyukbaba veya bakici",
                    role: .other, bg: Color.kPale.opacity(0.5)
                )
            }

            Spacer()

            onboardingButton("Devam") { currentStep = 2 }
                .padding(.bottom, 40)
        }
        .padding(.horizontal, 28)
    }

    // MARK: - Step 2: Baby Profile

    private var profileStep: some View {
        ScrollView {
            VStack(spacing: 0) {
                stepProgress(current: 2)

                Text("Bebeginle\n")
                    .font(.kinnaDisplay(26))
                    .foregroundStyle(.kChar)
                +
                Text("tanisalim.")
                    .font(.kinnaDisplayItalic(26))
                    .foregroundStyle(.kTerra)

                // Privacy note
                HStack(spacing: 8) {
                    Text("🔒")
                        .font(.system(size: 14))
                    Text("Sadece senin cihazinda.")
                        .font(.kinnaBody(10, weight: .medium))
                        .foregroundStyle(.kChar)
                    +
                    Text(" Hicbir sunucuya gonderilmez.")
                        .font(.kinnaBody(10))
                        .foregroundStyle(.kMid)
                }
                .padding(9)
                .background(Color.kSage.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding(.top, 10)
                .padding(.bottom, 20)

                // Avatar
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.kBlush)
                    .frame(width: 72, height: 72)
                    .overlay {
                        Text("👶")
                            .font(.system(size: 32))
                    }
                    .padding(.bottom, 20)

                // Form
                VStack(spacing: 12) {
                    formField(label: "BEBEK ADI") {
                        TextField("Ela", text: $babyName)
                            .font(.kinnaBody(15))
                            .foregroundStyle(.kChar)
                    }

                    formField(label: "DOGUM TARIHI") {
                        DatePicker("", selection: $birthDate, in: ...Date(), displayedComponents: .date)
                            .labelsHidden()
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text("CINSIYET")
                            .font(.kinnaBodyMedium(10))
                            .foregroundStyle(.kLight)
                            .tracking(1)

                        HStack(spacing: 10) {
                            genderButton("Kiz", gender: .female)
                            genderButton("Erkek", gender: .male)
                            genderButton("Belirtme", gender: .other)
                        }
                    }
                }

                // Warm moment
                if !babyName.trimmingCharacters(in: .whitespaces).isEmpty {
                    HStack(spacing: 12) {
                        Text("🌸")
                            .font(.system(size: 26))
                        VStack(alignment: .leading, spacing: 3) {
                            Text("Merhaba, kucuk \(babyName.trimmingCharacters(in: .whitespaces)).")
                                .font(.kinnaDisplay(16))
                                .foregroundStyle(.kChar)
                            Text("Seninle birlikte buyumek cok guzel olacak.")
                                .font(.kinnaBody(12, weight: .light))
                                .foregroundStyle(.kMid)
                        }
                    }
                    .padding(14)
                    .background(
                        LinearGradient(colors: [.kBlush, Color.kTerraLight.opacity(0.3)], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                    .padding(.top, 16)
                }

                onboardingButton("Devam") {
                    saveBaby()
                    currentStep = 3
                }
                .disabled(babyName.trimmingCharacters(in: .whitespaces).isEmpty)
                .opacity(babyName.trimmingCharacters(in: .whitespaces).isEmpty ? 0.5 : 1)
                .padding(.top, 20)
                .padding(.bottom, 40)
            }
            .padding(.horizontal, 28)
        }
        .scrollDismissesKeyboard(.interactively)
    }

    // MARK: - Step 3: Value Moment (WOW)

    private var valueStep: some View {
        ScrollView {
            VStack(spacing: 0) {
                stepProgress(current: 3)

                // Age hero card
                VStack(alignment: .leading, spacing: 4) {
                    Text(babyName.isEmpty ? "Bebek" : babyName)
                        .font(.kinnaBody(10))
                        .foregroundStyle(.white.opacity(0.35))
                        .tracking(1.5)
                        .textCase(.uppercase)

                    Text(ageDescription)
                        .font(.kinnaDisplay(28))
                        .foregroundStyle(.white)

                    Text("\(ageInDays). gun")
                        .font(.kinnaBody(12))
                        .foregroundStyle(.white.opacity(0.4))

                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 1.5)
                                .fill(.white.opacity(0.08))
                                .frame(height: 3)
                            RoundedRectangle(cornerRadius: 1.5)
                                .fill(Color.kTerra)
                                .frame(width: geo.size.width * monthProgress, height: 3)
                        }
                    }
                    .frame(height: 3)
                    .padding(.top, 12)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(20)
                .background(Color.kChar)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .padding(.bottom, 14)

                // This week expectations
                Text("BU HAFTA BEKLENENLER")
                    .font(.kinnaBodyMedium(10))
                    .foregroundStyle(.kTerra)
                    .tracking(1.5)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 10)

                let items = sampleMilestones
                VStack(spacing: 8) {
                    ForEach(items, id: \.title) { item in
                        HStack(spacing: 10) {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(item.bg)
                                .frame(width: 32, height: 32)
                                .overlay {
                                    Text(item.emoji)
                                        .font(.system(size: 16))
                                }
                            VStack(alignment: .leading, spacing: 2) {
                                Text(item.title)
                                    .font(.kinnaBodyMedium(13))
                                    .foregroundStyle(.kChar)
                                Text(item.desc)
                                    .font(.kinnaBody(11))
                                    .foregroundStyle(.kMid)
                                    .lineSpacing(2)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(12)
                        .background(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color.kPale, lineWidth: 1)
                        )
                    }
                }
                .padding(.bottom, 14)

                // Science badge
                HStack(spacing: 8) {
                    Text("🔬")
                        .font(.system(size: 14))
                    Text("WHO & Harvard kaynakli.")
                        .font(.kinnaBody(11, weight: .medium))
                        .foregroundStyle(.kChar)
                    +
                    Text(" Her bilgi bilimsel literature dayaniyor.")
                        .font(.kinnaBody(11))
                        .foregroundStyle(.kMid)
                }
                .padding(10)
                .background(Color.kBlush)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding(.bottom, 16)

                onboardingButton("Harika, devam et") { currentStep = 4 }
                    .padding(.bottom, 40)
            }
            .padding(.horizontal, 28)
        }
    }

    // MARK: - Step 4: Notification

    private var notificationStep: some View {
        VStack(spacing: 0) {
            stepProgress(current: 4)

            Text("Seni hic\n")
                .font(.kinnaDisplay(26))
                .foregroundStyle(.kChar)
            +
            Text("yalniz birakamayalim.")
                .font(.kinnaDisplayItalic(26))
                .foregroundStyle(.kTerra)

            Text("Sabah uyandiginda seni bekleyen kucuk bir not olsun.")
                .font(.kinnaBody(13, weight: .light))
                .foregroundStyle(.kMid)
                .padding(.top, 6)
                .padding(.bottom, 20)

            // Notification preview
            VStack(spacing: 0) {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(hex: 0x111111))
                    .frame(width: 56, height: 15)
                    .padding(.bottom, 12)

                HStack(spacing: 7) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.kTerra)
                        .frame(width: 20, height: 20)
                        .overlay {
                            Text("K")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(.white)
                        }
                    Text("KINNA")
                        .font(.kinnaBodyMedium(10))
                        .foregroundStyle(.kMid)
                        .tracking(0.5)
                    Spacer()
                    Text("simdi")
                        .font(.kinnaBody(10))
                        .foregroundStyle(.kLight)
                }
                .padding(.bottom, 7)

                Text("\(babyName.isEmpty ? "Bebek" : babyName) bugun \(ageDescription). 🎉")
                    .font(.kinnaBody(12, weight: .medium))
                    .foregroundStyle(.kChar)
                +
                Text("\nBu hafta ilk sosyal gulumsemesini gorebilirsin.")
                    .font(.kinnaBody(12))
                    .foregroundStyle(.kChar)
            }
            .padding(14)
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .padding(.horizontal, 4)
            .padding(14)
            .background(Color.kChar)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .padding(.bottom, 16)

            // Example notifications
            VStack(spacing: 7) {
                notifExample(emoji: "💛", title: "Her sabah bir motivasyon", desc: "\"Sen iyi bir annesin. Mukemmel olmak zorunda degilsin.\"")
                notifExample(emoji: "💉", title: "Asi hatirlatmasi", desc: "\"Besli Asi icin 5 gun kaldi. Randevu almayi unutma.\"")
                notifExample(emoji: "🧠", title: "Gunluk aktivite onerisi", desc: "\"Bugun siyah-beyaz kartlar goster.\"")
            }

            Spacer()

            Button {
                Task {
                    _ = await NotificationManager.shared.requestPermission()
                    notificationRequested = true
                    NotificationManager.shared.scheduleDailyReminder(hour: 9, minute: 0)
                    withAnimation { currentStep = 5 }
                }
            } label: {
                Text("Izin ver")
                    .font(.kinnaBodyMedium(15))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(16)
                    .background(Color.kTerra)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: .kTerra.opacity(0.35), radius: 12, y: 6)
            }

            Button {
                withAnimation { currentStep = 5 }
            } label: {
                Text("Simdi degil")
                    .font(.kinnaBody(13))
                    .foregroundStyle(.kLight)
                    .padding(.vertical, 10)
            }
            .padding(.bottom, 24)
        }
        .padding(.horizontal, 28)
    }

    // MARK: - Step 5: Ready

    private var readyStep: some View {
        VStack(spacing: 0) {
            Spacer()

            // Icon
            RoundedRectangle(cornerRadius: 22)
                .fill(Color.kTerra)
                .frame(width: 68, height: 68)
                .overlay {
                    Text("🤍")
                        .font(.system(size: 34))
                }
                .shadow(color: .kTerra.opacity(0.45), radius: 24, y: 8)
                .padding(.bottom, 32)

            Text("HER SEY HAZIR")
                .font(.kinnaBodyMedium(10))
                .foregroundStyle(.kTerra)
                .tracking(2)
                .padding(.bottom, 10)

            let name = babyName.isEmpty ? "Bebek" : babyName
            let roleText = selectedRole == .mother ? "\(name)'nin annesi" : (selectedRole == .father ? "\(name)'nin babasi" : "\(name)'nin yakini")

            Text("Hos geldin,\n")
                .font(.kinnaDisplay(28))
                .foregroundStyle(.kChar)
            +
            Text("\(roleText).")
                .font(.kinnaDisplayItalic(28))
                .foregroundStyle(.kTerra)

            Text("Bugunden itibaren her sabah seni bekleyen bir rehber var. Yalniz degilsin.")
                .font(.kinnaBody(13, weight: .light))
                .foregroundStyle(.kMid)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.top, 8)
                .padding(.bottom, 20)

            // Summary card
            HStack(spacing: 12) {
                RoundedRectangle(cornerRadius: 13)
                    .fill(Color.kBlush)
                    .frame(width: 42, height: 42)
                    .overlay {
                        Text("👶")
                            .font(.system(size: 20))
                    }
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(name) \u{00B7} \(ageDescription)")
                        .font(.kinnaDisplay(14))
                        .foregroundStyle(.kChar)
                    Text(birthDate, format: .dateTime.day().month(.wide).year())
                        .font(.kinnaBody(11))
                        .foregroundStyle(.kLight)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(14)
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(Color.kTerra.opacity(0.15), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.06), radius: 8, y: 4)

            Spacer()

            Button {
                hasCompletedOnboarding = true
            } label: {
                Text("Kinna'ya git")
                    .font(.kinnaBodyMedium(15))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(16)
                    .background(Color.kTerra)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: .kTerra.opacity(0.35), radius: 12, y: 6)
            }

            HStack(spacing: 16) {
                Text("🔒 Veriler sende")
                Text("🔬 Bilimsel")
                Text("💛 3 gun ucretsiz")
            }
            .font(.kinnaBody(10))
            .foregroundStyle(.kLight)
            .padding(.top, 10)
            .padding(.bottom, 24)
        }
        .padding(.horizontal, 28)
    }

    // MARK: - Save Baby

    private func saveBaby() {
        let name = babyName.trimmingCharacters(in: .whitespaces)
        guard !name.isEmpty else { return }

        let baby = Baby(
            name: name,
            birthDate: birthDate,
            gender: selectedGender ?? .other
        )
        modelContext.insert(baby)

        let schedule = VaccinationEngine.schedule(birthDate: birthDate)
        for item in schedule {
            let record = VaccinationRecord(
                vaccineName: item.nameTR,
                scheduledDate: VaccinationEngine.scheduledDate(birthDate: birthDate, monthAge: item.monthAge)
            )
            modelContext.insert(record)
        }
    }

    // MARK: - Helpers

    private var ageInDays: Int {
        Calendar.current.dateComponents([.day], from: birthDate, to: .now).day ?? 0
    }

    private var ageDescription: String {
        let components = Calendar.current.dateComponents([.year, .month, .day], from: birthDate, to: .now)
        let years = components.year ?? 0
        let months = components.month ?? 0
        let days = components.day ?? 0
        if years > 0 { return "\(years) yil \(months) ay" }
        else if months > 0 { return "\(months) ay \(days) gun" }
        else { return "\(max(0, days)) gun" }
    }

    private var monthProgress: CGFloat {
        let days = ageInDays
        let currentMonthDay = days % 30
        return min(CGFloat(currentMonthDay) / 30.0, 1.0)
    }

    private var sampleMilestones: [(emoji: String, bg: Color, title: String, desc: String)] {
        let months = Calendar.current.dateComponents([.month], from: birthDate, to: .now).month ?? 0
        if months <= 1 {
            return [
                ("👀", Color.kSage.opacity(0.15), "Yuzlere odaklanma", "Yakin mesafeden yuzleri incelemeye baslar."),
                ("✊", Color.kTerraLight.opacity(0.3), "Refleks kavrama", "Parmaginizi avucuna koyun — siki tutar."),
                ("👂", Color(hex: 0xEEE8F5), "Seslere tepki", "Yuksek seslere irkilme refleksi var."),
            ]
        } else if months <= 3 {
            return [
                ("😊", Color.kSage.opacity(0.15), "Sosyal gulumseme", "Yuzunuze bakarak gulumseyebilir."),
                ("🗣️", Color.kTerraLight.opacity(0.3), "Aglama disi sesler", "Ilk \"aguu\" sesleri baslar."),
                ("🏋️", Color(hex: 0xEEE8F5), "Basini 45° kaldirma", "Yuzustu pozisyonda kisa sure tasiyabilir."),
            ]
        } else {
            return [
                ("🤲", Color.kSage.opacity(0.15), "Nesneleri kavrama", "Oyuncaklari bilinçli olarak tutar."),
                ("🔄", Color.kTerraLight.opacity(0.3), "Yuvarlanma", "Sirtustu → yuzustu donebilir."),
                ("😂", Color(hex: 0xEEE8F5), "Kahkaha", "Komik seslere ve yuzlere guler."),
            ]
        }
    }

    // MARK: - Components

    private func stepProgress(current: Int) -> some View {
        VStack(spacing: 0) {
            HStack(spacing: 4) {
                ForEach(1..<5, id: \.self) { i in
                    RoundedRectangle(cornerRadius: 1.5)
                        .fill(i < current ? Color.kTerra : (i == current ? Color.kTerra.opacity(0.35) : Color.kPale))
                        .frame(width: i < current ? 32 : 20, height: 3)
                }
            }
            .padding(.top, 60)
            .padding(.bottom, 8)

            Text("Adim \(current) / 4")
                .font(.kinnaBody(10))
                .foregroundStyle(.kLight)
                .tracking(1.5)
                .textCase(.uppercase)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 12)
        }
    }

    private func onboardingButton(_ title: String, action: @escaping () -> Void) -> some View {
        Button {
            withAnimation { action() }
        } label: {
            Text(title)
                .font(.kinnaBodyMedium(15))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(16)
                .background(Color.kChar)
                .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }

    private func trustItem(_ text: String) -> some View {
        HStack(spacing: 5) {
            Circle()
                .fill(Color.kSage)
                .frame(width: 5, height: 5)
            Text(text)
                .font(.kinnaBody(10))
                .foregroundStyle(.kLight)
        }
    }

    private func roleCard(emoji: String, title: String, feel: String, desc: String, role: ParentRole, bg: Color) -> some View {
        let isSelected = selectedRole == role
        return Button {
            withAnimation(.easeInOut(duration: 0.2)) { selectedRole = role }
        } label: {
            HStack(alignment: .top, spacing: 14) {
                RoundedRectangle(cornerRadius: 15)
                    .fill(bg)
                    .frame(width: 48, height: 48)
                    .overlay {
                        Text(emoji)
                            .font(.system(size: 24))
                    }

                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.kinnaBodyMedium(15))
                        .foregroundStyle(.kChar)
                    Text(feel)
                        .font(.kinnaDisplayItalic(12))
                        .foregroundStyle(.kTerra)
                    Text(desc)
                        .font(.kinnaBody(11))
                        .foregroundStyle(.kLight)
                }

                Spacer()

                Circle()
                    .fill(isSelected ? Color.kTerra : .white)
                    .frame(width: 22, height: 22)
                    .overlay {
                        Circle()
                            .stroke(isSelected ? Color.clear : Color.kPale, lineWidth: 1.5)
                        if isSelected {
                            Text("✓")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundStyle(.white)
                        }
                    }
            }
            .padding(18)
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isSelected ? Color.kTerra : Color.kPale, lineWidth: 1.5)
            )
        }
    }

    private func formField<Content: View>(label: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.kinnaBodyMedium(10))
                .foregroundStyle(.kLight)
                .tracking(1)

            content()
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.kPale, lineWidth: 1.5)
                )
        }
    }

    private func genderButton(_ title: String, gender: Baby.Gender) -> some View {
        let isSelected = selectedGender == gender
        return Button {
            withAnimation(.easeInOut(duration: 0.2)) { selectedGender = gender }
        } label: {
            Text(title)
                .font(.kinnaBody(13))
                .foregroundStyle(isSelected ? .kTerra : .kMid)
                .fontWeight(isSelected ? .medium : .regular)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .padding(12)
                .frame(maxWidth: .infinity)
                .background(isSelected ? Color.kTerraLight.opacity(0.5) : .white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isSelected ? Color.kTerra : Color.kPale, lineWidth: 1.5)
                )
        }
    }

    private func notifExample(emoji: String, title: String, desc: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Text(emoji)
                .font(.system(size: 18))
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.kinnaBodyMedium(12))
                    .foregroundStyle(.kChar)
                Text(desc)
                    .font(.kinnaBody(11))
                    .foregroundStyle(.kMid)
                    .italic()
                    .lineSpacing(2)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.kPale, lineWidth: 1)
        )
    }
}

#Preview {
    OnboardingView()
        .modelContainer(for: [Baby.self, VaccinationRecord.self], inMemory: true)
}
