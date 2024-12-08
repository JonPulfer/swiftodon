//
//  PersonStorage.swift
//  swiftodon
//
//  Created by Jonathan Pulfer on 28/09/2024.
//
import Storage

public actor FixturePersonStorage: PersonStorage {
	let storage: InMemoryStore = .init()

	public init() {
		for fixture in DummyPersonModels() {
			self.storage.add(model: fixture)
		}
	}

	public func get(criteria: PersonCriteria) -> PersonModel? {
		if let person = self.storage.get(id: criteria.handle) {
			return person
		}
		return nil
	}

	public func create(from: CreatePerson) throws -> PersonModel? {
		let model = PersonModel(name: from.name, fullName: from.fullName)
		self.storage.add(model: model)
		return model
	}
}

final class InMemoryStore {
	var storage: [String: PersonModel] = [:]

	func add(model: PersonModel) {
		self.storage[model.id] = model
	}

	func get(id: String) -> PersonModel? {
		return self.storage[id]
	}
}
