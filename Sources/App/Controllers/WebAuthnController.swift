//
//  WebAuthnController.swift
//  swiftodon
//
//  Created by Jonathan Pulfer on 27/12/2024.
//

import FluentKit
import Foundation
import Hummingbird
import HummingbirdAuth
import HummingbirdFluent
import HummingbirdRouter
import JWTKit
@preconcurrency import WebAuthn

struct WebAuthnController: RouterController, Sendable {
    typealias Context = WebAuthnRequestContext

    let webauthn: WebAuthnManager
    let fluent: Fluent
    let webAuthnSessionAuthenticator: SessionAuthenticator<Context, FluentPersonStorage>
    let jwtKeyCollection: JWTKeyCollection
    let logger: Logger

    // return RouteGroup with user login endpoints
    var body: some RouterMiddleware<Context> {
        RouteGroup("user") {
            Post("signup", handler: signup)
            Get("login", handler: beginAuthentication)
            Post("login", handler: finishAuthentication)
            Get("logout") {
                webAuthnSessionAuthenticator
                logout
            }
            RouteGroup("register") {
                Post("start", handler: beginRegistration)
                Post("finish", handler: finishRegistration)
            }
        }
        RouteGroup("token") {
            webAuthnSessionAuthenticator
            JWTAuth(jwtKeyCollection: jwtKeyCollection, logger: logger, fluent: fluent)
            RedirectMiddleware(to: "/login.html")
            Get("refresh", handler: getToken)
        }
    }

    struct SignUpInput: Decodable {
        let username: String
    }

    @Sendable func signup(request: Request, context: Context) async throws -> Response {
        let input = try await request.decode(as: SignUpInput.self, context: context)
        guard
            try await FluentPersonModel.query(on: fluent.db())
                .filter(\.$name == input.username)
                .first() == nil
        else {
            throw HTTPError(.conflict, message: "Username already taken.")
        }
        let user = Person(name: input.username, fullName: "")
        let dbModel = FluentPersonModel(fromPersonModel: user)
        try await dbModel.save(on: fluent.db())
        try context.sessions.setSession(.signedUp(userId: user.requireID()), expiresIn: .seconds(600))
        return .redirect(to: "/api/user/register/start", type: .temporary)
    }

    /// Begin registering a User
    @Sendable func beginRegistration(
        request _: Request,
        context: Context
    ) async throws -> PublicKeyCredentialCreationOptions {
        let registrationSession = try await context.sessions.session?.session(fluent: fluent)
        guard case let .signedUp(user) = registrationSession else { throw HTTPError(.unauthorized) }
        let options = try webauthn.beginRegistration(user: user.publicKeyCredentialUserEntity)
        let session = try WebAuthnSession(
            from: .registering(
                user: user,
                challenge: options.challenge
            )
        )
        context.sessions.setSession(session, expiresIn: .seconds(600))
        return options
    }

    /// Finish registering a user
    @Sendable func finishRegistration(request: Request, context: Context) async throws -> HTTPResponse.Status {
        let registrationSession = try await context.sessions.session?.session(fluent: fluent)
        let input = try await request.decode(as: RegistrationCredential.self, context: context)
        guard case let .registering(user, challenge) = registrationSession else { throw HTTPError(.unauthorized) }
        do {
            let credential = try await webauthn.finishRegistration(
                challenge: challenge,
                credentialCreationData: input,
                // this is likely to be removed soon
                confirmCredentialIDNotRegisteredYet: { id in
                    try await FluentWebAuthnCredential.query(on: fluent.db()).filter(\.$id == id).first() == nil
                }
            )
            try await FluentWebAuthnCredential(credential: credential, userId: user.requireID()).save(on: fluent.db())
        } catch {
            context.logger.error("\(error)")
            throw HTTPError(.unauthorized)
        }
        context.sessions.clearSession()
        context.logger.info("Registration success, id: \(input.id)")

        return .ok
    }

    /// Begin Authenticating a user
    @Sendable func beginAuthentication(_: Request, context: Context) async throws -> PublicKeyCredentialRequestOptions {
        let options = try webauthn.beginAuthentication(timeout: 60000)
        let session = try WebAuthnSession(
            from: .authenticating(
                challenge: options.challenge
            )
        )
        context.sessions.setSession(session, expiresIn: .seconds(600))
        return options
    }

    /// End Authenticating a user
    @Sendable func finishAuthentication(request: Request, context: Context) async throws -> HTTPResponse.Status {
        let authenticationSession = try await context.sessions.session?.session(fluent: fluent)
        let input = try await request.decode(as: AuthenticationCredential.self, context: context)
        guard case let .authenticating(challenge) = authenticationSession else { throw HTTPError(.unauthorized) }
        let id = input.id.urlDecoded.asString()
        guard
            let webAuthnCredential = try await FluentWebAuthnCredential.query(on: fluent.db())
                .filter(\.$id == id)
                .with(\.$fluentPersonModel)
                .first()
        else {
            throw HTTPError(.unauthorized)
        }
        guard let decodedPublicKey = webAuthnCredential.publicKey.decoded else { throw HTTPError(.internalServerError) }
        context.logger.info("Challenge: \(challenge)")
        do {
            _ = try webauthn.finishAuthentication(
                credential: input,
                expectedChallenge: challenge,
                credentialPublicKey: [UInt8](decodedPublicKey),
                credentialCurrentSignCount: 0
            )
        } catch {
            context.logger.error("\(error)")
            throw HTTPError(.unauthorized)
        }
        try context.sessions.setSession(
            .authenticated(userId: webAuthnCredential.fluentPersonModel.requireID()),
            expiresIn: .seconds(24 * 60 * 60)
        )

        return .ok
    }

    /// Test authenticated
    @Sendable func logout(_: Request, context: Context) async throws -> HTTPResponse.Status {
        context.sessions.clearSession()
        return .ok
    }

    @Sendable func getToken(_: Request, context: Context) async throws -> TokenResponse {
        let contextSession = try await context.sessions.session?.session(fluent: fluent)
        switch contextSession {
        case let .authenticated(user: user):
            let userPayload: UserPayload = UserPayload(from: user.id)
            let token = try await jwtKeyCollection.sign(userPayload)
            let tokenResponse = TokenResponse(token: token, expiry: userPayload.expiration.value)
            return tokenResponse
        default:
            throw HTTPError(.unauthorized)
        }
    }
}

#if hasFeature(RetroactiveAttribute)
extension PublicKeyCredentialCreationOptions: @retroactive ResponseEncodable {}
extension PublicKeyCredentialRequestOptions: @retroactive ResponseEncodable {}
#else
extension PublicKeyCredentialCreationOptions: ResponseEncodable {}
extension PublicKeyCredentialRequestOptions: ResponseEncodable {}
#endif
