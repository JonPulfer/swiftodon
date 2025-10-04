//
//  FluentTimelineStorage.swift
//
//
//  Created by Jonathan Pulfer on 04/08/2025.
//

import FluentKit
import FluentSQLiteDriver
import Foundation
import HummingbirdFluent
import Logging
import Storage

public struct FluentTimelineStorage: TimelineStorage {

    let fluent: Fluent
    let logger: Logger

    public func get(criteria: TimelineCriteria) async -> Timeline? {
        return nil
    }

    public func create(from timeline: Timeline) async throws {

    }

    public func addItem(to timeline: Timeline, item: TimelineItem) async throws {

    }
}

final class FluentTimelineItemModel: Model, @unchecked Sendable {
    static let schema = "timeline_item"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "userId")
    var userId: String

    @Field(key: "statusId")
    var statusId: String

    @Field(key: "createdAtSecondsSinceEpoch")
    var createdAtSecondsSinceEpoch: TimeInterval
}

public struct CreateFluentTimelineStatusItem: AsyncMigration {

    public func prepare(on database: Database) async throws {
        try await database.schema(FluentTimelineItemModel.schema)
            .id()
            .field("userId", .string)
            .field("statusId", .string)
            .field("createdAtSecondsSinceEpoch", .int64)
            .create()
    }

    public func revert(on database: Database) async throws {
        try await database.schema(FluentTimelineItemModel.schema).delete()
    }
}

public func AddTimelineItemMigrations(fluent: Fluent) async {
    await fluent.migrations.add(CreateFluentTimelineStatusItem())
}
