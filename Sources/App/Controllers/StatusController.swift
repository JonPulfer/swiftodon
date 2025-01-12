//
//  StatusContoller.swift
//  swiftodon
//
//  Created by Jonathan Pulfer on 10/01/2025.
//
import Hummingbird
import HummingbirdAuth
import HummingbirdRouter

struct StatusController: RouterController {
    typealias Context = WebAuthnRequestContext

    let repository: StatusStorage

    let webAuthnSessionAuthenticator: SessionAuthenticator<Context, FluentPersonStorage>

    var body: some RouterMiddleware<Context> {
        // Session middleware to control access to all endpoints in this controller
        webAuthnSessionAuthenticator
        RedirectMiddleware(to: "/login.html")

        // Endpoints

    }
}
