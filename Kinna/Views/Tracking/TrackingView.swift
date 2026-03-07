import SwiftUI
import SwiftData

struct TrackingView: View {
    @Query(sort: \DailyLog.createdAt, order: .reverse) private var logs: [DailyLog]
    @Query private var babies: [Baby]

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
                    Text("Bugün")
                        .font(.kinnaDisplay(26))
                        .foregroundStyle(.kChar)

                    Text(Date.now, format: .dateTime.day().month(.wide).year().weekday(.wide))
                        .font(.kinnaBody(12))
                        .foregroundStyle(.kLight)
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

                // Add log button
                Button {
                    // TODO: Add log sheet
                } label: {
                    Text("+ Kayıt ekle")
                        .font(.kinnaBodyMedium(14))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(15)
                        .background(Color.kTerra)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
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

#Preview {
    NavigationStack {
        TrackingView()
    }
    .modelContainer(for: [DailyLog.self, Baby.self], inMemory: true)
}
