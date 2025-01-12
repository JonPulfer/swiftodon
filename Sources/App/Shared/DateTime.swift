import Foundation

public func RFC3339Timestamp(fromDate: Date) -> String {
    let RFC3339DateFormatter = DateFormatter()
    RFC3339DateFormatter.locale = Locale(identifier: "en_US_POSIX")
    RFC3339DateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
    RFC3339DateFormatter.timeZone = TimeZone(secondsFromGMT: 0)

    return RFC3339DateFormatter.string(from: fromDate)
}

public func ParseRFCTimestampToUTC(fromString: String) -> Date {
    let RFC3339DateFormatter = DateFormatter()
    RFC3339DateFormatter.locale = Locale(identifier: "en_US_POSIX")
    RFC3339DateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
    RFC3339DateFormatter.timeZone = TimeZone(secondsFromGMT: 0)

    if let date = RFC3339DateFormatter.date(from: fromString) {
        return date
    }

    return Date()
}
