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
		if let person = self.storage.get(id: criteria.id) {
			return person
		}
		return nil
	}

	public func create(from: CreatePerson) throws -> PersonModel? {
		let model = PersonModel(fromShortId: from.id)
		self.storage.add(model: model)
		return model
	}
}

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

final class InMemoryStore {
	var storage: [String: PersonModel] = [:]

	func add(model: PersonModel) {
		self.storage[model.id] = model
	}

	func get(id: String) -> PersonModel? {
		return self.storage[id]
	}
}
