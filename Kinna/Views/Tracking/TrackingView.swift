import SwiftUI
import SwiftData

struct TrackingView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \DailyLog.createdAt, order: .reverse) private var logs: [DailyLog]
    @Query private var babies: [Baby]
    @State private var showAddSheet = false
    @State private var preselectedType: DailyLog.LogType = .feeding

    private var baby: Baby? { babies.first }

    private var todayLogs: [DailyLog] {
        logs.filter { Calendar.current.isDateInToday($0.date) }
    }

    private var feedingCount: Int {
        todayLogs.filter { $0.type == .feeding }.count
    }

    private var sleepHours: Double {
        let totalSeconds = todayLogs
            .filter { $0.type == .sleep }
            .compactMap { $0.sleepDuration }
            .reduce(0, +)
        return totalSeconds / 3600
    }

    private var diaperCount: Int {
        todayLogs.filter { $0.type == .diaper }.count
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Header
                VStack(alignment: .leading, spacing: 4) {
                    Text(Date.now, format: .dateTime.day().month(.wide).year().weekday(.wide))
                        .font(.kinnaBody(9))
                        .foregroundStyle(.kMuted)
                        .tracking(1.5)
                        .textCase(.uppercase)

                    Text("Bugün")
                        .font(.kinnaDisplayItalic(26))
                        .foregroundStyle(.kChar)

                    if let baby {
                        Text("\(baby.name)'nin \(baby.ageInDays). gunu")
                            .font(.kinnaBody(10))
                            .foregroundStyle(.kMuted)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 12)
                .padding(.bottom, 20)

                // 2x2 Grid
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 10),
                    GridItem(.flexible(), spacing: 10),
                ], spacing: 10) {
                    trackingTile(
                        emoji: "🍼", label: "EMZİRME",
                        value: "\(feedingCount)", unit: "kez",
                        barColor: .kSage, barProgress: min(CGFloat(feedingCount) / 8.0, 1.0)
                    )
                    trackingTile(
                        emoji: "😴", label: "UYKU",
                        value: String(format: "%.1f", sleepHours), unit: "saat",
                        barColor: Color(hex: 0x8BA7C7), barProgress: min(sleepHours / 14.0, 1.0)
                    )
                    trackingTile(
                        emoji: "🧷", label: "BEZ",
                        value: "\(diaperCount)", unit: "kez",
                        barColor: .kTerraLight, barProgress: min(CGFloat(diaperCount) / 8.0, 1.0)
                    )
                    trackingTile(
                        emoji: "⚖️", label: "SON TARTI",
                        value: "—", unit: "kg",
                        barColor: .kBlush, barProgress: 0.6
                    )
                }
                .padding(.bottom, 16)

                // Quick-add buttons
                HStack(spacing: 6) {
                    quickAddButton("+ Beslenme", type: .feeding)
                    quickAddButton("+ Uyku", type: .sleep)
                    quickAddButton("+ Bez", type: .diaper)
                }
                .padding(.bottom, 16)

                // Timeline
                if !todayLogs.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("ZAMAN ÇİZELGESİ")
                            .font(.kinnaBodyMedium(11))
                            .foregroundStyle(.kLight)
                            .tracking(1.5)
                            .padding(.bottom, 4)

                        ForEach(todayLogs) { log in
                            timelineRow(log)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 20)
        }
        .background(Color.kCream.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showAddSheet) {
            AddLogSheet(initialType: preselectedType)
                .presentationDetents([.medium])
        }
    }

    // MARK: - Quick Add Button

    private func quickAddButton(_ title: String, type: DailyLog.LogType) -> some View {
        Button {
            preselectedType = type
            showAddSheet = true
        } label: {
            Text(title)
                .font(.kinnaBodyMedium(11))
                .foregroundStyle(.kMid)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.kPale, lineWidth: 1)
                )
        }
    }

    // MARK: - Tracking Tile

    private func trackingTile(
        emoji: String, label: String,
        value: String, unit: String,
        barColor: Color, barProgress: CGFloat
    ) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(emoji)
                .font(.system(size: 22))
                .padding(.bottom, 8)

            Text(label)
                .font(.kinnaBodyMedium(10))
                .foregroundStyle(.kLight)
                .tracking(1)
                .padding(.bottom, 4)

            HStack(alignment: .firstTextBaseline, spacing: 3) {
                Text(value)
                    .font(.kinnaDisplay(22))
                    .foregroundStyle(.kChar)
                Text(unit)
                    .font(.kinnaBody(11))
                    .foregroundStyle(.kMid)
            }
            .padding(.bottom, 8)

            // Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 1.5)
                        .fill(Color.kPale)
                        .frame(height: 3)
                    RoundedRectangle(cornerRadius: 1.5)
                        .fill(barColor)
                        .frame(width: geo.size.width * barProgress, height: 3)
                }
            }
            .frame(height: 3)
        }
        .padding(16)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.kPale, lineWidth: 1)
        )
    }

    // MARK: - Timeline Row

    private func timelineRow(_ log: DailyLog) -> some View {
        HStack(spacing: 12) {
            // Time
            Text(log.date, format: .dateTime.hour().minute())
                .font(.kinnaBody(10))
                .foregroundStyle(.kLight)
                .frame(width: 36, alignment: .leading)

            // Dot
            Circle()
                .fill(dotColor(for: log.type))
                .frame(width: 8, height: 8)

            // Description
            Text(logDescription(log))
                .font(.kinnaBody(12))
                .foregroundStyle(.kMid)
        }
    }

    private func dotColor(for type: DailyLog.LogType) -> Color {
        switch type {
        case .feeding: .kSage
        case .sleep: Color(hex: 0x8BA7C7)
        case .diaper: .kTerraLight
        }
    }

    private func logDescription(_ log: DailyLog) -> String {
        switch log.type {
        case .feeding:
            if let ft = log.feedingType {
                switch ft {
                case .breast: return "Anne sütü"
                case .bottle: return "Biberon"
                case .solid: return "Ek gıda"
                }
            }
            return "Beslenme"
        case .sleep:
            if let dur = log.sleepDuration {
                let mins = Int(dur / 60)
                return "\(mins) dk uyku"
            }
            return "Uyku"
        case .diaper:
            return "Bez değişimi"
        }
    }
}

// MARK: - Add Log Sheet

struct AddLogSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    var initialType: DailyLog.LogType = .feeding
    @State private var selectedType: DailyLog.LogType = .feeding
    @State private var feedingType: DailyLog.FeedingType = .breast
    @State private var sleepMinutes: Double = 30
    @State private var diaperType: DailyLog.DiaperType = .wet
    @State private var note = ""
    @State private var logDate = Date()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Type selector
                    HStack(spacing: 8) {
                        typeButton("Beslenme", type: .feeding, emoji: "🍼")
                        typeButton("Uyku", type: .sleep, emoji: "😴")
                        typeButton("Bez", type: .diaper, emoji: "🧷")
                    }
                    .padding(.top, 8)

                    // Type-specific fields
                    VStack(alignment: .leading, spacing: 12) {
                        switch selectedType {
                        case .feeding:
                            fieldLabel("TUR")
                            HStack(spacing: 8) {
                                feedingButton("Anne sutu", type: .breast)
                                feedingButton("Biberon", type: .bottle)
                                feedingButton("Ek gida", type: .solid)
                            }

                        case .sleep:
                            fieldLabel("SURE")
                            HStack(alignment: .firstTextBaseline, spacing: 4) {
                                Text("\(Int(sleepMinutes))")
                                    .font(.kinnaDisplay(32))
                                    .foregroundStyle(.kChar)
                                Text("dk")
                                    .font(.kinnaBody(14))
                                    .foregroundStyle(.kMid)
                            }
                            Slider(value: $sleepMinutes, in: 5...240, step: 5)
                                .tint(.kSage)

                        case .diaper:
                            fieldLabel("TUR")
                            HStack(spacing: 8) {
                                diaperButton("Islak", type: .wet)
                                diaperButton("Kirli", type: .dirty)
                                diaperButton("Ikisi de", type: .both)
                            }
                        }
                    }

                    // Time
                    VStack(alignment: .leading, spacing: 6) {
                        fieldLabel("SAAT")
                        DatePicker("", selection: $logDate, displayedComponents: .hourAndMinute)
                            .labelsHidden()
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    // Note
                    VStack(alignment: .leading, spacing: 6) {
                        fieldLabel("NOT (istege bagli)")
                        TextField("Ek bilgi...", text: $note)
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
                .padding(.horizontal, 24)
                .padding(.bottom, 20)
            }
            .background(Color.kCream.ignoresSafeArea())
            .onAppear { selectedType = initialType }
            .navigationTitle("Kayit Ekle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Vazgec") { dismiss() }
                        .foregroundStyle(.kMid)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Kaydet") { saveLog() }
                        .fontWeight(.semibold)
                        .foregroundStyle(.kTerra)
                }
            }
        }
    }

    // MARK: - Save

    private func saveLog() {
        let log = DailyLog(date: logDate, type: selectedType, note: note)

        switch selectedType {
        case .feeding:
            log.feedingType = feedingType
        case .sleep:
            log.sleepDuration = sleepMinutes * 60
        case .diaper:
            log.diaperType = diaperType
        }

        modelContext.insert(log)
        dismiss()
    }

    // MARK: - Components

    private func fieldLabel(_ text: String) -> some View {
        Text(text)
            .font(.kinnaBodyMedium(10))
            .foregroundStyle(.kLight)
            .tracking(1)
    }

    private func typeButton(_ title: String, type: DailyLog.LogType, emoji: String) -> some View {
        let isSelected = selectedType == type
        return Button {
            withAnimation(.easeInOut(duration: 0.15)) { selectedType = type }
        } label: {
            VStack(spacing: 6) {
                Text(emoji)
                    .font(.system(size: 22))
                Text(title)
                    .font(.kinnaBody(12))
                    .fontWeight(isSelected ? .medium : .regular)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(isSelected ? Color.kTerraLight.opacity(0.5) : .white)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isSelected ? Color.kTerra : Color.kPale, lineWidth: 1.5)
            )
        }
        .foregroundStyle(isSelected ? .kTerra : .kMid)
    }

    private func feedingButton(_ title: String, type: DailyLog.FeedingType) -> some View {
        let isSelected = feedingType == type
        return Button {
            feedingType = type
        } label: {
            Text(title)
                .font(.kinnaBody(12))
                .fontWeight(isSelected ? .medium : .regular)
                .frame(maxWidth: .infinity)
                .padding(10)
                .background(isSelected ? Color.kSage.opacity(0.15) : .white)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(isSelected ? Color.kSage : Color.kPale, lineWidth: 1.5)
                )
        }
        .foregroundStyle(isSelected ? .kSageDark : .kMid)
    }

    private func diaperButton(_ title: String, type: DailyLog.DiaperType) -> some View {
        let isSelected = diaperType == type
        return Button {
            diaperType = type
        } label: {
            Text(title)
                .font(.kinnaBody(12))
                .fontWeight(isSelected ? .medium : .regular)
                .frame(maxWidth: .infinity)
                .padding(10)
                .background(isSelected ? Color.kTerraLight.opacity(0.5) : .white)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(isSelected ? Color.kTerra : Color.kPale, lineWidth: 1.5)
                )
        }
        .foregroundStyle(isSelected ? .kTerra : .kMid)
    }
}

#Preview {
    NavigationStack {
        TrackingView()
    }
    .modelContainer(for: [DailyLog.self, Baby.self], inMemory: true)
}
