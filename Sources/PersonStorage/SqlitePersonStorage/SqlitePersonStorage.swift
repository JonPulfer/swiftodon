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

public actor SqlitePersonStorage: PersonStorage {
	let storage: Fluent
	
	public init(migrate: Bool = false) async {
		let logger = Logger(label: "swiftodon")
		self.storage = Fluent(logger: logger)
		self.storage.databases.use(.sqlite(.file("person_storage.sqlite")), as: .sqlite)
		// add migrations
		await self.storage.migrations.add(CreateSQLitePerson())
		// migrate
		if migrate {
			do {
				try await self.storage.migrate()
			} catch {
				print(error)
			}
		}
	}
	
	public func get(criteria: PersonCriteria) async -> PersonModel? {
		do {
			let dbModel = try await SQLitePersonModel.query(on: self.storage.db()).filter(\SQLitePersonModel.$personId == criteria.id).first()
			return dbModel?.sqliteModelToPersonModel()
		} catch {
			print("error running query: \(error)")
		}
		return nil
	}

	public func create(from: CreatePerson) throws -> PersonModel? {
		let model = PersonModel(fromShortId: from.id)
		let sqliteModel = SQLitePersonModel(fromPersonModel: model)
		let _ = sqliteModel.save(on: self.storage.db())
		return sqliteModel.sqliteModelToPersonModel()
	}
}

final class SQLitePersonModel: Model, @unchecked Sendable {
	static let schema = "person"
	
	@ID(key: .id)
	var id: UUID?
	
	@Field(key: "person_id")
	var personId: String
	
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
	
	public init(type: String, personId: String, serverDialect: String, following: String, followers: String,
	            inbox: String, outbox: String, featured: String, featuredTags: String, endpoints: PersonEndpoints)
	{
		self.type = type
		self.personId = personId
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
		self.personId = fromPersonModel.id
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
		var toModel = PersonModel(fromShortId: self.personId)
		toModel.type = self.type
		toModel.id = self.personId
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
			.field("person_id", .string)
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
