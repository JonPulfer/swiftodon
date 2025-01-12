import Foundation
import Testing

@testable import App

@Suite struct DateTimeRFC3339TimestampTests {
    @Test func testRFC3339Timestamp() async throws {
        let testDate = Date(timeIntervalSince1970: 1736586339.461763)
        let timestamp = RFC3339Timestamp(fromDate: testDate)
        #expect(timestamp == "2025-01-11T09:05:39Z")
    }
}

@Suite struct DateTimeParseRFCTimestampToUTC {
    @Test func middayMonday6thJune2024BST() async throws {
        let dateComponents = DateComponents(
            calendar: Calendar.current,
            timeZone: TimeZone.init(secondsFromGMT: 3600),
            year: 2024,
            month: 6,
            day: 6,
            hour: 12,
            minute: 0,
            second: 0,
            nanosecond: 0
        )
        let expectedDate = dateComponents.date!

        let timestampToParse = "2024-06-06T12:00:00+01:00"
        let parsedDate = ParseRFCTimestampToUTC(fromString: timestampToParse)

        #expect(parsedDate == expectedDate)
    }
}
