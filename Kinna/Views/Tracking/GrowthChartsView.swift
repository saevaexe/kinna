import Charts
import SwiftUI

struct GrowthChartsView: View {
    @Environment(\.dismiss) private var dismiss

    let baby: Baby
    let records: [GrowthRecord]

    @State private var selectedMetric: GrowthMetric = .weight

    private var isEN: Bool { Locale.current.language.languageCode?.identifier != "tr" }
    private var referencePoints: [GrowthReferencePoint]? {
        GrowthReferenceEngine.referencePoints(metric: selectedMetric, gender: baby.gender)
    }
    private var visibleReferencePoints: [GrowthReferencePoint]? {
        guard let referencePoints else { return nil }
        let filtered = referencePoints.filter { $0.day <= chartXUpperBound }
        return filtered.isEmpty ? referencePoints : filtered
    }
    private var chartPoints: [GrowthChartPoint] {
        GrowthReferenceEngine.chartPoints(
            records: records,
            birthDate: baby.birthDate,
            metric: selectedMetric
        )
    }
    private var summary: GrowthMetricSummary? {
        GrowthReferenceEngine.latestSummary(
            records: records,
            birthDate: baby.birthDate,
            metric: selectedMetric,
            gender: baby.gender
        )
    }
    private var hasOutOfRangeData: Bool {
        records.contains { record in
            guard selectedMetric.value(from: record) != nil else { return false }
            return GrowthReferenceEngine.ageInDays(at: record.measuredAt, birthDate: baby.birthDate) > GrowthReferenceEngine.supportedRange.upperBound
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                headerCard
                metricPicker

                if let summary {
                    summaryCard(summary)
                }

                if chartPoints.isEmpty {
                    emptyStateCard
                } else {
                    chartCard
                }

                if referencePoints == nil {
                    infoCard(
                        title: isEN ? "Reference note" : "Referans notu",
                        body: isEN
                            ? "WHO percentile comparison requires selecting your baby's sex."
                            : "WHO persentil karşılaştırması için bebeğin cinsiyet bilgisinin seçili olması gerekir.",
                        icon: "info.circle"
                    )
                }

                if hasOutOfRangeData {
                    infoCard(
                        title: isEN ? "Range note" : "Kapsam notu",
                        body: isEN
                            ? "The first version of growth charts covers the first 24 months."
                            : "Büyüme eğrilerinin ilk sürümü yalnızca ilk 24 ayı kapsar.",
                        icon: "calendar.badge.exclamationmark"
                    )
                }

                infoCard(
                    title: isEN ? "Clinical note" : "Klinik not",
                    body: isEN
                        ? "This chart offers a WHO-based comparison view and does not replace medical evaluation."
                        : "Bu grafik WHO referansına göre karşılaştırmalı izleme sunar, tıbbi değerlendirme yerine geçmez.",
                    icon: "cross.case"
                )
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)
            .padding(.bottom, 24)
        }
        .background(Color.kCream.ignoresSafeArea())
        .navigationTitle(isEN ? "Growth Charts" : "Büyüme Eğrisi")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.kChar)
                }
            }
        }
    }

    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(selectedMetric.chartTitle(isEnglish: isEN))
                .font(.kinnaDisplay(24))
                .foregroundStyle(.kChar)

            Text(isEN
                 ? "\(baby.name)'s measurements against WHO reference curves."
                 : "\(baby.name)'nın ölçümlerini WHO referans eğrileriyle birlikte gör.")
                .font(.kinnaBody(12))
                .foregroundStyle(.kMid)
                .lineSpacing(3)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(
            LinearGradient(
                colors: [Color.kWarm, Color.kTerraPale.opacity(0.55)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 22))
        .overlay(
            RoundedRectangle(cornerRadius: 22)
                .stroke(Color.kPale, lineWidth: 1)
        )
    }

    private var metricPicker: some View {
        HStack(spacing: 8) {
            ForEach(GrowthMetric.allCases) { metric in
                Button {
                    withAnimation(.easeInOut(duration: 0.18)) {
                        selectedMetric = metric
                    }
                } label: {
                    Text(metric.title(isEnglish: isEN))
                        .font(.kinnaBodyMedium(13))
                        .foregroundStyle(selectedMetric == metric ? .white : .kMid)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(selectedMetric == metric ? Color.kChar : Color.kWarm)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(selectedMetric == metric ? Color.kChar : Color.kPale, lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(6)
        .background(Color.kPale)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    private func summaryCard(_ summary: GrowthMetricSummary) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(isEN ? "Latest measurement" : "Son ölçüm")
                .font(.kinnaBodyMedium(10))
                .foregroundStyle(.kLight)
                .tracking(1)
                .textCase(.uppercase)

            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text(summary.latestValue.formatted(.number.precision(.fractionLength(1))))
                    .font(.kinnaDisplay(28))
                    .foregroundStyle(.kChar)

                Text(selectedMetric.unit)
                    .font(.kinnaBody(12))
                    .foregroundStyle(.kMid)
            }

            Text(summary.latestDate, format: .dateTime.day().month(.wide).year())
                .font(.kinnaBody(11))
                .foregroundStyle(.kMid)

            Text(summaryBandText(for: summary))
                .font(.kinnaBodyMedium(11))
                .foregroundStyle(.kSageDark)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 22))
        .overlay(
            RoundedRectangle(cornerRadius: 22)
                .stroke(Color.kPale, lineWidth: 1)
        )
    }

    private var chartCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text(chartSectionTitle)
                    .font(.kinnaBodyMedium(10))
                    .foregroundStyle(.kLight)
                    .tracking(1)
                    .textCase(.uppercase)

                Text(chartWindowLabel)
                    .font(.kinnaBody(12))
                    .foregroundStyle(.kMid)
            }

            Chart {
                if let visibleReferencePoints {
                    percentileBoundary(
                        visibleReferencePoints,
                        value: \.p15,
                        label: "P15",
                        color: .kSage,
                        width: 1.8,
                        dash: [4, 4]
                    )
                    percentileBoundary(
                        visibleReferencePoints,
                        value: \.p85,
                        label: "P85",
                        color: .kSage,
                        width: 1.8,
                        dash: [4, 4]
                    )
                    percentileBoundary(
                        visibleReferencePoints,
                        value: \.p50,
                        label: "P50",
                        color: .kSageDark,
                        width: 2.2,
                        dash: []
                    )
                }

                ForEach(chartPoints) { point in
                    PointMark(
                        x: .value("Age", point.day),
                        y: .value("Measurement", point.value)
                    )
                    .foregroundStyle(.kTerra)
                    .symbolSize(52)
                }
            }
            .chartXAxis {
                AxisMarks(values: xAxisMarks) { value in
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [2, 2]))
                        .foregroundStyle(Color.kPale)
                    AxisTick()
                        .foregroundStyle(Color.kPale)

                    if let day = value.as(Int.self) {
                        AxisValueLabel {
                            Text(axisLabel(for: day))
                                .font(.kinnaBody(10))
                                .foregroundStyle(.kLight)
                        }
                    }
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading) { value in
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [2, 2]))
                        .foregroundStyle(Color.kPale)
                    AxisValueLabel {
                        if let number = value.as(Double.self) {
                            Text(number.formatted(.number.precision(.fractionLength(0...1))))
                                .font(.kinnaBody(10))
                                .foregroundStyle(.kLight)
                        }
                    }
                }
            }
            .chartLegend(.hidden)
            .chartXScale(domain: chartXDomain)
            .chartYScale(domain: yDomain)
            .frame(height: 280)

            legend
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 22))
        .overlay(
            RoundedRectangle(cornerRadius: 22)
                .stroke(Color.kPale, lineWidth: 1)
        )
    }

    private var emptyStateCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(isEN ? "No measurements yet" : "Henüz ölçüm yok")
                .font(.kinnaBodyMedium(13))
                .foregroundStyle(.kChar)

            Text(
                hasOutOfRangeData
                ? (isEN
                    ? "Measurements older than 24 months are excluded from this first chart version."
                    : "24 ay üstündeki ölçümler bu ilk grafik sürümünde gösterilmiyor.")
                : (isEN
                    ? "Add weight or height entries from the tracking screen to see the chart."
                    : "Grafiği görmek için takip ekranından tartı veya boy ölçümü ekle.")
            )
            .font(.kinnaBody(12))
            .foregroundStyle(.kMid)
            .lineSpacing(3)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 22))
        .overlay(
            RoundedRectangle(cornerRadius: 22)
                .stroke(Color.kPale, lineWidth: 1)
        )
    }

    private var legend: some View {
        HStack(spacing: 16) {
            legendDotItem(color: .kTerra, label: isEN ? "Your record" : "Senin ölçümün")
            legendLineItem(color: .kSageDark, label: isEN ? "Middle line" : "Orta çizgi", width: 16, lineWidth: 4)
            legendDashedItem(color: .kSage, label: isEN ? "Expected range" : "Beklenen aralık", dash: [4, 4])
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func legendDotItem(color: Color, label: String) -> some View {
        HStack(spacing: 6) {
            Circle()
                .fill(color)
                .frame(width: 10, height: 10)

            Text(label)
                .font(.kinnaBody(10))
                .foregroundStyle(.kMid)
        }
    }

    private func legendLineItem(color: Color, label: String, width: CGFloat, lineWidth: CGFloat) -> some View {
        HStack(spacing: 6) {
            RoundedRectangle(cornerRadius: 2)
                .fill(color)
                .frame(width: width, height: lineWidth)

            Text(label)
                .font(.kinnaBody(10))
                .foregroundStyle(.kMid)
        }
    }

    private func legendDashedItem(color: Color, label: String, dash: [CGFloat]) -> some View {
        HStack(spacing: 6) {
            RoundedRectangle(cornerRadius: 2)
                .stroke(style: StrokeStyle(lineWidth: 2, dash: dash))
                .foregroundStyle(color)
                .frame(width: 16, height: 10)

            Text(label)
                .font(.kinnaBody(10))
                .foregroundStyle(.kMid)
        }
    }

    private func infoCard(title: String, body: String, icon: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.kTerra)
                .frame(width: 28, height: 28)
                .background(Color.kTerraPale)
                .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.kinnaBodyMedium(12))
                    .foregroundStyle(.kChar)

                Text(body)
                    .font(.kinnaBody(11))
                    .foregroundStyle(.kMid)
                    .lineSpacing(3)
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

    @ChartContentBuilder
    private func percentileBoundary(
        _ points: [GrowthReferencePoint],
        value: KeyPath<GrowthReferencePoint, Double>,
        label: String,
        color: Color,
        width: CGFloat,
        dash: [CGFloat]
    ) -> some ChartContent {
        ForEach(points) { point in
            LineMark(
                x: .value("Age", point.day),
                y: .value(label, point[keyPath: value]),
                series: .value("Series", label)
            )
            .foregroundStyle(color)
            .lineStyle(.init(lineWidth: width, lineCap: .round, lineJoin: .round, dash: dash))
            .interpolationMethod(.catmullRom)
        }
    }

    private var yDomain: ClosedRange<Double> {
        let referenceValues = (visibleReferencePoints ?? []).flatMap { [$0.p15, $0.p50, $0.p85] }
        let userValues = chartPoints.map(\.value)
        let values = referenceValues + userValues

        guard let minValue = values.min(), let maxValue = values.max() else {
            return 0...1
        }

        let padding = max((maxValue - minValue) * 0.08, 0.4)
        return (minValue - padding)...(maxValue + padding)
    }

    private var chartXDomain: ClosedRange<Int> {
        0...chartXUpperBound
    }

    private var chartXUpperBound: Int {
        let latestDay = max(chartPoints.map(\.day).max() ?? 0, baby.ageInDays)

        switch latestDay {
        case ..<90:
            return 120
        case ..<180:
            return 180
        case ..<365:
            return 365
        case ..<540:
            return 540
        default:
            return 730
        }
    }

    private var xAxisMarks: [Int] {
        switch chartXUpperBound {
        case 120:
            return [0, 30, 60, 90, 120]
        case 180:
            return [0, 30, 60, 90, 120, 150, 180]
        case 365:
            return [0, 90, 180, 270, 365]
        case 540:
            return [0, 90, 180, 365, 540]
        default:
            return [0, 90, 180, 365, 540, 730]
        }
    }

    private var chartSectionTitle: String {
        if isEN {
            switch selectedMetric {
            case .weight:
                return "WHO Weight Curve"
            case .height:
                return "WHO Length Curve"
            }
        } else {
            switch selectedMetric {
            case .weight:
                return "WHO Tartı Eğrisi"
            case .height:
                return "WHO Boy Eğrisi"
            }
        }
    }

    private var chartWindowLabel: String {
        if isEN {
            switch chartXUpperBound {
            case 120:
                return "First 4 months"
            case 180:
                return "First 6 months"
            case 365:
                return "First 12 months"
            case 540:
                return "First 18 months"
            default:
                return "0–24 months"
            }
        } else {
            switch chartXUpperBound {
            case 120:
                return "İlk 4 ay"
            case 180:
                return "İlk 6 ay"
            case 365:
                return "İlk 12 ay"
            case 540:
                return "İlk 18 ay"
            default:
                return "0–24 ay"
            }
        }
    }

    private func axisLabel(for day: Int) -> String {
        let month = day == 0 ? 0 : Int(round(Double(day) / 30.4375))

        if isEN {
            return "\(month) mo"
        } else {
            return "\(month). ay"
        }
    }

    private func summaryBandText(for summary: GrowthMetricSummary) -> String {
        if let band = summary.band {
            switch band {
            case .p15To85:
                return isEN ? "Within the expected range" : "Beklenen aralıkta"
            case .p3To15, .p85To97:
                return isEN ? "Close to the expected range" : "Beklenen aralığın yakınında"
            case .belowP3:
                return isEN ? "Below the expected range" : "Beklenen aralığın altında"
            case .aboveP97:
                return isEN ? "Above the expected range" : "Beklenen aralığın üstünde"
            }
        }

        if baby.gender == .other {
            return isEN
                ? "Select sex to compare against WHO percentiles."
                : "WHO persentilleriyle karşılaştırmak için cinsiyet bilgisini seç."
        }

        return isEN
            ? "WHO comparison unavailable for this point."
            : "Bu nokta için WHO karşılaştırması gösterilemiyor."
    }
}

#Preview {
    let baby = Baby(name: "Ela", birthDate: Calendar.current.date(byAdding: .month, value: -2, to: .now)!, gender: .female)
    let records = [
        GrowthRecord(measuredAt: Calendar.current.date(byAdding: .day, value: -35, to: .now)!, weightKilograms: 4.5, heightCentimeters: 54),
        GrowthRecord(measuredAt: Calendar.current.date(byAdding: .day, value: -7, to: .now)!, weightKilograms: 5.2, heightCentimeters: 58)
    ]

    NavigationStack {
        GrowthChartsView(baby: baby, records: records)
    }
}
