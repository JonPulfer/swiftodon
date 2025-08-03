//
//  FluentStatusStorage.swift
//  swiftodon
//
//  Created by Jonathan Pulfer on 01/01/2025.
//

import FluentKit
import FluentSQLiteDriver
import Foundation
import HummingbirdFluent
import Logging
import Storage

public struct FluentStatusStorage: StatusStorage {

    let fluent: Fluent
    let logger: Logger

    public func get(criteria: StatusCriteria) async -> Status? {

        return nil
    }

    public func create(from status: Status) async throws {
        let dbModel = FluentStatusModel(from: status)
        try await dbModel.save(on: fluent.db())
    }

}

final class FluentStatusModel: Model, @unchecked Sendable {
    static let schema = "status"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "uri")
    var uri: String

    @Field(key: "content")
    var content: String

    @Field(key: "created_at")
    var createdAt: String

    @Field(key: "created_at_seconds_since_epoch")
    var createdAtSecondsSinceEpoch: TimeInterval

    @Field(key: "updated_at")
    var updatedAt: String?

    @Field(key: "in_reply_to_id")
    var inReplyToId: String?

    @Field(key: "reblog_of_id")
    var reblogOfId: String?

    @Field(key: "url")
    var url: String

    @Field(key: "sensitive")
    var sensitive: Bool

    @Field(key: "visibility")
    var visibility: String

    @Field(key: "spoiler_text")
    var spoilerText: String?

    @Field(key: "reply")
    var reply: Bool

    @Field(key: "language")
    var language: String

    @Field(key: "conversation_id")
    var conversationId: String?

    @Field(key: "local")
    var local: Bool

    @Field(key: "account_id")
    var accountId: String?

    @Field(key: "application_id")
    var applicationId: String?

    @Field(key: "in_reply_to_account_id")
    var inReplyToAccountId: String?

    @Field(key: "poll_id")
    var pollId: String?

    @Field(key: "deleted_at")
    var deletedAt: String?

    @Field(key: "edited_at")
    var editedAt: String?

    @Field(key: "trendable")
    var trendable: Bool?

    @Field(key: "ordered_media_attachments")
    var orderedMediaAttachments: [String]

    public init() {}

    public init(from status: Status) {
        self.id = (status.id ?? UUID())
        self.uri = status.uri
        self.content = status.content
        self.createdAt = status.createdAt
        self.createdAtSecondsSinceEpoch = ParseRFCTimestampToUTC(fromString: status.createdAt).timeIntervalSince1970
        self.updatedAt = status.updatedAt
        self.inReplyToId = status.inReplyToId
        self.reblogOfId = status.reblogOfId
        self.url = status.url
        self.sensitive = status.sensitive
        self.visibility = status.visibility
        self.spoilerText = status.spoilerText
        self.reply = status.reply
        self.language = status.language
        self.conversationId = status.conversationId
        self.local = status.local
        self.accountId = status.accountId
        self.applicationId = status.applicationId
        self.inReplyToAccountId = status.inReplyToAccountId
        self.pollId = status.pollId
        self.deletedAt = status.deletedAt
        self.editedAt = status.editedAt
        self.trendable = status.trendable
        self.orderedMediaAttachments = status.orderedMediaAttachments
    }
}

public struct CreateFluentStatus: AsyncMigration {

    public func prepare(on database: Database) async throws {
        try await database.schema("status")
            .id()
            .field("uri", .string)
            .field("content", .string)
            .field("created_at", .string)
            .field("updated_at", .string)
            .field("in_reply_to_id", .string)
            .field("reblog_of_id", .string)
            .field("url", .string)
            .field("sensitive", .bool)
            .field("visibility", .string)
            .field("spoiler_text", .string)
            .field("reply", .string)
            .field("language", .string)
            .field("conversation_id", .string)
            .field("local", .bool)
            .field("account_id", .string)
            .field("application_id", .string)
            .field("in_reply_to_account_id", .string)
            .field("poll_id", .string)
            .field("deleted_at", .string)
            .field("edited_at", .string)
            .field("trendable", .bool)
            .field("ordered_media_attachments", .array)
            .create()
    }

    public func revert(on database: Database) async throws {
        try await database.schema("status").delete()
    }

    public init() {}
}

public func AddStatusMigrations(fluent: Fluent) async {
    await fluent.migrations.add(CreateFluentStatus())
    await fluent.migrations.add(CreateStatusAccountIdIndex())
    await fluent.migrations.add(CreateStatusConversationIdIndex())
    await fluent.migrations.add(CreateStatusInReplyToIdIndex())
    await fluent.migrations.add(AddCreatedAtSecondsSinceEpoch())
}

public struct CreateStatusAccountIdIndex: AsyncMigration {

    public func prepare(on database: Database) async throws {
        try await (database as! SQLDatabase)
            .create(index: "status_account_id_idx")
            .on("status")
            .column("account_id")
            .run()
    }

    public func revert(on database: Database) async throws {
        try await (database as! SQLDatabase)
            .drop(index: "status_account_id_idx")
            .run()
    }
}

public struct CreateStatusConversationIdIndex: AsyncMigration {

    public func prepare(on database: Database) async throws {
        try await (database as! SQLDatabase)
            .create(index: "conversation_id_idx")
            .on("status")
            .column("conversation_id")
            .run()
    }

    public func revert(on database: Database) async throws {
        try await (database as! SQLDatabase)
            .drop(index: "conversation_id_idx")
            .run()
    }
}

public struct CreateStatusInReplyToIdIndex: AsyncMigration {

    public func prepare(on database: Database) async throws {
        try await (database as! SQLDatabase)
            .create(index: "in_reply_to_id_idx")
            .on("status")
            .column("in_reply_to_id")
            .run()
    }

    public func revert(on database: Database) async throws {
        try await (database as! SQLDatabase)
            .drop(index: "in_reply_to_id_idx")
            .run()
    }
}

public struct AddCreatedAtSecondsSinceEpoch: AsyncMigration {

    public func prepare(on database: Database) async throws {
        try await database.schema("status")
            .field("created_at_seconds_since_epoch", .double)
            .update()
    }

    public func revert(on database: Database) async throws {
        try await database.schema("status")
            .deleteField("created_at_seconds_since_epoch")
            .update()
    }
}
