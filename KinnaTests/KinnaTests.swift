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

    func testVaccineReminderIdentifiersStayStablePerReminderSlot() {
        let items = [
            VaccinationItem(
                id: "hep_b_1",
                nameTR: "Hepatit B (1. doz)",
                nameEN: "Hepatitis B (1st dose)",
                monthAge: 0,
                descriptionTR: "",
                descriptionEN: ""
            )
        ]

        let identifiers = NotificationManager.allVaccineReminderIdentifiers(items: items)

        XCTAssertEqual(
            identifiers,
            [
                "vaccine-hepatit_b_1_doz-3d",
                "vaccine-hepatit_b_1_doz-0d"
            ]
        )
    }

    func testVaccineReminderRequestsCreateThreeDayAndSameDayNotifications() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!

        let birthDate = calendar.date(from: DateComponents(year: 2026, month: 1, day: 1, hour: 8))!
        let referenceDate = calendar.date(from: DateComponents(year: 2026, month: 1, day: 10, hour: 12))!
        let items = [
            VaccinationItem(
                id: "dtap_2",
                nameTR: "DaBT-İPA-Hib (2. doz)",
                nameEN: "DTaP-IPV-Hib (2nd dose)",
                monthAge: 1,
                descriptionTR: "",
                descriptionEN: ""
            )
        ]

        let requests = NotificationManager.vaccineReminderRequests(
            birthDate: birthDate,
            referenceDate: referenceDate,
            calendar: calendar,
            isEnglish: false,
            items: items
        )

        XCTAssertEqual(requests.count, 2)
        XCTAssertEqual(requests.map(\.leadDays), [3, 0])
        XCTAssertEqual(
            requests.map(\.identifier),
            [
                "vaccine-dabt_ipa_hib_2_doz-3d",
                "vaccine-dabt_ipa_hib_2_doz-0d"
            ]
        )
        XCTAssertEqual(
            requests.map(\.scheduledAt),
            [
                calendar.date(from: DateComponents(year: 2026, month: 1, day: 29, hour: 9, minute: 0))!,
                calendar.date(from: DateComponents(year: 2026, month: 2, day: 1, hour: 9, minute: 0))!
            ]
        )
    }

    func testParentRoleProfileChangesHomeAndNotificationTone() {
        let mother = ParentRoleProfile(storedValue: "mother")
        let father = ParentRoleProfile(storedValue: "father")

        XCTAssertNotEqual(
            mother.homeLead(isEnglish: false),
            father.homeLead(isEnglish: false)
        )
        XCTAssertNotEqual(
            mother.dailyReminderBody(isEnglish: false),
            father.dailyReminderBody(isEnglish: false)
        )
        XCTAssertEqual(father.possessiveLabel(isEnglish: false), "babası")
    }

    func testParentRoleGuideTemplatesRotateByRole() {
        let mother = ParentRoleProfile(storedValue: "mother")
        let caregiver = ParentRoleProfile(storedValue: "caregiver")

        let motherTemplate = mother.dailyGuideTemplate(isEnglish: false, rotationIndex: 0)
        let caregiverTemplate = caregiver.dailyGuideTemplate(isEnglish: false, rotationIndex: 0)

        XCTAssertNotEqual(motherTemplate.title, caregiverTemplate.title)
        XCTAssertFalse(motherTemplate.action.isEmpty)
        XCTAssertFalse(caregiverTemplate.action.isEmpty)
    }

    func testHomeVaccinePlannerPrefersManualNextDoseWhenSooner() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        let referenceDate = calendar.date(from: DateComponents(year: 2026, month: 3, day: 14, hour: 10))!

        let scheduled = VaccinationRecord(
            vaccineName: "KPA (2. doz)",
            scheduledDate: calendar.date(from: DateComponents(year: 2026, month: 5, day: 1, hour: 9))!
        )
        let manual = VaccinationRecord(
            vaccineName: "Hepatit B",
            administeredDate: calendar.date(from: DateComponents(year: 2026, month: 3, day: 14, hour: 8))!,
            nextDoseDate: calendar.date(from: DateComponents(year: 2026, month: 3, day: 15, hour: 9))!,
            note: "Bildirim test edilecek"
        )

        let model = HomeGuidancePlanner.vaccineCardModel(
            records: [scheduled, manual],
            referenceDate: referenceDate,
            calendar: calendar,
            isEnglish: false
        )

        XCTAssertEqual(model.state, .upcoming)
        XCTAssertEqual(model.title, "Yaklaşan aşı")
        XCTAssertEqual(model.entry?.name, "Hepatit B")
        XCTAssertEqual(model.description, "Hepatit B için sonraki doz tarihi 15 Mart.")
        XCTAssertTrue(model.hasUpcomingThisMonth)
    }

    func testHomeVaccinePlannerMarksOverdueDoseAsNeedsAttention() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        let referenceDate = calendar.date(from: DateComponents(year: 2026, month: 3, day: 14, hour: 10))!

        let overdue = VaccinationRecord(
            vaccineName: "Hepatit B (1. doz)",
            scheduledDate: calendar.date(from: DateComponents(year: 2026, month: 1, day: 1, hour: 9))!
        )

        let model = HomeGuidancePlanner.vaccineCardModel(
            records: [overdue],
            referenceDate: referenceDate,
            calendar: calendar,
            isEnglish: false
        )

        XCTAssertEqual(model.state, .overdue)
        XCTAssertEqual(model.title, "İlgilenmen gereken aşı")
        XCTAssertEqual(model.description, "Hepatit B (1. doz) için planlanan tarih 1 Ocak idi.")
        XCTAssertTrue(model.hasUpcomingThisMonth)
    }

    func testScheduledRecordReminderRequestsFollowRescheduledDates() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        let referenceDate = calendar.date(from: DateComponents(year: 2026, month: 3, day: 10, hour: 12))!

        let rescheduledRecord = VaccinationRecord(
            vaccineName: "Hepatit B",
            scheduledDate: calendar.date(from: DateComponents(year: 2026, month: 3, day: 15, hour: 9))!
        )

        let requests = NotificationManager.vaccineReminderRequests(
            scheduledRecords: [rescheduledRecord],
            referenceDate: referenceDate,
            calendar: calendar,
            isEnglish: false
        )

        XCTAssertEqual(requests.count, 2)
        XCTAssertEqual(
            requests.map(\.identifier),
            [
                "vaccine-hepatit_b-3d",
                "vaccine-hepatit_b-0d"
            ]
        )
        XCTAssertEqual(
            requests.map(\.scheduledAt),
            [
                calendar.date(from: DateComponents(year: 2026, month: 3, day: 12, hour: 9, minute: 0))!,
                calendar.date(from: DateComponents(year: 2026, month: 3, day: 15, hour: 9, minute: 0))!
            ]
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
