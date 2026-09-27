import XCTest
#if canImport(HanLearn)
@testable import HanLearn
#endif

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
        XCTAssertEqual(result.newInterval, 1)
        XCTAssertEqual(result.newMastery, 15)
    }
    
    func testConsecutiveReviewsFollowIntervalSteps() {
        let r1 = SRSEngine.processReview(
            grade: .good,
            currentRepetitionCount: 0,
            currentIntervalDays: 0,
            currentEaseFactor: 2.5,
            currentMastery: 0
        )
        XCTAssertEqual(r1.newInterval, 1)
        
        let r2 = SRSEngine.processReview(
            grade: .good,
            currentRepetitionCount: r1.newRepetitionCount,
            currentIntervalDays: r1.newInterval,
            currentEaseFactor: r1.newEaseFactor,
            currentMastery: r1.newMastery
        )
        XCTAssertEqual(r2.newInterval, 3)
        
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
        XCTAssertEqual(result.newInterval, 1)
        XCTAssertEqual(result.newMastery, 45)
    }
    
    func testEasyGradeBoostsMasteryMore() {
        let result = SRSEngine.processReview(
            grade: .easy,
            currentRepetitionCount: 0,
            currentIntervalDays: 0,
            currentEaseFactor: 2.5,
            currentMastery: 0
        )
        
        XCTAssertEqual(result.newMastery, 25)
    }
}
