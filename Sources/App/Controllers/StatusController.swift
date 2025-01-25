//
//  StatusContoller.swift
//  swiftodon
//
//  Created by Jonathan Pulfer on 10/01/2025.
//
import Hummingbird
import HummingbirdAuth
import HummingbirdRouter
import MastodonData

struct StatusController: RouterController {
    typealias Context = WebAuthnRequestContext

    let repository: StatusStorage

    let webAuthnSessionAuthenticator: SessionAuthenticator<Context, FluentPersonStorage>

    var body: some RouterMiddleware<Context> {
        // Session middleware to control access to all endpoints in this controller
        webAuthnSessionAuthenticator
        RedirectMiddleware(to: "/login.html")

        // Endpoints

        // POST /api/v1/statuses
        // Create a new status, returns the created status

        // GET /api/v1/statuses/:id
        // Returns an individual status

    }
}

extension StatusController {
    @Sendable func create(request _: Request, context: some RequestContext) async throws -> MastodonStatus? {
        return nil
    }
}
