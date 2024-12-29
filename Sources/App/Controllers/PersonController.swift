//
//  PersonController.swift
//  swiftodon
//
//  Created by Jonathan Pulfer on 28/09/2024.
//
import Hummingbird
import HummingbirdRouter
import MastodonData

struct PersonController: RouterController {
	typealias Context = WebAuthnRequestContext
	
	let repository: any PersonStorage
	
	let controllerPath: String = "https://somewhere.com/person/"

	var endpoints: RouteCollection<WebAuthnRequestContext> {
		return RouteCollection(context: WebAuthnRequestContext.self)
			.get(":id", use: get)
			.post(use: create)
	}
	
	var body: some RouterMiddleware<Context> {
		Post(handler: self.create)
		Get(handler: self.get)
	}

	@Sendable func get(request: Request, context: some RequestContext) async throws -> Account? {
		let id = try context.parameters.require("id", as: String.self)
		if case let personObject as Person = await repository.get(criteria: PersonCriteria(handle: id.replacingOccurrences(of: "@", with: ""), id: nil)) {
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
		if case let createdModel as Person = try await repository.create(from: CreatePerson(name: createRequest.handle, fullName: createRequest.fullName)) {
			return EditedResponse(status: .created, response: createdModel.toMastodonAccount())
		}
		return EditedResponse(status: .badRequest, response: nil)
	}
}
