import XCTest
@testable import Kinna

final class KinnaTests: XCTestCase {
    func testBabyAgeCalculation() {
        let calendar = Calendar.current
        let birthDate = calendar.date(byAdding: .month, value: -3, to: .now)!
        let baby = Baby(name: "Test", birthDate: birthDate, gender: .male)

        XCTAssertEqual(baby.ageInMonths, 3)
        XCTAssertGreaterThan(baby.ageInDays, 80)
    }

    func testMilestoneDataCoversBirthTo24MonthsWithoutGaps() throws {
        let data = try Data(contentsOf: dataFileURL(named: "milestones"))
        let items = try JSONDecoder().decode([Milestone].self, from: data)

        let expectedBands: Set<String> = [
            "0-2", "3-4", "5-6", "7-9", "10-12", "13-15", "16-18", "19-24"
        ]

        XCTAssertGreaterThanOrEqual(items.count, 64)
        XCTAssertEqual(Set(items.map { "\($0.monthStart)-\($0.monthEnd)" }), expectedBands)
        XCTAssertTrue(items.contains { $0.category == "cognitive" })
        XCTAssertTrue(items.contains { $0.id == "social_0_2_calms_when_comforted" && $0.monthEnd == 2 })
        XCTAssertTrue(items.contains { $0.id == "language_19_24_two_word_phrases" && $0.monthStart == 19 })

        for month in 0...24 {
            XCTAssertFalse(
                items.filter { month >= $0.monthStart && month <= $0.monthEnd }.isEmpty,
                "Missing milestone coverage for month \(month)"
            )
        }
    }

    func testGrowthRecordStoresMeasurements() {
        let babyID = UUID()
        let record = GrowthRecord(
            measuredAt: .now,
            weightKilograms: 6.4,
            heightCentimeters: 61.2,
            note: "Routine check",
            babyID: babyID
        )

        XCTAssertEqual(record.weightKilograms, 6.4)
        XCTAssertEqual(record.heightCentimeters, 61.2)
        XCTAssertEqual(record.note, "Routine check")
        XCTAssertEqual(record.babyID, babyID)
    }

    func testDailyLogStoresStandaloneNoteAndBabyReference() {
        let babyID = UUID()
        let log = DailyLog(
            date: .now,
            type: .note,
            note: "Sabahtan beri daha huzursuz, dis donemi olabilir.",
            babyID: babyID
        )

        XCTAssertEqual(log.type, .note)
        XCTAssertEqual(log.note, "Sabahtan beri daha huzursuz, dis donemi olabilir.")
        XCTAssertEqual(log.babyID, babyID)
    }

    func testVaccinationDataIncludesCurrentTRScheduleEntries() throws {
        let testFileURL = URL(fileURLWithPath: #filePath)
        let projectRoot = testFileURL
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        let jsonURL = projectRoot
            .appendingPathComponent("Kinna")
            .appendingPathComponent("Resources")
            .appendingPathComponent("Data")
            .appendingPathComponent("vaccinations.json")

        let data = try Data(contentsOf: jsonURL)
        let items = try JSONDecoder().decode([VaccinationItem].self, from: data)

        XCTAssertGreaterThanOrEqual(items.count, 18)
        XCTAssertTrue(items.contains { $0.id == "mmr_extra_1" && $0.monthAge == 9 })
        XCTAssertTrue(items.contains { $0.id == "hexa_booster" && $0.monthAge == 18 })
        XCTAssertTrue(items.contains { $0.id == "dtap_ipv_booster" && $0.monthAge == 48 })
    }

    func testSafetyAlertDataCoversCoreInfantAndToddlerRisks() throws {
        let data = try Data(contentsOf: dataFileURL(named: "safety_alerts"))
        let items = try JSONDecoder().decode([SafetyAlert].self, from: data)

        XCTAssertGreaterThanOrEqual(items.count, 6)
        XCTAssertTrue(items.contains { $0.id == "safe_sleep_back_0_2" && $0.monthStart == 0 && $0.monthEnd == 2 })
        XCTAssertTrue(items.contains { $0.id == "solid_food_choking_6_8" && $0.monthStart == 6 })
        XCTAssertTrue(items.contains { $0.id == "drowning_supervision_12_24" && $0.monthEnd == 24 })
    }

    func testMonetizationPolicyReflectsFreeTierDecisions() {
        XCTAssertEqual(MonetizationPolicy.trialLengthDays, 7)
        XCTAssertEqual(MonetizationPolicy.freeTrackingHistoryDays, 7)
        XCTAssertEqual(MonetizationPolicy.freeFoodLogLimit, 5)

        XCTAssertTrue(MonetizationPolicy.canAccessMilestoneMonth(
            hasFullAccess: false,
            selectedMonth: 8,
            currentMonth: 8
        ))
        XCTAssertFalse(MonetizationPolicy.canAccessMilestoneMonth(
            hasFullAccess: false,
            selectedMonth: 7,
            currentMonth: 8
        ))

        XCTAssertTrue(MonetizationPolicy.canAddFoodLog(hasFullAccess: false, currentCount: 4))
        XCTAssertFalse(MonetizationPolicy.canAddFoodLog(hasFullAccess: false, currentCount: 5))
        XCTAssertFalse(MonetizationPolicy.canUseVaccineReminders(hasFullAccess: false))
    }

    func testFreeHistoryCutoffKeepsSevenDayWindow() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        let referenceDate = calendar.date(from: DateComponents(year: 2026, month: 3, day: 13, hour: 15))!

        let cutoffDate = MonetizationPolicy.freeHistoryCutoffDate(
            referenceDate: referenceDate,
            calendar: calendar
        )

        XCTAssertEqual(
            cutoffDate,
            calendar.date(from: DateComponents(year: 2026, month: 3, day: 7, hour: 0))
        )
    }

    private func dataFileURL(named fileName: String) -> URL {
        let testFileURL = URL(fileURLWithPath: #filePath)
        let projectRoot = testFileURL
            .deletingLastPathComponent()
            .deletingLastPathComponent()

        return projectRoot
            .appendingPathComponent("Kinna")
            .appendingPathComponent("Resources")
            .appendingPathComponent("Data")
            .appendingPathComponent("\(fileName).json")
    }
}
