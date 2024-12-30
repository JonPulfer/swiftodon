//
//  PersonController.swift
//  swiftodon
//
//  Created by Jonathan Pulfer on 28/09/2024.
//
import Hummingbird
import HummingbirdAuth
import HummingbirdRouter
import MastodonData

struct PersonController: RouterController {
    typealias Context = WebAuthnRequestContext

    let repository: any PersonStorage

    let controllerPath: String = "https://somewhere.com/person/"
	
	let webAuthnSessionAuthenticator: SessionAuthenticator<Context, FluentPersonStorage>

    var body: some RouterMiddleware<Context> {
		Get("/:id") {
			self.webAuthnSessionAuthenticator
			RedirectMiddleware(to: "/login.html")
			self.get
		}
    }

    @Sendable func get(request _: Request, context: some RequestContext) async throws -> Account? {
        let id = try context.parameters.require("id", as: String.self)
        if case let personObject as Person = await repository.get(criteria: PersonCriteria(handle: id.replacingOccurrences(of: "@", with: ""), id: nil)) {
            return personObject.toMastodonAccount()
        }
        throw HTTPError(.notFound)
    }
}
