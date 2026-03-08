import SwiftUI
import SwiftData

struct MilestonesView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var babies: [Baby]
    @Query private var progressRecords: [MilestoneProgress]
    @State private var selectedMonth = 0

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

    private var ringContextTitle: String {
        let locale = Locale.current.language.languageCode?.identifier ?? "tr"
        if locale == "tr" {
            switch selectedMonth {
            case 0...2: return "Bağlanma kalıpları destekleniyor"
            case 3...5: return "Motor beceriler gelişiyor"
            case 6...9: return "İletişim temelleri kuruluyor"
            case 10...12: return "Keşfetme dönemi başlıyor"
            default: return "Gelişim ilerlemeye devam ediyor"
            }
        } else {
            switch selectedMonth {
            case 0...2: return "Building attachment patterns"
            case 3...5: return "Motor skills developing"
            case 6...9: return "Communication foundations forming"
            case 10...12: return "Exploration period beginning"
            default: return "Development continues to progress"
            }
        }
    }

    private var ringContextDescription: String {
        let locale = Locale.current.language.languageCode?.identifier ?? "tr"
        if locale == "tr" {
            switch selectedMonth {
            case 0...2: return "Ses, gülümseme ve göz temasıyla etkileşimler bu ay kritik."
            case 3...5: return "Nesneleri kavrama ve yuvarlanma gibi hareketler başlıyor."
            case 6...9: return "İlk heceler ve işaret etme gibi iletişim becerileri gelişiyor."
            case 10...12: return "Bağımsız hareket ve çevre keşfetme yoğunlaşıyor."
            default: return "Her ay yeni gelişim aşamaları bebeğinizi bekliyor."
            }
        } else {
            switch selectedMonth {
            case 0...2: return "Voice, smile, and eye contact interactions are critical this month."
            case 3...5: return "Grasping objects and rolling movements are starting."
            case 6...9: return "First syllables and pointing communication skills are developing."
            case 10...12: return "Independent movement and environment exploration are intensifying."
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

                    if let baby {
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

                // Month selector
                ScrollViewReader { proxy in
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(0..<25, id: \.self) { month in
                                Button {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        selectedMonth = month
                                    }
                                } label: {
                                    Text(isEN ? "Mo \(month)" : "\(month). ay")
                                        .font(.kinnaBody(12))
                                        .foregroundStyle(selectedMonth == month ? .white : .kMid)
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
                HStack(spacing: 6) {
                    Text(isEN ? milestone.titleEN : milestone.titleTR)
                        .font(.kinnaBodyMedium(13))
                        .foregroundStyle(.kChar)

                    categoryTag(milestone.category)
                }

                Text(isEN ? milestone.descriptionEN : milestone.descriptionTR)
                    .font(.kinnaBody(11))
                    .foregroundStyle(.kMid)
                    .lineSpacing(2)
                    .lineLimit(2)
            }
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
                return (Color(hex: 0xEAF3EF), .kSageDark, "Motor")
            case "sosyal", "sosyal-duygusal", "social":
                return (.kTerraLight, .kTerra, "Social")
            case "bilişsel", "dil", "dil-bilişsel", "language", "cognitive":
                return (Color(hex: 0xE8E4F0), Color(hex: 0x6B5C8F), "Language")
            default:
                return (.kPale, .kMid, category)
            }
        } else {
            switch lowered {
            case "motor", "kaba motor", "ince motor":
                return (Color(hex: 0xEAF3EF), .kSageDark, category)
            case "sosyal", "sosyal-duygusal":
                return (.kTerraLight, .kTerra, category)
            case "bilişsel", "dil", "dil-bilişsel":
                return (Color(hex: 0xE8E4F0), Color(hex: 0x6B5C8F), category)
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
}
