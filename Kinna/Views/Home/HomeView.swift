import StoreKit
import SwiftData
import SwiftUI

enum HomeGuidancePlanner {
    enum VaccineCardState: Equatable {
        case overdue
        case upcoming
        case next
        case quiet
    }

    struct VaccineEntry: Equatable {
        let name: String
        let date: Date
        let isManualDose: Bool
    }

    struct VaccineCardModel: Equatable {
        let state: VaccineCardState
        let title: String
        let description: String
        let hasUpcomingThisMonth: Bool
        let isUrgent: Bool
        let entry: VaccineEntry?
    }

    static func nextVaccineEntry(records: [VaccinationRecord]) -> VaccineEntry? {
        let nextSchedule = records
            .filter { $0.isManual != true && !$0.isCompleted }
            .sorted { $0.scheduledDate < $1.scheduledDate }
            .first

        let nextManualDose = records
            .filter { $0.isManual == true && $0.nextDoseDate != nil }
            .sorted { ($0.nextDoseDate ?? .distantFuture) < ($1.nextDoseDate ?? .distantFuture) }
            .first

        let candidates = [
            nextSchedule.map { VaccineEntry(name: $0.vaccineName, date: $0.scheduledDate, isManualDose: false) },
            nextManualDose.flatMap { record in
                record.nextDoseDate.map { VaccineEntry(name: record.vaccineName, date: $0, isManualDose: true) }
            }
        ]
        .compactMap { $0 }
        .sorted { $0.date < $1.date }

        return candidates.first
    }

    static func vaccineCardModel(
        records: [VaccinationRecord],
        referenceDate: Date = .now,
        calendar: Calendar = .current,
        isEnglish: Bool
    ) -> VaccineCardModel {
        let startOfToday = calendar.startOfDay(for: referenceDate)

        guard let nextEntry = nextVaccineEntry(records: records) else {
            return VaccineCardModel(
                state: .quiet,
                title: isEnglish ? "No vaccine due this month" : "Bu ay aşı görünmüyor",
                description: isEnglish
                    ? "Your vaccine calendar looks quiet for now. We'll bring the next dose forward when it gets close."
                    : "Aşı takvimi bu ay daha sakin. Bir sonraki dozu yaklaşınca öne çıkaracağız.",
                hasUpcomingThisMonth: false,
                isUrgent: false,
                entry: nil
            )
        }

        let dateText = nextEntry.date.formatted(.dateTime.day().month(.wide))
        let isOverdue = nextEntry.date < startOfToday
        let isThisMonth = calendar.isDate(nextEntry.date, equalTo: referenceDate, toGranularity: .month)
            && calendar.isDate(nextEntry.date, equalTo: referenceDate, toGranularity: .year)
        let isUrgent = nextEntry.date <= (calendar.date(byAdding: .day, value: 7, to: referenceDate) ?? nextEntry.date)

        if isOverdue {
            return VaccineCardModel(
                state: .overdue,
                title: isEnglish ? "Needs attention" : "İlgilenmen gereken aşı",
                description: overdueDescription(
                    vaccineName: nextEntry.name,
                    dateText: dateText,
                    isManualDose: nextEntry.isManualDose,
                    isEnglish: isEnglish
                ),
                hasUpcomingThisMonth: true,
                isUrgent: true,
                entry: nextEntry
            )
        }

        if isThisMonth {
            return VaccineCardModel(
                state: .upcoming,
                title: isEnglish ? "Upcoming vaccine" : "Yaklaşan aşı",
                description: plannedDescription(
                    vaccineName: nextEntry.name,
                    dateText: dateText,
                    isManualDose: nextEntry.isManualDose,
                    isEnglish: isEnglish
                ),
                hasUpcomingThisMonth: true,
                isUrgent: isUrgent,
                entry: nextEntry
            )
        }

        return VaccineCardModel(
            state: .next,
            title: nextEntry.isManualDose
                ? (isEnglish ? "Next dose" : "Sıradaki doz")
                : (isEnglish ? "Next on the vaccine plan" : "Sıradaki aşı"),
            description: plannedDescription(
                vaccineName: nextEntry.name,
                dateText: dateText,
                isManualDose: nextEntry.isManualDose,
                isEnglish: isEnglish
            ),
            hasUpcomingThisMonth: false,
            isUrgent: false,
            entry: nextEntry
        )
    }

    private static func plannedDescription(
        vaccineName: String,
        dateText: String,
        isManualDose: Bool,
        isEnglish: Bool
    ) -> String {
        if isEnglish {
            return isManualDose
                ? "\(vaccineName) next dose is planned for \(dateText)."
                : "\(vaccineName) is planned for \(dateText)."
        }

        return isManualDose
            ? "\(vaccineName) için sonraki doz tarihi \(dateText)."
            : "\(vaccineName) için planlanan tarih \(dateText)."
    }

    private static func overdueDescription(
        vaccineName: String,
        dateText: String,
        isManualDose: Bool,
        isEnglish: Bool
    ) -> String {
        if isEnglish {
            return isManualDose
                ? "\(vaccineName) next dose was expected on \(dateText)."
                : "\(vaccineName) was planned for \(dateText)."
        }

        return isManualDose
            ? "\(vaccineName) için sonraki doz tarihi \(dateText) idi."
            : "\(vaccineName) için planlanan tarih \(dateText) idi."
    }
}

struct HomeView: View {
    @State private var selectedTab = 0
    @State private var homeStackID = UUID()
    @State private var milestonesStackID = UUID()
    @State private var trackingStackID = UUID()
    @State private var vaccinationStackID = UUID()
    @State private var foodsStackID = UUID()

    private var isEN: Bool { Locale.current.language.languageCode?.identifier != "tr" }

    private var tabs: [(emoji: String, label: String)] {
        [
            ("🏠", isEN ? "Home" : "Ana"),
            ("📈", isEN ? "Growth" : "Gelişim"),
            ("📝", isEN ? "Track" : "Takip"),
            ("💉", isEN ? "Vaccines" : "Aşılar"),
            ("🥄", isEN ? "Foods" : "Besinler"),
        ]
    }

    var body: some View {
        VStack(spacing: 0) {
            // Content
            Group {
                switch selectedTab {
                case 0:
                    NavigationStack { HomeDashboardView() }
                        .id(homeStackID)
                case 1:
                    NavigationStack { MilestonesView() }
                        .id(milestonesStackID)
                case 2:
                    NavigationStack { TrackingView() }
                        .id(trackingStackID)
                case 3:
                    NavigationStack { VaccinationView() }
                        .id(vaccinationStackID)
                case 4:
                    NavigationStack { AllergyView() }
                        .id(foodsStackID)
                default:
                    EmptyView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Custom tab bar
            VStack(spacing: 0) {
                Divider()
                    .overlay(Color.kPale)

                HStack(spacing: 0) {
                    ForEach(0..<tabs.count, id: \.self) { i in
                        Button {
                            withAnimation(.easeInOut(duration: 0.15)) {
                                if selectedTab == i {
                                    resetStack(for: i)
                                } else {
                                    selectedTab = i
                                }
                            }
                        } label: {
                            VStack(spacing: 4) {
                                Text(tabs[i].emoji)
                                    .font(.system(size: 20))
                                Text(tabs[i].label)
                                    .font(.kinnaBody(9))
                                    .fontWeight(selectedTab == i ? .medium : .regular)
                                    .foregroundStyle(selectedTab == i ? .kTerra : .kLight)
                            }
                            .frame(maxWidth: .infinity)
                            .overlay(alignment: .bottom) {
                                if selectedTab == i {
                                    Circle()
                                        .fill(Color.kTerra)
                                        .frame(width: 4, height: 4)
                                        .offset(y: 6)
                                }
                            }
                        }
                    }
                }
                .padding(.top, 10)
                .padding(.bottom, 6)
            }
            .background(.white)
        }
        .ignoresSafeArea(.keyboard)
    }

    private func resetStack(for tab: Int) {
        switch tab {
        case 0:
            homeStackID = UUID()
        case 1:
            milestonesStackID = UUID()
        case 2:
            trackingStackID = UUID()
        case 3:
            vaccinationStackID = UUID()
        case 4:
            foodsStackID = UUID()
        default:
            break
        }
    }
}

// MARK: - Home Dashboard

struct HomeDashboardView: View {
    @AppStorage("parentName") private var parentName = ""
    @AppStorage("parentRole") private var parentRoleRaw = "mother"
    @Query(sort: \Baby.createdAt) private var babies: [Baby]
    @Query(sort: \DailyLog.createdAt, order: .reverse) private var logs: [DailyLog]
    @Query(sort: \GrowthRecord.createdAt, order: .reverse) private var growthRecords: [GrowthRecord]
    @Query(sort: \VaccinationRecord.scheduledDate) private var vaccinationRecords: [VaccinationRecord]
    @Query(sort: \AllergyLog.createdAt, order: .reverse) private var allergyLogs: [AllergyLog]
    @Query private var progressRecords: [MilestoneProgress]
    @Environment(SubscriptionManager.self) private var subscriptionManager
    @Environment(\.requestReview) private var requestReview
    @State private var showPaywall = false

    private var baby: Baby? { babies.first }
    private var roleProfile: ParentRoleProfile { ParentRoleProfile(storedValue: parentRoleRaw) }

    private var isEN: Bool { Locale.current.language.languageCode?.identifier != "tr" }

    private var motivationQuotes: [String] {
        roleProfile.motivationQuotes(isEnglish: isEN)
    }

    private var babyLogs: [DailyLog] {
        guard let baby else { return [] }
        return logs.filter { $0.babyID == nil || $0.babyID == baby.id }
    }

    private var babyGrowthRecords: [GrowthRecord] {
        guard let baby else { return [] }
        return growthRecords.filter { $0.babyID == nil || $0.babyID == baby.id }
    }

    private var reviewPromptMetrics: ReviewPromptMetrics {
        let meaningfulDates = babyLogs.map(\.date)
            + babyGrowthRecords.map(\.measuredAt)
            + allergyLogs.map(\.introducedDate)
            + vaccinationRecords.compactMap { record in
                record.isManual == true ? (record.administeredDate ?? record.createdAt) : nil
            }
            + progressRecords.compactMap(\.completedAt)

        let engagedDays = Set(meaningfulDates.map { Calendar.current.startOfDay(for: $0) }).count

        return ReviewPromptMetrics(
            engagedDayCount: engagedDays,
            meaningfulActionCount: meaningfulDates.count,
            firstMeaningfulActivityAt: meaningfulDates.min()
        )
    }

    private var reviewPromptEvaluationKey: String {
        let babyKey = baby?.id.uuidString ?? "none"
        return [
            babyKey,
            String(babyLogs.count),
            String(babyGrowthRecords.count),
            String(allergyLogs.count),
            String(vaccinationRecords.filter { $0.isManual == true }.count),
            String(progressRecords.count),
            String(showPaywall)
        ].joined(separator: "-")
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                if let baby {
                    // Greeting
                    VStack(alignment: .leading, spacing: 4) {
                        Text(greetingText.uppercased())
                            .font(.kinnaBody(12))
                            .foregroundStyle(.kLight)
                            .tracking(1)

                        Text(isEN ? "\(baby.name)'s \(roleProfile.possessiveLabel(isEnglish: isEN)) 👋" : "\(baby.name)'ın \(roleProfile.possessiveLabel(isEnglish: isEN)) 👋")
                            .font(.kinnaDisplay(26))
                            .foregroundStyle(.kChar)

                        Text(greetingSupportLine(for: baby))
                            .font(.kinnaBody(11))
                            .foregroundStyle(.kMid)
                            .lineSpacing(2)
                            .padding(.top, 2)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 20)

                    // Age card
                    ageCard(baby: baby)
                        .padding(.bottom, 20)

                    // Motivation card
                    motivationCard
                        .padding(.bottom, 10)

                    // Section header
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(alignment: .firstTextBaseline) {
                            Text(isEN ? "This month" : "Bu ay için")
                                .font(.kinnaBodyMedium(13))
                                .foregroundStyle(.kChar)
                                .tracking(0.3)
                            Spacer()
                            Text(subscriptionManager.hasFullAccess
                                 ? (isEN ? "3/3 open" : "3/3 açık")
                                 : (isEN ? "1/3 open" : "1/3 açık"))
                                .font(.kinnaBodyMedium(10))
                                .foregroundStyle(subscriptionManager.hasFullAccess ? .kSageDark : .kTerra)
                        }

                        Text(roleProfile.thisMonthSectionIntro(isEnglish: isEN))
                            .font(.kinnaBody(11))
                            .foregroundStyle(.kMid)
                            .lineSpacing(2)
                    }
                    .padding(.bottom, 12)

                    // Daily cards
                    dailyCards(baby: baby)

                    // WHO reference
                    Text(isEN
                         ? "Our content is based on WHO guidelines and Republic of Turkey Ministry of Health protocols."
                         : "İçeriklerimiz WHO rehberleri ve T.C. Sağlık Bakanlığı protokolleri temel alınarak hazırlanmıştır.")
                        .font(.kinnaBody(9))
                        .foregroundStyle(.kMuted)
                        .lineSpacing(2)
                        .padding(.top, 8)
                        .padding(.bottom, 4)

                } else {
                    // No baby
                    VStack(spacing: 12) {
                        Image(systemName: "person.badge.plus")
                            .font(.system(size: 40))
                            .foregroundStyle(.kTerra)
                        Text(isEN ? "No baby profile added" : "Bebek profili eklenmemiş")
                            .font(.kinnaBodyMedium(15))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 12)
            .padding(.bottom, 20)
        }
        .background(Color.kCream.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink {
                    SettingsView()
                } label: {
                    Image(systemName: "gearshape.fill")
                        .foregroundStyle(.kMid)
                }
            }
        }
        .task(id: reviewPromptEvaluationKey) {
            await maybeRequestReview()
        }
    }

    // MARK: - Greeting

    private var greetingText: String {
        let hour = Calendar.current.component(.hour, from: .now)
        if isEN {
            switch hour {
            case 6..<12: return "Good Morning"
            case 12..<18: return "Good Afternoon"
            case 18..<22: return "Good Evening"
            default: return "Good Night"
            }
        } else {
            switch hour {
            case 6..<12: return "Günaydın"
            case 12..<18: return "İyi günler"
            case 18..<22: return "İyi akşamlar"
            default: return "İyi Geceler"
            }
        }
    }

    private func greetingSupportLine(for baby: Baby) -> String {
        let trimmedName = parentName.trimmingCharacters(in: .whitespacesAndNewlines)

        if isEN {
            if trimmedName.isEmpty {
                return roleProfile.homeLead(isEnglish: true)
            }
            return "\(trimmedName), \(roleProfile.homeLead(isEnglish: true).lowercased())"
        }

        if trimmedName.isEmpty {
            return roleProfile.homeLead(isEnglish: false)
        }
        return "\(trimmedName), \(roleProfile.homeLead(isEnglish: false).lowercased())"
    }

    // MARK: - Age Card

    private func ageCard(baby: Baby) -> some View {
        ZStack(alignment: .topTrailing) {
            // Decorative circle
            Circle()
                .fill(.white.opacity(0.04))
                .frame(width: 120, height: 120)
                .offset(x: 20, y: -20)

            VStack(alignment: .leading, spacing: 4) {
                Text(baby.name.uppercased())
                    .font(.kinnaBody(10))
                    .foregroundStyle(.white.opacity(0.4))
                    .tracking(1.5)

                Text(baby.ageDescription)
                    .font(.kinnaDisplay(36, weight: .light))
                    .foregroundStyle(.white)

                Text(roleProfile.ageCardDescription(babyAgeInDays: baby.ageInDays, isEnglish: isEN))
                    .font(.kinnaBody(12))
                    .foregroundStyle(.white.opacity(0.4))

                // Progress bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 1.5)
                            .fill(.white.opacity(0.1))
                            .frame(height: 3)
                        RoundedRectangle(cornerRadius: 1.5)
                            .fill(Color.kTerra)
                            .frame(width: geo.size.width * monthProgress(baby: baby), height: 3)
                    }
                }
                .frame(height: 3)
                .padding(.top, 12)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(20)
        .background(Color.kChar)
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }

    private func monthProgress(baby: Baby) -> CGFloat {
        let days = baby.ageInDays
        let currentMonthDay = days % 30
        return min(CGFloat(currentMonthDay) / 30.0, 1.0)
    }

    // MARK: - Motivation Card

    private var motivationCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(motivationQuotes.randomElement() ?? motivationQuotes[0])
                .font(.kinnaDisplayItalic(14, weight: .light))
                .foregroundStyle(.white)
                .lineSpacing(5)

            Text(isEN ? "DAILY KINNA NOTE" : "GÜNLÜK KINNA NOTU")
                .font(.kinnaBody(10))
                .foregroundStyle(.white.opacity(0.6))
                .tracking(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(
            LinearGradient(
                colors: [.kSageDark, .kSage],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }

    // MARK: - Daily Cards

    private func dailyCards(baby: Baby) -> some View {
        let items = guidanceItems(for: baby)
        let visibleCount = min(items.count, MonetizationPolicy.visibleHomeGuidanceCardCount(hasFullAccess: subscriptionManager.hasFullAccess))

        return VStack(spacing: 10) {
            ForEach(Array(items.prefix(visibleCount).indices), id: \.self) { i in
                VStack(alignment: .leading, spacing: 12) {
                    HStack(alignment: .top, spacing: 14) {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(items[i].bg)
                            .frame(width: 40, height: 40)
                            .overlay {
                                Text(items[i].emoji)
                                    .font(.system(size: 18))
                            }

                        VStack(alignment: .leading, spacing: 5) {
                            Text(items[i].eyebrow.uppercased())
                                .font(.kinnaBodyMedium(9))
                                .foregroundStyle(.kMuted)
                                .tracking(1.1)

                            Text(items[i].title)
                                .font(.kinnaBodyMedium(13))
                                .foregroundStyle(.kChar)

                            Text(items[i].desc)
                                .font(.kinnaBody(11))
                                .foregroundStyle(.kMid)
                                .lineSpacing(2)
                        }

                        Spacer()
                    }

                    if let action = items[i].action {
                        HStack(spacing: 7) {
                            Image(systemName: items[i].actionIcon)
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundStyle(items[i].accent)
                            Text(action)
                                .font(.kinnaBodyMedium(10))
                                .foregroundStyle(items[i].accent)
                                .lineSpacing(2)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 18))
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(Color.kPale, lineWidth: 1)
                )
            }

            if !subscriptionManager.hasFullAccess && items.count > visibleCount {
                Button {
                    showPaywall = true
                } label: {
                    HStack(spacing: 14) {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.kTerraLight.opacity(0.35))
                            .frame(width: 40, height: 40)
                            .overlay {
                                Image(systemName: "star.fill")
                                    .font(.system(size: 16))
                                    .foregroundStyle(.kTerra)
                            }

                        VStack(alignment: .leading, spacing: 3) {
                            let cta = roleProfile.premiumUnlockCTA(isEnglish: isEN)
                            Text(cta.title)
                                .font(.kinnaBodyMedium(13))
                                .foregroundStyle(.kChar)
                            Text(cta.body)
                                .font(.kinnaBody(11))
                                .foregroundStyle(.kMid)
                                .lineSpacing(2)
                        }

                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(.kLight)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                    .background(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(Color.kPale, lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .fullScreenCover(isPresented: $showPaywall) {
            NavigationStack {
                PaywallView()
            }
            .environment(subscriptionManager)
        }
    }

    private func guidanceItems(for baby: Baby) -> [GuidanceCard] {
        [
            milestoneCard(for: baby),
            vaccineCard(for: baby),
            dailyGuideCard(for: baby)
        ]
        .sorted { $0.priority < $1.priority }
    }

    private func milestoneCard(for baby: Baby) -> GuidanceCard {
        let month = baby.ageInMonths
        if let milestone = MilestoneEngine.milestonesForAge(month).first {
            return GuidanceCard(
                emoji: "🧠",
                bg: Color(hex: 0xEAF3EF),
                eyebrow: isEN ? "Development focus" : "Gelişim odağı",
                title: isEN ? "Month \(month) spotlight" : "\(month). ay odağı",
                desc: isEN ? milestone.descriptionEN : milestone.descriptionTR,
                action: roleProfile.milestoneAction(isEnglish: isEN),
                actionIcon: "sparkles",
                accent: .kSageDark,
                priority: 1
            )
        }

        return GuidanceCard(
            emoji: "🧠",
            bg: Color(hex: 0xEAF3EF),
            eyebrow: isEN ? "Development focus" : "Gelişim odağı",
            title: isEN ? "This month's spotlight" : "Bu ayın odağı",
            desc: isEN
            ? "Watch for new social, language, and motor responses this month."
            : "Bu ay yeni sosyal, dil ve motor tepkilere dikkat edin.",
            action: roleProfile.milestoneAction(isEnglish: isEN),
            actionIcon: "sparkles",
            accent: .kSageDark,
            priority: 1
        )
    }

    private func vaccineCard(for baby: Baby) -> GuidanceCard {
        let model = HomeGuidancePlanner.vaccineCardModel(
            records: vaccinationRecords,
            referenceDate: .now,
            calendar: .current,
            isEnglish: isEN
        )

        let emoji: String
        let background: Color
        let accent: Color
        let actionIcon: String
        let priority: Int

        switch model.state {
        case .overdue:
            emoji = "⏰"
            background = Color(hex: 0xFFF3EB)
            accent = .kTerra
            actionIcon = "exclamationmark.circle"
            priority = 0
        case .upcoming:
            emoji = "💉"
            background = .kPale
            accent = .kTerra
            actionIcon = model.isUrgent ? "bell.badge" : "calendar"
            priority = model.isUrgent ? 0 : 1
        case .next:
            emoji = "🗓️"
            background = .kPale
            accent = .kTerra
            actionIcon = "calendar"
            priority = 2
        case .quiet:
            emoji = "✓"
            background = Color.kSage.opacity(0.14)
            accent = .kSageDark
            actionIcon = "calendar.badge.checkmark"
            priority = 2
        }

        return GuidanceCard(
            emoji: emoji,
            bg: background,
            eyebrow: isEN ? "Vaccines" : "Aşı planı",
            title: model.title,
            desc: model.description,
            action: roleProfile.vaccineAction(isEnglish: isEN, hasUpcomingThisMonth: model.hasUpcomingThisMonth),
            actionIcon: actionIcon,
            accent: accent,
            priority: priority
        )
    }

    private func dailyGuideCard(for baby: Baby) -> GuidanceCard {
        let rotationSeed = (Calendar.current.ordinality(of: .day, in: .year, for: .now) ?? 0) + baby.ageInMonths
        let template = roleProfile.dailyGuideTemplate(isEnglish: isEN, rotationIndex: rotationSeed)
        let icons = ["🌿", "🌙", "🙂", "📝"]
        let backgrounds = [
            Color.kSage.opacity(0.14),
            Color(hex: 0xEEF1F8),
            Color(hex: 0xFEF0E7),
            Color(hex: 0xF6F2EA)
        ]
        let index = rotationSeed % icons.count

        return GuidanceCard(
            emoji: icons[index],
            bg: backgrounds[index],
            eyebrow: isEN ? "Daily guide" : "Günün rehberi",
            title: template.title,
            desc: template.body,
            action: template.action,
            actionIcon: "sparkles",
            accent: .kTerra,
            priority: 3
        )
    }

    private struct GuidanceCard {
        let emoji: String
        let bg: Color
        let eyebrow: String
        let title: String
        let desc: String
        let action: String?
        let actionIcon: String
        let accent: Color
        let priority: Int
    }

    @MainActor
    private func maybeRequestReview() async {
        guard baby != nil, !showPaywall else { return }

        guard ReviewPromptManager.shouldRequestReview(metrics: reviewPromptMetrics) else {
            return
        }

        try? await Task.sleep(nanoseconds: 700_000_000)
        guard !showPaywall else { return }

        requestReview()
        ReviewPromptManager.recordRequest()
    }
}

#Preview {
    HomeView()
        .modelContainer(for: [Baby.self, DailyLog.self, GrowthRecord.self, VaccinationRecord.self, AllergyLog.self, MilestoneProgress.self], inMemory: true)
        .environment(SubscriptionManager.shared)
}
