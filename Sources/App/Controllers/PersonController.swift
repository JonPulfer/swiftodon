//
//  PersonController.swift
//  swiftodon
//
//  Created by Jonathan Pulfer on 28/09/2024.
//
import Hummingbird
import MastodonData
import PersonStorage
import Storage

struct PersonController<Repository: Storage>: Sendable {
	let repository: Repository

	var endpoints: RouteCollection<AppRequestContext> {
		return RouteCollection(context: AppRequestContext.self)
			.get(":id", use: get)
	}

	@Sendable func get(request: Request, context: some RequestContext) async throws -> Person? {
		let id = try context.parameters.require("id", as: String.self)
		if let personObject = repository.Get(criteria: PersonCriteria(id: "https://somewhere.com/" + id)) {
			switch personObject {
			case let aPerson as PersonModel:
				return aPerson.toPerson()
			default:
				return nil
			}
		}
		return nil
	}
}
