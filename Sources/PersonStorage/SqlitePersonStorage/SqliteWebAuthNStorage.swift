//
//  SqliteWebAuthNStorage.swift
//  swiftodon
//
//  Created by Jonathan Pulfer on 23/11/2024.
//
import FluentSQLiteDriver
import Foundation
import HummingbirdFluent
import HummingbirdAuth
@preconcurrency import WebAuthn

/// A ``SqliteWebAuthNStorage`` that uses SQLite3 in a file to store the data.
///
/// This is an example of a storage adapter implementation which abstracts the
/// specific way the SQLite3 stores the data by transforming between the
/// ``WebAuthNModel`` and an internal model.
public actor SqliteWebAuthNStorage: WebAuthNStorage {
	let storage: Fluent
	
	/// Initialise the SQLite3 connection using `Fluent`
	///
	/// - Parameters:
	///   - migrate: indicate whether to try to migrate the database.
	public init(migrate: Bool = false) async {
		let logger = Logger(label: "swiftodon")
		self.storage = Fluent(logger: logger)
		self.storage.databases.use(.sqlite(.file("person_storage.sqlite")), as: .sqlite)
		
		if migrate {
			await self.storage.migrations.add(CreateSqliteWebAuthnCredential())
			do {
				try await self.storage.migrate()
			} catch {
				print(error)
			}
		}
	}
	
	/// Get a ``WebAuthNModel`` from the data store.
	///
	///  - Parameters:
	///    - criteria: A ``WebAuthNCriteria`` that indicates what object to return
	///
	///
	public func get(criteria: WebAuthNCriteria) async -> WebAuthNModel? {
		do {
			let dbModel = try await SqliteWebAuthnCredential.query(on: self.storage.db()).filter(\SqliteWebAuthnCredential.$userUuid == criteria.userUuid).first()
			return dbModel?.toWebAuthNModel()
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
		let dbModel = SqliteWebAuthnCredential(publicKey: from.publicKey, userId: from.userUuid)
		return dbModel.toWebAuthNModel()
	}
}


final class SqliteWebAuthnCredential: Model, @unchecked Sendable {
	static let schema = "webauthn_credential"

	@ID(custom: "id")
	var id: String?

	@Field(key: "public_key")
	var publicKey: EncodedBase64

	@Field(key: "user_uuid")
	var userUuid: String

	init() {}

	init(id: String = UUID().uuidString, publicKey: EncodedBase64, userId: UUID) {
		self.id = id
		self.publicKey = publicKey
		self.userUuid = userId.uuidString
	}

	convenience init(credential: Credential, userId: UUID) {
		self.init(
			id: credential.id,
			publicKey: credential.publicKey.base64EncodedString(),
			userId: userId
		)
	}
	
	func toWebAuthNModel() -> WebAuthNModel {
		var userId: UUID = UUID()
		do {
			if let userUUID = UUID(uuidString: self.userUuid) {
				userId = userUUID
			} else {
				print("could not convert self.userUuid value \(self.userUuid) to UUID")
			}
		}
		return WebAuthNModel(userUuid: userId, publicKey: self.publicKey)
	}
}

struct CreateSqliteWebAuthnCredential: AsyncMigration {
	func prepare(on database: Database) async throws {
		try await database.schema("webauthn_credential")
			.id()
			.field("public_key", .string, .required)
			.field("user_uuid", .uuid, .required, .references("person", "id"))
			.unique(on: "id")
			.create()
	}
	
	// Optionally reverts the changes made in the prepare method.
	func revert(on database: Database) async throws {
		try await database.schema("webauthn_credential").delete()
	}
}
