//
//  StatusContoller.swift
//  swiftodon
//
//  Created by Jonathan Pulfer on 10/01/2025.
//
import Hummingbird
import HummingbirdFluent
import HummingbirdRouter
import Logging
import MastodonData

struct StatusController: RouterController {
    typealias Context = WebAuthnRequestContext

    let repository: StatusStorage
    let fluent: Fluent
    let logger: Logger

    var body: some RouterMiddleware<Context> {

        // Endpoints

        /// POST /api/v1/statuses
        /// Create a new status, returns the created status
        Post("/", handler: create)

        // GET /api/v1/statuses/:id
        // Returns an individual status

    }
}

extension StatusController {
    @Sendable func create(request: Request, context: some RequestContext) async throws -> MastodonStatus? {
        let statusReceived = try await request.decode(as: MastodonStatus.self, context: context)
        let dbModel = FluentStatusModel(from: Status(fromMastodonStatus: statusReceived))
        try await dbModel.save(on: fluent.db())
        return nil
    }
}
