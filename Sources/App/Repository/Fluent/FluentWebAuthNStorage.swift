//
//  FLuentWebAuthNStorage.swift
//  swiftodon
//
//  Created by Jonathan Pulfer on 23/11/2024.
//
import FluentSQLiteDriver
import Foundation
import HummingbirdAuth
import HummingbirdFluent
@preconcurrency import WebAuthn

/// A ``FluentWebAuthNStorage`` that uses Fluent in a file to store the data.
///
/// This is an example of a storage adapter implementation which abstracts the
/// specific way the datastore stores the data by transforming between the
/// ``WebAuthNModel`` and an internal model.
public struct FluentWebAuthNStorage: WebAuthNStorage {
    let fluent: Fluent

    /// Initialise the Datastore connection using `Fluent`
    ///
    ///  - Parameters:
    ///    - fluent: the pre-initialised Fluent connection
    public init(fluent: Fluent) {
        self.fluent = fluent
    }

    /// Get a ``WebAuthNModel`` from the data store.
    ///
    ///  - Parameters:
    ///    - criteria: A ``WebAuthNCriteria`` that indicates what object to return
    ///
    ///
    public func get(criteria: WebAuthNCriteria) async -> WebAuthNModel? {
        do {
            if let criteriaUuid = UUID(uuidString: criteria.userUuid) {
                if let dbPersonModel = try await FluentPersonModel.query(on: fluent.db()).filter(
                    \FluentPersonModel.$id == criteriaUuid
                ).with(\.$webAuthnCredential).first() {
                    if let cred = dbPersonModel.webAuthnCredential {
                        return cred.toWebAuthNModel()
                    }
                }
            }
        } catch {
            print("error running query: \(error)")
        }
        return nil
    }

    /// Create a new ``WebAuthNModel`` in the datastore
    ///
    ///  - Parameters:
    ///    - from: ``CreateWebAuthN`` holding the credential and user_id to link to
    ///       the ``PersonModel`` for.
    public func create(from: CreateWebAuthN) throws -> WebAuthNModel? {
        let dbModel = FluentWebAuthnCredential(credential: from.publicKey, userId: from.userUuid)
        let _ = dbModel.save(on: fluent.db())
        return dbModel.toWebAuthNModel()
    }
}

final class FluentWebAuthnCredential: Model, @unchecked Sendable {
    static let schema = "webauthn_credential"

    @ID(custom: "id", generatedBy: .user)
    var id: String?

    @Field(key: "public_key")
    var publicKey: EncodedBase64

    @Parent(key: "person_id")
    var fluentPersonModel: FluentPersonModel

    init() {}

    private init(id: String, publicKey: EncodedBase64, userId: UUID) {
        self.id = id
        self.publicKey = publicKey
        $fluentPersonModel.id = userId
    }

    convenience init(credential: Credential, userId: UUID) {
        self.init(
            id: credential.id,
            publicKey: credential.publicKey.base64EncodedString(),
            userId: userId
        )
    }

    public func toWebAuthNModel() -> WebAuthNModel? {
        if let userUuid = fluentPersonModel.id {
            return WebAuthNModel(userUuid: userUuid, publicKey: publicKey)
        }
        return nil
    }
}

public struct CreateFluentWebAuthnCredential: AsyncMigration {
    public init() {}

    public func prepare(on database: Database) async throws {
        try await database.schema("webauthn_credential")
            .field("id", .string, .identifier(auto: false))
            .field("public_key", .string, .required)
            .field("person_id", .uuid, .required, .references("person", "id"))
            .unique(on: "id")
            .create()
    }

    public func revert(on database: Database) async throws {
        try await database.schema("webauthn_credential").delete()
    }
}
