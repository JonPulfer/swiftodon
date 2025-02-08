//
//  TimelineController.swift
//  swiftodon
//
//  Created by Jonathan Pulfer on 07/02/2025.
//
import Foundation
import Hummingbird
import HummingbirdFluent
import HummingbirdRouter
import Logging
import MastodonData

struct TimelineController: RouterController {
    typealias Context = WebAuthnRequestContext

    let fluent: Fluent
    let logger: Logger

    var body: some RouterMiddleware<Context> {

        // Endpoints

        /// GET /api/v1/timelines/home
        /// Returns a timeline of statuses for the authenticated user.
        Get("/home", handler: home)

        /// GET /api/v1/timelines/public
        /// Return a timeline of statuses of all statuses received by this server.
        Get("/public", handler: publicStatuses)

        /// GET /api/v1/timelines/tag
        /// Return a timeline for the statuses for a given hashtag.
        Get("/tag", handler: tagStatuses)

        /// GET /api/v1/timelines/list
        /// Return a timeline for the statuses of a given list.
        Get("/list", handler: listStatuses)
    }

    @Sendable func home(request: Request, context: some RequestContext) async throws -> [MastodonStatus] {

        return []
    }

    @Sendable func publicStatuses(request: Request, context: some RequestContext) async throws -> [MastodonStatus] {

        return []
    }

    @Sendable func tagStatuses(request: Request, context: some RequestContext) async throws -> [MastodonStatus] {

        return []
    }

    @Sendable func listStatuses(request: Request, context: some RequestContext) async throws -> [MastodonStatus] {

        return []
    }
}
