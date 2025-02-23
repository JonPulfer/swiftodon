//
//  WellKnownController.swift
//  swiftodon
//
//  Created by Jonathan Pulfer on 23/02/2025.
//

import Foundation
import Hummingbird
import HummingbirdRouter
import Logging
import MastodonData

struct WellKnownController: RouterController {
    typealias Context = WebAuthnRequestContext

    var body: some RouterMiddleware<Context> {

        Get(".webfinger", handler: webfinger)
    }

    @Sendable func webfinger(request: Request, context: some RequestContext) async throws -> WebFinger? {
        let providedHostname = ProcessInfo.processInfo.environment["SWIFTODON_HOSTNAME"]
        let hostname = (providedHostname ?? "http://localhost:8080")

        if let resourceQueryValue = request.uri.queryParameters["resource"] {
            if !resourceQueryValue.contains("acct:") {
                return nil
            }
            return try WebFinger(acctValue: String(resourceQueryValue), hostname: hostname)
        }
        return nil
    }
}
