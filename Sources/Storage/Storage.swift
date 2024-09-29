//
//  Storage.swift
//  swiftodon
//
//  Created by Jonathan Pulfer on 28/09/2024.
//
import Foundation

public enum ServerDialects: String, Codable {
	case Mastodon = "mastodon"
}

extension ServerDialects: Sendable {}
