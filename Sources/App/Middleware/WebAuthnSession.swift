//
//  WebAuthnSession.swift
//  swiftodon
//
//  Created by Jonathan Pulfer on 27/12/2024.
//
import Foundation
import Hummingbird
import HummingbirdAuth
import HummingbirdFluent
import WebAuthn

/// Authentication session state
public enum AuthenticationSession: Sendable, Codable {
    case signedUp(user: Person)
    case registering(user: Person, challenge: [UInt8])
    case authenticating(challenge: [UInt8])
    case authenticated(user: Person)
}

/// Session object extracted from session state
public enum WebAuthnSession: Codable, Sendable {
    case signedUp(userId: UUID)
    case registering(userId: UUID, encodedChallenge: String)
    case authenticating(encodedChallenge: String)
    case authenticated(userId: UUID)

    /// init session object from authentication state
    public init(from session: AuthenticationSession) throws {
        switch session {
        case let .authenticating(challenge):
            self = .authenticating(encodedChallenge: challenge.base64URLEncodedString().asString())
        case let .signedUp(user):
            self = try .signedUp(userId: user.requireID())
        case let .registering(user, challenge):
            self = try .registering(userId: user.requireID(), encodedChallenge: challenge.base64URLEncodedString().asString())
        case let .authenticated(user):
            self = try .authenticated(userId: user.requireID())
        }
    }

    /// return authentication state from session object
    public func session(fluent: Fluent) async throws -> AuthenticationSession? {
        switch self {
        case let .authenticating(encodedChallenge):
            guard let challenge = URLEncodedBase64(encodedChallenge).decodedBytes else { return nil }
            return .authenticating(challenge: challenge)
        case let .signedUp(userId):
            guard let user = await FluentPersonStorage(fluent: fluent).get(criteria: PersonCriteria(handle: nil, id: userId.uuidString)) else { return nil }
            return .signedUp(user: user)
        case let .registering(userId, encodedChallenge):
            guard let user = await FluentPersonStorage(fluent: fluent).get(criteria: PersonCriteria(handle: nil, id: userId.uuidString)) else { return nil }
            guard let challenge = URLEncodedBase64(encodedChallenge).decodedBytes else { return nil }
            return .registering(user: user, challenge: challenge)
        case let .authenticated(userId):
            guard let user = await FluentPersonStorage(fluent: fluent).get(criteria: PersonCriteria(handle: nil, id: userId.uuidString)) else { return nil }
            return .authenticated(user: user)
        }
    }
}
