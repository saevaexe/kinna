import SwiftUI
import SwiftData

struct OnboardingView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @AppStorage("parentName") private var parentName = ""
    @AppStorage("childOrder") private var childOrder = 1
    @Environment(\.modelContext) private var modelContext

    @State private var currentStep = 0
    @State private var selectedRole: ParentRole = .mother
    @State private var nameInput = ""
    @State private var babyName = ""
    @State private var birthDay = 1
    @State private var birthMonth = 1
    @State private var birthYear = Calendar.current.component(.year, from: Date())
    @State private var selectedGender: Baby.Gender? = nil

    private let totalSteps = 6

    enum ParentRole: String {
        case mother, father, caregiver
    }

    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $currentStep) {
                welcomeStep.tag(0)
                roleStep.tag(1)
                userNameStep.tag(2)
                babyInfoStep.tag(3)
                childOrderStep.tag(4)
                notificationStep.tag(5)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .scrollDisabled(true)
            .animation(.easeInOut(duration: 0.3), value: currentStep)
        }
        .background(Color.kCream.ignoresSafeArea())
    }

    // MARK: - Step 0: Welcome

    private var welcomeStep: some View {
        VStack(spacing: 0) {
            Spacer()

            // App icon
            RoundedRectangle(cornerRadius: 22)
                .fill(
                    LinearGradient(
                        colors: [Color(hex: 0xD4896A), .kTerra, Color(hex: 0xA85E42)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 72, height: 72)
                .overlay {
                    Text("K")
                        .font(.kinnaDisplay(36, weight: .light))
                        .foregroundStyle(.white.opacity(0.95))
                        .italic()
                }
                .shadow(color: .kTerra.opacity(0.4), radius: 16, y: 5)
                .padding(.bottom, 22)

            // Headline
            (
                Text("Bebeğine en iyi\nbaşlangıcı ver, ")
                    .font(.kinnaDisplay(30))
                    .foregroundStyle(.kChar)
                +
                Text("birlikte.")
                    .font(.kinnaDisplayItalic(30))
                    .foregroundStyle(.kTerra)
            )
            .multilineTextAlignment(.center)
            .lineSpacing(2)
            .padding(.bottom, 10)

            Text("Türkiye'nin ilk duygusal bebek rehberi.\nBilimsel, güvenli, sana özel.")
                .font(.kinnaBody(12, weight: .light))
                .foregroundStyle(.kMid)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.bottom, 24)

            // Trust chips
            HStack(spacing: 6) {
                trustChip("🔬", "WHO onaylı")
                trustChip("🔒", "Veriler sende")
                trustChip("🇹🇷", "T.C. takvimi")
            }

            Spacer()

            // CTA
            Button {
                withAnimation { currentStep = 1 }
            } label: {
                Text("Hadi başlayalım →")
                    .font(.kinnaBodyMedium(14))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(14)
                    .background(
                        LinearGradient(
                            colors: [Color(hex: 0xD4896A), Color(hex: 0xA85E42)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .shadow(color: .kTerra.opacity(0.35), radius: 12, y: 6)
            }

            Button {
                // Future: restore / sign in
            } label: {
                Text("Hesabım var, giriş yap")
                    .font(.kinnaBody(13))
                    .foregroundStyle(.kMid)
                    .padding(.vertical, 10)
                    .frame(maxWidth: .infinity)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.kPale, lineWidth: 1.5)
                    )
            }
            .padding(.top, 8)
            .padding(.bottom, 24)
        }
        .padding(.horizontal, 28)
    }

    // MARK: - Step 1: Role

    private var roleStep: some View {
        VStack(spacing: 0) {
            progressBar(current: 1)
            stepLabel("Adım 1 / 5")

            (
                Text("Sen bebeğin\n")
                    .font(.kinnaDisplay(28))
                    .foregroundStyle(.kChar)
                +
                Text("annesi misin,\n")
                    .font(.kinnaDisplayItalic(28))
                    .foregroundStyle(.kTerra)
                +
                Text("babası mı?")
                    .font(.kinnaDisplay(28))
                    .foregroundStyle(.kChar)
            )
            .lineSpacing(2)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.bottom, 4)

            Text("Sana özel içerikler ve dil hazırlayalım.")
                .font(.kinnaBody(12, weight: .light))
                .foregroundStyle(.kMid)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 20)

            optionCard(
                emoji: "👩", emojiBg: Color(hex: 0xFEF0F5),
                title: "Anneyim", subtitle: "Anne perspektifinden içerik",
                isSelected: selectedRole == .mother
            ) { selectedRole = .mother }

            optionCard(
                emoji: "👨", emojiBg: Color(hex: 0xE8F0F6),
                title: "Babayım", subtitle: "Baba perspektifinden içerik",
                isSelected: selectedRole == .father
            ) { selectedRole = .father }

            optionCard(
                emoji: "🧑", emojiBg: Color.kSage.opacity(0.15),
                title: "Bakım veren", subtitle: "Bakıcı, büyükanne vb.",
                isSelected: selectedRole == .caregiver
            ) { selectedRole = .caregiver }

            Spacer()

            darkButton("Devam →") { currentStep = 2 }
                .padding(.bottom, 32)
        }
        .padding(.horizontal, 24)
    }

    // MARK: - Step 2: User Name

    private var userNameStep: some View {
        VStack(spacing: 0) {
            progressBar(current: 2)
            stepLabel("Adım 2 / 5")

            (
                Text("Sana nasıl\n")
                    .font(.kinnaDisplay(28))
                    .foregroundStyle(.kChar)
                +
                Text("seslenelim?")
                    .font(.kinnaDisplayItalic(28))
                    .foregroundStyle(.kTerra)
            )
            .lineSpacing(2)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.bottom, 4)

            Text("Kinna sana her sabah adınla seslenecek.")
                .font(.kinnaBody(12, weight: .light))
                .foregroundStyle(.kMid)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 20)

            // Illustration
            RoundedRectangle(cornerRadius: 18)
                .fill(
                    LinearGradient(
                        colors: [Color.kPale.opacity(0.5), Color.kTerraLight.opacity(0.4)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(height: 110)
                .overlay {
                    Text("🌸")
                        .font(.system(size: 58))
                }
                .padding(.bottom, 20)

            // Name field
            fieldGroup(label: "ADIN") {
                TextField("Ayşe", text: $nameInput)
                    .font(.kinnaBody(14))
                    .foregroundStyle(.kChar)
            }
            .padding(.bottom, 4)

            Text("Sadece sen göreceksin 🔒")
                .font(.kinnaBody(9))
                .foregroundStyle(.kMuted)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 2)

            Spacer()

            darkButton("Devam →") {
                parentName = nameInput.trimmingCharacters(in: .whitespaces)
                currentStep = 3
            }
            .disabled(nameInput.trimmingCharacters(in: .whitespaces).isEmpty)
            .opacity(nameInput.trimmingCharacters(in: .whitespaces).isEmpty ? 0.5 : 1)
            .padding(.bottom, 32)
        }
        .padding(.horizontal, 24)
        .scrollDismissesKeyboard(.interactively)
    }

    // MARK: - Step 3: Baby Info

    private var babyInfoStep: some View {
        ScrollView {
            VStack(spacing: 0) {
                progressBar(current: 3)
                stepLabel("Adım 3 / 5")

                (
                    Text("Bebeğinle\n")
                        .font(.kinnaDisplay(28))
                        .foregroundStyle(.kChar)
                    +
                    Text("tanışalım.")
                        .font(.kinnaDisplayItalic(28))
                        .foregroundStyle(.kTerra)
                )
                .lineSpacing(2)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 4)

                Text("Kinna'yı bebeğin için kişisel hale getirelim.")
                    .font(.kinnaBody(12, weight: .light))
                    .foregroundStyle(.kMid)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 16)

                // Baby avatar
                ZStack(alignment: .bottomTrailing) {
                    RoundedRectangle(cornerRadius: 22)
                        .fill(
                            LinearGradient(
                                colors: [Color.kTerraLight.opacity(0.4), Color.kPale.opacity(0.5)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 72, height: 72)
                        .overlay {
                            Text("👶")
                                .font(.system(size: 34))
                        }
                        .shadow(color: .black.opacity(0.08), radius: 8, y: 4)

                    Circle()
                        .fill(Color.kTerra)
                        .frame(width: 22, height: 22)
                        .overlay {
                            Text("+")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundStyle(.white)
                        }
                        .overlay(
                            Circle().stroke(Color.kCream, lineWidth: 2.5)
                        )
                        .offset(x: 4, y: 4)
                }
                .padding(.bottom, 16)

                // Baby name
                fieldGroup(label: "BEBEĞİNİN ADI") {
                    TextField("Ela", text: $babyName)
                        .font(.kinnaBody(14))
                        .foregroundStyle(.kChar)
                }
                .padding(.bottom, 14)

                // Birth date segments
                Text("DOĞUM TARİHİ")
                    .font(.kinnaBodyMedium(9))
                    .foregroundStyle(.kMuted)
                    .tracking(1.2)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 2)
                    .padding(.bottom, 6)

                HStack(spacing: 8) {
                    dateSegment(label: "GÜN", value: "\(birthDay)", isActive: true)
                    dateSegment(label: "AY", value: monthAbbreviation(birthMonth), isActive: true)
                    dateSegment(label: "YIL", value: "\(birthYear)", isActive: true)
                }
                .padding(.bottom, 14)

                // Hidden DatePicker for actual input
                DatePicker("", selection: birthDateBinding, in: ...Date(), displayedComponents: .date)
                    .labelsHidden()
                    .datePickerStyle(.compact)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 14)

                // Gender
                Text("CİNSİYET")
                    .font(.kinnaBodyMedium(9))
                    .foregroundStyle(.kMuted)
                    .tracking(1.2)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 2)
                    .padding(.bottom, 6)

                HStack(spacing: 8) {
                    genderPill("Kız", gender: .female)
                    genderPill("Erkek", gender: .male)
                    genderPill("Belirtme", gender: .other)
                }
                .padding(.bottom, 14)

                // Privacy info box
                HStack(alignment: .top, spacing: 10) {
                    Text("🔒")
                        .font(.system(size: 14))
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Veriler sadece sende")
                            .font(.kinnaBodyMedium(10))
                            .foregroundStyle(.kSageDark)
                        Text("Hiçbir sunucuya gönderilmez. Tamamen cihazında.")
                            .font(.kinnaBody(10))
                            .foregroundStyle(.kMid)
                    }
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.kSage.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(Color.kSage.opacity(0.2), lineWidth: 1)
                )
                .padding(.bottom, 20)

                darkButton("Devam →") {
                    saveBaby()
                    currentStep = 4
                }
                .disabled(babyName.trimmingCharacters(in: .whitespaces).isEmpty)
                .opacity(babyName.trimmingCharacters(in: .whitespaces).isEmpty ? 0.5 : 1)
                .padding(.bottom, 32)
            }
            .padding(.horizontal, 24)
        }
        .scrollDismissesKeyboard(.interactively)
    }

    // MARK: - Step 4: Child Order

    private var childOrderStep: some View {
        VStack(spacing: 0) {
            progressBar(current: 4)
            stepLabel("Adım 4 / 5")

            let name = babyName.isEmpty ? "Bebek" : babyName
            (
                Text("\(name) senin\nkaçıncı ")
                    .font(.kinnaDisplay(28))
                    .foregroundStyle(.kChar)
                +
                Text("çocuğun?")
                    .font(.kinnaDisplayItalic(28))
                    .foregroundStyle(.kTerra)
            )
            .lineSpacing(2)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.bottom, 4)

            Text("İlk çocuk deneyimi çok farklı — sana göre içerik hazırlayalım.")
                .font(.kinnaBody(12, weight: .light))
                .foregroundStyle(.kMid)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 24)

            // Number picker
            HStack(spacing: 8) {
                numberButton(1)
                numberButton(2)
                numberButton(3)
                numberButton(4, label: "4+")
            }
            .padding(.bottom, 14)

            // Context info box
            infoBox(
                title: childOrder == 1 ? "İlk bebek 🎉" : "\(childOrder). çocuk",
                body: childOrder == 1
                    ? "Her şey ilk kez. Adım adım seninle olacağız — hiçbir sorun aptalca değil."
                    : "Deneyimin var ama her bebek farklı. Kinna sana güncel bilgi sunacak.",
                style: .terra
            )
            .padding(.bottom, 14)

            // Feature preview
            VStack(alignment: .leading, spacing: 6) {
                Text("Kinna sana şunları sunacak:")
                    .font(.kinnaBodyMedium(10))
                    .foregroundStyle(.kChar)
                    .padding(.bottom, 2)

                featurePreviewRow("📅", "Haftalık gelişim güncellemeleri", Color.kSage.opacity(0.15))
                featurePreviewRow("💉", "Aşı takvimi hatırlatıcıları", Color.kTerraLight.opacity(0.4))
                featurePreviewRow("🧠", "Bilimsel mikro-doz içerik", Color(hex: 0xE8F0F6))
            }
            .padding(14)
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.kPale, lineWidth: 1)
            )

            Spacer()

            darkButton("Devam →") { currentStep = 5 }
                .padding(.bottom, 32)
        }
        .padding(.horizontal, 24)
    }

    // MARK: - Step 5: Notifications

    private var notificationStep: some View {
        VStack(spacing: 0) {
            progressBar(current: 5)
            stepLabel("Son adım")

            let name = babyName.isEmpty ? "Bebek" : babyName
            (
                Text("\(name)'yi\n")
                    .font(.kinnaDisplay(28))
                    .foregroundStyle(.kChar)
                +
                Text("kaçırma.")
                    .font(.kinnaDisplayItalic(28))
                    .foregroundStyle(.kTerra)
            )
            .lineSpacing(2)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.bottom, 4)

            Text("Aşı zamanları, gelişim dönümleri ve günlük motivasyon notun için.")
                .font(.kinnaBody(12, weight: .light))
                .foregroundStyle(.kMid)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 18)

            // Notification previews
            VStack(spacing: 8) {
                notificationCard(
                    time: "şimdi",
                    title: "💉 Beşli Aşı — 3 gün sonra",
                    body: "\(name)'nin Beşli Aşı vakti yaklaşıyor. Randevu aldın mı?"
                )
                notificationCard(
                    time: "sabah 8",
                    title: "🌱 \(name) bugün 2 aylık!",
                    body: "\"Zor günleri geçtin. Bu hafta emzirme düzene giriyor.\""
                )
                notificationCard(
                    time: "öğleden önce",
                    title: "📈 Bu hafta: Kontrast oyunu zamanı",
                    body: "Siyah-beyaz kart göster — 2. ayda nöral bağlar güçleniyor."
                )
            }
            .padding(.bottom, 16)

            Spacer()

            // Permission button
            Button {
                Task {
                    _ = await NotificationManager.shared.requestPermission()
                    NotificationManager.shared.scheduleDailyReminder(hour: 9, minute: 0)
                    hasCompletedOnboarding = true
                }
            } label: {
                Text("Bildirimlere izin ver 🔔")
                    .font(.kinnaBodyMedium(14))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(14)
                    .background(
                        LinearGradient(
                            colors: [Color(hex: 0xD4896A), Color(hex: 0xA85E42)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .shadow(color: .kTerra.opacity(0.35), radius: 12, y: 6)
            }

            Button {
                hasCompletedOnboarding = true
            } label: {
                Text("Şimdi değil")
                    .font(.kinnaBody(13))
                    .foregroundStyle(.kMid)
                    .padding(.vertical, 10)
                    .frame(maxWidth: .infinity)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.kPale, lineWidth: 1.5)
                    )
            }
            .padding(.top, 8)
            .padding(.bottom, 24)
        }
        .padding(.horizontal, 24)
    }

    // MARK: - Save Baby

    private func saveBaby() {
        let name = babyName.trimmingCharacters(in: .whitespaces)
        guard !name.isEmpty else { return }

        var components = DateComponents()
        components.day = birthDay
        components.month = birthMonth
        components.year = birthYear
        let birthDate = Calendar.current.date(from: components) ?? Date()

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

    // MARK: - Date Helpers

    private var birthDateBinding: Binding<Date> {
        Binding(
            get: {
                var components = DateComponents()
                components.day = birthDay
                components.month = birthMonth
                components.year = birthYear
                return Calendar.current.date(from: components) ?? Date()
            },
            set: { newDate in
                let comps = Calendar.current.dateComponents([.day, .month, .year], from: newDate)
                birthDay = comps.day ?? 1
                birthMonth = comps.month ?? 1
                birthYear = comps.year ?? 2025
            }
        )
    }

    private func monthAbbreviation(_ month: Int) -> String {
        let symbols = Calendar.current.shortMonthSymbols
        guard month >= 1, month <= symbols.count else { return "" }
        return symbols[month - 1]
    }

    // MARK: - Components

    private func progressBar(current: Int) -> some View {
        HStack(spacing: 4) {
            ForEach(1...5, id: \.self) { i in
                RoundedRectangle(cornerRadius: 1.5)
                    .fill(
                        i < current ? Color.kTerra :
                        i == current ? Color.kTerra.opacity(0.4) :
                        Color.kPale
                    )
                    .frame(height: 3)
            }
        }
        .padding(.top, 56)
        .padding(.bottom, 6)
    }

    private func stepLabel(_ text: String) -> some View {
        Text(text.uppercased())
            .font(.kinnaBody(9))
            .foregroundStyle(.kMuted)
            .tracking(2)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.bottom, 10)
    }

    private func trustChip(_ emoji: String, _ text: String) -> some View {
        HStack(spacing: 4) {
            Text(emoji)
                .font(.system(size: 11))
            Text(text)
                .font(.kinnaBodyMedium(9))
                .foregroundStyle(.kMid)
        }
        .padding(.horizontal, 9)
        .padding(.vertical, 5)
        .background(Color.kChar.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private func optionCard(
        emoji: String, emojiBg: Color,
        title: String, subtitle: String,
        isSelected: Bool, action: @escaping () -> Void
    ) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) { action() }
        } label: {
            HStack(spacing: 10) {
                RoundedRectangle(cornerRadius: 10)
                    .fill(emojiBg)
                    .frame(width: 34, height: 34)
                    .overlay {
                        Text(emoji)
                            .font(.system(size: 17))
                    }

                VStack(alignment: .leading, spacing: 1) {
                    Text(title)
                        .font(.kinnaBodyMedium(13))
                        .foregroundStyle(.kChar)
                    Text(subtitle)
                        .font(.kinnaBody(10))
                        .foregroundStyle(.kMid)
                }

                Spacer()

                RoundedRectangle(cornerRadius: 6)
                    .fill(isSelected ? Color.kTerra : .white)
                    .frame(width: 19, height: 19)
                    .overlay {
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(isSelected ? Color.clear : Color.kPale, lineWidth: 1.5)
                        if isSelected {
                            Text("✓")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundStyle(.white)
                        }
                    }
            }
            .padding(12)
            .background(isSelected ? Color.kTerraLight.opacity(0.3) : .white)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isSelected ? Color.kTerra : Color.kPale, lineWidth: 1.5)
            )
        }
        .padding(.bottom, 8)
    }

    private func fieldGroup<Content: View>(label: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(label)
                .font(.kinnaBodyMedium(9))
                .foregroundStyle(.kMuted)
                .tracking(1.2)
                .padding(.leading, 2)

            content()
                .padding(.horizontal, 14)
                .padding(.vertical, 11)
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.kTerra, lineWidth: 1.5)
                )
        }
    }

    private func dateSegment(label: String, value: String, isActive: Bool) -> some View {
        VStack(spacing: 2) {
            Text(label)
                .font(.kinnaBody(8))
                .foregroundStyle(.kMuted)
                .tracking(0.8)
            Text(value)
                .font(.kinnaDisplay(18))
                .foregroundStyle(isActive ? .kTerra : .kChar)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 9)
        .background(isActive ? Color.kTerraLight.opacity(0.3) : .white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isActive ? Color.kTerra : Color.kPale, lineWidth: 1.5)
        )
    }

    private func genderPill(_ title: String, gender: Baby.Gender) -> some View {
        let isSelected = selectedGender == gender
        return Button {
            withAnimation(.easeInOut(duration: 0.2)) { selectedGender = gender }
        } label: {
            Text(title)
                .font(.kinnaBody(12))
                .foregroundStyle(isSelected ? .kTerra : .kMid)
                .fontWeight(isSelected ? .medium : .regular)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .padding(.vertical, 9)
                .frame(maxWidth: .infinity)
                .background(isSelected ? Color.kTerraLight.opacity(0.4) : .white)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(isSelected ? Color.kTerra : Color.kPale, lineWidth: 1.5)
                )
        }
    }

    private func numberButton(_ number: Int, label: String? = nil) -> some View {
        let isSelected = childOrder == number
        return Button {
            withAnimation(.easeInOut(duration: 0.2)) { childOrder = number }
        } label: {
            Text(label ?? "\(number).")
                .font(.kinnaDisplay(22))
                .foregroundStyle(isSelected ? .white : .kMid)
                .frame(width: 56, height: 56)
                .background(isSelected ? Color.kTerra : .white)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(isSelected ? Color.clear : Color.kPale, lineWidth: 1.5)
                )
                .shadow(color: isSelected ? .kTerra.opacity(0.3) : .clear, radius: 8, y: 4)
        }
    }

    enum InfoBoxStyle { case terra, sage }

    private func infoBox(title: String, body: String, style: InfoBoxStyle) -> some View {
        let bg = style == .terra ? Color.kTerraLight.opacity(0.3) : Color.kSage.opacity(0.1)
        let border = style == .terra ? Color.kTerra : Color.kSageDark
        let titleColor = style == .terra ? Color.kTerra : Color.kSageDark

        return VStack(alignment: .leading, spacing: 3) {
            Text(title)
                .font(.kinnaBodyMedium(10))
                .foregroundStyle(titleColor)
            Text(body)
                .font(.kinnaBody(10))
                .foregroundStyle(.kMid)
                .lineSpacing(2)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(bg)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(alignment: .leading) {
            Rectangle()
                .fill(border)
                .frame(width: 3)
                .clipShape(RoundedRectangle(cornerRadius: 2))
        }
    }

    private func featurePreviewRow(_ emoji: String, _ text: String, _ bg: Color) -> some View {
        HStack(spacing: 8) {
            RoundedRectangle(cornerRadius: 6)
                .fill(bg)
                .frame(width: 20, height: 20)
                .overlay {
                    Text(emoji)
                        .font(.system(size: 10))
                }
            Text(text)
                .font(.kinnaBody(11))
                .foregroundStyle(.kMid)
        }
    }

    private func notificationCard(time: String, title: String, body: String) -> some View {
        VStack(alignment: .leading, spacing: 7) {
            HStack(spacing: 7) {
                RoundedRectangle(cornerRadius: 7)
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: 0xD4896A), Color(hex: 0xA85E42)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 24, height: 24)
                    .overlay {
                        Text("K")
                            .font(.system(size: 11, weight: .bold, design: .serif))
                            .foregroundStyle(.white)
                            .italic()
                    }
                Text("Kinna")
                    .font(.kinnaBodyMedium(9))
                    .foregroundStyle(.kChar)
                Spacer()
                Text(time)
                    .font(.kinnaBody(8))
                    .foregroundStyle(.kMuted)
            }

            Text(title)
                .font(.kinnaBodyMedium(11))
                .foregroundStyle(.kChar)
            Text(body)
                .font(.kinnaBody(10))
                .foregroundStyle(.kMid)
                .lineSpacing(2)
        }
        .padding(12)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.kPale, lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.05), radius: 6, y: 3)
    }

    private func darkButton(_ title: String, action: @escaping () -> Void) -> some View {
        Button {
            withAnimation { action() }
        } label: {
            Text(title)
                .font(.kinnaBodyMedium(13))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(14)
                .background(Color.kChar)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .shadow(color: .kChar.opacity(0.2), radius: 8, y: 4)
        }
    }
}

#Preview {
    OnboardingView()
        .modelContainer(for: [Baby.self, VaccinationRecord.self], inMemory: true)
}
