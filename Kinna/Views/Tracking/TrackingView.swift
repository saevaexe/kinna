import SwiftUI
import SwiftData

struct TrackingView: View {
    @AppStorage("showGrowthChartsInTracking") private var showGrowthChartsInTracking = true
    @AppStorage("useMetricUnits") private var useMetricUnits = true
    @Environment(SubscriptionManager.self) private var subscriptionManager
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \DailyLog.createdAt, order: .reverse) private var logs: [DailyLog]
    @Query(sort: \GrowthRecord.measuredAt, order: .reverse) private var growthRecords: [GrowthRecord]
    @Query(sort: \Baby.createdAt) private var babies: [Baby]
    @State private var showAddSheet = false
    @State private var showAddGrowthSheet = false
    @State private var showGrowthCharts = false
    @State private var showPaywall = false
    @State private var preselectedType: DailyLog.LogType = .feeding
    @State private var showTimerSheet = false
    @State private var timerSheetMode: TimerSheet.Mode = .feeding

    private var isEN: Bool { Locale.current.language.languageCode?.identifier != "tr" }

    private var baby: Baby? { babies.first }
    private var canAccessGrowthCharts: Bool {
        MonetizationPolicy.canAccessGrowthCharts(hasFullAccess: subscriptionManager.hasFullAccess)
    }

    private var babyLogs: [DailyLog] {
        guard let baby else { return logs }
        return logs.filter { $0.babyID == nil || $0.babyID == baby.id }
    }

    private var todayLogs: [DailyLog] {
        babyLogs.filter { Calendar.current.isDateInToday($0.date) }
    }

    private var babyGrowthRecords: [GrowthRecord] {
        guard let baby else { return growthRecords }
        return growthRecords.filter { $0.babyID == nil || $0.babyID == baby.id }
    }

    private var todayGrowthRecords: [GrowthRecord] {
        babyGrowthRecords.filter { Calendar.current.isDateInToday($0.measuredAt) }
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

    private var sleepSummary: SleepInsightSummary? {
        SleepInsightEngine.summary(logs: babyLogs)
    }

    private var breastfeedingTimerSummary: BreastfeedingTimerSummary? {
        BreastfeedingTimerEngine.summary(logs: babyLogs)
    }

    private var activeTimers: [DailyLog] {
        ActiveTimerEngine.activeTimers(in: babyLogs)
    }

    private var diaperCount: Int {
        todayLogs.filter { $0.type == .diaper }.count
    }

    private var noteCount: Int {
        todayLogs.filter { $0.type == .note }.count
    }

    private var latestGrowthRecord: GrowthRecord? {
        babyGrowthRecords.first
    }

    private var recentNoteLogs: [DailyLog] {
        babyLogs
            .filter { $0.type == .note && !$0.note.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
            .filter { subscriptionManager.hasFullAccess || $0.date >= MonetizationPolicy.freeHistoryCutoffDate() }
            .prefix(3)
            .map { $0 }
    }

    private var todayTimelineItems: [TrackingTimelineItem] {
        let items = todayLogs.map(TrackingTimelineItem.log) + todayGrowthRecords.map(TrackingTimelineItem.growth)
        return items.sorted { $0.date > $1.date }
    }

    private var historyTimelineItems: [TrackingTimelineItem] {
        let cutoffDate = MonetizationPolicy.freeHistoryCutoffDate()
        let logItems = babyLogs
            .filter { !Calendar.current.isDateInToday($0.date) && $0.type != .note }
            .filter { subscriptionManager.hasFullAccess || $0.date >= cutoffDate }
            .map(TrackingTimelineItem.log)
        let growthItems = babyGrowthRecords
            .filter { !Calendar.current.isDateInToday($0.measuredAt) }
            .filter { subscriptionManager.hasFullAccess || $0.measuredAt >= cutoffDate }
            .map(TrackingTimelineItem.growth)

        return (logItems + growthItems).sorted { $0.date > $1.date }
    }

    private var hasLockedHistory: Bool {
        guard !subscriptionManager.hasFullAccess else { return false }

        let cutoffDate = MonetizationPolicy.freeHistoryCutoffDate()

        return babyLogs.contains {
            !Calendar.current.isDateInToday($0.date) && $0.date < cutoffDate
        } || babyGrowthRecords.contains {
            !Calendar.current.isDateInToday($0.measuredAt) && $0.measuredAt < cutoffDate
        }
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

                    Text(isEN ? "Today" : "Bugün")
                        .font(.kinnaDisplayItalic(26))
                        .foregroundStyle(.kChar)

                    if let baby {
                        Text(isEN ? "\(baby.name)'s day \(baby.ageInDays)" : "\(baby.name)'nın \(baby.ageInDays). günü")
                            .font(.kinnaBody(10))
                            .foregroundStyle(.kMuted)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 12)
                .padding(.bottom, 20)

                // Active timer banner
                ActiveTimerBanner(
                    activeTimers: activeTimers,
                    onStop: { timer in
                        ActiveTimerEngine.stopTimer(timer)
                    },
                    onCancel: { timer in
                        ActiveTimerEngine.cancelTimer(timer, context: modelContext)
                    }
                )

                // 2x2 Grid
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 10),
                    GridItem(.flexible(), spacing: 10),
                ], spacing: 10) {
                    TimelineView(.periodic(from: .now, by: 60)) { context in
                        feedingTile(referenceDate: context.date)
                    }
                    trackingTile(
                        emoji: "😴", label: isEN ? "SLEEP" : "UYKU",
                        value: String(format: "%.1f", sleepHours), unit: isEN ? "hours" : "saat",
                        barColor: Color(hex: 0x8BA7C7), barProgress: min(sleepHours / 14.0, 1.0)
                    )
                    .onTapGesture {
                        timerSheetMode = .sleep
                        showTimerSheet = true
                    }
                    trackingTile(
                        emoji: "🧷", label: isEN ? "DIAPER" : "BEZ",
                        value: "\(diaperCount)", unit: isEN ? "times" : "kez",
                        barColor: .kTerraLight, barProgress: min(CGFloat(diaperCount) / 8.0, 1.0)
                    )
                    trackingTile(
                        emoji: "⚖️", label: isEN ? "LAST WEIGHT" : "SON TARTI",
                        value: displayMeasurement(latestGrowthRecord?.weightKilograms, metric: .weight),
                        unit: GrowthMetric.weight.unit(metric: useMetricUnits),
                        barColor: .kBlush,
                        barProgress: latestGrowthRecord?.weightKilograms == nil ? 0 : 1
                    )
                    trackingTile(
                        emoji: "📏", label: isEN ? "LAST HEIGHT" : "SON BOY",
                        value: displayMeasurement(latestGrowthRecord?.heightCentimeters, metric: .height),
                        unit: GrowthMetric.height.unit(metric: useMetricUnits),
                        barColor: .kTerra,
                        barProgress: latestGrowthRecord?.heightCentimeters == nil ? 0 : 1
                    )
                    trackingTile(
                        emoji: "💭", label: isEN ? "NOTES" : "NOTLAR",
                        value: "\(noteCount)", unit: isEN ? "today" : "bugün",
                        barColor: .kSageDark,
                        barProgress: min(CGFloat(noteCount) / 3.0, 1.0)
                    )
                }
                .padding(.bottom, 16)

                // Quick-add buttons
                VStack(spacing: 6) {
                    HStack(spacing: 6) {
                        quickActionButton(title: isEN ? "+ Feeding" : "+ Beslenme") {
                            timerSheetMode = .feeding
                            showTimerSheet = true
                        }
                        quickActionButton(title: isEN ? "+ Sleep" : "+ Uyku") {
                            timerSheetMode = .sleep
                            showTimerSheet = true
                        }
                        quickAddButton(isEN ? "+ Diaper" : "+ Bez", type: .diaper)
                    }

                    HStack(spacing: 6) {
                        quickAddButton(isEN ? "+ Note" : "+ Not", type: .note)

                        quickActionButton(
                            title: isEN ? "+ Growth" : "+ Tartı / Boy",
                            systemImage: "ruler"
                        ) {
                            showAddGrowthSheet = true
                        }
                    }
                }
                .padding(.bottom, 16)

                if baby != nil && showGrowthChartsInTracking {
                    growthChartsCard
                        .padding(.bottom, 16)
                }

                if let sleepSummary {
                    sleepSummaryCard(summary: sleepSummary)
                        .padding(.bottom, 16)
                }

                // Timeline
                if !todayTimelineItems.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(isEN ? "TIMELINE" : "ZAMAN ÇİZELGESİ")
                            .font(.kinnaBodyMedium(11))
                            .foregroundStyle(.kLight)
                            .tracking(1.5)
                            .padding(.bottom, 4)

                        ForEach(todayTimelineItems) { item in
                            timelineRow(item)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

                if !recentNoteLogs.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(isEN ? "RECENT NOTES" : "SON NOTLAR")
                            .font(.kinnaBodyMedium(11))
                            .foregroundStyle(.kLight)
                            .tracking(1.5)
                            .padding(.top, todayTimelineItems.isEmpty ? 0 : 20)
                            .padding(.bottom, 4)

                        ForEach(recentNoteLogs) { noteLog in
                            VStack(alignment: .leading, spacing: 8) {
                                Text(noteLog.date, format: .dateTime.day().month(.wide).hour().minute())
                                    .font(.kinnaBody(10))
                                    .foregroundStyle(.kLight)
                                    .textCase(.uppercase)

                                Text(noteLog.note)
                                    .font(.kinnaBody(12))
                                    .foregroundStyle(.kMid)
                                    .lineSpacing(3)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(14)
                            .background(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.kPale, lineWidth: 1)
                            )
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, todayTimelineItems.isEmpty ? 0 : 4)
                }

                if !historyTimelineItems.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(subscriptionManager.hasFullAccess
                             ? (isEN ? "HISTORY" : "GEÇMİŞ")
                             : (isEN ? "LAST 7 DAYS" : "SON 7 GÜN"))
                            .font(.kinnaBodyMedium(11))
                            .foregroundStyle(.kLight)
                            .tracking(1.5)
                            .padding(.top, (todayTimelineItems.isEmpty && recentNoteLogs.isEmpty) ? 0 : 20)
                            .padding(.bottom, 4)

                        ForEach(historyTimelineItems) { item in
                            timelineRow(item)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

                if hasLockedHistory {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(spacing: 8) {
                            Image(systemName: "clock.arrow.circlepath")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(.kTerra)
                            Text(isEN
                                 ? "Free includes the last \(MonetizationPolicy.freeTrackingHistoryDays) days of tracking history."
                                 : "Ücretsiz plan son \(MonetizationPolicy.freeTrackingHistoryDays) günlük takip geçmişini gösterir.")
                                .font(.kinnaBody(10))
                                .foregroundStyle(.kMid)
                                .lineSpacing(2)
                        }

                        Button(isEN ? "Unlock full history" : "Tüm geçmişi aç") {
                            showPaywall = true
                        }
                        .font(.kinnaBodyMedium(11))
                        .foregroundStyle(.kTerra)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(14)
                    .background(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.kPale, lineWidth: 1)
                    )
                    .padding(.top, historyTimelineItems.isEmpty ? 12 : 16)
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
                .presentationBackground(Color.kCream)
        }
        .sheet(isPresented: $showAddGrowthSheet) {
            AddGrowthSheet()
                .presentationDetents([.medium, .large])
                .presentationBackground(Color.kCream)
        }
        .sheet(isPresented: $showGrowthCharts) {
            NavigationStack {
                if let baby {
                    GrowthChartsView(baby: baby, records: babyGrowthRecords)
                }
            }
            .presentationBackground(Color.kCream)
        }
        .sheet(isPresented: $showPaywall) {
            NavigationStack {
                PaywallView()
            }
            .environment(subscriptionManager)
            .presentationBackground(Color.kCream)
        }
        .sheet(isPresented: $showTimerSheet) {
            TimerSheet(mode: timerSheetMode)
                .presentationDetents([.medium])
                .presentationBackground(Color.kCream)
        }
    }

    // MARK: - Quick Add Button

    private func quickAddButton(_ title: String, type: DailyLog.LogType) -> some View {
        quickActionButton(title: title) {
            preselectedType = type
            showAddSheet = true
        }
    }

    private func quickActionButton(
        title: String,
        systemImage: String? = nil,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if let systemImage {
                    Image(systemName: systemImage)
                        .font(.system(size: 13, weight: .medium))
                }

                Text(title)
                    .font(.kinnaBodyMedium(11))
            }
            .foregroundStyle(.kMid)
            .frame(maxWidth: .infinity, minHeight: 42)
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.kPale, lineWidth: 1)
            )
        }
    }

    private var growthChartsCard: some View {
        ZStack(alignment: .topTrailing) {
            HStack(alignment: .top, spacing: 14) {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.kTerraPale)
                    .frame(width: 52, height: 52)
                    .overlay {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundStyle(.kTerra)
                    }

                VStack(alignment: .leading, spacing: 6) {
                    Text(isEN ? "Growth charts" : "Büyüme eğrisi")
                        .font(.kinnaBodyMedium(13))
                        .foregroundStyle(.kChar)

                    Text(canAccessGrowthCharts
                         ? (isEN
                            ? "See weight and height against WHO reference curves."
                            : "Tartı ve boy ölçümlerini WHO referans eğrilerinde gör.")
                         : (isEN
                            ? "Unlock WHO growth charts with Premium."
                            : "WHO büyüme eğrilerini Premium ile aç."))
                        .font(.kinnaBody(11))
                        .foregroundStyle(.kMid)
                        .lineSpacing(3)

                    if let latestGrowthRecord {
                        Text(growthChartMetaText(for: latestGrowthRecord))
                            .font(.kinnaBodyMedium(10))
                            .foregroundStyle(.kSageDark)
                    }
                }

                Spacer(minLength: 10)

                Image(systemName: canAccessGrowthCharts ? "chevron.right" : "lock.fill")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(canAccessGrowthCharts ? .kLight : .kTerra)
                    .padding(.top, 6)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.kPale, lineWidth: 1)
            )
            .contentShape(Rectangle())
            .onTapGesture {
                if canAccessGrowthCharts {
                    showGrowthCharts = true
                } else {
                    showPaywall = true
                }
            }

            Button {
                showGrowthChartsInTracking = false
            } label: {
                Text(isEN ? "Hide" : "Gizle")
                    .font(.kinnaBodyMedium(10))
                    .foregroundStyle(.kLight)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.kWarm)
                    .clipShape(Capsule())
                    .overlay(
                        Capsule()
                            .stroke(Color.kPale, lineWidth: 1)
                    )
            }
            .buttonStyle(.plain)
            .padding(12)
        }
    }

    private func feedingTile(referenceDate: Date) -> some View {
        let summary = BreastfeedingTimerEngine.summary(logs: babyLogs, referenceDate: referenceDate)

        return VStack(alignment: .leading, spacing: 0) {
            Text("🍼")
                .font(.system(size: 22))
                .padding(.bottom, 8)

            Text(isEN ? "FEEDING" : "EMZİRME")
                .font(.kinnaBodyMedium(10))
                .foregroundStyle(.kLight)
                .tracking(1)
                .padding(.bottom, 4)

            HStack(alignment: .firstTextBaseline, spacing: 3) {
                Text("\(feedingCount)")
                    .font(.kinnaDisplay(22))
                    .foregroundStyle(.kChar)
                Text(isEN ? "times" : "kez")
                    .font(.kinnaBody(11))
                    .foregroundStyle(.kMid)
            }
            .padding(.bottom, 6)

            Text(feedingSubtitleText(for: summary))
                .font(.kinnaBodyMedium(10))
                .foregroundStyle(summary == nil ? .kLight : .kSageDark)
                .lineLimit(2)
                .padding(.bottom, 8)

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 1.5)
                        .fill(Color.kPale)
                        .frame(height: 3)
                    RoundedRectangle(cornerRadius: 1.5)
                        .fill(Color.kSage)
                        .frame(width: geo.size.width * min(CGFloat(feedingCount) / 8.0, 1.0), height: 3)
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
        .contentShape(Rectangle())
        .onTapGesture {
            timerSheetMode = .feeding
            showTimerSheet = true
        }
    }

    private func sleepSummaryCard(summary: SleepInsightSummary) -> some View {
        HStack(alignment: .top, spacing: 14) {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(hex: 0xE6EDF7))
                .frame(width: 52, height: 52)
                .overlay {
                    Text("😴")
                        .font(.system(size: 21))
                }

            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .firstTextBaseline) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(isEN ? "Sleep summary" : "Uyku özeti")
                            .font(.kinnaBodyMedium(13))
                            .foregroundStyle(.kChar)

                        HStack(alignment: .firstTextBaseline, spacing: 4) {
                            Text(summary.averageTrackedHours.formatted(.number.precision(.fractionLength(1))))
                                .font(.kinnaDisplay(24))
                                .foregroundStyle(.kChar)
                            Text(isEN ? "hours" : "saat")
                                .font(.kinnaBody(11))
                                .foregroundStyle(.kMid)
                        }
                    }

                    Spacer()

                    Text(sleepSummaryBadgeText(summary))
                        .font(.kinnaBodyMedium(10))
                        .foregroundStyle(.kLight)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 5)
                        .background(Color.kWarm)
                        .clipShape(Capsule())
                }

                Text(sleepSummaryDetailText(summary))
                    .font(.kinnaBody(11))
                    .foregroundStyle(.kMid)
                    .lineSpacing(3)

                sleepBars(summary.dailyHours)

                HStack(spacing: 8) {
                    Image(systemName: sleepTrendIcon(summary.trend))
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(Color(hex: 0x6F8FB3))

                    Text(sleepTrendText(summary.trend))
                        .font(.kinnaBodyMedium(10))
                        .foregroundStyle(Color(hex: 0x6F8FB3))
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.kPale, lineWidth: 1)
        )
    }

    private func sleepBars(_ dailyHours: [SleepDailyHours]) -> some View {
        let maxHours = max(dailyHours.map(\.hours).max() ?? 0, 1)

        return HStack(alignment: .bottom, spacing: 6) {
            ForEach(dailyHours) { item in
                VStack(spacing: 6) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(item.hours > 0 ? Color(hex: 0x8BA7C7) : Color.kPale)
                        .frame(height: max(8, CGFloat(item.hours / maxHours) * 34))

                    Text(shortDayLabel(for: item.date))
                        .font(.kinnaBody(9))
                        .foregroundStyle(.kLight)
                }
                .frame(maxWidth: .infinity, alignment: .bottom)
            }
        }
        .frame(height: 54, alignment: .bottom)
    }

    private func sleepSummaryDetailText(_ summary: SleepInsightSummary) -> String {
        if isEN {
            if summary.trackedDaysCount == 1 {
                return "Only 1 sleep entry in the last week. Add a few more to unlock a clearer weekly average."
            }

            return "Average across \(summary.trackedDaysCount) tracked days in the last week."
        }

        if summary.trackedDaysCount == 1 {
            return "Son hafta içinde yalnızca 1 uyku kaydı var. Birkaç gün daha ekledikçe haftalık ortalama netleşir."
        }

        return "Son 7 günde takip ettiğin \(summary.trackedDaysCount) günün ortalaması."
    }

    private func sleepTrendText(_ trend: SleepTrend) -> String {
        if isEN {
            switch trend {
            case .increasing:
                return "Sleep time looks slightly higher than the previous days."
            case .decreasing:
                return "Sleep time looks slightly lower than the previous days."
            case .stable:
                return "Sleep rhythm looks fairly stable across tracked days."
            case .insufficientData:
                return "Add a few more sleep entries to reveal a clearer pattern."
            }
        }

        switch trend {
        case .increasing:
            return "Son günlerde uyku süresi biraz daha yukarıda görünüyor."
        case .decreasing:
            return "Son günlerde uyku süresi biraz daha kısa görünüyor."
        case .stable:
            return "Takip edilen günlerde uyku ritmi oldukça benzer ilerliyor."
        case .insufficientData:
            return "Daha net bir örüntü için birkaç gün daha uyku kaydet."
        }
    }

    private func sleepSummaryBadgeText(_ summary: SleepInsightSummary) -> String {
        if isEN {
            return "\(summary.trackedDaysCount) day\(summary.trackedDaysCount == 1 ? "" : "s")"
        }

        return "\(summary.trackedDaysCount) gün"
    }

    private func sleepTrendIcon(_ trend: SleepTrend) -> String {
        switch trend {
        case .increasing:
            return "arrow.up.forward"
        case .decreasing:
            return "arrow.down.forward"
        case .stable:
            return "equal"
        case .insufficientData:
            return "sparkles"
        }
    }

    private func shortDayLabel(for date: Date) -> String {
        let weekday = Calendar.current.component(.weekday, from: date)

        if isEN {
            let labels = ["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"]
            return labels[max(0, min(labels.count - 1, weekday - 1))]
        }

        let labels = ["Pz", "Pt", "Sa", "Ça", "Pe", "Cu", "Ct"]
        return labels[max(0, min(labels.count - 1, weekday - 1))]
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

    private func timelineRow(_ item: TrackingTimelineItem) -> some View {
        HStack(spacing: 12) {
            // Time
            Text(item.date, format: .dateTime.hour().minute())
                .font(.kinnaBody(10))
                .foregroundStyle(.kLight)
                .frame(width: 56, alignment: .leading)

            // Dot
            Circle()
                .fill(dotColor(for: item))
                .frame(width: 8, height: 8)

            // Description
            Text(timelineDescription(for: item))
                .font(.kinnaBody(12))
                .foregroundStyle(.kMid)
        }
    }

    private func dotColor(for item: TrackingTimelineItem) -> Color {
        switch item {
        case .log(let log):
            switch log.type {
            case .feeding: .kSage
            case .sleep: Color(hex: 0x8BA7C7)
            case .diaper: .kTerraLight
            case .note: .kSageDark
            }
        case .growth:
            .kBlush
        }
    }

    private func timelineDescription(for item: TrackingTimelineItem) -> String {
        switch item {
        case .log(let log):
            switch log.type {
            case .feeding:
                if let ft = log.feedingType {
                    switch ft {
                    case .breast:
                        var text = isEN ? "Breast milk" : "Anne sütü"
                        if let side = log.breastSide {
                            let sideText = side == .left ? (isEN ? "left" : "sol") : (isEN ? "right" : "sağ")
                            text += " (\(sideText))"
                        }
                        if let duration = log.timerDuration {
                            text += " · \(ActiveTimerEngine.formattedElapsed(duration))"
                        }
                        return text
                    case .bottle:
                        var text = isEN ? "Bottle" : "Biberon"
                        if let ml = log.feedingAmountML {
                            text += " · \(Int(ml)) ml"
                        }
                        return text
                    case .solid: return isEN ? "Solid food" : "Ek gıda"
                    }
                }
                return isEN ? "Feeding" : "Beslenme"
            case .sleep:
                if let dur = log.sleepDuration {
                    let mins = Int(dur / 60)
                    let isTimer = log.timerStartDate != nil
                    let suffix = isTimer ? (isEN ? " (timer)" : " (zamanlayıcı)") : ""
                    return isEN ? "\(mins) min sleep\(suffix)" : "\(mins) dk uyku\(suffix)"
                }
                if log.isTimerRunning {
                    return isEN ? "Sleep (in progress...)" : "Uyku (devam ediyor...)"
                }
                return isEN ? "Sleep" : "Uyku"
            case .diaper:
                if let dt = log.diaperType {
                    switch dt {
                    case .wet: return isEN ? "Diaper — wet" : "Bez — ıslak"
                    case .dirty: return isEN ? "Diaper — dirty" : "Bez — kirli"
                    case .both: return isEN ? "Diaper — both" : "Bez — ikisi de"
                    }
                }
                return isEN ? "Diaper change" : "Bez değişimi"
            case .note:
                let trimmed = log.note.trimmingCharacters(in: .whitespacesAndNewlines)
                return trimmed.isEmpty ? (isEN ? "Daily note" : "Günlük not") : trimmed
            }
        case .growth(let record):
            var parts: [String] = []
            if let weight = record.weightKilograms {
                let v = GrowthMetric.weight.displayValue(weight, metric: useMetricUnits)
                parts.append("\(measurementText(v)) \(GrowthMetric.weight.unit(metric: useMetricUnits))")
            }
            if let height = record.heightCentimeters {
                let v = GrowthMetric.height.displayValue(height, metric: useMetricUnits)
                parts.append("\(measurementText(v)) \(GrowthMetric.height.unit(metric: useMetricUnits))")
            }

            let summary = parts.joined(separator: " • ")
            guard !record.note.isEmpty else {
                return isEN ? "Growth check: \(summary)" : "Büyüme ölçümü: \(summary)"
            }

            if summary.isEmpty {
                return record.note
            }

            return "\(summary) — \(record.note)"
        }
    }

    private func measurementText(_ value: Double?) -> String {
        guard let value else { return "—" }
        return value.formatted(.number.precision(.fractionLength(1)))
    }

    private func displayMeasurement(_ metricValue: Double?, metric: GrowthMetric) -> String {
        guard let metricValue else { return "—" }
        let converted = metric.displayValue(metricValue, metric: useMetricUnits)
        return converted.formatted(.number.precision(.fractionLength(1)))
    }

    private func growthChartMetaText(for record: GrowthRecord) -> String {
        var parts: [String] = []

        if let weight = record.weightKilograms {
            let v = GrowthMetric.weight.displayValue(weight, metric: useMetricUnits)
            parts.append("\(measurementText(v)) \(GrowthMetric.weight.unit(metric: useMetricUnits))")
        }

        if let height = record.heightCentimeters {
            let v = GrowthMetric.height.displayValue(height, metric: useMetricUnits)
            parts.append("\(measurementText(v)) \(GrowthMetric.height.unit(metric: useMetricUnits))")
        }

        let values = parts.joined(separator: " • ")

        if isEN {
            return values.isEmpty ? "WHO reference view" : "Latest: \(values)"
        } else {
            return values.isEmpty ? "WHO referans görünümü" : "Son ölçüm: \(values)"
        }
    }

    private func elapsedIntervalText(_ interval: TimeInterval) -> String {
        let totalMinutes = max(0, Int(interval / 60))
        let days = totalMinutes / (24 * 60)
        let hours = (totalMinutes % (24 * 60)) / 60
        let minutes = totalMinutes % 60

        if isEN {
            if days > 0 {
                return "\(days)d \(hours)h"
            }

            if hours > 0 {
                return "\(hours)h \(minutes)m"
            }

            return "\(minutes)m"
        }

        if days > 0 {
            return "\(days) gün \(hours) sa"
        }

        if hours > 0 {
            return "\(hours) sa \(minutes) dk"
        }

        return "\(minutes) dk"
    }

    private func feedingSubtitleText(for summary: BreastfeedingTimerSummary?) -> String {
        guard let summary else {
            return isEN ? "Tap to save the first breast milk log." : "İlk anne sütü kaydını ekle"
        }

        if isEN {
            return "Last feed \(elapsedIntervalText(summary.elapsedSinceLatest)) ago"
        }

        return "Son emzirme \(elapsedIntervalText(summary.elapsedSinceLatest)) önce"
    }

    private enum TrackingTimelineItem: Identifiable {
        case log(DailyLog)
        case growth(GrowthRecord)

        var id: String {
            switch self {
            case .log(let log):
                "log-\(log.id.uuidString)"
            case .growth(let record):
                "growth-\(record.id.uuidString)"
            }
        }

        var date: Date {
            switch self {
            case .log(let log):
                log.date
            case .growth(let record):
                record.measuredAt
            }
        }
    }
}

// MARK: - Add Log Sheet

struct AddLogSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Baby.createdAt) private var babies: [Baby]

    private var isEN: Bool { Locale.current.language.languageCode?.identifier != "tr" }

    var initialType: DailyLog.LogType = .feeding
    @State private var selectedType: DailyLog.LogType = .feeding
    @State private var feedingType: DailyLog.FeedingType = .breast
    @State private var breastSide: DailyLog.BreastSide = .left
    @State private var bottleAmountText = ""
    @State private var sleepMinutes: Double = 30
    @State private var diaperType: DailyLog.DiaperType = .wet
    @State private var note = ""
    @State private var logDate = Date()
    private var placeholderColor: Color { .kMid.opacity(0.8) }

    private var canSave: Bool {
        if selectedType == .note {
            return !note.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
        return true
    }

    var body: some View {
        VStack(spacing: 0) {
            sheetHeader(
                title: isEN ? "Add Log" : "Kayıt Ekle",
                cancelLabel: isEN ? "Cancel" : "Vazgeç",
                saveLabel: isEN ? "Save" : "Kaydet",
                onCancel: { dismiss() },
                onSave: { saveLog() },
                saveDisabled: !canSave
            )
            ScrollView {
                VStack(spacing: 20) {
                    // Type selector
                    HStack(spacing: 8) {
                        typeButton(isEN ? "Feeding" : "Beslenme", type: .feeding, emoji: "🍼")
                        typeButton(isEN ? "Sleep" : "Uyku", type: .sleep, emoji: "😴")
                        typeButton(isEN ? "Diaper" : "Bez", type: .diaper, emoji: "🧷")
                        typeButton(isEN ? "Note" : "Not", type: .note, emoji: "💭")
                    }
                    .padding(.top, 8)

                    // Type-specific fields
                    VStack(alignment: .leading, spacing: 12) {
                        switch selectedType {
                        case .feeding:
                            fieldLabel(isEN ? "TYPE" : "TÜR")
                            HStack(spacing: 8) {
                                feedingButton(isEN ? "Breast milk" : "Anne sütü", type: .breast)
                                feedingButton(isEN ? "Bottle" : "Biberon", type: .bottle)
                                feedingButton(isEN ? "Solid food" : "Ek gıda", type: .solid)
                            }

                            if feedingType == .breast {
                                fieldLabel(isEN ? "SIDE" : "TARAF")
                                HStack(spacing: 8) {
                                    sideButton(isEN ? "Left" : "Sol", side: .left)
                                    sideButton(isEN ? "Right" : "Sağ", side: .right)
                                }
                            }

                            if feedingType == .bottle {
                                fieldLabel(isEN ? "AMOUNT (ml)" : "MİKTAR (ml)")
                                TextField(
                                    "",
                                    text: $bottleAmountText,
                                    prompt: Text("ml")
                                        .foregroundStyle(placeholderColor)
                                )
                                .font(.kinnaDisplay(24))
                                .foregroundStyle(.kChar)
                                .tint(.kTerra)
                                .keyboardType(.numberPad)
                                .padding(12)
                                .background(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.kPale, lineWidth: 1.5)
                                )
                            }

                        case .sleep:
                            fieldLabel(isEN ? "MANUAL DURATION" : "MANUEL SÜRE")
                            HStack(alignment: .firstTextBaseline, spacing: 4) {
                                Text("\(Int(sleepMinutes))")
                                    .font(.kinnaDisplay(32))
                                    .foregroundStyle(.kChar)
                                Text(isEN ? "min" : "dk")
                                    .font(.kinnaBody(14))
                                    .foregroundStyle(.kMid)
                            }
                            Slider(value: $sleepMinutes, in: 5...240, step: 5)
                                .tint(.kSage)

                            Text(isEN
                                 ? "💡 Tip: Use the sleep timer on the tracking screen for automatic duration."
                                 : "💡 İpucu: Otomatik süre için takip ekranındaki uyku zamanlayıcısını kullan.")
                                .font(.kinnaBody(10))
                                .foregroundStyle(.kLight)
                                .lineSpacing(2)

                        case .diaper:
                            fieldLabel(isEN ? "TYPE" : "TÜR")
                            HStack(spacing: 8) {
                                diaperButton(isEN ? "Wet" : "Islak", type: .wet)
                                diaperButton(isEN ? "Dirty" : "Kirli", type: .dirty)
                                diaperButton(isEN ? "Both" : "İkisi de", type: .both)
                            }

                        case .note:
                            VStack(alignment: .leading, spacing: 6) {
                                fieldLabel(isEN ? "ENTRY" : "KAYIT")
                                Text(isEN
                                     ? "Capture a doctor note, a difficult moment, or something you want to remember."
                                     : "Doktor notu, zor bir an ya da hatırlamak istediğiniz bir gözlemi kaydedin.")
                                    .font(.kinnaBody(12))
                                    .foregroundStyle(.kMid)
                                    .lineSpacing(3)
                            }
                        }
                    }

                    // Time
                    VStack(alignment: .leading, spacing: 6) {
                        fieldLabel(isEN ? "TIME" : "SAAT")
                        ZStack {
                            HStack {
                                Text(logDate.formatted(date: .omitted, time: .shortened))
                                    .font(.kinnaBody(14))
                                    .foregroundStyle(.kChar)
                                Spacer()
                                Image(systemName: "clock")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundStyle(.kTerra)
                            }
                            .padding(12)
                            .background(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.kPale, lineWidth: 1.5)
                            )

                            DatePicker("", selection: $logDate, displayedComponents: .hourAndMinute)
                                .labelsHidden()
                                .datePickerStyle(.compact)
                                .blendMode(.destinationOver)
                                .opacity(0.015)
                                .tint(.kTerra)
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    // Note
                    VStack(alignment: .leading, spacing: 6) {
                        fieldLabel(selectedType == .note
                                   ? (isEN ? "NOTE" : "NOT")
                                   : (isEN ? "NOTE (optional)" : "NOT (isteğe bağlı)"))

                        if selectedType == .note {
                            TextEditor(text: $note)
                                .font(.kinnaBody(14))
                                .foregroundStyle(.kChar)
                                .tint(.kTerra)
                                .scrollContentBackground(.hidden)
                                .frame(minHeight: 140)
                                .padding(8)
                                .background(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.kPale, lineWidth: 1.5)
                                )
                        } else {
                            TextField(
                                "",
                                text: $note,
                                prompt: Text(isEN ? "Additional info..." : "Ek bilgi...")
                                    .foregroundStyle(placeholderColor)
                            )
                                .font(.kinnaBody(14))
                                .foregroundStyle(.kChar)
                                .tint(.kTerra)
                                .padding(12)
                                .background(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.kPale, lineWidth: 1.5)
                                )
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 20)
            }
            .background(Color.kCream.ignoresSafeArea())
            .onAppear { selectedType = initialType }
        }
        .background(Color.kCream.ignoresSafeArea())
    }

    // MARK: - Save

    private func saveLog() {
        let log = DailyLog(
            date: logDate,
            type: selectedType,
            note: note.trimmingCharacters(in: .whitespacesAndNewlines),
            babyID: babies.first?.id
        )

        switch selectedType {
        case .feeding:
            log.feedingType = feedingType
            if feedingType == .breast {
                log.breastSide = breastSide
            }
            if feedingType == .bottle, let amount = parsedBottleAmount {
                log.feedingAmountML = amount
            }
        case .sleep:
            log.sleepDuration = sleepMinutes * 60
        case .diaper:
            log.diaperType = diaperType
        case .note:
            break
        }

        modelContext.insert(log)

        // Analytics
        switch selectedType {
        case .feeding:
            AnalyticsManager.featureUsed(feedingType == .bottle ? .bottleLog : .feedingTimer)
        case .sleep:
            AnalyticsManager.featureUsed(.sleepTimer)
        case .diaper:
            AnalyticsManager.featureUsed(.diaperLog)
        case .note:
            AnalyticsManager.featureUsed(.noteLog)
        }

        dismiss()
    }

    private var parsedBottleAmount: Double? {
        let normalized = bottleAmountText
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: ",", with: ".")
        guard let value = Double(normalized), value > 0 else { return nil }
        return value
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

    private func sideButton(_ title: String, side: DailyLog.BreastSide) -> some View {
        let isSelected = breastSide == side
        return Button {
            breastSide = side
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
}

struct AddGrowthSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Baby.createdAt) private var babies: [Baby]
    @AppStorage("useMetricUnits") private var useMetricUnits = true

    @State private var weightText = ""
    @State private var heightText = ""
    @State private var note = ""
    @State private var measuredAt = Date()

    private var isEN: Bool { Locale.current.language.languageCode?.identifier != "tr" }
    private var placeholderColor: Color { .kMid.opacity(0.8) }

    private var parsedWeight: Double? {
        parseMeasurement(weightText)
    }

    private var parsedHeight: Double? {
        parseMeasurement(heightText)
    }

    private var canSave: Bool {
        parsedWeight != nil || parsedHeight != nil
    }

    var body: some View {
        VStack(spacing: 0) {
            sheetHeader(
                title: isEN ? "Add Growth" : "Tartı / Boy Ekle",
                cancelLabel: isEN ? "Cancel" : "Vazgeç",
                saveLabel: isEN ? "Save" : "Kaydet",
                onCancel: { dismiss() },
                onSave: { saveRecord() },
                saveDisabled: !canSave
            )
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    HStack(spacing: 12) {
                        measurementField(
                            title: isEN ? "WEIGHT" : "TARTI",
                            placeholder: GrowthMetric.weight.unit(metric: useMetricUnits),
                            text: $weightText
                        )
                        measurementField(
                            title: isEN ? "HEIGHT" : "BOY",
                            placeholder: GrowthMetric.height.unit(metric: useMetricUnits),
                            text: $heightText
                        )
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        fieldLabel(isEN ? "MEASURED AT" : "ÖLÇÜM ZAMANI")
                        ZStack {
                            HStack {
                                Text(measuredAt.formatted(date: .abbreviated, time: .shortened))
                                    .font(.kinnaBody(14))
                                    .foregroundStyle(.kChar)
                                Spacer()
                                Image(systemName: "calendar.badge.clock")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundStyle(.kTerra)
                            }
                            .padding(12)
                            .background(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.kPale, lineWidth: 1.5)
                            )

                            DatePicker("", selection: $measuredAt, displayedComponents: [.date, .hourAndMinute])
                                .labelsHidden()
                                .datePickerStyle(.compact)
                                .blendMode(.destinationOver)
                                .opacity(0.015)
                                .tint(.kTerra)
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        fieldLabel(isEN ? "NOTE (optional)" : "NOT (isteğe bağlı)")
                        TextField(
                            "",
                            text: $note,
                            prompt: Text(isEN ? "Doctor visit, home scale, etc." : "Doktor kontrolü, ev tartısı, vb.")
                                .foregroundStyle(placeholderColor)
                        )
                            .font(.kinnaBody(14))
                            .foregroundStyle(.kChar)
                            .tint(.kTerra)
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
        }
        .background(Color.kCream.ignoresSafeArea())
    }

    private func saveRecord() {
        let metricWeight = parsedWeight.map { GrowthMetric.weight.toMetric($0, metric: useMetricUnits) }
        let metricHeight = parsedHeight.map { GrowthMetric.height.toMetric($0, metric: useMetricUnits) }
        let record = GrowthRecord(
            measuredAt: measuredAt,
            weightKilograms: metricWeight,
            heightCentimeters: metricHeight,
            note: note,
            babyID: babies.first?.id
        )

        modelContext.insert(record)
        dismiss()
    }

    private func measurementField(title: String, placeholder: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            fieldLabel(title)
            TextField(
                "",
                text: text,
                prompt: Text(placeholder)
                    .font(.kinnaDisplay(24))
                    .foregroundStyle(placeholderColor)
            )
                .font(.kinnaDisplay(24))
                .foregroundStyle(.kChar)
                .tint(.kTerra)
                .keyboardType(.decimalPad)
                .padding(12)
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.kPale, lineWidth: 1.5)
                )
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func fieldLabel(_ text: String) -> some View {
        Text(text)
            .font(.kinnaBodyMedium(10))
            .foregroundStyle(.kLight)
            .tracking(1)
    }

    private func parseMeasurement(_ text: String) -> Double? {
        let normalized = text
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: ",", with: ".")
        guard !normalized.isEmpty, let value = Double(normalized), value > 0 else { return nil }
        return value
    }
}

#Preview {
    NavigationStack {
        TrackingView()
    }
    .modelContainer(for: [DailyLog.self, GrowthRecord.self, Baby.self], inMemory: true)
    .environment(SubscriptionManager.shared)
}
