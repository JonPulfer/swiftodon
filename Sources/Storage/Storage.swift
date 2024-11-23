//
//  Storage.swift
//  swiftodon
//
//  Created by Jonathan Pulfer on 28/09/2024.
//
import Foundation

public enum ServerDialect: String, Codable, CaseIterable {
	case mastodon

	public init(fromString: String) {
		for dialect in ServerDialect.allCases {
			if fromString == dialect.rawValue {
				self = dialect
			}
		}
		self = ServerDialect(rawValue: "mastodon")!
	}
}

extension ServerDialect: Sendable {
	public func match(string: String) -> ServerDialect? {
		for dialect in ServerDialect.allCases {
			if string == dialect.rawValue {
				return dialect
			}
		}
		return nil
	}
}
