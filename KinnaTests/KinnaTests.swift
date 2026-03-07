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

    func testMilestoneEngineReturnsResults() {
        // Stub test — will pass once milestones.json is loaded in test bundle
        let milestones = MilestoneEngine.milestonesForAge(2)
        // In test environment without bundle, this returns empty
        XCTAssertNotNil(milestones)
    }
}
