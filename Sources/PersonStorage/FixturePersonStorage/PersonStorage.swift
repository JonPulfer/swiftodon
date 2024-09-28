//
//  PersonStorage.swift
//  swiftodon
//
//  Created by Jonathan Pulfer on 28/09/2024.
//
import Storage

public struct FixturePersonStorage: Storage {
	var storage: Dictionary<String, PersonModel> = [:]

	public init() {
		for fixture in DummyPersonModels() {
			self.storage[fixture.id] = fixture
		}
	}

	public func Get(criteria: Criteria) -> StorageObject? {
		if let person = self.storage[criteria.id] {
			return person
		}
		return nil
	}
}

public struct PersonCriteria: Criteria {
	public var id: String
	
	public init(id: String) {
		self.id = id
	}
}

func DummyPersonModels() -> [PersonModel] {
	return [
		PersonModel(
			id: "https://somewhere.com/@someone",
			type: "Person",
			serverDialect: ServerDialects.Mastodon,
			following: "https://somewhere.com/@someone/following",
			followers: "https://somewhere.com/@someone/followers",
			inbox: "https://somewhere.com/@someone/inbox",
			outbox: "https://somewhere.com/@someone/outbox",
			featured: "https://somewhere.com/@someone/collections/featured",
			featuredTags: "https://somewhere.com/@someone/collections/tags",
			endpoints: PersonEndpoints(sharedInbox: "https://somewhere.com/inbox"))
		]
}
