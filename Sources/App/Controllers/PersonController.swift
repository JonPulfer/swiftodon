//
//  PersonController.swift
//  swiftodon
//
//  Created by Jonathan Pulfer on 28/09/2024.
//
import Hummingbird
import MastodonData
import PersonStorage

struct PersonController<Repository: PersonStorage>: Sendable {
	let repository: Repository
	let controllerPath: String = "https://somewhere.com/person/"

	var endpoints: RouteCollection<AppRequestContext> {
		return RouteCollection(context: AppRequestContext.self)
			.get(":id", use: get)
	}

	@Sendable func get(request: Request, context: some RequestContext) async throws -> Person? {
		let id = try context.parameters.require("id", as: String.self)
		if let personObject = repository.get(criteria: PersonCriteria(id: controllerPath + id)) {
			return personObject.toPerson()
		}
		return nil
	}
}
