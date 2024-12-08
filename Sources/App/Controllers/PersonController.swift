//
//  PersonController.swift
//  swiftodon
//
//  Created by Jonathan Pulfer on 28/09/2024.
//
import Hummingbird
import MastodonData
import PersonStorage

struct PersonController<Repository: PersonStorage> {
	let repository: Repository
	let controllerPath: String = "https://somewhere.com/person/"

	var endpoints: RouteCollection<AppRequestContext> {
		return RouteCollection(context: AppRequestContext.self)
			.get(":id", use: get)
			.post(use: create)
	}

	@Sendable func get(request: Request, context: some RequestContext) async throws -> Account? {
		let id = try context.parameters.require("id", as: String.self)
		if let personObject = await repository.get(criteria: PersonCriteria(handle: id.replacingOccurrences(of: "@", with: ""))) {
			return personObject.toMastodonAccount()
		}
		throw HTTPError(.notFound)
	}

	struct CreatePersonRequest: Decodable {
		let handle: String
		let fullName: String
	}

	@Sendable func create(request: Request, context: some RequestContext) async throws -> EditedResponse<Account?> {
		let createRequest = try await request.decode(as: CreatePersonRequest.self, context: context)
		if let createdModel = try await repository.create(from: CreatePerson(name: createRequest.handle, fullName: createRequest.fullName)) {
			return EditedResponse(status: .created, response: createdModel.toMastodonAccount())
		}
		return EditedResponse(status: .badRequest, response: nil)
	}
}
