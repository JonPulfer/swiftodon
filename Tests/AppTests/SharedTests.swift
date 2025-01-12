import Foundation
import Testing

@testable import App

@Suite struct DateTimeTests {
    @Test func testRFC3339Timestamp() async throws {
        let testDate = Date(timeIntervalSince1970: 1736586339.461763)
        let timestamp = RFC3339Timestamp(fromDate: testDate)
        #expect(timestamp == "2025-01-11T09:05:39Z")
    }
}
