//
//  PersonController.swift
//  swiftodon
//
//  Created by Jonathan Pulfer on 28/09/2024.
//
import Hummingbird
import HummingbirdRouter
import Logging
import MastodonData

struct PersonController: RouterController {
    typealias Context = WebAuthnRequestContext

    let repository: any PersonStorage
    let logger: Logger

    var body: some RouterMiddleware<Context> {

        // Endpoints

        /// GET /api/v1/accounts/:id
        ///
        Get("/:id", handler: get)
    }
}

extension PersonController {
    @Sendable func get(request _: Request, context: some RequestContext) async throws -> MastodonAccount? {
        let id = try context.parameters.require("id", as: String.self)
        if case let personObject as Person = await repository.get(
            criteria: PersonCriteria(handle: id.replacingOccurrences(of: "@", with: ""))
        ) {
            return personObject.toMastodonAccount()
        }
        throw HTTPError(.notFound)
    }
}
