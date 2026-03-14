import Foundation

enum GrowthMetric: String, CaseIterable, Identifiable {
    case weight
    case height

    var id: String { rawValue }

    var unit: String {
        switch self {
        case .weight: "kg"
        case .height: "cm"
        }
    }

    func title(isEnglish: Bool) -> String {
        switch self {
        case .weight:
            return isEnglish ? "Weight" : "Tartı"
        case .height:
            return isEnglish ? "Height" : "Boy"
        }
    }

    func chartTitle(isEnglish: Bool) -> String {
        switch self {
        case .weight:
            return isEnglish ? "Weight-for-age" : "Yaşa göre tartı"
        case .height:
            return isEnglish ? "Length-for-age" : "Yaşa göre boy"
        }
    }

    func shortDescription(isEnglish: Bool) -> String {
        switch self {
        case .weight:
            return isEnglish ? "WHO weight reference" : "WHO tartı referansı"
        case .height:
            return isEnglish ? "WHO length reference" : "WHO boy referansı"
        }
    }

    func value(from record: GrowthRecord) -> Double? {
        switch self {
        case .weight: record.weightKilograms
        case .height: record.heightCentimeters
        }
    }
}

struct GrowthReferencePoint: Codable, Equatable, Identifiable {
    let day: Int
    let p3: Double
    let p15: Double
    let p50: Double
    let p85: Double
    let p97: Double

    var id: Int { day }
}

struct GrowthChartPoint: Identifiable, Equatable {
    let day: Int
    let value: Double
    let measuredAt: Date

    var id: String {
        "\(day)-\(measuredAt.timeIntervalSinceReferenceDate)-\(value)"
    }
}

enum GrowthBand: String {
    case belowP3
    case p3To15
    case p15To85
    case p85To97
    case aboveP97

    func label(isEnglish: Bool) -> String {
        switch self {
        case .belowP3:
            return isEnglish ? "below P3" : "P3 altı"
        case .p3To15:
            return isEnglish ? "between P3 and P15" : "P3–P15 arası"
        case .p15To85:
            return isEnglish ? "between P15 and P85" : "P15–P85 arası"
        case .p85To97:
            return isEnglish ? "between P85 and P97" : "P85–P97 arası"
        case .aboveP97:
            return isEnglish ? "above P97" : "P97 üstü"
        }
    }
}

struct GrowthMetricSummary {
    let latestValue: Double
    let latestDay: Int
    let latestDate: Date
    let band: GrowthBand?
}

enum GrowthReferenceEngine {
    static let supportedRange = 0...730

    private static let fileNames: [GrowthMetric: [Baby.Gender: String]] = [
        .weight: [
            .male: "who_weight_for_age_boys_0_24",
            .female: "who_weight_for_age_girls_0_24"
        ],
        .height: [
            .male: "who_length_for_age_boys_0_24",
            .female: "who_length_for_age_girls_0_24"
        ]
    ]

    static func loadReferencePoints(from url: URL) throws -> [GrowthReferencePoint] {
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode([GrowthReferencePoint].self, from: data)
    }

    static func referencePoints(
        metric: GrowthMetric,
        gender: Baby.Gender,
        bundle: Bundle = .main
    ) -> [GrowthReferencePoint]? {
        guard let fileName = fileNames[metric]?[gender],
              let url = bundle.url(forResource: fileName, withExtension: "json"),
              let points = try? loadReferencePoints(from: url)
        else {
            return nil
        }

        return points
    }

    static func chartPoints(
        records: [GrowthRecord],
        birthDate: Date,
        metric: GrowthMetric,
        calendar: Calendar = .current
    ) -> [GrowthChartPoint] {
        records.compactMap { record in
            guard let value = metric.value(from: record) else { return nil }
            let day = ageInDays(at: record.measuredAt, birthDate: birthDate, calendar: calendar)
            guard supportedRange.contains(day) else { return nil }

            return GrowthChartPoint(day: day, value: value, measuredAt: record.measuredAt)
        }
        .sorted { lhs, rhs in
            if lhs.day == rhs.day {
                return lhs.measuredAt < rhs.measuredAt
            }
            return lhs.day < rhs.day
        }
    }

    static func latestSummary(
        records: [GrowthRecord],
        birthDate: Date,
        metric: GrowthMetric,
        gender: Baby.Gender,
        calendar: Calendar = .current,
        bundle: Bundle = .main
    ) -> GrowthMetricSummary? {
        let points = chartPoints(records: records, birthDate: birthDate, metric: metric, calendar: calendar)
        guard let latest = points.last else { return nil }

        let reference = referencePoints(metric: metric, gender: gender, bundle: bundle)
        let resolvedBand: GrowthBand? = reference.flatMap { points in
            GrowthReferenceEngine.band(for: latest.value, day: latest.day, referencePoints: points)
        }

        return GrowthMetricSummary(
            latestValue: latest.value,
            latestDay: latest.day,
            latestDate: latest.measuredAt,
            band: resolvedBand
        )
    }

    static func band(
        for value: Double,
        day: Int,
        referencePoints: [GrowthReferencePoint]
    ) -> GrowthBand? {
        guard let reference = nearestReferencePoint(for: day, in: referencePoints) else {
            return nil
        }

        switch value {
        case ..<reference.p3:
            return .belowP3
        case ..<reference.p15:
            return .p3To15
        case ...reference.p85:
            return .p15To85
        case ...reference.p97:
            return .p85To97
        default:
            return .aboveP97
        }
    }

    static func nearestReferencePoint(
        for day: Int,
        in points: [GrowthReferencePoint]
    ) -> GrowthReferencePoint? {
        guard !points.isEmpty else { return nil }
        guard supportedRange.contains(day) else { return nil }

        return points.min { lhs, rhs in
            abs(lhs.day - day) < abs(rhs.day - day)
        }
    }

    static func ageInDays(
        at measurementDate: Date,
        birthDate: Date,
        calendar: Calendar = .current
    ) -> Int {
        max(0, calendar.dateComponents([.day], from: birthDate, to: measurementDate).day ?? 0)
    }
}
