//
//  Link.swift
//  swiftodon
//
//  Created by Jonathan Pulfer on 21/09/2024.
//

import Foundation

struct Link: ObjectOrLink, Codable {
    var href: String
    var rel: URL?

    /// The ActivityPub spec defines this will contain "Link" for Link types.
    var type: String

    /// mime media type e.g. "text/html"
    var mediaType: String?

    let isObject: Bool = false
    let isLink: Bool = true

    enum CodingKeys: String, CodingKey {
        case href
        case type
        case rel
        case mediaType
    }
}
