//
//  StatusContoller.swift
//  swiftodon
//
//  Created by Jonathan Pulfer on 10/01/2025.
//
import Hummingbird
import HummingbirdRouter
import Logging
import MastodonData

struct StatusController: RouterController {
    typealias Context = WebAuthnRequestContext

    let repository: StatusStorage
    let logger: Logger

    var body: some RouterMiddleware<Context> {

        // Endpoints

        /// POST /api/v1/statuses
        /// Create a new status, returns the created status
        Post("/", handler: create)

        // GET /api/v1/statuses/:id
        // Returns an individual status

    }

    @Sendable func create(request: Request, context: some RequestContext) async throws -> MastodonStatus? {
        let statusReceived = try await request.decode(as: MastodonStatus.self, context: context)
        try await repository.create(from: Status(fromMastodonStatus: statusReceived))
        return nil
    }
}
