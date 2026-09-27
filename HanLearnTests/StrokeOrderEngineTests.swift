import XCTest
@testable import HanLearn

final class StrokeOrderEngineTests: XCTestCase {
    
    func testKnownCharacterNiReturnsCorrectStrokeCount() {
        let data = StrokeOrderEngine.shared.getStrokeData(for: "你")
        XCTAssertEqual(data.hanzi, "你")
        XCTAssertEqual(data.totalStrokes, 7)
        XCTAssertEqual(data.strokeNames.count, 7)
        XCTAssertEqual(data.strokePathDefinitions.count, 7)
    }
    
    func testKnownCharacterHaoReturnsCorrectStrokeCount() {
        let data = StrokeOrderEngine.shared.getStrokeData(for: "好")
        XCTAssertEqual(data.hanzi, "好")
        XCTAssertEqual(data.totalStrokes, 6)
        XCTAssertEqual(data.strokeNames.count, 6)
    }
    
    func testFallbackCharacterReturnsDefaultStrokes() {
        let data = StrokeOrderEngine.shared.getStrokeData(for: "水")
        XCTAssertEqual(data.hanzi, "水")
        XCTAssertEqual(data.totalStrokes, 4)
        XCTAssertFalse(data.strokePathDefinitions.isEmpty)
    }
}
