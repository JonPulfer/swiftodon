//
//  Storage.swift
//  swiftodon
//
//  Created by Jonathan Pulfer on 28/09/2024.
//
import Foundation

public protocol Storage: Sendable {
	func Get(criteria: Criteria) -> StorageObject?
}

public protocol Criteria {
	var id: String { get }
}

public protocol StorageObject {
	var id: String { get }
	var serverDialect: ServerDialects { get }
	var type: String { get }
}

public enum ServerDialects: String, Codable {
	case Mastodon = "mastodon"
}

extension ServerDialects: Sendable {}
