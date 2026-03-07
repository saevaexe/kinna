import SwiftUI
import SwiftData

struct AllergyView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \AllergyLog.introducedDate, order: .reverse) private var logs: [AllergyLog]
    @Query private var babies: [Baby]
    @State private var showAddSheet = false

    private var baby: Baby? { babies.first }

    private var totalCount: Int { logs.count }
    private var safeCount: Int { logs.filter { $0.reaction == .none }.count }
    private var cautionCount: Int { logs.filter { $0.reaction != .none }.count }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Header
                VStack(alignment: .leading, spacing: 4) {
                    Text("EK GIDA GÜNLÜĞÜ")
                        .font(.kinnaBody(9))
                        .foregroundStyle(.kMuted)
                        .tracking(1.5)

                    (
                        Text("Besin ")
                            .font(.kinnaDisplay(26))
                            .foregroundStyle(.kChar)
                        +
                        Text("takibi")
                            .font(.kinnaDisplayItalic(26))
                            .foregroundStyle(.kTerra)
                    )

                    Text("Reaksiyonları ilk 24 saatte not al.")
                        .font(.kinnaBody(12, weight: .light))
                        .foregroundStyle(.kMid)
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

                // Tip box
                HStack(alignment: .top, spacing: 8) {
                    Text("📌")
                        .font(.system(size: 12))
                    Text("Yeni besinleri tek tek ve 3 gün arayla dene. Belirgin reaksiyon durumunda doktoruna danış.")
                        .font(.kinnaBody(10))
                        .foregroundStyle(.kMid)
                        .lineSpacing(2)
                }
                .padding(12)
                .background(Color.kWarm)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(Color.kPale, style: StrokeStyle(lineWidth: 1, dash: [5, 3]))
                )
                .padding(.top, 8)

                // Add food button
                Button {
                    showAddSheet = true
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
        .sheet(isPresented: $showAddSheet) {
            AddFoodSheet()
                .presentationDetents([.medium])
        }
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
        let (bg, fg, label): (Color, Color, String) = {
            switch reaction {
            case .none:
                return (Color(hex: 0xEAF3EF), .kSageDark, "İyi")
            case .mild:
                return (Color(hex: 0xFFF8ED), Color(hex: 0x8B7030), "Hafif")
            case .moderate:
                return (Color(hex: 0xFFF3ED), Color(hex: 0xA85E42), "Kızarıklık")
            case .severe:
                return (Color(hex: 0xFFF3ED), Color(hex: 0xC4644A), "Ciddi")
            }
        }()

        return Text(label)
            .font(.kinnaBodyMedium(9))
            .foregroundStyle(fg)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(bg)
            .clipShape(RoundedRectangle(cornerRadius: 100))
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

// MARK: - Add Food Sheet

struct AddFoodSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var foodName = ""
    @State private var introducedDate = Date()
    @State private var reaction: AllergyLog.ReactionType = .none
    @State private var reactionNote = ""

    private let commonFoods = [
        "Havuc", "Muz", "Elma", "Patates", "Avokado", "Kabak",
        "Yumurta", "Yogurt", "Pirinc", "Brokoli", "Armut", "Cilek"
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Food name
                    VStack(alignment: .leading, spacing: 6) {
                        fieldLabel("BESIN ADI")
                        TextField("örnek: Havuç püresi", text: $foodName)
                            .font(.kinnaBody(14))
                            .padding(12)
                            .background(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.kPale, lineWidth: 1.5)
                            )
                    }

                    // Quick picks
                    VStack(alignment: .leading, spacing: 8) {
                        fieldLabel("HIZLI SECIM")
                        LazyVGrid(columns: [
                            GridItem(.flexible()), GridItem(.flexible()),
                            GridItem(.flexible()), GridItem(.flexible())
                        ], spacing: 8) {
                            ForEach(commonFoods, id: \.self) { food in
                                Button {
                                    foodName = food
                                } label: {
                                    Text(food)
                                        .font(.kinnaBody(11))
                                        .foregroundStyle(foodName == food ? .kTerra : .kMid)
                                        .fontWeight(foodName == food ? .medium : .regular)
                                        .padding(.vertical, 8)
                                        .frame(maxWidth: .infinity)
                                        .background(foodName == food ? Color.kTerraLight.opacity(0.5) : .white)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(foodName == food ? Color.kTerra : Color.kPale, lineWidth: 1)
                                        )
                                }
                            }
                        }
                    }

                    // Date
                    VStack(alignment: .leading, spacing: 6) {
                        fieldLabel("TANITIM TARIHI")
                        DatePicker("", selection: $introducedDate, in: ...Date(), displayedComponents: .date)
                            .labelsHidden()
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    // Reaction
                    VStack(alignment: .leading, spacing: 8) {
                        fieldLabel("REAKSIYON")
                        HStack(spacing: 8) {
                            reactionButton("Yok", type: .none, color: .kSage)
                            reactionButton("Hafif", type: .mild, color: Color(hex: 0xD4A643))
                            reactionButton("Orta", type: .moderate, color: .kTerra)
                            reactionButton("Ciddi", type: .severe, color: Color(hex: 0xC44A4A))
                        }
                    }

                    // Reaction note
                    if reaction != .none {
                        VStack(alignment: .leading, spacing: 6) {
                            fieldLabel("REAKSIYON NOTU")
                            TextField("Kızarıklık, kusma, gaz...", text: $reactionNote)
                                .font(.kinnaBody(14))
                                .padding(12)
                                .background(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.kPale, lineWidth: 1.5)
                                )
                        }
                    }

                    // Tip
                    HStack(alignment: .top, spacing: 8) {
                        Text("📌")
                            .font(.system(size: 12))
                        Text("Yeni besinleri tek tek ve 3 gun arayla deneyin.")
                            .font(.kinnaBody(11))
                            .foregroundStyle(.kMid)
                            .lineSpacing(2)
                    }
                    .padding(12)
                    .background(Color.kWarm)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .strokeBorder(Color.kPale, style: StrokeStyle(lineWidth: 1, dash: [5, 3]))
                    )
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 20)
            }
            .background(Color.kCream.ignoresSafeArea())
            .navigationTitle("Yeni Besin")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Vazgeç") { dismiss() }
                        .foregroundStyle(.kMid)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Kaydet") { saveFood() }
                        .fontWeight(.semibold)
                        .foregroundStyle(.kTerra)
                        .disabled(foodName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }

    private func saveFood() {
        let name = foodName.trimmingCharacters(in: .whitespaces)
        guard !name.isEmpty else { return }

        let log = AllergyLog(
            foodName: name,
            introducedDate: introducedDate,
            reaction: reaction,
            reactionNote: reactionNote
        )
        modelContext.insert(log)
        dismiss()
    }

    private func fieldLabel(_ text: String) -> some View {
        Text(text)
            .font(.kinnaBodyMedium(10))
            .foregroundStyle(.kLight)
            .tracking(1)
    }

    private func reactionButton(_ title: String, type: AllergyLog.ReactionType, color: Color) -> some View {
        let isSelected = reaction == type
        return Button {
            withAnimation(.easeInOut(duration: 0.15)) { reaction = type }
        } label: {
            Text(title)
                .font(.kinnaBody(12))
                .fontWeight(isSelected ? .medium : .regular)
                .frame(maxWidth: .infinity)
                .padding(10)
                .background(isSelected ? color.opacity(0.15) : .white)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(isSelected ? color : Color.kPale, lineWidth: 1.5)
                )
        }
        .foregroundStyle(isSelected ? color : .kMid)
    }
}

#Preview {
    NavigationStack {
        AllergyView()
    }
    .modelContainer(for: [AllergyLog.self, Baby.self], inMemory: true)
}
