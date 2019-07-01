import XCTest
@testable import SwiftTimeit

final class SwiftTimeitTests: XCTestCase {

    func testFormatTimeUnits() {
        let testCases = [(1e-1, "0.1 ns"), (1e0, "1 ns"), (1e1, "10 ns"), (1e2, "100 ns"), 
                         (1e3, "1 µs"), (1e4, "10 µs"), (1e5, "100 µs"),
                         (1e6, "1 ms"), (1e7, "10 ms"), (1e8, "100 ms"),
                         (1e9, "1 s"), (1e10, "10 s"),
                        ]
        for tc in testCases{
            XCTAssertEqual(formatTime(tc.0), tc.1)
        }
    }

    func testFormatTimePrecision() {
        let testCases = [(1, 1e0, "1 ns"), (2, 1e0, "1 ns"), (3, 1e0, "1 ns"),
                         (1, 4.0/3.0, "1 ns"), (2, 4.0/3.0, "1.3 ns"), (3, 4.0/3.0, "1.33 ns"),
                         (4, 4.0/3.0, "1.333 ns"), (5, 4.0/3.0, "1.3333 ns"), (6, 4.0/3.0, "1.33333 ns"),
                         (7, 4.0/3.0, "1.333333 ns"), (8, 4.0/3.0, "1.3333333 ns"), (9, 4.0/3.0, "1.33333333 ns"),
                        ]
        for tc in testCases{
            XCTAssertEqual(formatTime(precision: tc.0, tc.1), tc.2)
        }
    }

    func testFormatTimeOverMinute() {
        let testCases = [(24*60*60*1e9, "1d"), (24*60*60*1e9+60*60*1e9, "1d 1h"), (24*60*60*1e9+60*1e9, "1d 1min"), (24*60*60*1e9+1e9, "1d 1s"),
                         (60*60*1e9, "1h"), (60*60*1e9+60*1e9, "1h 1min"), (60*60*1e9+1e9, "1h 1s"), (60*60*1e9+60*1e9+1e9, "1h 1min 1s"),
                         (60*1e9, "1min"), (60*1e9+1e9, "1min 1s")]
        for tc in testCases{
            XCTAssertEqual(formatTime(tc.0), tc.1)
        }
    }

    func testFormatTimeitResult() {
        let loops = 10
        let repititions = 5
        let allRuns: [UInt64] = [10,10,10,10,20]
        let precision = 3
        let result = TimeitResult(loops: loops, repititions: repititions, allRuns: allRuns, precision: precision)
        XCTAssertEqual(result.best, 1, accuracy: 1e-9)
        XCTAssertEqual(result.worst, 2, accuracy: 1e-9)
        XCTAssertEqual(result.average, 1.2, accuracy: 1e-9)
        XCTAssertEqual(result.stdev, 1/sqrt(5), accuracy: 1e-9)
        XCTAssertEqual(result.description, "1.2 ns ± 0.447 ns per loop (mean ± std. dev. of 5 runs, 10 loops each)")
    }

    static var allTests = [
        ("testFormatTimeUnits", testFormatTimeUnits),
        ("testFormatTimePrecision", testFormatTimePrecision),
        ("testFormatTimeOverMinute", testFormatTimeOverMinute),
        ("testFormatTimeitResult", testFormatTimeitResult),
    ]
}
