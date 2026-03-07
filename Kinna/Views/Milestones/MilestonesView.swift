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
        switch selectedMonth {
        case 0...2: return "Baglanma kaliplari destekleniyor"
        case 3...5: return "Motor beceriler gelisiyor"
        case 6...9: return "Iletisim temelleri kuruluyor"
        case 10...12: return "Kesfetme donemi basliyor"
        default: return "Gelisim ilerlemeye devam ediyor"
        }
    }

    private var ringContextDescription: String {
        switch selectedMonth {
        case 0...2: return "Ses, gulumseme ve goz temasiyla etkilesimler bu ay kritik."
        case 3...5: return "Nesneleri kavrama ve yuvarlanma gibi hareketler basliyor."
        case 6...9: return "Ilk heceler ve isaret etme gibi iletisim becerileri gelisiyor."
        case 10...12: return "Bagimsiz hareket ve cevre kesfetme yogunlasiyor."
        default: return "Her ay yeni gelisim asamalari bebeginizi bekliyor."
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(alignment: .leading, spacing: 4) {
                Text(baby != nil ? "\(baby!.name) büyüyor" : "Gelişim Taşları")
                    .font(.kinnaDisplay(26))
                    .foregroundStyle(.kChar)

                Text("\(selectedMonth). ay · \(milestones.count) taştan \(completedCount)'i tamamlandı")
                    .font(.kinnaBody(12))
                    .foregroundStyle(.kLight)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 24)
            .padding(.top, 12)
            .padding(.bottom, 20)

            // Ring progress + context
            if !milestones.isEmpty {
                HStack(spacing: 14) {
                    // Conic ring
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
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(0..<25, id: \.self) { month in
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedMonth = month
                            }
                        } label: {
                            Text("\(month). ay")
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
                    }
                }
                .padding(.horizontal, 24)
            }
            .padding(.bottom, 20)

            // Milestone list
            ScrollView {
                LazyVStack(spacing: 0) {
                    if milestones.isEmpty {
                        VStack(spacing: 12) {
                            Text("🌟")
                                .font(.system(size: 40))
                            Text("Bu ay için kilometre taşı bulunmuyor")
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
        }
        .background(Color.kCream.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if let baby {
                selectedMonth = baby.ageInMonths
            }
        }
    }

    // MARK: - Milestone Row

    private func milestoneRow(_ milestone: Milestone) -> some View {
        let isDone = completedIDs.contains(milestone.id)
        let needsAttention = attentionIDs.contains(milestone.id)

        return HStack(alignment: .top, spacing: 14) {
            // Checkbox
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

            // Content
            VStack(alignment: .leading, spacing: 2) {
                Text(milestone.titleTR)
                    .font(.kinnaBodyMedium(13))
                    .foregroundStyle(.kChar)

                Text(milestone.descriptionTR)
                    .font(.kinnaBody(11))
                    .foregroundStyle(.kMid)
                    .lineSpacing(2)

                // Category tag
                categoryTag(milestone.category)
                    .padding(.top, 4)
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
        switch category.lowercased() {
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
