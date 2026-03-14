import SwiftUI
import SwiftData

struct HomeView: View {
    @State private var selectedTab = 0

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
                case 1:
                    NavigationStack { MilestonesView() }
                case 2:
                    NavigationStack { TrackingView() }
                case 3:
                    NavigationStack { VaccinationView() }
                case 4:
                    NavigationStack { AllergyView() }
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
                                selectedTab = i
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
}

// MARK: - Home Dashboard

struct HomeDashboardView: View {
    @AppStorage("parentRole") private var parentRoleRaw = "mother"
    @Query private var babies: [Baby]
    @Query(sort: \VaccinationRecord.scheduledDate) private var vaccinationRecords: [VaccinationRecord]
    @Environment(SubscriptionManager.self) private var subscriptionManager

    private var baby: Baby? { babies.first }

    private var isEN: Bool { Locale.current.language.languageCode?.identifier != "tr" }

    private var motivationQuotes: [String] {
        if isEN {
            return [
                "\u{201C}Every bond you build with your baby shapes their brain architecture.\u{201D}",
                "\u{201C}The patience you show today builds tomorrow\u{2019}s strong neural circuits.\u{201D}",
                "\u{201C}Small moments create lasting attachment patterns.\u{201D}",
            ]
        } else {
            return [
                "\u{201C}Her gün bebeğinle kurduğun bağ, onun beyin mimarisini şekillendiriyor.\u{201D}",
                "\u{201C}Bugün gösterdiğin sabır, yarının güçlü nöral devrelerini kuruyor.\u{201D}",
                "\u{201C}Küçük anlar, büyük bağlanma kalıpları oluşturur.\u{201D}",
            ]
        }
    }

    private var parentRoleLabel: String {
        let role = parentRoleRaw.lowercased()
        if isEN {
            switch role {
            case "father":
                return "father"
            case "caregiver":
                return "caregiver"
            default:
                return "mother"
            }
        } else {
            switch role {
            case "father":
                return "babası"
            case "caregiver":
                return "bakım vereni"
            default:
                return "annesi"
            }
        }
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

                        Text(isEN ? "\(baby.name)'s \(parentRoleLabel) 👋" : "\(baby.name)'ın \(parentRoleLabel) 👋")
                            .font(.kinnaDisplay(26))
                            .foregroundStyle(.kChar)
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
                    HStack {
                        Text(isEN ? "This month" : "Bu ay için")
                            .font(.kinnaBodyMedium(13))
                            .foregroundStyle(.kChar)
                            .tracking(0.3)
                        Spacer()
                        Text(isEN ? "All →" : "Tümü →")
                            .font(.kinnaBodyMedium(11))
                            .foregroundStyle(.kSage)
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

                Text(isEN
                     ? "\(baby.ageInDays) days in your life"
                     : "\(baby.ageInDays) gündür hayatınızda")
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

        let visibleCount = min(
            items.count,
            MonetizationPolicy.visibleHomeGuidanceCardCount(hasFullAccess: subscriptionManager.hasFullAccess)
        )

        return VStack(spacing: 10) {
            ForEach(Array(items.prefix(visibleCount).indices), id: \.self) { i in
                HStack(spacing: 14) {
                    // Icon
                    RoundedRectangle(cornerRadius: 12)
                        .fill(items[i].bg)
                        .frame(width: 40, height: 40)
                        .overlay {
                            Text(items[i].emoji)
                                .font(.system(size: 18))
                        }

                    // Text
                    VStack(alignment: .leading, spacing: 3) {
                        Text(items[i].title)
                            .font(.kinnaBodyMedium(13))
                            .foregroundStyle(.kChar)
                        Text(items[i].desc)
                            .font(.kinnaBody(11))
                            .foregroundStyle(.kMid)
                            .lineSpacing(2)
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
                NavigationLink {
                    PaywallView(entryPoint: .navigation)
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
                            Text(isEN ? "Unlock full monthly guidance" : "Tüm aylık rehberliği aç")
                                .font(.kinnaBodyMedium(13))
                                .foregroundStyle(.kChar)
                            Text(isEN
                                 ? "See all guidance cards and save unlimited milestones with Kinna Premium."
                                 : "Tüm rehber kartlarını gör ve sınırsız milestone kaydetmek için Kinna Premium'a geç.")
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
    }

    private func guidanceItems(for baby: Baby) -> [GuidanceCard] {
        [
            milestoneCard(for: baby),
            safetyCard(for: baby),
            vaccineCard(for: baby)
        ]
    }

    private func milestoneCard(for baby: Baby) -> GuidanceCard {
        let month = baby.ageInMonths
        if let milestone = MilestoneEngine.milestonesForAge(month).first {
            return GuidanceCard(
                emoji: "🧠",
                bg: Color(hex: 0xEAF3EF),
                title: isEN ? "Month \(month) focus" : "\(month). ay odağı",
                desc: isEN ? milestone.descriptionEN : milestone.descriptionTR
            )
        }

        return GuidanceCard(
            emoji: "🧠",
            bg: Color(hex: 0xEAF3EF),
            title: isEN ? "Development this month" : "Bu ay gelişim",
            desc: isEN
            ? "Watch for new social, language, and motor responses this month."
            : "Bu ay yeni sosyal, dil ve motor tepkilere dikkat edin."
        )
    }

    private func safetyCard(for baby: Baby) -> GuidanceCard {
        if let alert = SafetyAlertEngine.alertsForAge(baby.ageInMonths).first {
            return GuidanceCard(
                emoji: "⚠️",
                bg: .kTerraLight,
                title: isEN ? alert.titleEN : alert.titleTR,
                desc: isEN ? alert.descriptionEN : alert.descriptionTR
            )
        }

        return GuidanceCard(
            emoji: "⚠️",
            bg: .kTerraLight,
            title: isEN ? "Safety check" : "Güvenlik kontrolü",
            desc: isEN
            ? "Re-check your baby's sleep area, feeding seat, and transport setup this month."
            : "Bu ay bebeğinizin uyku alanını, beslenme oturuşunu ve taşıma düzenini tekrar gözden geçirin."
        )
    }

    private func vaccineCard(for baby: Baby) -> GuidanceCard {
        let upcomingSchedule = vaccinationRecords
            .filter { $0.isManual != true && !$0.isCompleted && $0.scheduledDate >= Calendar.current.startOfDay(for: .now) }
            .sorted { $0.scheduledDate < $1.scheduledDate }
            .first

        if let upcomingSchedule {
            let dateText = upcomingSchedule.scheduledDate.formatted(.dateTime.day().month(.wide))
            return GuidanceCard(
                emoji: "💉",
                bg: .kPale,
                title: isEN ? "Next vaccine" : "Sıradaki aşı",
                desc: isEN
                ? "\(upcomingSchedule.vaccineName) is scheduled for \(dateText)."
                : "\(upcomingSchedule.vaccineName) için planlanan tarih \(dateText)."
            )
        }

        return GuidanceCard(
            emoji: "📖",
            bg: .kPale,
            title: isEN ? "Connection tip" : "Bağ kurma ipucu",
            desc: isEN
            ? "Talking to your baby with eye contact strengthens attachment."
            : "Bebeğinizle göz teması kurarak konuşmak bağlanmayı güçlendirir."
        )
    }

    private struct GuidanceCard {
        let emoji: String
        let bg: Color
        let title: String
        let desc: String
    }
}

#Preview {
    HomeView()
        .modelContainer(for: [Baby.self, DailyLog.self, GrowthRecord.self, VaccinationRecord.self, AllergyLog.self], inMemory: true)
        .environment(SubscriptionManager.shared)
}
