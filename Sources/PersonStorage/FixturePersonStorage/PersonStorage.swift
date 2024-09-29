//
//  PersonStorage.swift
//  swiftodon
//
//  Created by Jonathan Pulfer on 28/09/2024.
//
import Storage

public struct FixturePersonStorage: PersonStorage {
	var storage: Dictionary<String, PersonModel> = [:]

	public init() {
		for fixture in DummyPersonModels() {
			self.storage[fixture.id] = fixture
		}
	}

	public func get(criteria: PersonCriteria) -> PersonModel? {
		if let person = self.storage[criteria.id] {
			return person
		}
		return nil
	}
}

public struct PersonCriteria {
	public var id: String
	
	public init(id: String) {
		self.id = id
	}
}

public protocol PersonStorage: Sendable {
	func get(criteria: PersonCriteria) -> PersonModel?
}

func DummyPersonModels() -> [PersonModel] {
	return [
		PersonModel(
			id: "https://somewhere.com/person/@someone",
			type: "Person",
			serverDialect: ServerDialects.Mastodon,
			following: "https://somewhere.com/person/@someone/following",
			followers: "https://somewhere.com/person/@someone/followers",
			inbox: "https://somewhere.com/person/@someone",
			outbox: "https://somewhere.com/person/@someone/outbox",
			featured: "https://somewhere.com/person/@someone/collections/featured",
			featuredTags: "https://somewhere.com/person/@someone/collections/tags",
			endpoints: PersonEndpoints(sharedInbox: "https://somewhere.com/shared/inbox"))
		]
}
