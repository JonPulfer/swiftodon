//
//  KeyStorage.swift
//  swiftodon
//
//  Created by Jonathan Pulfer on 05/10/2024.
//
import FluentKit
import Foundation
import Hummingbird
import Security

public struct KeyCriteria: Sendable {
    let ownerId: String?
    let keyId: String?
}

public struct KeyCreateDetails: Sendable {
    let ownerId: String
}

public protocol KeyStorage: Sendable {
    func get(keyCriteria: KeyCriteria) async throws -> Key?
    func create(from: KeyCreateDetails) async throws -> Key?
}
