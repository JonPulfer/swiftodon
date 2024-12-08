//
//  PersonStorage.swift
//  swiftodon
//
//  Created by Jonathan Pulfer on 17/11/2024.
//

import FluentSQLiteDriver
import Foundation
import HummingbirdFluent
import Storage

/// A ``PersonStorage`` that uses SQLite3 in a file to store the data.
///
/// This is an example of a storage adapter implementation which abstracts the
/// specific way the SQLite3 stores the data by transforming between the
/// ``PersonModel`` and an internal model.
public actor SqlitePersonStorage: PersonStorage {
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
			await self.storage.migrations.add(CreateSQLitePerson())
			do {
				try await self.storage.migrate()
			} catch {
				print(error)
			}
		}
	}
	
	/// Get a ``PersonModel`` from the data store.
	///
	///  - Parameters:
	///    - criteria: A ``PersonCriteria`` that indicates what object to return
	///
	///
	public func get(criteria: PersonCriteria) async -> PersonModel? {
		do {
			let dbModel = try await SQLitePersonModel.query(on: self.storage.db()).filter(\SQLitePersonModel.$name == criteria.handle).first()
			return dbModel?.sqliteModelToPersonModel()
		} catch {
			print("error running query: \(error)")
		}
		return nil
	}

	/// Create a new ``PersonModel`` in the datastore
	///
	///  - Parameters:
	///    - from: ``CreatePerson`` holding the shortId to create the ``PersonModel`` for.
	public func create(from: CreatePerson) throws -> PersonModel? {
		let model = PersonModel(name: from.name, fullName: from.fullName)
		let sqliteModel = SQLitePersonModel(fromPersonModel: model)
		let _ = sqliteModel.save(on: self.storage.db())
		return sqliteModel.sqliteModelToPersonModel()
	}
}

final class SQLitePersonModel: Model, @unchecked Sendable {
	static let schema = "person"
	
	@ID(key: .id)
	var id: UUID?
	
	@Field(key: "name")
	var name: String
	
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
	
	public init(type: String, id: String, serverDialect: String, following: String, followers: String,
	            inbox: String, outbox: String, featured: String, featuredTags: String, endpoints: PersonEndpoints)
	{
		self.type = type
		self.id = UUID(uuidString: id)
		self.serverDialect = serverDialect
		self.following = following
		self.followers = followers
		self.inbox = inbox
		self.outbox = outbox
		self.featured = featured
		self.featuredTags = featuredTags
		self.endpointSharedInbox = endpoints.sharedInbox
	}
	
	public init(fromPersonModel: PersonModel) {
		self.type = fromPersonModel.type
		self.name = fromPersonModel.name
		self.fullName = fromPersonModel.fullName
		self.publicURL = fromPersonModel.publicURL
		self.realURL = fromPersonModel.realURL
		self.profilePictureURL = fromPersonModel.profilePictureURL
		self.headerPictureURL = fromPersonModel.headerPictureURL
		self.bio = fromPersonModel.bio
		self.createdAt = fromPersonModel.createdAt.formatted(.iso8601.locale(Locale(identifier: "en_US_POSIX")))
		self.id = UUID(uuidString: fromPersonModel.id)
		self.serverDialect = fromPersonModel.serverDialect.rawValue
		self.following = fromPersonModel.following
		self.followers = fromPersonModel.followers
		self.inbox = fromPersonModel.inbox
		self.outbox = fromPersonModel.outbox
		self.featured = fromPersonModel.featured
		self.featuredTags = fromPersonModel.featuredTags
		self.endpointSharedInbox = fromPersonModel.endpoints.sharedInbox
	}
	
	func sqliteModelToPersonModel() -> PersonModel {
		var toModel = PersonModel(name: self.name, fullName: self.fullName)
		if let recordId = self.id {
			toModel.id = recordId.uuidString
		}
		toModel.publicURL = self.publicURL
		toModel.realURL = self.realURL
		toModel.profilePictureURL = self.profilePictureURL
		toModel.headerPictureURL = self.headerPictureURL
		toModel.bio = self.bio
		toModel.createdAt = ISO8601DateFormatter().date(from: self.createdAt)!
		toModel.type = self.type
		toModel.serverDialect = ServerDialect(fromString: self.serverDialect)
		toModel.following = self.following
		toModel.followers = self.followers
		toModel.inbox = self.inbox
		toModel.outbox = self.outbox
		toModel.featured = self.featured
		toModel.featuredTags = self.featuredTags
		toModel.endpoints.sharedInbox = self.endpointSharedInbox
		
		return toModel
	}
}

struct CreateSQLitePerson: AsyncMigration {
	// Prepares the database for storing Person models.
	func prepare(on database: Database) async throws {
		try await database.schema("person")
			.id()
			.field("name", .string)
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
	func revert(on database: Database) async throws {
		try await database.schema("person").delete()
	}
}
