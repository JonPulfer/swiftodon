//
//  Link.swift
//  swiftodon
//
//  Created by Jonathan Pulfer on 21/09/2024.
//

import Hummingbird

public struct Link: ResponseEncodable, Codable, Equatable {
    public var rel: String?
    public var type: String?
    public var href: String?

    public init(rel: String?, type: String?, href: String?) {
        self.rel = rel
        self.type = type
        self.href = href
    }

    public enum CodingKeys: String, CodingKey {
        case rel = "rel"
        case type = "type"
        case href = "href"
    }
}
