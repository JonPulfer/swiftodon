//
//  Link.swift
//  swiftodon
//
//  Created by Jonathan Pulfer on 21/09/2024.
//

public struct Link: Codable {
    public var rel: String?
    public var type: String?
    public var href: String?

    public init(rel: String?, type: String?, href: String?) {
        self.rel = rel
        self.type = type
        self.href = href
    }
}
