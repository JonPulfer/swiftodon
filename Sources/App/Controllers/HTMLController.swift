//
//  HTMLController.swift
//  swiftodon
//
//  Created by Jonathan Pulfer on 27/12/2024.
//

import Hummingbird
import HummingbirdAuth
import HummingbirdFluent
import HummingbirdRouter
import Mustache

/// Redirects to login page if no user has been authenticated
struct RedirectMiddleware<Context: AuthRequestContext>: RouterMiddleware {
    let to: String
    func handle(
        _ request: Request,
        context: Context,
        next: (Request, Context) async throws -> Response
    ) async throws -> Response {
        guard context.identity != nil else {
            // if not authenticated then redirect to login page
            return .redirect(to: "\(to)?from=\(request.uri)", type: .found)
        }
        return try await next(request, context)
    }
}

/// Serves HTML pages
struct HTMLController: RouterController {
    typealias Context = WebAuthnRequestContext

    let homeTemplate: MustacheTemplate
    let fluent: Fluent
    let webAuthnSessionAuthenticator: SessionAuthenticator<Context, FluentPersonStorage>

    init(
        mustacheLibrary: MustacheLibrary,
        fluent: Fluent,
        webAuthnSessionAuthenticator: SessionAuthenticator<Context, FluentPersonStorage>
    ) {
        // get the mustache templates from the library
        guard let homeTemplate = mustacheLibrary.getTemplate(named: "home")
        else {
            preconditionFailure("Failed to load mustache templates")
        }
        self.homeTemplate = homeTemplate
        self.fluent = fluent
        self.webAuthnSessionAuthenticator = webAuthnSessionAuthenticator
    }

    // return Route for home page
    var body: some RouterMiddleware<Context> {
        Get("/") {
            webAuthnSessionAuthenticator
            RedirectMiddleware(to: "/login.html")
            home
        }
    }

    /// Home page listing todos and with add todo UI
    @Sendable func home(request _: Request, context: Context) async throws -> HTML {
        // get user
        let user = try context.requireIdentity()
        // Render home template and return as HTML
        let object: [String: Any] = [
            "name": user.name
        ]
        let html = homeTemplate.render(object)
        return HTML(html: html)
    }
}
