//
//  FluentPersonStorage.swift
//  swiftodon
//
//  Created by Jonathan Pulfer on 17/11/2024.
//

import FluentKit
import FluentSQLiteDriver
import Foundation
import HummingbirdAuth
import HummingbirdFluent
import Storage

/// A ``PersonStorage`` that uses Fluent to store the data.
///
/// This is an example of a storage adapter implementation which abstracts the
/// specific way Fluent stores the data by transforming between the
/// ``Person`` and an internal model.
public struct FluentPersonStorage: PersonStorage, UserSessionRepository {
    public func getUser(
        from session: WebAuthnSession,
        context _: HummingbirdAuth.UserRepositoryContext
    ) async throws -> Person? {
        guard case let .authenticated(userId) = session else { return nil }
        return await get(criteria: PersonCriteria(handle: nil, id: userId.uuidString))
    }

    public func getUser(from id: String, context _: HummingbirdAuth.UserRepositoryContext) async throws -> Person? {
        await get(criteria: PersonCriteria(handle: nil, id: id))
    }

    public typealias Identifier = WebAuthnSession

    public typealias User = Person

    let fluent: Fluent

    /// Get a ``Person`` from the data store.
    ///
    ///  - Parameters:
    ///    - criteria: A ``PersonCriteria`` that indicates what object to return
    ///
    ///
    public func get(criteria: PersonCriteria) async -> Person? {
        do {
            if let handleSupplied = criteria.handle {
                if let dbModel = try await FluentPersonModel.query(on: fluent.db()).filter(
                    \FluentPersonModel.$name == handleSupplied
                ).first() {
                    return dbModel.fluentModelToPersonModel()
                }
            }
            if let idSupplied = criteria.id {
                if let idUuid = UUID(uuidString: idSupplied) {
                    if let dbModel = try await FluentPersonModel.query(on: fluent.db()).filter(
                        \FluentPersonModel.$id == idUuid
                    ).first() {
                        return dbModel.fluentModelToPersonModel()
                    }
                }
            }
        } catch {
            print("error running query: \(error)")
        }
        return nil
    }

    /// Create a new ``PersonModel`` in the datastore
    ///
    ///  - Parameters:
    ///    - from: ``CreatePerson`` holding the shortId to create the ``Person`` for.
    public func create(from: CreatePerson) throws -> Person? {
        let model = Person(name: from.name, fullName: from.fullName)
        let sqliteModel = FluentPersonModel(fromPersonModel: model)
        let _ = sqliteModel.save(on: fluent.db())
        return sqliteModel.fluentModelToPersonModel()
    }

    public init(fluent: Fluent) {
        self.fluent = fluent
    }
}

extension String: Sendable {}

final class FluentPersonModel: Model, @unchecked Sendable {
    static let schema = "person"

    @ID(key: .id)
    var id: UUID?

    @OptionalChild(for: \.$fluentPersonModel)
    var webAuthnCredential: FluentWebAuthnCredential?

    @Field(key: "name")
    var name: String

    @Field(key: "session_id")
    var sessionId: String?

    @Field(key: "session_created_at")
    var sessionCreatedAt: String?

    @Field(key: "full_name")
    var fullName: String

    @Field(key: "public_url")
    var publicURL: String

    @Field(key: "real_url")
    var realURL: String

    @Field(key: "created_at")
    var createdAt: String

    @Field(key: "bio")
    var bio: String

    @Field(key: "profile_picture_url")
    var profilePictureURL: String

    @Field(key: "header_picture_url")
    var headerPictureURL: String

    @Field(key: "type")
    var type: String

    @Field(key: "server_dialect")
    var serverDialect: String

    @Field(key: "following")
    var following: String

    @Field(key: "followers")
    var followers: String

    @Field(key: "inbox")
    var inbox: String

    @Field(key: "outbox")
    var outbox: String

    @Field(key: "featured")
    var featured: String

    @Field(key: "featured_tags")
    var featuredTags: String

    @Field(key: "endpoints_shared_inbox")
    var endpointSharedInbox: String

    public init() {}

    public init(
        type: String,
        id: String,
        serverDialect: String,
        following: String,
        followers: String,
        inbox: String,
        outbox: String,
        featured: String,
        featuredTags: String,
        endpoints: PersonEndpoints
    ) {
        self.type = type
        self.id = UUID(uuidString: id)
        self.serverDialect = serverDialect
        self.following = following
        self.followers = followers
        self.inbox = inbox
        self.outbox = outbox
        self.featured = featured
        self.featuredTags = featuredTags
        endpointSharedInbox = endpoints.sharedInbox
    }

    public init(fromPersonModel: Person) {
        type = fromPersonModel.type
        name = fromPersonModel.name
        sessionId = fromPersonModel.sessionId
        if let sessionCreatedAt = fromPersonModel.sessionCreatedAt {
            self.sessionCreatedAt = RFC3339Timestamp(fromDate: sessionCreatedAt)
        }
        fullName = fromPersonModel.fullName
        publicURL = fromPersonModel.publicURL
        realURL = fromPersonModel.realURL
        profilePictureURL = fromPersonModel.profilePictureURL
        headerPictureURL = fromPersonModel.headerPictureURL
        bio = fromPersonModel.bio
        createdAt = RFC3339Timestamp(fromDate: fromPersonModel.createdAt)
        id = UUID(uuidString: fromPersonModel.id)
        serverDialect = fromPersonModel.serverDialect.rawValue
        following = fromPersonModel.following
        followers = fromPersonModel.followers
        inbox = fromPersonModel.inbox
        outbox = fromPersonModel.outbox
        featured = fromPersonModel.featured
        featuredTags = fromPersonModel.featuredTags
        endpointSharedInbox = fromPersonModel.endpoints.sharedInbox
    }

    func fluentModelToPersonModel() -> Person {
        var toModel = Person(name: name, fullName: fullName)
        if let recordId = id {
            toModel.id = recordId.uuidString
        }
        if let sessionId {
            toModel.sessionId = sessionId
        }
        // if let sessionCreatedAt {
        //     if !sessionCreatedAt.isEmpty {
        //         toModel.sessionCreatedAt = ISO8601DateFormatter().date(from: sessionCreatedAt)!
        //     }
        // }
        toModel.publicURL = publicURL
        toModel.realURL = realURL
        toModel.profilePictureURL = profilePictureURL
        toModel.headerPictureURL = headerPictureURL
        toModel.bio = bio
        toModel.createdAt = ParseRFCTimestampToUTC(fromString: createdAt)
        toModel.type = type
        toModel.serverDialect = ServerDialect(fromString: serverDialect)
        toModel.following = following
        toModel.followers = followers
        toModel.inbox = inbox
        toModel.outbox = outbox
        toModel.featured = featured
        toModel.featuredTags = featuredTags
        toModel.endpoints.sharedInbox = endpointSharedInbox

        return toModel
    }
}

public func AddPersonMigrations(fluent: Fluent) async {
    await fluent.migrations.add(CreateFluentPerson())
    await fluent.migrations.add(CreatePersonNameIndex())
}

public struct CreateFluentPerson: AsyncMigration {
    // Prepares the database for storing Person models.
    public func prepare(on database: Database) async throws {
        try await database.schema("person")
            .id()
            .field("name", .string, .required)
            .unique(on: "name")
            .field("session_id", .string)
            .field("session_created_at", .string)
            .field("full_name", .string)
            .field("public_url", .string)
            .field("real_url", .string)
            .field("created_at", .string)
            .field("bio", .string)
            .field("profile_picture_url", .string)
            .field("header_picture_url", .string)
            .field("type", .string)
            .field("server_dialect", .string)
            .field("following", .string)
            .field("followers", .string)
            .field("inbox", .string)
            .field("outbox", .string)
            .field("featured", .string)
            .field("featured_tags", .string)
            .field("endpoints_shared_inbox", .string)
            .create()
    }

    // Optionally reverts the changes made in the prepare method.
    public func revert(on database: Database) async throws {
        try await database.schema("person").delete()
    }

    public init() {}
}

public struct CreatePersonNameIndex: AsyncMigration {

    public func prepare(on database: Database) async throws {
        try await (database as! SQLDatabase)
            .create(index: "name_idx")
            .on("person")
            .column("name")
            .run()
    }

    public func revert(on database: Database) async throws {
        try await (database as! SQLDatabase)
            .drop(index: "name_idx")
            .run()
    }
}
