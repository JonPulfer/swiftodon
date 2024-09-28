//
//  PersonModel.swift
//  swiftodon
//
//  Created by Jonathan Pulfer on 28/09/2024.
//
import Foundation
import MastodonData
import Storage

public struct PersonModel: StorageObject, Codable {
	public var id: String
	public var type: String
	public var serverDialect: ServerDialects
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
}

extension PersonModel: Sendable {}

public struct PersonEndpoints: Codable {
	var sharedInbox: String
}

extension PersonEndpoints: Sendable {}
