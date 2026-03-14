import SwiftUI
import SwiftData

struct OnboardingView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @AppStorage("parentName") private var parentName = ""
    @AppStorage("childOrder") private var childOrder = 1
    @AppStorage("parentRole") private var storedParentRole = ParentRole.mother.rawValue
    @Environment(\.modelContext) private var modelContext
    @Environment(SubscriptionManager.self) private var subscriptionManager

    @State private var currentStep = 0
    @State private var selectedRole: ParentRole = .mother
    @State private var nameInput = ""
    @State private var babyName = ""
    @State private var birthDay = Calendar.current.component(.day, from: Date())
    @State private var birthMonth = Calendar.current.component(.month, from: Date())
    @State private var birthYear = Calendar.current.component(.year, from: Date())
    @State private var selectedGender: Baby.Gender? = nil
    @State private var disclaimerAccepted = false
    @State private var showCompletionPaywall = false
    @State private var showBirthDatePicker = false

    private let totalSteps = 5
    private var setupStepCount: Int { totalSteps - 1 }

    private var isEN: Bool { Locale.current.language.languageCode?.identifier != "tr" }

    private var onboardingBirthDate: Date {
        var components = DateComponents()
        components.day = birthDay
        components.month = birthMonth
        components.year = birthYear
        return Calendar.current.date(from: components) ?? Date()
    }

    private var summaryBabyName: String {
        let trimmed = babyName.trimmingCharacters(in: .whitespaces)
        return trimmed.isEmpty ? (isEN ? "Baby" : "Bebek") : trimmed
    }

    private var onboardingAgeInMonths: Int {
        Calendar.current.dateComponents([.month], from: onboardingBirthDate, to: .now).month ?? 0
    }

    private var birthDateText: String {
        onboardingBirthDate.formatted(.dateTime.day().month(.wide).year())
    }

    private var onboardingAgeDescription: String {
        let components = Calendar.current.dateComponents([.year, .month, .day], from: onboardingBirthDate, to: .now)
        let years = components.year ?? 0
        let months = components.month ?? 0
        let days = components.day ?? 0

        if isEN {
            if years > 0 {
                return "\(years) yr \(months) mo"
            } else if months > 0 {
                return "\(months) mo \(days) days"
            } else {
                return "\(days) days"
            }
        } else {
            if years > 0 {
                return "\(years) yıl \(months) ay"
            } else if months > 0 {
                return "\(months) ay \(days) gün"
            } else {
                return "\(days) gün"
            }
        }
    }

    private var milestoneFocus: Milestone? {
        MilestoneEngine.milestonesForAge(onboardingAgeInMonths).first
    }

    private var safetyFocus: SafetyAlert? {
        SafetyAlertEngine.alertsForAge(onboardingAgeInMonths).first
    }

    private var upcomingScheduledVaccine: (item: VaccinationItem, date: Date)? {
        let startOfToday = Calendar.current.startOfDay(for: .now)
        let schedule = VaccinationEngine.schedule(birthDate: onboardingBirthDate)
            .map { item in
                (
                    item: item,
                    date: VaccinationEngine.scheduledDate(
                        birthDate: onboardingBirthDate,
                        monthAge: item.monthAge
                    )
                )
            }
            .sorted { $0.date < $1.date }

        return schedule.first(where: { $0.date >= startOfToday })
    }

    enum ParentRole: String {
        case mother, father, caregiver
    }

    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $currentStep) {
                welcomeStep.tag(0)
                roleStep.tag(1)
                familyInfoStep.tag(2)
                safetyNoteStep.tag(3)
                valueSummaryStep.tag(4)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .scrollDisabled(true)
            .animation(.easeInOut(duration: 0.3), value: currentStep)
        }
        .background(Color.kCream.ignoresSafeArea())
        .onAppear {
            selectedRole = ParentRole(rawValue: storedParentRole) ?? .mother
            nameInput = parentName
        }
        .sheet(isPresented: $showBirthDatePicker) {
            NavigationStack {
                VStack(spacing: 0) {
                    DatePicker(
                        "",
                        selection: birthDateBinding,
                        in: ...Date(),
                        displayedComponents: .date
                    )
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    .frame(maxWidth: .infinity)
                    .padding(.top, 12)

                    darkButton(isEN ? "Done" : "Tamam") {
                        showBirthDatePicker = false
                    }
                    .padding(20)
                }
                .background(Color.kCream.ignoresSafeArea())
                .navigationTitle(isEN ? "Date of birth" : "Doğum tarihi")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(isEN ? "Done" : "Tamam") {
                            showBirthDatePicker = false
                        }
                    }
                }
            }
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
        }
        .fullScreenCover(isPresented: $showCompletionPaywall, onDismiss: {
            hasCompletedOnboarding = true
        }) {
            NavigationStack {
                PaywallView(entryPoint: .onboarding)
            }
            .environment(subscriptionManager)
        }
    }

    // MARK: - Step 0: Welcome

    private var welcomeStep: some View {
        VStack(spacing: 0) {
            Spacer()

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

            (
                Text(isEN ? "Give your baby\nthe best start, " : "Bebeğine en iyi\nbaşlangıcı ver, ")
                    .font(.kinnaDisplay(30))
                    .foregroundStyle(.kChar)
                +
                Text(isEN ? "together." : "birlikte.")
                    .font(.kinnaDisplayItalic(30))
                    .foregroundStyle(.kTerra)
            )
            .multilineTextAlignment(.center)
            .lineSpacing(2)
            .padding(.bottom, 10)

            Text(isEN ? "Turkey's first emotional baby guide.\nScientific, safe, personalized." : "Türkiye'nin ilk duygusal bebek rehberi.\nBilimsel, güvenli, sana özel.")
                .font(.kinnaBody(12, weight: .light))
                .foregroundStyle(.kMid)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.bottom, 24)

            HStack(spacing: 6) {
                trustChip("🔬", isEN ? "WHO based" : "WHO temelli")
                trustChip("🔒", isEN ? "On-device data" : "Veri cihazında")
                trustChip("🇹🇷", isEN ? "TR vaccine plan" : "T.C. aşı planı")
            }

            Spacer()

            Button {
                withAnimation { currentStep = 1 }
            } label: {
                Text(isEN ? "Let's start →" : "Hadi başlayalım →")
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
            .padding(.bottom, 24)
        }
        .padding(.horizontal, 28)
    }

    // MARK: - Step 1: Role

    private var roleStep: some View {
        VStack(spacing: 0) {
            progressBar(current: 1)
            stepLabel(stepIndicatorText(for: 1))

            (
                Text(isEN ? "What's your role\n" : "Bebeğin için\n")
                    .font(.kinnaDisplay(28))
                    .foregroundStyle(.kChar)
                +
                Text(isEN ? "for your baby?" : "rolün ne?")
                    .font(.kinnaDisplayItalic(28))
                    .foregroundStyle(.kTerra)
            )
            .lineSpacing(2)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.bottom, 4)

            Text(isEN ? "We'll shape the language and guidance around you." : "Dili ve rehberliği sana göre şekillendirelim.")
                .font(.kinnaBody(12, weight: .light))
                .foregroundStyle(.kMid)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 20)

            optionCard(
                emoji: "👩", emojiBg: Color(hex: 0xFEF0F5),
                title: isEN ? "I'm the mother" : "Anneyim",
                subtitle: isEN ? "Content from mother's perspective" : "Anne perspektifinden içerik",
                isSelected: selectedRole == .mother
            ) { selectedRole = .mother }

            optionCard(
                emoji: "👨", emojiBg: Color(hex: 0xE8F0F6),
                title: isEN ? "I'm the father" : "Babayım",
                subtitle: isEN ? "Content from father's perspective" : "Baba perspektifinden içerik",
                isSelected: selectedRole == .father
            ) { selectedRole = .father }

            optionCard(
                emoji: "🧑", emojiBg: Color.kSage.opacity(0.15),
                title: isEN ? "Caregiver" : "Bakım veren",
                subtitle: isEN ? "Nanny, grandparent, etc." : "Bakıcı, büyükanne vb.",
                isSelected: selectedRole == .caregiver
            ) { selectedRole = .caregiver }

            Spacer()

            darkButton(isEN ? "Continue →" : "Devam →") {
                storedParentRole = selectedRole.rawValue
                currentStep = 2
            }
            .padding(.bottom, 32)
        }
        .padding(.horizontal, 24)
    }

    // MARK: - Step 2: Family Info

    private var familyInfoStep: some View {
        ScrollView {
            VStack(spacing: 0) {
                progressBar(current: 2)
                stepLabel(stepIndicatorText(for: 2))

                (
                    Text(isEN ? "Let's set up\nyour " : "Seni ve\nbebeğini ")
                        .font(.kinnaDisplay(28))
                        .foregroundStyle(.kChar)
                    +
                    Text(isEN ? "family." : "tanıyalım.")
                        .font(.kinnaDisplayItalic(28))
                        .foregroundStyle(.kTerra)
                )
                .lineSpacing(2)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 4)

                Text(isEN ? "We'll personalize Kinna for both of you in one quick step." : "Kinna'yı ikiniz için de tek adımda kişiselleştirelim.")
                    .font(.kinnaBody(12, weight: .light))
                    .foregroundStyle(.kMid)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 18)

                familyHeroCard
                    .padding(.bottom, 18)

                fieldGroup(label: isEN ? "YOUR NAME" : "ADIN") {
                    TextField(isEN ? "Jane" : "Ayşe", text: $nameInput)
                        .font(.kinnaBody(14))
                        .foregroundStyle(.kChar)
                }
                .padding(.bottom, 4)

                Text(isEN ? "Only you will see this 🔒" : "Sadece sen göreceksin 🔒")
                    .font(.kinnaBody(9))
                    .foregroundStyle(.kMuted)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 2)
                    .padding(.bottom, 14)

                fieldGroup(label: isEN ? "BABY'S NAME" : "BEBEĞİNİN ADI") {
                    TextField("Ela", text: $babyName)
                        .font(.kinnaBody(14))
                        .foregroundStyle(.kChar)
                }
                .padding(.bottom, 14)

                Text(isEN ? "DATE OF BIRTH" : "DOĞUM TARİHİ")
                    .font(.kinnaBodyMedium(9))
                    .foregroundStyle(.kMuted)
                    .tracking(1.2)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 2)
                    .padding(.bottom, 6)

                HStack(spacing: 8) {
                    dateSegment(label: isEN ? "DAY" : "GÜN", value: "\(birthDay)")
                    dateSegment(label: isEN ? "MONTH" : "AY", value: monthAbbreviation(birthMonth))
                    dateSegment(label: isEN ? "YEAR" : "YIL", value: "\(birthYear)")
                }
                .padding(.bottom, 14)

                birthDatePickerField
                    .padding(.bottom, 14)

                Text(isEN ? "GENDER" : "CİNSİYET")
                    .font(.kinnaBodyMedium(9))
                    .foregroundStyle(.kMuted)
                    .tracking(1.2)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 2)
                    .padding(.bottom, 6)

                HStack(spacing: 8) {
                    genderPill(isEN ? "Girl" : "Kız", gender: .female)
                    genderPill(isEN ? "Boy" : "Erkek", gender: .male)
                    genderPill(isEN ? "Prefer not to say" : "Belirtme", gender: .other)
                }
                .padding(.bottom, 14)

                privacyInfoBox
                    .padding(.bottom, 20)

                darkButton(isEN ? "Continue →" : "Devam →") {
                    parentName = nameInput.trimmingCharacters(in: .whitespaces)
                    saveBaby()
                    currentStep = 3
                }
                .disabled(
                    nameInput.trimmingCharacters(in: .whitespaces).isEmpty ||
                    babyName.trimmingCharacters(in: .whitespaces).isEmpty
                )
                .opacity(
                    nameInput.trimmingCharacters(in: .whitespaces).isEmpty ||
                    babyName.trimmingCharacters(in: .whitespaces).isEmpty ? 0.5 : 1
                )
                .padding(.bottom, 32)
            }
            .padding(.horizontal, 24)
        }
        .scrollDismissesKeyboard(.interactively)
    }

    // MARK: - Step 3: Safety Note

    private var safetyNoteStep: some View {
        VStack(spacing: 0) {
            progressBar(current: 3)
            stepLabel(stepIndicatorText(for: 3))

            (
                Text(isEN ? "One quick\n" : "Başlamadan önce\n")
                    .font(.kinnaDisplay(28))
                    .foregroundStyle(.kChar)
                +
                Text(isEN ? "safety note." : "kısa bir not.")
                    .font(.kinnaDisplayItalic(28))
                    .foregroundStyle(.kTerra)
            )
            .lineSpacing(2)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.bottom, 4)

            Text(isEN ? "Kinna supports you with trusted information, but it never replaces your doctor." : "Kinna güvenilir bilgi sunar, ama doktorunun yerini asla tutmaz.")
                .font(.kinnaBody(12, weight: .light))
                .foregroundStyle(.kMid)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 18)

            compactSafetyCard

            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    disclaimerAccepted.toggle()
                }
            } label: {
                HStack(spacing: 10) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(disclaimerAccepted ? Color.kSage : .white)
                        .frame(width: 22, height: 22)
                        .overlay {
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(disclaimerAccepted ? Color.clear : Color.kPale, lineWidth: 1.5)
                            if disclaimerAccepted {
                                Text("✓")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundStyle(.white)
                            }
                        }

                    Text(isEN
                        ? "I understand that Kinna is for informational use and does not replace medical advice."
                        : "Kinna'nın bilgilendirme amaçlı olduğunu ve tıbbi tavsiye yerine geçmediğini anlıyorum.")
                        .font(.kinnaBody(11))
                        .foregroundStyle(.kChar)
                        .multilineTextAlignment(.leading)
                }
            }
            .padding(.bottom, 14)

            Spacer(minLength: 24)

            darkButton(isEN ? "Continue →" : "Devam →") { currentStep = 4 }
                .disabled(!disclaimerAccepted)
                .opacity(disclaimerAccepted ? 1 : 0.5)
                .padding(.bottom, 32)
        }
        .padding(.horizontal, 24)
    }

    // MARK: - Step 4: Value Summary

    private var valueSummaryStep: some View {
        ScrollView {
            VStack(spacing: 0) {
                progressBar(current: 4)
                stepLabel(stepIndicatorText(for: 4))

                (
                    Text(isEN ? "\(summaryBabyName) is \(onboardingAgeDescription).\n" : "\(summaryBabyName) \(onboardingAgeDescription).\n")
                        .font(.kinnaDisplay(28))
                        .foregroundStyle(.kChar)
                    +
                    Text(isEN ? "Here's what matters now." : "Şimdi en çok bunlar önemli.")
                        .font(.kinnaDisplayItalic(28))
                        .foregroundStyle(.kTerra)
                )
                .lineSpacing(2)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 4)

                Text(isEN ? "We prepared a gentle plan for this month before you enter Kinna." : "Kinna'ya girmeden önce bu ay için kısa bir plan hazırladık.")
                    .font(.kinnaBody(12, weight: .light))
                    .foregroundStyle(.kMid)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 18)

                VStack(spacing: 10) {
                    if let milestoneFocus {
                        valueSummaryCard(
                            icon: "🧠",
                            iconBackground: Color(hex: 0xEAF3EF),
                            title: isEN ? "Development focus" : "Gelişim odağı",
                            body: isEN ? milestoneFocus.descriptionEN : milestoneFocus.descriptionTR
                        )
                    }

                    if let upcomingScheduledVaccine {
                        valueSummaryCard(
                            icon: "💉",
                            iconBackground: Color.kTerraLight.opacity(0.45),
                            title: isEN ? "Upcoming vaccine" : "Yaklaşan aşı",
                            body: vaccineSummaryBody(upcomingScheduledVaccine)
                        )
                    }

                    valueSummaryCard(
                        icon: "🌿",
                        iconBackground: Color.kSage.opacity(0.15),
                        title: isEN ? "Gentle reminder" : "Kısa rehber",
                        body: guideSummaryBody
                    )
                }
                .padding(.bottom, 18)

                Text(isEN ? "Would you like Kinna to remind you at the right time?" : "Kinna bunları sana zamanında hatırlatsın mı?")
                    .font(.kinnaBodyMedium(12))
                    .foregroundStyle(.kChar)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 10)

                VStack(spacing: 8) {
                    notificationCard(
                        time: upcomingScheduledVaccine.map { relativeNotificationTimeText(for: $0.date) } ?? (isEN ? "this month" : "bu ay"),
                        title: upcomingScheduledVaccine.map { vaccineNotificationTitle(for: $0.item) } ?? (isEN ? "💉 Vaccine timing" : "💉 Aşı zamanı"),
                        body: upcomingScheduledVaccine.map { vaccineNotificationBody(for: $0) } ?? (isEN
                            ? "We'll remind you before each scheduled vaccine so you can plan ahead."
                            : "Her planlı aşıdan önce haber verip önceden plan yapmana yardımcı oluruz.")
                    )
                    notificationCard(
                        time: isEN ? "morning" : "sabah",
                        title: isEN ? "🌱 Today's gentle nudge" : "🌱 Günün küçük notu",
                        body: milestoneFocus.map { isEN ? $0.descriptionEN : $0.descriptionTR } ?? (isEN
                            ? "You'll see one useful development note that matches your baby's age."
                            : "Bebeğinin yaşına uygun tek bir faydalı gelişim notu göreceksin.")
                    )
                }
                .padding(.bottom, 16)

                Button {
                    Task {
                        let granted = await NotificationManager.shared.requestPermission()
                        if granted {
                            NotificationManager.shared.scheduleDailyReminder(hour: 9, minute: 0)
                        }
                        completeOnboarding()
                    }
                } label: {
                    Text(isEN ? "Allow notifications 🔔" : "Bildirimlere izin ver 🔔")
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
                    completeOnboarding()
                } label: {
                    Text(isEN ? "Not now" : "Şimdi değil")
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
    }

    // MARK: - Save Baby

    private func saveBaby() {
        let trimmedBabyName = babyName.trimmingCharacters(in: .whitespaces)
        guard !trimmedBabyName.isEmpty else { return }

        let birthDate = onboardingBirthDate
        let descriptor = FetchDescriptor<Baby>()
        let babies = (try? modelContext.fetch(descriptor)) ?? []

        let alreadyExists = babies.contains {
            $0.name == trimmedBabyName && Calendar.current.isDate($0.birthDate, inSameDayAs: birthDate)
        }

        if !alreadyExists {
            let baby = Baby(
                name: trimmedBabyName,
                birthDate: birthDate,
                gender: selectedGender ?? .other
            )
            modelContext.insert(baby)
        }

        let vaccinationDescriptor = FetchDescriptor<VaccinationRecord>()
        let existingRecords = (try? modelContext.fetch(vaccinationDescriptor)) ?? []
        let existingNames = Set(existingRecords.map { $0.vaccineName })

        let schedule = VaccinationEngine.schedule(birthDate: birthDate)
        for item in schedule where !existingNames.contains(item.nameTR) {
            let record = VaccinationRecord(
                vaccineName: item.nameTR,
                scheduledDate: VaccinationEngine.scheduledDate(birthDate: birthDate, monthAge: item.monthAge)
            )
            modelContext.insert(record)
        }
    }

    private func completeOnboarding() {
        storedParentRole = selectedRole.rawValue
        showCompletionPaywall = true
    }

    // MARK: - Summary Helpers

    private var guideSummaryBody: String {
        if let safetyFocus {
            return isEN ? safetyFocus.descriptionEN : safetyFocus.descriptionTR
        }

        if isEN {
            return "We'll surface one timely sleep, feeding, or safety reminder when it matters most."
        }
        return "Uyku, beslenme veya güvenlik için tam zamanında tek bir hatırlatma göstereceğiz."
    }

    private func vaccineSummaryBody(_ upcoming: (item: VaccinationItem, date: Date)) -> String {
        let dateText = upcoming.date.formatted(.dateTime.day().month(.wide))
        if isEN {
            return "\(upcoming.item.nameEN) is expected around \(dateText)."
        }
        return "\(upcoming.item.nameTR) için beklenen tarih \(dateText)."
    }

    private func vaccineNotificationTitle(for item: VaccinationItem) -> String {
        if isEN {
            return "💉 \(item.nameEN) is coming up"
        }
        return "💉 \(item.nameTR) yaklaşıyor"
    }

    private func vaccineNotificationBody(for upcoming: (item: VaccinationItem, date: Date)) -> String {
        if isEN {
            return "We'll nudge you before \(upcoming.item.nameEN) so you can schedule it calmly."
        }
        return "\(upcoming.item.nameTR) öncesinde sakin sakin plan yapman için sana haber vereceğiz."
    }

    private func relativeNotificationTimeText(for date: Date) -> String {
        let dayCount = Calendar.current.dateComponents([.day], from: Calendar.current.startOfDay(for: .now), to: Calendar.current.startOfDay(for: date)).day ?? 0

        if isEN {
            switch dayCount {
            case ..<0: return "soon"
            case 0: return "today"
            case 1: return "tomorrow"
            default: return "in \(dayCount) days"
            }
        }

        switch dayCount {
        case ..<0: return "yakında"
        case 0: return "bugün"
        case 1: return "yarın"
        default: return "\(dayCount) gün sonra"
        }
    }

    // MARK: - Date Helpers

    private var birthDateBinding: Binding<Date> {
        Binding(
            get: { onboardingBirthDate },
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

    private var privacyInfoBox: some View {
        HStack(alignment: .top, spacing: 10) {
            Text("🔒")
                .font(.system(size: 14))
            VStack(alignment: .leading, spacing: 2) {
                Text(isEN ? "Data stays with you" : "Veriler sadece sende")
                    .font(.kinnaBodyMedium(10))
                    .foregroundStyle(.kSageDark)
                Text(isEN ? "Never sent to any server. Stays on your device." : "Hiçbir sunucuya gönderilmez. Tamamen cihazında.")
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
    }

    private var familyHeroCard: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 18)
                .fill(roleHeroBackground)
                .frame(width: 76, height: 76)
                .overlay {
                    Text(roleHeroEmoji)
                        .font(.system(size: 36))
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(roleHeroBorder, lineWidth: 1)
                )

            VStack(alignment: .leading, spacing: 5) {
                Text(isEN ? "A few details, then you're in." : "Birkaç bilgi, sonra hazırsın.")
                    .font(.kinnaBodyMedium(12))
                    .foregroundStyle(.kChar)

                Text(isEN ? "Kinna will shape the home feed, reminders, and language around your family." : "Kinna ana ekranı, hatırlatmaları ve dili ailenize göre şekillendirecek.")
                    .font(.kinnaBody(10))
                    .foregroundStyle(.kMid)
                    .lineSpacing(2)

                HStack(spacing: 6) {
                    miniTag(text: selectedRoleLabel)
                    miniTag(text: isEN ? "Private" : "Özel")
                }
            }

            Spacer(minLength: 0)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(
                colors: [.white.opacity(0.85), Color.kTerraLight.opacity(0.18)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.kPale, lineWidth: 1)
        )
    }

    private var selectedRoleLabel: String {
        switch selectedRole {
        case .mother:
            return isEN ? "Mother" : "Anne"
        case .father:
            return isEN ? "Father" : "Baba"
        case .caregiver:
            return isEN ? "Caregiver" : "Bakım veren"
        }
    }

    private var roleHeroEmoji: String {
        switch selectedRole {
        case .mother:
            return "👩"
        case .father:
            return "👨"
        case .caregiver:
            return "🧑"
        }
    }

    private var roleHeroBackground: Color {
        switch selectedRole {
        case .mother:
            return Color(hex: 0xFBE7DD)
        case .father:
            return Color(hex: 0xE8F0F6)
        case .caregiver:
            return Color.kSage.opacity(0.2)
        }
    }

    private var roleHeroBorder: Color {
        switch selectedRole {
        case .mother:
            return Color.kTerra.opacity(0.14)
        case .father:
            return Color(hex: 0x7F95A8).opacity(0.18)
        case .caregiver:
            return Color.kSageDark.opacity(0.16)
        }
    }

    private func miniTag(text: String) -> some View {
        Text(text)
            .font(.kinnaBodyMedium(8))
            .foregroundStyle(.kMid)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.kChar.opacity(0.05))
            .clipShape(Capsule())
    }

    private var birthDatePickerField: some View {
        Button {
            showBirthDatePicker = true
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "calendar")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.kTerra)

                Text(birthDateText)
                    .font(.kinnaBody(13))
                    .foregroundStyle(.kChar)

                Spacer()

                Text(isEN ? "Change" : "Değiştir")
                    .font(.kinnaBodyMedium(11))
                    .foregroundStyle(.kTerra)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.kPale, lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var compactSafetyCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.kTerraLight.opacity(0.4))
                    .frame(width: 34, height: 34)
                    .overlay {
                        Text("🩺")
                            .font(.system(size: 18))
                    }

                VStack(alignment: .leading, spacing: 2) {
                    Text(isEN ? "Safe and science-based guidance" : "Güvenli ve bilimsel rehberlik")
                        .font(.kinnaBodyMedium(12))
                        .foregroundStyle(.kChar)
                    Text(isEN ? "A quick promise before you begin." : "Başlamadan önce kısa bir sözleşme.")
                        .font(.kinnaBody(10))
                        .foregroundStyle(.kMid)
                }
            }

            safetyBullet(
                icon: "•",
                text: isEN
                ? "Kinna is for informational use and does not replace medical advice."
                : "Kinna bilgilendirme amaçlıdır ve tıbbi tavsiyenin yerini tutmaz."
            )
            safetyBullet(
                icon: "•",
                text: isEN
                ? "For health concerns or exact vaccine timing, always confirm with your pediatrician."
                : "Sağlık endişelerinde ve kesin aşı zamanlarında mutlaka doktoruna danış."
            )
            safetyBullet(
                icon: "•",
                text: isEN
                ? "Content is built from WHO guidance and Turkey Ministry of Health vaccination protocols."
                : "İçerik WHO rehberleri ve T.C. Sağlık Bakanlığı aşı protokolleri temel alınarak hazırlanır."
            )
            safetyBullet(
                icon: "•",
                text: isEN ? "In emergencies, call 112." : "Acil durumda 112'yi ara."
            )
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.kPale, lineWidth: 1)
        )
        .padding(.bottom, 18)
    }

    private func safetyBullet(icon: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Text(icon)
                .font(.kinnaBodyMedium(11))
                .foregroundStyle(.kTerra)
                .padding(.top, 1)
            Text(text)
                .font(.kinnaBody(10))
                .foregroundStyle(.kMid)
                .lineSpacing(2)
        }
    }

    private func progressBar(current: Int) -> some View {
        HStack(spacing: 4) {
            ForEach(1...setupStepCount, id: \.self) { i in
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

    private func stepIndicatorText(for current: Int) -> String {
        if isEN {
            return "Step \(current) / \(setupStepCount)"
        }
        return "Adım \(current) / \(setupStepCount)"
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

    private func dateSegment(label: String, value: String) -> some View {
        VStack(spacing: 2) {
            Text(label)
                .font(.kinnaBody(8))
                .foregroundStyle(.kMuted)
                .tracking(0.8)
            Text(value)
                .font(.kinnaDisplay(18))
                .foregroundStyle(.kTerra)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 9)
        .background(Color.kTerraLight.opacity(0.3))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.kTerra, lineWidth: 1.5)
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

    private func valueSummaryCard(icon: String, iconBackground: Color, title: String, body: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            RoundedRectangle(cornerRadius: 10)
                .fill(iconBackground)
                .frame(width: 34, height: 34)
                .overlay {
                    Text(icon)
                        .font(.system(size: 18))
                }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.kinnaBodyMedium(12))
                    .foregroundStyle(.kChar)
                Text(body)
                    .font(.kinnaBody(10))
                    .foregroundStyle(.kMid)
                    .lineSpacing(2)
            }

            Spacer()
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.kPale, lineWidth: 1)
        )
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
        .environment(SubscriptionManager.shared)
        .modelContainer(for: [Baby.self, VaccinationRecord.self], inMemory: true)
}
