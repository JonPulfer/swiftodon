//
//  RequestContext.swift
//  swiftodon
//
//  Created by Jonathan Pulfer on 27/12/2024.
//
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

	public init(source: Source) {
		self.coreContext = .init(source: source)
		self.identity = nil
		self.routerContext = .init()
		self.sessions = .init()
	}
}