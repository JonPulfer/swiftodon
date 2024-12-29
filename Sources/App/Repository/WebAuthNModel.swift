//
//  WebAuthNModel.swift
//  swiftodon
//
//  Created by Jonathan Pulfer on 30/11/2024.
//
@preconcurrency import WebAuthn
import Foundation

public struct WebAuthNModel: Sendable {
	public let userUuid: UUID
	public let publicKey: EncodedBase64
}

public struct CreateWebAuthN: @unchecked Sendable {
	public let userUuid: UUID
	public let publicKey: Credential
}

public struct WebAuthNCriteria: Sendable {
	public var userUuid: String
}

public protocol WebAuthNStorage: Sendable {
	func get(criteria: WebAuthNCriteria) async -> WebAuthNModel?
	func create(from: CreateWebAuthN) async throws -> WebAuthNModel?
}
