import SwiftUI
import SwiftData

struct MilestonesView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(SubscriptionManager.self) private var subscriptionManager
    @Query private var babies: [Baby]
    @Query private var progressRecords: [MilestoneProgress]
    @State private var selectedMonth = 0
    @State private var showPaywall = false

    private var baby: Baby? { babies.first }

    private var milestones: [Milestone] {
        MilestoneEngine.milestonesForAge(selectedMonth)
    }

    private var completedIDs: Set<String> {
        Set(progressRecords.filter { $0.status == .completed }.map(\.milestoneID))
    }

    private var attentionIDs: Set<String> {
        Set(progressRecords.filter { $0.status == .attention }.map(\.milestoneID))
    }

    private var completedCount: Int {
        milestones.filter { completedIDs.contains($0.id) }.count
    }

    private var currentMonth: Int {
        min(max(baby?.ageInMonths ?? 0, 0), 24)
    }

    private var upgradeHint: String {
        if isEN {
            return "Free includes this month plus your first \(MonetizationPolicy.freeMilestoneTrackingLimit) saved milestones. Upgrade for every month and unlimited tracking."
        }
        return "Ücretsiz planda yalnızca bu ay ve ilk \(MonetizationPolicy.freeMilestoneTrackingLimit) milestone kaydı dahildir. Tüm aylar ve sınırsız takip için Premium'a geç."
    }

    private func isMonthLocked(_ month: Int) -> Bool {
        !MonetizationPolicy.canAccessMilestoneMonth(
            hasFullAccess: subscriptionManager.hasFullAccess,
            selectedMonth: month,
            currentMonth: currentMonth
        )
    }

    private var ringContextTitle: String {
        let locale = Locale.current.language.languageCode?.identifier ?? "tr"
        if locale == "tr" {
            switch selectedMonth {
            case 0...2: return "Bağlanma ve sakinleşme temelleri"
            case 3...4: return "Gülümseme ve baş kontrolü güçleniyor"
            case 5...6: return "Ses oyunları ve yuvarlanma başlıyor"
            case 7...9: return "İşaretler ve oturma becerisi belirginleşiyor"
            case 10...12: return "İlk jestler ve ayakta durma dönemi"
            case 13...15: return "Taklit ve ilk bağımsız adımlar"
            case 16...18: return "Bağımsızlık ve basit oyun artıyor"
            case 19...24: return "İki kelimelik ifadeler ve hareket temposu"
            default: return "Gelişim ilerlemeye devam ediyor"
            }
        } else {
            switch selectedMonth {
            case 0...2: return "Attachment and regulation foundations"
            case 3...4: return "Smiles and head control are strengthening"
            case 5...6: return "Sound play and rolling are emerging"
            case 7...9: return "Signals and sitting skills are taking shape"
            case 10...12: return "First gestures and standing practice"
            case 13...15: return "Imitation and first independent steps"
            case 16...18: return "Independence and simple play are growing"
            case 19...24: return "Two-word phrases and faster movement"
            default: return "Development continues to progress"
            }
        }
    }

    private var ringContextDescription: String {
        let locale = Locale.current.language.languageCode?.identifier ?? "tr"
        if locale == "tr" {
            switch selectedMonth {
            case 0...2: return "Sakinleşme, karşılıklı gülümseme ve yüzüstü baş kaldırma en belirgin işaretlerdir."
            case 3...4: return "Sese yönelme, agulama ve dirseklerle yükselme bu bantta öne çıkar."
            case 5...6: return "Tanıdık kişileri ayırt etme, ses oyunları ve yuvarlanma bu dönemde sık görülür."
            case 7...9: return "Tekrarlayan heceler, ayrılığa tepki ve desteksiz oturma belirginleşir."
            case 10...12: return "Jestler, saklanan nesneyi arama ve tutunarak ilerleme hızlanır."
            case 13...15: return "Taklit, yeni kelimeler ve kısa bağımsız yürüyüşler öne çıkar."
            case 16...18: return "İşaret ederek paylaşma, yönerge izleme ve basit oyun kurma artar."
            case 19...24: return "İki kelimelik ifadeler, koşma ve sosyal tepkiyi takip etme dönemi başlar."
            default: return "Her ay yeni gelişim aşamaları bebeğinizi bekliyor."
            }
        } else {
            switch selectedMonth {
            case 0...2: return "Calming, responsive smiles, and lifting the head during tummy time are the clearest signs here."
            case 3...4: return "Turning toward voices, cooing, and pushing up on elbows become more visible."
            case 5...6: return "Recognizing familiar people, sound play, and rolling show up more consistently."
            case 7...9: return "Repeated syllables, separation reactions, and unsupported sitting become easier to notice."
            case 10...12: return "Gestures, searching for hidden objects, and cruising along furniture accelerate."
            case 13...15: return "Imitation, new words, and short independent walks stand out in this stage."
            case 16...18: return "Pointing to share interest, following directions, and simple pretend play increase."
            case 19...24: return "Two-word phrases, running, and reading social reactions become more apparent."
            default: return "New developmental milestones await your baby each month."
            }
        }
    }

    private var isEN: Bool {
        Locale.current.language.languageCode?.identifier != "tr"
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Header
                VStack(alignment: .leading, spacing: 4) {
                    Text(String(localized: "milestones_eyebrow", defaultValue: "DEVELOPMENTAL MILESTONES"))
                        .font(.kinnaBody(9))
                        .foregroundStyle(.kMuted)
                        .tracking(1.5)

                    if isEN {
                        (
                            Text("Development ")
                                .font(.kinnaDisplay(26))
                                .foregroundStyle(.kChar)
                            +
                            Text("milestones")
                                .font(.kinnaDisplayItalic(26))
                                .foregroundStyle(.kTerra)
                        )
                    } else {
                        (
                            Text("Gelişim ")
                                .font(.kinnaDisplay(26))
                                .foregroundStyle(.kChar)
                            +
                            Text("taşları")
                                .font(.kinnaDisplayItalic(26))
                                .foregroundStyle(.kTerra)
                        )
                    }

                    if baby != nil {
                        Text(isEN
                            ? "\(selectedMonth) months \u{00B7} \(completedCount) of \(milestones.count) completed"
                            : "\(selectedMonth). ay \u{00B7} \(milestones.count) taştan \(completedCount)'i tamamlandı"
                        )
                            .font(.kinnaBody(12))
                            .foregroundStyle(.kLight)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 24)
                .padding(.top, 12)
                .padding(.bottom, 20)

                // Ring progress + context
                if !milestones.isEmpty {
                    HStack(spacing: 14) {
                        ZStack {
                            Circle()
                                .stroke(Color.kPale, lineWidth: 6)
                                .frame(width: 72, height: 72)
                            Circle()
                                .trim(from: 0, to: milestones.isEmpty ? 0 : CGFloat(completedCount) / CGFloat(milestones.count))
                                .stroke(Color.kSage, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                                .frame(width: 72, height: 72)
                                .rotationEffect(.degrees(-90))
                            Text("\(milestones.isEmpty ? 0 : (completedCount * 100 / milestones.count))%")
                                .font(.kinnaBodyMedium(14))
                                .foregroundStyle(.kChar)
                        }
                        .frame(width: 72)

                        VStack(alignment: .leading, spacing: 3) {
                            Text(ringContextTitle)
                                .font(.kinnaBodyMedium(12))
                                .foregroundStyle(.kChar)
                            Text(ringContextDescription)
                                .font(.kinnaBody(10))
                                .foregroundStyle(.kMid)
                                .lineSpacing(2)
                        }
                    }
                    .padding(14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.kPale, lineWidth: 1)
                    )
                    .padding(.horizontal, 24)
                    .padding(.bottom, 12)
                }

                if !subscriptionManager.hasFullAccess {
                    HStack(spacing: 10) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 12))
                            .foregroundStyle(.kTerra)

                        Text(upgradeHint)
                            .font(.kinnaBody(10))
                            .foregroundStyle(.kMid)
                            .lineSpacing(2)

                        Spacer(minLength: 8)

                        Button(isEN ? "Upgrade" : "Pro") {
                            showPaywall = true
                        }
                        .font(.kinnaBodyMedium(10))
                        .foregroundStyle(.kTerra)
                    }
                    .padding(12)
                    .background(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.kPale, lineWidth: 1)
                    )
                    .padding(.horizontal, 24)
                    .padding(.bottom, 12)
                }

                // Month selector
                ScrollViewReader { proxy in
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(0..<25, id: \.self) { month in
                                let isLocked = isMonthLocked(month)
                                Button {
                                    guard !isLocked else {
                                        showPaywall = true
                                        return
                                    }

                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        selectedMonth = month
                                    }
                                } label: {
                                    HStack(spacing: 4) {
                                        Text(isEN ? "Mo \(month)" : "\(month). ay")
                                            .font(.kinnaBody(12))

                                        if isLocked {
                                            Image(systemName: "lock.fill")
                                                .font(.system(size: 9, weight: .semibold))
                                        }
                                    }
                                        .foregroundStyle(selectedMonth == month ? .white : (isLocked ? .kLight : .kMid))
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 6)
                                        .background(selectedMonth == month ? Color.kChar : .white)
                                        .clipShape(Capsule())
                                        .overlay(
                                            Capsule()
                                                .stroke(selectedMonth == month ? Color.kChar : Color.kPale, lineWidth: 1)
                                        )
                                }
                                .id(month)
                            }
                        }
                        .padding(.horizontal, 24)
                    }
                    .onAppear {
                        if let baby {
                            selectedMonth = baby.ageInMonths
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                withAnimation {
                                    proxy.scrollTo(selectedMonth, anchor: .center)
                                }
                            }
                        }
                    }
                }
                .padding(.bottom, 16)

                if !subscriptionManager.hasFullAccess {
                    HStack(spacing: 10) {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(.kTerra)

                        Text(isEN
                             ? "Free access stays on your baby's current month. Upgrade to browse every month."
                             : "Ücretsiz planda yalnızca bebeğinin bu ayı açık. Tüm ayları görmek için Premium'a geç.")
                            .font(.kinnaBody(10))
                            .foregroundStyle(.kMid)
                            .lineSpacing(2)

                        Spacer(minLength: 8)

                        Button(isEN ? "Premium" : "Premium") {
                            showPaywall = true
                        }
                        .font(.kinnaBodyMedium(10))
                        .foregroundStyle(.kTerra)
                    }
                    .padding(12)
                    .background(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.kPale, lineWidth: 1)
                    )
                    .padding(.horizontal, 24)
                    .padding(.bottom, 16)
                }

                // Milestone list
                LazyVStack(spacing: 0) {
                    if milestones.isEmpty {
                        VStack(spacing: 12) {
                            Text("🌟")
                                .font(.system(size: 40))
                            Text(String(localized: "milestones_empty", defaultValue: "No milestones for this month"))
                                .font(.kinnaBody(14))
                                .foregroundStyle(.kMid)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 60)
                    } else {
                        ForEach(milestones) { milestone in
                            milestoneRow(milestone)
                        }
                    }
                }
                .padding(.horizontal, 24)
            }
            .padding(.bottom, 20)
        }
        .background(Color.kCream.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showPaywall) {
            NavigationStack {
                PaywallView()
            }
            .environment(subscriptionManager)
        }
    }

    // MARK: - Milestone Row

    private func milestoneRow(_ milestone: Milestone) -> some View {
        let isDone = completedIDs.contains(milestone.id)
        let needsAttention = attentionIDs.contains(milestone.id)

        return HStack(alignment: .top, spacing: 14) {
            Button {
                toggleMilestone(milestone.id)
            } label: {
                RoundedRectangle(cornerRadius: 8)
                    .fill(isDone ? Color.kSage : (needsAttention ? Color.kTerraLight : .white))
                    .frame(width: 24, height: 24)
                    .overlay {
                        if isDone {
                            Text("✓")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(.white)
                        } else if needsAttention {
                            Text("!")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(.kTerra)
                        }
                    }
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(isDone ? Color.clear : (needsAttention ? Color.clear : Color.kPale), lineWidth: 1.5)
                    )
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(isEN ? milestone.titleEN : milestone.titleTR)
                    .font(.kinnaBodyMedium(13))
                    .foregroundStyle(.kChar)

                Text(isEN ? milestone.descriptionEN : milestone.descriptionTR)
                    .font(.kinnaBody(11))
                    .foregroundStyle(.kMid)
                    .lineSpacing(2)
                    .lineLimit(2)
            }

            Spacer()

            categoryTag(milestone.category)
        }
        .padding(.vertical, 14)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Color.kPale)
                .frame(height: 1)
        }
    }

    private func categoryTag(_ category: String) -> some View {
        let (bg, fg, label) = tagStyle(for: category)
        return Text(label.uppercased())
            .font(.kinnaBodyMedium(9))
            .foregroundStyle(fg)
            .tracking(0.5)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(bg)
            .clipShape(RoundedRectangle(cornerRadius: 6))
    }

    private func tagStyle(for category: String) -> (Color, Color, String) {
        let lowered = category.lowercased()
        if isEN {
            switch lowered {
            case "motor", "kaba motor", "ince motor":
                return (Color(hex: 0xEAF3EF), .kSageDark, "Physical")
            case "sosyal", "sosyal-duygusal", "social":
                return (.kTerraLight, .kTerra, "Social")
            case "dil", "language":
                return (Color(hex: 0xE8EEF7), Color(hex: 0x4F6B8A), "Language")
            case "bilişsel", "cognitive":
                return (Color(hex: 0xE8E4F0), Color(hex: 0x6B5C8F), "Cognitive")
            case "dil-bilişsel":
                return (Color(hex: 0xE8E4F0), Color(hex: 0x6B5C8F), "Language")
            default:
                return (.kPale, .kMid, category)
            }
        } else {
            switch lowered {
            case "motor", "kaba motor", "ince motor":
                return (Color(hex: 0xEAF3EF), .kSageDark, "Fiziksel")
            case "sosyal", "sosyal-duygusal", "social":
                return (.kTerraLight, .kTerra, "Sosyal")
            case "dil", "language":
                return (Color(hex: 0xE8EEF7), Color(hex: 0x4F6B8A), "Dil")
            case "bilişsel", "cognitive":
                return (Color(hex: 0xE8E4F0), Color(hex: 0x6B5C8F), "Bilişsel")
            case "dil-bilişsel":
                return (Color(hex: 0xE8E4F0), Color(hex: 0x6B5C8F), "Dil")
            default:
                return (.kPale, .kMid, category)
            }
        }
    }

    private func toggleMilestone(_ id: String) {
        withAnimation(.easeInOut(duration: 0.2)) {
            if let existing = progressRecords.first(where: { $0.milestoneID == id }) {
                modelContext.delete(existing)
            } else {
                guard MonetizationPolicy.canSaveMilestone(
                    hasFullAccess: subscriptionManager.hasFullAccess,
                    currentTrackedCount: progressRecords.count,
                    isAlreadyTracked: false
                ) else {
                    showPaywall = true
                    return
                }

                let progress = MilestoneProgress(milestoneID: id, status: .completed)
                modelContext.insert(progress)
            }
        }
    }
}

#Preview {
    NavigationStack {
        MilestonesView()
    }
    .modelContainer(for: [Baby.self, MilestoneProgress.self], inMemory: true)
    .environment(SubscriptionManager.shared)
}
