//
//  Timeline.swift
//
//
//  Created by Jonathan Pulfer on 03/08/2025.
//

import Foundation

public struct Timeline {
    var accountId: String
    var items: [TimelineItem]
}

public struct PublicTimeline {
    var items: [TimelineItem]
}

public struct TimelineItem: Codable {
    var accountId: String
    var statusId: UUID
    var isPublic: Bool
    var createdAtSecondsSinceEpoch: TimeInterval

    init(
        accountId: String,
        statusId: UUID,
        isPublic: Bool = false,
        statusCreatedAt: String = RFC3339Timestamp(fromDate: Date())
    ) {
        self.accountId = accountId
        self.statusId = statusId
        self.isPublic = isPublic
        self.createdAtSecondsSinceEpoch = ParseRFCTimestampToUTC(fromString: statusCreatedAt).timeIntervalSince1970
    }
}
