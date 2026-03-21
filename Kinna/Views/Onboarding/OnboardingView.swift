import SwiftUI
import SwiftData

struct OnboardingView: View {
    @Binding var onboardingStarted: Bool
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
    @FocusState private var nameFieldFocused: Bool

    // Cached expensive computations
    @State private var cachedMilestoneFocus: Milestone?
    @State private var cachedSafetyFocus: SafetyAlert?
    @State private var cachedVaccine: (item: VaccinationItem, date: Date)?

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
            if years > 0 { return "\(years) yr \(months) mo" }
            else if months > 0 { return "\(months) mo \(days) days" }
            else { return "\(days) days" }
        } else {
            if years > 0 { return "\(years) yıl \(months) ay" }
            else if months > 0 { return "\(months) ay \(days) gün" }
            else { return "\(days) gün" }
        }
    }

    private var parentNamePlaceholder: String {
        if isEN {
            switch selectedRole {
            case .mother: return "e.g. Sarah"
            case .father: return "e.g. David"
            case .caregiver: return "e.g. Alex"
            }
        }
        switch selectedRole {
        case .mother: return "örn. Mine"
        case .father: return "örn. Osman"
        case .caregiver: return "örn. Derya"
        }
    }

    private var milestoneFocus: Milestone? { cachedMilestoneFocus }
    private var safetyFocus: SafetyAlert? { cachedSafetyFocus }
    private var upcomingScheduledVaccine: (item: VaccinationItem, date: Date)? { cachedVaccine }

    private func refreshCachedData() {
        let ageMonths = onboardingAgeInMonths
        cachedMilestoneFocus = MilestoneEngine.milestonesForAge(ageMonths).first
        cachedSafetyFocus = SafetyAlertEngine.alertsForAge(ageMonths).first

        let startOfToday = Calendar.current.startOfDay(for: .now)
        let birthDate = onboardingBirthDate
        cachedVaccine = VaccinationEngine.schedule(birthDate: birthDate)
            .map { item in
                (
                    item: item,
                    date: VaccinationEngine.scheduledDate(
                        birthDate: birthDate,
                        monthAge: item.monthAge
                    )
                )
            }
            .sorted { $0.date < $1.date }
            .first(where: { $0.date >= startOfToday })
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
            refreshCachedData()
        }
        .onChange(of: currentStep) { _, newStep in
            if newStep == 2 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    nameFieldFocused = true
                }
            }
            if newStep == 3 || newStep == 4 {
                refreshCachedData()
            }
        }
        .onChange(of: birthDay) { _, _ in refreshCachedData() }
        .onChange(of: birthMonth) { _, _ in refreshCachedData() }
        .onChange(of: birthYear) { _, _ in refreshCachedData() }
        .sheet(isPresented: $showBirthDatePicker) {
            NavigationStack {
                VStack(spacing: 0) {
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
                        .padding(.vertical, 12)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)

                    terraButton(isEN ? "Done" : "Tamam") {
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
            .preferredColorScheme(.light)
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
            .presentationBackground(Color.kCream)
        }
        .fullScreenCover(isPresented: $showCompletionPaywall, onDismiss: {
            hasCompletedOnboarding = true
        }) {
            NavigationStack {
                PaywallView(entryPoint: .onboarding)
            }
            .environment(subscriptionManager)
            .presentationBackground(Color.kCream)
        }
    }

    // MARK: - Step 0: Welcome

    private var welcomeStep: some View {
        VStack(spacing: 0) {
            // Hero area — full-bleed placeholder gradient (replace with real photo later)
            ZStack(alignment: .bottomLeading) {
                if let img = UIImage(named: "onboarding_hero") {
                    Image(uiImage: img)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity)
                        .frame(height: 380)
                        .clipped()
                } else {
                    LinearGradient(
                        colors: [Color.kTerraPale, Color.kBlush, Color.kTerraLight.opacity(0.5)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .frame(height: 380)
                    .overlay(alignment: .center) {
                        Image("BrandIcon")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .shadow(color: .kTerra.opacity(0.2), radius: 20, y: 8)
                    }
                }
            }
            .ignoresSafeArea(edges: .top)

            VStack(alignment: .leading, spacing: 14) {
                Spacer(minLength: 24)

                (
                    Text(isEN ? "Nurturing with\n" : "Şefkatle ve bilimle\n")
                        .font(.kinnaDisplay(30, weight: .semibold))
                        .foregroundStyle(.kChar)
                    +
                    Text(isEN ? "Science & Heart." : "yanında.")
                        .font(.kinnaDisplayItalic(30, weight: .semibold))
                        .foregroundStyle(.kTerra)
                )
                .lineSpacing(2)

                Text(isEN
                    ? "The premium developmental guide for your baby's first years."
                    : "Bebeğinin ilk yılları için premium gelişim rehberi.")
                    .font(.kinnaBody(14))
                    .foregroundStyle(.kMid)
                    .lineSpacing(3)

                // Trust badges
                HStack(spacing: 8) {
                    trustBadgePill(text: isEN ? "WHO-BASED GUIDANCE" : "WHO TEMELLİ REHBERLİK")
                    trustBadgePill(text: isEN ? "ON-DEVICE PRIVACY" : "CİHAZDA GİZLİLİK")
                    trustBadgePill(text: isEN ? "LOCAL SCHEDULE" : "YEREL TAKVİM")
                }
                .padding(.top, 4)

                Spacer(minLength: 16)

                terraButton(isEN ? "Get Started" : "Başlayalım") {
                    onboardingStarted = true
                    currentStep = 1
                }
                .padding(.bottom, 32)
            }
            .padding(.horizontal, 24)
        }
    }

    // MARK: - Step 1: Role

    private var roleStep: some View {
        VStack(spacing: 0) {
            progressBar(current: 1)
            stepLabel(stepIndicatorText(for: 1))

            Text(isEN ? "Welcome." : "Hoş geldiniz.")
                .font(.kinnaDisplay(28, weight: .semibold))
                .foregroundStyle(.kChar)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 2)

            Text(isEN ? "What is your role today?" : "Bugün rolünüz nedir?")
                .font(.kinnaDisplay(28))
                .foregroundStyle(.kChar)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 6)

            Text(isEN
                ? "We tailor our medical insights based on who is providing care."
                : "Bakım veren kişiye göre tıbbi içgörülerimizi uyarlıyoruz.")
                .font(.kinnaBody(13))
                .foregroundStyle(.kMid)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 20)

            roleCard(
                title: isEN ? "Mother" : "Anne",
                subtitle: isEN ? "Primary caregiver insights for mothers" : "Anneler için birincil bakım içgörüleri",
                isSelected: selectedRole == .mother
            ) { selectedRole = .mother }

            roleCard(
                title: isEN ? "Father" : "Baba",
                subtitle: isEN ? "Tailored guidance for involved fathers" : "İlgili babalar için uyarlanmış rehberlik",
                isSelected: selectedRole == .father
            ) { selectedRole = .father }

            roleCard(
                title: isEN ? "Caregiver" : "Bakım veren",
                subtitle: isEN ? "Support for the person providing daily care" : "Günlük bakımı üstlenen kişi için destek",
                isSelected: selectedRole == .caregiver
            ) { selectedRole = .caregiver }

            Spacer()

            terraButton(isEN ? "Continue" : "Devam") {
                storedParentRole = selectedRole.rawValue
                DispatchQueue.main.async {
                    currentStep = 2
                }
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

                Text(isEN ? "The details matter." : "Detaylar önemli.")
                    .font(.kinnaDisplay(28, weight: .semibold))
                    .foregroundStyle(.kChar)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 24)

                // YOUR FULL NAME
                underlineField(
                    label: isEN ? "YOUR FULL NAME" : "ADINIZ",
                    placeholder: parentNamePlaceholder,
                    text: $nameInput,
                    focused: $nameFieldFocused
                )
                .padding(.bottom, 20)

                // BABY'S NAME
                underlineField(
                    label: isEN ? "BABY'S NAME" : "BEBEĞİNİZİN ADI",
                    placeholder: isEN ? "e.g. Oliver" : "örn. Ela",
                    text: $babyName
                )
                .padding(.bottom, 20)

                // DATE OF BIRTH
                Text(isEN ? "DATE OF BIRTH" : "DOĞUM TARİHİ")
                    .font(.kinnaBodyMedium(10))
                    .foregroundStyle(.kMuted)
                    .tracking(1.2)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 2)
                    .padding(.bottom, 6)

                Button {
                    showBirthDatePicker = true
                } label: {
                    HStack {
                        Text(birthDateText)
                            .font(.kinnaBody(15))
                            .foregroundStyle(.kChar)
                        Spacer()
                        Image(systemName: "chevron.down")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(.kMuted)
                    }
                    .padding(.bottom, 8)
                    .overlay(alignment: .bottom) {
                        Rectangle()
                            .fill(Color.kPale)
                            .frame(height: 1)
                    }
                }
                .buttonStyle(.plain)
                .padding(.bottom, 20)

                // BABY'S GENDER
                Text(isEN ? "BABY'S GENDER" : "BEBEĞİN CİNSİYETİ")
                    .font(.kinnaBodyMedium(10))
                    .foregroundStyle(.kMuted)
                    .tracking(1.2)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 2)
                    .padding(.bottom, 8)

                HStack(spacing: 8) {
                    genderPill(isEN ? "Boy" : "Erkek", gender: .male)
                    genderPill(isEN ? "Girl" : "Kız", gender: .female)
                    genderPill(isEN ? "Other" : "Diğer", gender: .other)
                }
                .padding(.bottom, 32)

                terraButton(isEN ? "Continue" : "Devam") {
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
            .padding(.bottom, 24)
        }
        .scrollDismissesKeyboard(.interactively)
    }

    // MARK: - Step 3: Safety Note

    private var safetyNoteStep: some View {
        VStack(spacing: 0) {
            progressBar(current: 3)
            stepLabel(stepIndicatorText(for: 3))

            Text(isEN ? "Your trust is our\npriority" : "Güveniniz bizim\nönceliğimiz")
                .font(.kinnaDisplay(30, weight: .semibold))
                .foregroundStyle(.kChar)
                .lineSpacing(2)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 24)

            // Disclaimer card
            VStack(alignment: .leading, spacing: 14) {
                Circle()
                    .fill(Color(hex: 0xFBE7DD))
                    .frame(width: 44, height: 44)
                    .overlay {
                        Image(systemName: "stethoscope")
                            .font(.system(size: 20))
                            .foregroundStyle(.kTerra)
                    }

                Text(isEN ? "Medical Disclaimer" : "Tıbbi Sorumluluk Reddi")
                    .font(.kinnaBodyMedium(16))
                    .foregroundStyle(.kChar)

                Text(isEN
                    ? "Kinna provides science-based developmental guidance following WHO standards."
                    : "Kinna, WHO standartlarını takip eden bilime dayalı gelişim rehberliği sunar.")
                    .font(.kinnaBody(13))
                    .foregroundStyle(.kMid)
                    .lineSpacing(3)

                (
                    Text(isEN ? "Important: " : "Önemli: ")
                        .font(.kinnaBodyMedium(13))
                        .foregroundStyle(.kTerra)
                    +
                    Text(isEN
                        ? "This app is an educational resource and does not replace professional medical advice, diagnosis, or treatment from your doctor."
                        : "Bu uygulama eğitsel bir kaynaktır ve doktorunuzdan alacağınız profesyonel tıbbi tavsiye, teşhis veya tedavinin yerini tutmaz.")
                        .font(.kinnaBody(13))
                        .foregroundStyle(.kTerra)
                )
                .italic()
                .lineSpacing(3)
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.kPale, lineWidth: 1)
            )
            .padding(.bottom, 24)

            Spacer()

            // Checkbox
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    disclaimerAccepted.toggle()
                }
            } label: {
                HStack(alignment: .top, spacing: 10) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(disclaimerAccepted ? Color.kTerra : .white)
                        .frame(width: 22, height: 22)
                        .overlay {
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(disclaimerAccepted ? Color.clear : Color.kPale, lineWidth: 1.5)
                            if disclaimerAccepted {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundStyle(.white)
                            }
                        }

                    Text(isEN
                        ? "I understand that Kinna is a supportive guide and I should always consult with my pediatrician for medical concerns."
                        : "Kinna'nın destekleyici bir rehber olduğunu ve tıbbi endişeler için her zaman doktoruma danışmam gerektiğini anlıyorum.")
                        .font(.kinnaBody(12))
                        .foregroundStyle(.kChar)
                        .multilineTextAlignment(.leading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(.plain)
            .padding(.bottom, 20)

            terraButton(isEN ? "I Understand" : "Anlıyorum") {
                currentStep = 4
            }
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
                            let descriptor = FetchDescriptor<VaccinationRecord>()
                            let records = (try? modelContext.fetch(descriptor)) ?? []
                            await NotificationManager.shared.syncVaccineReminders(
                                birthDate: onboardingBirthDate,
                                scheduledRecords: records,
                                hasFullAccess: subscriptionManager.hasFullAccess
                            )
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
        let descriptor = FetchDescriptor<Baby>(
            sortBy: [SortDescriptor(\.createdAt)]
        )
        let babies = (try? modelContext.fetch(descriptor)) ?? []

        if let existingBaby = babies.first {
            existingBaby.name = trimmedBabyName
            existingBaby.birthDate = birthDate
            existingBaby.gender = selectedGender ?? .other
        } else {
            let baby = Baby(
                name: trimmedBabyName,
                birthDate: birthDate,
                gender: selectedGender ?? .other
            )
            modelContext.insert(baby)
        }

        let vaccinationDescriptor = FetchDescriptor<VaccinationRecord>()
        let existingRecords = (try? modelContext.fetch(vaccinationDescriptor)) ?? []
        let autoRecords = existingRecords.filter { $0.isManual != true }
        let existingNames = Set(autoRecords.map { $0.vaccineName })
        let existingByName = Dictionary(uniqueKeysWithValues: autoRecords.map { ($0.vaccineName, $0) })

        let schedule = VaccinationEngine.schedule(birthDate: birthDate)
        for item in schedule {
            let scheduledDate = VaccinationEngine.scheduledDate(birthDate: birthDate, monthAge: item.monthAge)

            if let existingRecord = existingByName[item.nameTR] {
                if !existingRecord.isCompleted {
                    existingRecord.scheduledDate = scheduledDate
                }
                continue
            }

            if !existingNames.contains(item.nameTR) {
                let record = VaccinationRecord(
                    vaccineName: item.nameTR,
                    scheduledDate: scheduledDate
                )
                modelContext.insert(record)
            }
        }

        let refreshedRecords = (try? modelContext.fetch(vaccinationDescriptor)) ?? existingRecords

        Task {
            await NotificationManager.shared.syncVaccineReminders(
                birthDate: birthDate,
                scheduledRecords: refreshedRecords,
                hasFullAccess: subscriptionManager.hasFullAccess
            )
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
        return isEN
            ? "We'll surface one timely sleep, feeding, or safety reminder when it matters most."
            : "Uyku, beslenme veya güvenlik için tam zamanında tek bir hatırlatma göstereceğiz."
    }

    private func vaccineSummaryBody(_ upcoming: (item: VaccinationItem, date: Date)) -> String {
        let dateText = upcoming.date.formatted(.dateTime.day().month(.wide))
        if isEN {
            return "\(upcoming.item.nameEN) is expected around \(dateText)."
        }
        return "\(upcoming.item.nameTR) için beklenen tarih \(dateText)."
    }

    private func vaccineNotificationTitle(for item: VaccinationItem) -> String {
        isEN ? "💉 \(item.nameEN) is coming up" : "💉 \(item.nameTR) yaklaşıyor"
    }

    private func vaccineNotificationBody(for upcoming: (item: VaccinationItem, date: Date)) -> String {
        isEN
            ? "We'll nudge you before \(upcoming.item.nameEN) so you can schedule it calmly."
            : "\(upcoming.item.nameTR) öncesinde sakin sakin plan yapman için sana haber vereceğiz."
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

    // MARK: - Components

    private func terraButton(_ title: String, action: @escaping () -> Void) -> some View {
        Button {
            withAnimation { action() }
        } label: {
            Text(title)
                .font(.kinnaBodyMedium(15))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.kTerra)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .shadow(color: .kTerra.opacity(0.3), radius: 10, y: 5)
        }
    }

    private func safetyBullet(text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Text("•")
                .font(.kinnaBodyMedium(11))
                .foregroundStyle(.kTerra)
                .padding(.top, 1)
            Text(text)
                .font(.kinnaBody(11))
                .foregroundStyle(.kMid)
                .lineSpacing(2)
        }
    }

    private func trustBadgePill(text: String) -> some View {
        Text(text)
            .font(.kinnaBodyMedium(8))
            .foregroundStyle(.kMid)
            .tracking(0.5)
            .lineLimit(2)
            .minimumScaleFactor(0.7)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 8)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity)
            .background(Color.kBlush)
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private func progressBar(current: Int) -> some View {
        HStack(spacing: 4) {
            ForEach(1...setupStepCount, id: \.self) { i in
                RoundedRectangle(cornerRadius: 1.5)
                    .fill(i <= current ? Color.kTerra : Color.kPale)
                    .frame(height: 3)
            }
        }
        .padding(.top, 56)
        .padding(.bottom, 6)
    }

    private func stepIndicatorText(for current: Int) -> String {
        if isEN {
            return "Step \(current) of \(setupStepCount)"
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

    private func roleCard(
        title: String, subtitle: String,
        isSelected: Bool, action: @escaping () -> Void
    ) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) { action() }
        } label: {
            HStack(spacing: 14) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.kinnaBodyMedium(15))
                        .foregroundStyle(.kChar)
                    Text(subtitle)
                        .font(.kinnaBody(11))
                        .foregroundStyle(.kMid)
                }

                Spacer()

                Circle()
                    .fill(isSelected ? Color.kTerra : .white)
                    .frame(width: 22, height: 22)
                    .overlay {
                        Circle()
                            .stroke(isSelected ? Color.clear : Color.kPale, lineWidth: 1.5)
                        if isSelected {
                            Circle()
                                .fill(.white)
                                .frame(width: 8, height: 8)
                        }
                    }
            }
            .padding(16)
            .background(isSelected ? Color.kTerraLight.opacity(0.25) : .white)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isSelected ? Color.kTerra : Color.kPale, lineWidth: 1.5)
            )
        }
        .padding(.bottom, 8)
    }

    private func underlineField(
        label: String, placeholder: String,
        text: Binding<String>,
        focused: FocusState<Bool>.Binding? = nil
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.kinnaBodyMedium(10))
                .foregroundStyle(.kMuted)
                .tracking(1.2)
                .padding(.leading, 2)

            Group {
                if let focused {
                    TextField(
                        "",
                        text: text,
                        prompt: Text(placeholder).foregroundStyle(.kMid.opacity(0.6))
                    )
                    .focused(focused)
                } else {
                    TextField(
                        "",
                        text: text,
                        prompt: Text(placeholder).foregroundStyle(.kMid.opacity(0.6))
                    )
                }
            }
            .font(.kinnaBody(15))
            .foregroundColor(.kChar)
            .tint(.kTerra)
            .autocorrectionDisabled()
            .textInputAutocapitalization(.words)
            .padding(.bottom, 8)
            .overlay(alignment: .bottom) {
                Rectangle()
                    .fill(Color.kPale)
                    .frame(height: 1)
            }
        }
    }

    private func genderPill(_ title: String, gender: Baby.Gender) -> some View {
        let isSelected = selectedGender == gender
        return Button {
            withAnimation(.easeInOut(duration: 0.2)) { selectedGender = gender }
        } label: {
            Text(title)
                .font(.kinnaBody(13))
                .foregroundStyle(isSelected ? .white : .kChar)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity)
                .background(isSelected ? Color.kTerra : Color.kBlush)
                .clipShape(Capsule())
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
}

#Preview {
    OnboardingView(onboardingStarted: .constant(false))
        .environment(SubscriptionManager.shared)
        .modelContainer(for: [Baby.self, VaccinationRecord.self], inMemory: true)
}
