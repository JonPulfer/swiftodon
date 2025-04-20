//
//  RequestContext.swift
//  swiftodon
//
//  Created by Jonathan Pulfer on 27/12/2024.
//

import Foundation
import Hummingbird
import HummingbirdAuth
import HummingbirdRouter
import Logging
import NIOCore

public struct WebAuthnRequestContext: AuthRequestContext, RouterRequestContext, SessionRequestContext {
    public typealias Session = WebAuthnSession

    public var coreContext: CoreRequestContextStorage
    public var identity: Person?
    public var routerContext: RouterBuilderContext
    public let sessions: SessionContext<WebAuthnSession>

    var responseEncoder: ResponseEncoder {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .withoutEscapingSlashes
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }

    public init(source: Source) {
        coreContext = .init(source: source)
        identity = nil
        routerContext = .init()
        sessions = .init()
    }
}
