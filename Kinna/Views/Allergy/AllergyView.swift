import SwiftUI
import SwiftData

struct AllergyView: View {
    @Query(sort: \AllergyLog.introducedDate, order: .reverse) private var logs: [AllergyLog]
    @Query private var babies: [Baby]

    private var baby: Baby? { babies.first }

    private var totalCount: Int { logs.count }
    private var safeCount: Int { logs.filter { $0.reaction == .none }.count }
    private var cautionCount: Int { logs.filter { $0.reaction != .none }.count }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Header
                VStack(alignment: .leading, spacing: 4) {
                    Text("Besin Günlüğü")
                        .font(.kinnaDisplay(26))
                        .foregroundStyle(.kChar)

                    if let baby {
                        Text("\(baby.name) · 6. aydan itibaren")
                            .font(.kinnaBody(12))
                            .foregroundStyle(.kLight)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 12)
                .padding(.bottom, 20)

                // Stats row
                HStack(spacing: 10) {
                    statCard(value: "\(totalCount)", label: "DENENEN", valueColor: .kChar)
                    statCard(value: "\(safeCount)", label: "SORUNSUZ", valueColor: .kSageDark)
                    statCard(value: "\(cautionCount)", label: "DİKKAT", valueColor: .kTerra)
                }
                .padding(.bottom, 16)

                // Food list
                if !logs.isEmpty {
                    Text("SON EKLENENLER")
                        .font(.kinnaBodyMedium(11))
                        .foregroundStyle(.kLight)
                        .tracking(1.5)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.bottom, 8)

                    ForEach(logs) { log in
                        foodRow(log)
                    }
                } else {
                    VStack(spacing: 12) {
                        Text("🥄")
                            .font(.system(size: 40))
                        Text("Henüz besin kaydı eklenmemiş")
                            .font(.kinnaBody(14))
                            .foregroundStyle(.kMid)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 40)
                }

                // Add food button
                Button {
                    // TODO: Add food sheet
                } label: {
                    Text("+ Yeni besin ekle")
                        .font(.kinnaBody(13))
                        .foregroundStyle(.kLight)
                        .frame(maxWidth: .infinity)
                        .padding(14)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .strokeBorder(Color.kPale, style: StrokeStyle(lineWidth: 1.5, dash: [6, 4]))
                        )
                }
                .padding(.top, 12)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 20)
        }
        .background(Color.kCream.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Stat Card

    private func statCard(value: String, label: String, valueColor: Color) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.kinnaDisplay(28, weight: .light))
                .foregroundStyle(valueColor)

            Text(label)
                .font(.kinnaBodyMedium(10))
                .foregroundStyle(.kLight)
                .tracking(0.8)
        }
        .frame(maxWidth: .infinity)
        .padding(14)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.kPale, lineWidth: 1)
        )
    }

    // MARK: - Food Row

    private func foodRow(_ log: AllergyLog) -> some View {
        HStack(spacing: 12) {
            // Emoji box
            RoundedRectangle(cornerRadius: 10)
                .fill(.white)
                .frame(width: 36, height: 36)
                .overlay {
                    Text(foodEmoji(log.foodName))
                        .font(.system(size: 18))
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.kPale, lineWidth: 1)
                )

            // Info
            VStack(alignment: .leading, spacing: 2) {
                Text(log.foodName)
                    .font(.kinnaBodyMedium(13))
                    .foregroundStyle(.kChar)

                Text(log.introducedDate, format: .dateTime.day().month(.abbreviated))
                    .font(.kinnaBody(10))
                    .foregroundStyle(.kLight)
            }

            Spacer()

            // Reaction badge
            reactionBadge(log.reaction)
        }
        .padding(.vertical, 12)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Color.kPale)
                .frame(height: 1)
        }
    }

    private func reactionBadge(_ reaction: AllergyLog.ReactionType) -> some View {
        let (bg, fg, icon): (Color, Color, String) = {
            switch reaction {
            case .none:
                return (Color(hex: 0xEAF3EF), .kSageDark, "✓")
            case .mild:
                return (Color(hex: 0xFFF8ED), Color(hex: 0xC49A4A), "~")
            case .moderate, .severe:
                return (Color(hex: 0xFFF3ED), Color(hex: 0xC4644A), "⚠️")
            }
        }()

        return Text(icon)
            .font(.kinnaBodyMedium(10))
            .foregroundStyle(fg)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(bg)
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private func foodEmoji(_ name: String) -> String {
        let lowered = name.lowercased()
        if lowered.contains("yumurta") { return "🥚" }
        if lowered.contains("süt") { return "🥛" }
        if lowered.contains("muz") { return "🍌" }
        if lowered.contains("elma") { return "🍎" }
        if lowered.contains("havuç") { return "🥕" }
        if lowered.contains("patates") { return "🥔" }
        if lowered.contains("avokado") { return "🥑" }
        if lowered.contains("pirinç") || lowered.contains("pilav") { return "🍚" }
        if lowered.contains("balık") { return "🐟" }
        if lowered.contains("et") { return "🥩" }
        if lowered.contains("peynir") { return "🧀" }
        if lowered.contains("ekmek") { return "🍞" }
        if lowered.contains("yoğurt") { return "🥣" }
        if lowered.contains("çilek") { return "🍓" }
        if lowered.contains("portakal") { return "🍊" }
        return "🥄"
    }
}

#Preview {
    NavigationStack {
        AllergyView()
    }
    .modelContainer(for: [AllergyLog.self, Baby.self], inMemory: true)
}
