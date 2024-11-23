//
//  PersonModel.swift
//  swiftodon
//
//  Created by Jonathan Pulfer on 28/09/2024.
//
import Foundation
import MastodonData
import Storage

let personBaseURL: String = "https://somewhere.com/person/"
let sharedInboxURL: String = "https://somewhere.com/shared/inbox"
let personType: String = "Person"

public struct PersonModel: Codable {
	public var id: String
	public var type: String
	public var serverDialect: ServerDialect
	var following: String
	var followers: String
	var inbox: String
	var outbox: String
	var featured: String
	var featuredTags: String
	var endpoints: PersonEndpoints

	public func toPerson() -> Person {
		return Person(id: self.id, type: self.type, following: self.following, followers: self.followers,
		              inbox: self.inbox, outbox: self.outbox, featured: self.featured, featuredTags: self.featuredTags,
		              sharedInbox: self.endpoints.sharedInbox)
	}

	public init(fromShortId: String) {
		let personId = personBaseURL + fromShortId
		self.id = personId
		self.type = personType
		self.serverDialect = .mastodon
		self.following = personId + "/following"
		self.followers = personId + "/followers"
		self.inbox = personId + "/inbox"
		self.outbox = personId + "/outbox"
		self.featured = personId + "/collections/featured"
		self.featuredTags = personId + "/collections/tags"
		self.endpoints = PersonEndpoints(sharedInbox: sharedInboxURL)
	}
}

extension PersonModel: Sendable {}

public struct PersonEndpoints: Codable {
	var sharedInbox: String
}

extension PersonEndpoints: Sendable {}

public struct PersonCriteria: Sendable {
	public var id: String

	public init(id: String) {
		self.id = id
	}
}

public struct CreatePerson: Sendable {
	public let id: String

	public init(id: String) {
		self.id = id
	}
}

public protocol PersonStorage: Sendable {
	func get(criteria: PersonCriteria) async -> PersonModel?
	func create(from: CreatePerson) async throws -> PersonModel?
}

func DummyPersonModels() -> [PersonModel] {
	return [
		PersonModel(fromShortId: "@someone")
	]
}

