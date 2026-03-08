import SwiftUI
import SwiftData

struct AllergyView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \AllergyLog.introducedDate, order: .reverse) private var logs: [AllergyLog]
    @Query private var babies: [Baby]
    @State private var showAddSheet = false

    private var baby: Baby? { babies.first }

    private var isEN: Bool { Locale.current.language.languageCode?.identifier != "tr" }

    private var totalCount: Int { logs.count }
    private var safeCount: Int { logs.filter { $0.reaction == .none }.count }
    private var cautionCount: Int { logs.filter { $0.reaction != .none }.count }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Header
                VStack(alignment: .leading, spacing: 4) {
                    Text(isEN ? "FOOD DIARY" : "EK GIDA GÜNLÜĞÜ")
                        .font(.kinnaBody(9))
                        .foregroundStyle(.kMuted)
                        .tracking(1.5)

                    (
                        Text(isEN ? "Food " : "Besin ")
                            .font(.kinnaDisplay(26))
                            .foregroundStyle(.kChar)
                        +
                        Text(isEN ? "tracker" : "takibi")
                            .font(.kinnaDisplayItalic(26))
                            .foregroundStyle(.kTerra)
                    )

                    Text(isEN ? "Note reactions within the first 24 hours." : "Reaksiyonları ilk 24 saatte not al.")
                        .font(.kinnaBody(12, weight: .light))
                        .foregroundStyle(.kMid)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 12)
                .padding(.bottom, 20)

                // Stats row
                HStack(spacing: 10) {
                    statCard(value: "\(totalCount)", label: isEN ? "TRIED" : "DENENEN", valueColor: .kChar)
                    statCard(value: "\(safeCount)", label: isEN ? "SAFE" : "SORUNSUZ", valueColor: .kSageDark)
                    statCard(value: "\(cautionCount)", label: isEN ? "CAUTION" : "DİKKAT", valueColor: .kTerra)
                }
                .padding(.bottom, 16)

                // Food list
                if !logs.isEmpty {
                    Text(isEN ? "RECENTLY ADDED" : "SON EKLENENLER")
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
                        Text(isEN ? "No food records added yet" : "Henüz besin kaydı eklenmemiş")
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
                    Text(isEN ? "Try new foods one at a time, 3 days apart. Consult your doctor if there is a noticeable reaction." : "Yeni besinleri tek tek ve 3 gün arayla dene. Belirgin reaksiyon durumunda doktoruna danış.")
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
                    Text(isEN ? "+ Add new food" : "+ Yeni besin ekle")
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
                return (Color(hex: 0xEAF3EF), .kSageDark, isEN ? "Good" : "İyi")
            case .mild:
                return (Color(hex: 0xFFF8ED), Color(hex: 0x8B7030), isEN ? "Mild" : "Hafif")
            case .moderate:
                return (Color(hex: 0xFFF3ED), Color(hex: 0xA85E42), isEN ? "Rash" : "Kızarıklık")
            case .severe:
                return (Color(hex: 0xFFF3ED), Color(hex: 0xC4644A), isEN ? "Severe" : "Ciddi")
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
        let folded = lowered.folding(options: .diacriticInsensitive, locale: Locale(identifier: "tr"))

        // Fruits
        if lowered.contains("elma") || lowered.contains("apple") { return "🍎" }
        if lowered.contains("muz") || lowered.contains("banana") { return "🍌" }
        if lowered.contains("armut") || lowered.contains("pear") { return "🍐" }
        if lowered.contains("çilek") || folded.contains("cilek") || lowered.contains("strawberry") { return "🍓" }
        if lowered.contains("karpuz") || lowered.contains("watermelon") { return "🍉" }
        if lowered.contains("üzüm") || folded.contains("uzum") || lowered.contains("grape") { return "🍇" }
        if lowered.contains("şeftali") || folded.contains("seftali") || lowered.contains("peach") { return "🍑" }
        if lowered.contains("erik") || lowered.contains("plum") { return "🫐" }
        if lowered.contains("kiraz") || lowered.contains("cherry") { return "🍒" }
        if lowered.contains("kivi") || lowered.contains("kiwi") { return "🥝" }
        if lowered.contains("mango") { return "🥭" }
        if lowered.contains("kavun") || lowered.contains("melon") { return "🍈" }
        if lowered.contains("portakal") || lowered.contains("orange") { return "🍊" }
        if lowered.contains("yaban mersini") || lowered.contains("blueberry") { return "🫐" }
        if lowered.contains("ahududu") || lowered.contains("raspberry") { return "🫐" }
        if lowered.contains("kayısı") || folded.contains("kayisi") || lowered.contains("apricot") { return "🍑" }

        // Vegetables
        if lowered.contains("havuç") || folded.contains("havuc") || lowered.contains("carrot") { return "🥕" }
        if lowered.contains("tatlı patates") || lowered.contains("sweet potato") { return "🍠" }
        if lowered.contains("patates") || lowered.contains("potato") { return "🥔" }
        if lowered.contains("kabak") || lowered.contains("zucchini") { return "🥒" }
        if lowered.contains("brokoli") || lowered.contains("broccoli") { return "🥦" }
        if lowered.contains("ıspanak") || folded.contains("ispanak") || lowered.contains("spinach") { return "🥬" }
        if lowered.contains("domates") || lowered.contains("tomato") { return "🍅" }
        if lowered.contains("bezelye") || lowered.contains("peas") { return "🫛" }
        if lowered.contains("mısır") || folded.contains("misir") || lowered.contains("corn") { return "🌽" }
        if lowered.contains("biber") || lowered.contains("pepper") { return "🌶️" }
        if lowered.contains("salatalık") || folded.contains("salatalik") || lowered.contains("cucumber") { return "🥒" }
        if lowered.contains("marul") || lowered.contains("lettuce") { return "🥬" }
        if lowered.contains("soğan") || folded.contains("sogan") || lowered.contains("onion") { return "🧅" }
        if lowered.contains("sarımsak") || folded.contains("sarimsak") || lowered.contains("garlic") { return "🧄" }
        if lowered.contains("patlıcan") || folded.contains("patlican") || lowered.contains("eggplant") { return "🍆" }
        if lowered.contains("karnabahar") || lowered.contains("cauliflower") { return "🥦" }
        if lowered.contains("kereviz") || lowered.contains("celery") { return "🥬" }
        if lowered.contains("pancar") || lowered.contains("beet") { return "🫒" }
        if lowered.contains("avokado") || lowered.contains("avocado") { return "🥑" }

        // Protein
        if lowered.contains("yumurta") || lowered.contains("egg") { return "🥚" }
        if lowered.contains("tavuk") || lowered.contains("chicken") { return "🍗" }
        if lowered.contains("balık") || folded.contains("balik") || lowered.contains("fish") { return "🐟" }
        if lowered.contains("hindi") || lowered.contains("turkey") { return "🍗" }
        if lowered.contains("kuzu") || lowered.contains("lamb") { return "🥩" }
        if lowered.contains("et") || lowered.contains("meat") || lowered.contains("beef") { return "🥩" }

        // Dairy
        if lowered.contains("süt") || folded.contains("sut") || lowered.contains("milk") { return "🥛" }
        if lowered.contains("yoğurt") || folded.contains("yogurt") { return "🥣" }
        if lowered.contains("peynir") || lowered.contains("cheese") { return "🧀" }
        if lowered.contains("tereyağı") || folded.contains("tereyagi") || lowered.contains("butter") { return "🧈" }

        // Grains
        if lowered.contains("pirinç") || folded.contains("pirinc") || lowered.contains("pilav") || lowered.contains("rice") { return "🍚" }
        if lowered.contains("ekmek") || lowered.contains("bread") { return "🍞" }
        if lowered.contains("yulaf") || lowered.contains("oat") { return "🥣" }
        if lowered.contains("makarna") || lowered.contains("pasta") { return "🍝" }
        if lowered.contains("buğday") || folded.contains("bugday") || lowered.contains("wheat") { return "🌾" }
        if lowered.contains("mercimek") || lowered.contains("lentil") { return "🫘" }
        if lowered.contains("nohut") || lowered.contains("chickpea") { return "🫘" }
        if lowered.contains("bulgur") { return "🌾" }

        // Other
        if lowered.contains("bal") || lowered.contains("honey") { return "🍯" }
        if lowered.contains("fıstık") || folded.contains("fistik") || lowered.contains("peanut") { return "🥜" }
        if lowered.contains("badem") || lowered.contains("almond") { return "🥜" }
        if lowered.contains("ceviz") || lowered.contains("walnut") { return "🥜" }
        if lowered.contains("fındık") || folded.contains("findik") || lowered.contains("hazelnut") { return "🌰" }
        if lowered.contains("susam") || lowered.contains("sesame") { return "🥜" }
        if lowered.contains("soya") || lowered.contains("soy") { return "🫘" }

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

    private var isEN: Bool { Locale.current.language.languageCode?.identifier != "tr" }

    private var commonFoods: [String] {
        isEN
            ? ["Carrot", "Banana", "Apple", "Potato", "Avocado", "Zucchini",
               "Egg", "Yogurt", "Rice", "Broccoli", "Pear", "Strawberry"]
            : ["Havuç", "Muz", "Elma", "Patates", "Avokado", "Kabak",
               "Yumurta", "Yoğurt", "Pirinç", "Brokoli", "Armut", "Çilek"]
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Food name
                    VStack(alignment: .leading, spacing: 6) {
                        fieldLabel(isEN ? "FOOD NAME" : "BESIN ADI")
                        TextField(isEN ? "e.g., Carrot puree" : "örnek: Havuç püresi", text: $foodName)
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
                        fieldLabel(isEN ? "QUICK PICK" : "HIZLI SECIM")
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
                        fieldLabel(isEN ? "INTRODUCTION DATE" : "TANITIM TARIHI")
                        DatePicker("", selection: $introducedDate, in: ...Date(), displayedComponents: .date)
                            .labelsHidden()
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    // Reaction
                    VStack(alignment: .leading, spacing: 8) {
                        fieldLabel(isEN ? "REACTION" : "REAKSIYON")
                        HStack(spacing: 8) {
                            reactionButton(isEN ? "None" : "Yok", type: .none, color: .kSage)
                            reactionButton(isEN ? "Mild" : "Hafif", type: .mild, color: Color(hex: 0xD4A643))
                            reactionButton(isEN ? "Moderate" : "Orta", type: .moderate, color: .kTerra)
                            reactionButton(isEN ? "Severe" : "Ciddi", type: .severe, color: Color(hex: 0xC44A4A))
                        }
                    }

                    // Reaction note
                    if reaction != .none {
                        VStack(alignment: .leading, spacing: 6) {
                            fieldLabel(isEN ? "REACTION NOTE" : "REAKSIYON NOTU")
                            TextField(isEN ? "Rash, vomiting, gas..." : "Kızarıklık, kusma, gaz...", text: $reactionNote)
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
                        Text(isEN ? "Try new foods one at a time, 3 days apart." : "Yeni besinleri tek tek ve 3 gun arayla deneyin.")
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
            .navigationTitle(isEN ? "New Food" : "Yeni Besin")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(isEN ? "Cancel" : "Vazgeç") { dismiss() }
                        .foregroundStyle(.kMid)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(isEN ? "Save" : "Kaydet") { saveFood() }
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
