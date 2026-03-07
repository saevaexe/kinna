import SwiftUI
import SwiftData

struct HomeView: View {
    @State private var selectedTab = 0

    private let tabs: [(emoji: String, label: String)] = [
        ("🏠", "Ana"),
        ("📈", "Gelişim"),
        ("📝", "Takip"),
        ("💉", "Aşılar"),
        ("🥄", "Besinler"),
    ]

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
    @Query private var babies: [Baby]

    private var baby: Baby? { babies.first }

    private let motivationQuotes = [
        "Her gün bebeğinle kurduğun bağ, onun beyin mimarisini şekillendiriyor.",
        "Bugün gösterdiğin sabır, yarının güçlü nöral devrelerini kuruyor.",
        "Küçük anlar, büyük bağlanma kalıpları oluşturur.",
    ]

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

                        Text("\(baby.name)'ın annesi 👋")
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
                        Text("Bu ay için")
                            .font(.kinnaBodyMedium(13))
                            .foregroundStyle(.kChar)
                            .tracking(0.3)
                        Spacer()
                        Text("Tümü →")
                            .font(.kinnaBodyMedium(11))
                            .foregroundStyle(.kSage)
                    }
                    .padding(.bottom, 12)

                    // Daily cards
                    dailyCards(baby: baby)

                } else {
                    // No baby
                    VStack(spacing: 12) {
                        Image(systemName: "person.badge.plus")
                            .font(.system(size: 40))
                            .foregroundStyle(.kTerra)
                        Text("Bebek profili eklenmemiş")
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
        switch hour {
        case 6..<12: return "Günaydın"
        case 12..<18: return "İyi günler"
        case 18..<22: return "İyi akşamlar"
        default: return "İyi Geceler"
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

                Text("\(baby.ageInDays) gündür hayatınızda")
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
                .font(.kinnaDisplay(15, weight: .light))
                .italic()
                .foregroundStyle(.white)
                .lineSpacing(4)

            Text("GÜNLÜK KINNA NOTU")
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
        let items: [(emoji: String, bg: Color, title: String, desc: String)] = [
            ("🧠", Color(hex: 0xEAF3EF), "\(baby.ageInMonths). ay bilişsel gelişim",
             "Nesneleri takip etme ve seslere yönelme becerisi gelişiyor."),
            ("⚠️", .kTerraLight, "Aşı hatırlatması",
             "Yaklaşan aşı kontrolünü unutmayın."),
            ("📖", .kPale, "Günün ipucu",
             "Bebeğinizle göz teması kurarak konuşmak bağlanmayı güçlendirir."),
        ]

        return VStack(spacing: 10) {
            ForEach(items.indices, id: \.self) { i in
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
        }
    }
}

#Preview {
    HomeView()
        .modelContainer(for: [Baby.self, DailyLog.self, VaccinationRecord.self, AllergyLog.self], inMemory: true)
}
