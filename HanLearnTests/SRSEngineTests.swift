import XCTest
@testable import HanLearn

final class SRSEngineTests: XCTestCase {
    
    func testInitialReviewWithGoodGradeAdvancesStep() {
        let result = SRSEngine.processReview(
            grade: .good,
            currentRepetitionCount: 0,
            currentIntervalDays: 0,
            currentEaseFactor: 2.5,
            currentMastery: 0
        )
        
        XCTAssertEqual(result.newRepetitionCount, 1)
        XCTAssertEqual(result.newInterval, 1) // First step is 1 day
        XCTAssertEqual(result.newMastery, 15) // Good grade adds 15
    }
    
    func testConsecutiveReviewsFollowIntervalSteps() {
        // Step 0 -> Step 1 (1 day)
        let r1 = SRSEngine.processReview(
            grade: .good,
            currentRepetitionCount: 0,
            currentIntervalDays: 0,
            currentEaseFactor: 2.5,
            currentMastery: 0
        )
        XCTAssertEqual(r1.newInterval, 1)
        
        // Step 1 -> Step 2 (3 days)
        let r2 = SRSEngine.processReview(
            grade: .good,
            currentRepetitionCount: r1.newRepetitionCount,
            currentIntervalDays: r1.newInterval,
            currentEaseFactor: r1.newEaseFactor,
            currentMastery: r1.newMastery
        )
        XCTAssertEqual(r2.newInterval, 3)
        
        // Step 2 -> Step 3 (7 days)
        let r3 = SRSEngine.processReview(
            grade: .good,
            currentRepetitionCount: r2.newRepetitionCount,
            currentIntervalDays: r2.newInterval,
            currentEaseFactor: r2.newEaseFactor,
            currentMastery: r2.newMastery
        )
        XCTAssertEqual(r3.newInterval, 7)
    }
    
    func testFailedReviewResetsIntervalAndRepetition() {
        let result = SRSEngine.processReview(
            grade: .again,
            currentRepetitionCount: 4,
            currentIntervalDays: 14,
            currentEaseFactor: 2.5,
            currentMastery: 60
        )
        
        XCTAssertEqual(result.newRepetitionCount, 0)
        XCTAssertEqual(result.newInterval, 1) // Resets to first step
        XCTAssertEqual(result.newMastery, 45) // Penalized by 15
    }
    
    func testEasyGradeBoostsMasteryMore() {
        let result = SRSEngine.processReview(
            grade: .easy,
            currentRepetitionCount: 0,
            currentIntervalDays: 0,
            currentEaseFactor: 2.5,
            currentMastery: 0
        )
        
        XCTAssertEqual(result.newMastery, 25) // Easy grade adds 25
    }
}
