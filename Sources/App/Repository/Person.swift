//
//  Person.swift
//  swiftodon
//
//  Created by Jonathan Pulfer on 28/09/2024.
//
import Foundation
import MastodonData
import Storage
@preconcurrency import WebAuthn

let serverBaseURL: String = "https://somewhere.com"
let personBaseURL: String = serverBaseURL + "/person/"
let sharedInboxURL: String = serverBaseURL + "/shared/inbox"
let personType: String = "Person"

enum PersonError: Error {
	case idMissing
}

public struct Person: Codable {
	public var id: String
	public var publicURL: String
	public var realURL: String
	public var name: String
	public var sessionId: String?
	public var sessionCreatedAt: Date?
	public var fullName: String
	public var createdAt: Date
	public var bio: String = ""
	public var profilePictureURL: String = ""
	public var headerPictureURL: String = ""
	public var type: String
	public var serverDialect: ServerDialect
	public var following: String
	public var followers: String
	public var inbox: String
	public var outbox: String
	public var featured: String
	public var featuredTags: String
	public var endpoints: PersonEndpoints

	public func toMastodonAccount() -> Account {
		return Account(id: self.id, username: self.name, account: self.name, displayName: self.fullName,
					   createdAt: self.createdAt, note: self.bio, url: self.publicURL, uri: self.realURL,
					   avatar: self.profilePictureURL, header: self.headerPictureURL,
					lastStatusAt: Date())
	}

	public init(name: String, fullName: String) {
		let handle = "@" + name
		let uri = personBaseURL + handle
		self.id = UUID().uuidString
		self.type = personType
		self.name = name
		self.fullName = fullName
		self.publicURL = serverBaseURL + "/" + handle
		self.realURL = uri
		self.createdAt = Date()
		self.serverDialect = .mastodon
		self.following = uri + "/following"
		self.followers = uri + "/followers"
		self.inbox = uri + "/inbox"
		self.outbox = uri + "/outbox"
		self.featured = uri + "/collections/featured"
		self.featuredTags = uri + "/collections/tags"
		self.endpoints = PersonEndpoints(sharedInbox: sharedInboxURL)
	}
	
	public func requireID() throws -> UUID {
		if self.id.isEmpty {
			throw PersonError.idMissing
		}
		return UUID(uuidString: self.id)!
	}
	
	var publicKeyCredentialUserEntity: PublicKeyCredentialUserEntity {
		get throws {
			try .init(id: .init(self.requireID().uuidString.utf8), name: self.name, displayName: self.name)
		}
	}
}

extension Person: Sendable {}

public struct PersonEndpoints: Codable {
	public var sharedInbox: String
}

extension PersonEndpoints: Sendable {}

/// Criteria to pass to the storage get method to select particular
/// records.
public struct PersonCriteria: Sendable {
	
	/// This is the short name used by the person when they created the account.
	///
	/// Example:
	///  - `myAccount`
	public var handle: String?
	
	/// This is the id of the person assigned when they created the account.
	///
	/// Example:
	///  - ``
	public var id: String?
	
	

	public init(handle: String?, id: String?) {
		if let handleSupplied = handle {
			self.handle = handleSupplied
		}
		if let idSupplied = id {
			self.id = idSupplied
		}
	}
}

/// Request parameters to create a new ``PersonModel`` in the datastore.
public struct CreatePerson: Sendable {
	
	/// This is the name the person wants to create on this server.
	///
	/// Example:
	///  - `janeD`
	public let name: String
	
	/// This is the full display name the person wants to create on
	/// this server.
	///
	/// Example:
	///   - `Jane Doe`
	public let fullName: String

	public init(name: String, fullName: String) {
		self.name = name
		self.fullName = fullName
	}
}

public protocol PersonStorage: Sendable {
	associatedtype Identifier: Codable
	associatedtype Person: Sendable
	
	func get(criteria: PersonCriteria) async -> Person?
	func create(from: CreatePerson) async throws -> Person?
}

func DummyPersonModels() -> [Person] {
	return [
		Person(name: "someone", fullName: "Some One")
	]
}

