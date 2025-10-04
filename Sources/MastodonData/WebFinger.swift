//
//  WebFinger.swift
//  swiftodon
//
//  Created by Jonathan Pulfer on 21/09/2024.
//

import Hummingbird

public struct WebFinger: ResponseEncodable, Codable, Equatable {
    public let subject: String
    public var links: [Link] = []

    enum CodingKeys: String, CodingKey {
        case subject = "subject"
        case links = "links"
    }

    public init(subject: String, links: [Link]) {
        self.subject = subject
        self.links = links
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        subject = try container.decode(String.self, forKey: .subject)
        links = try container.decode([Link].self, forKey: .links)
    }

    public init(acctValue: String, hostname: String) throws {
        self.subject = acctValue
        var host = hostname
        if host.hasSuffix("/") {
            host.remove(at: host.endIndex)
        }
        if host.hasPrefix("https://") {
            host.replace("https://", with: "")
        }
        if let accountName = extractAccountNameFromAcctValue(acctValue: acctValue) {
            self.links = [
                Link(
                    rel: "self",
                    type: "application/activity+json",
                    href: "https://" + host + "/accounts/" + accountName
                )
            ]
        }
    }
}

/// The 'acctValue' is expected to be a string such as `acct:someone@host.com`. We want to extract the `someone` from
/// that string.
func extractAccountNameFromAcctValue(acctValue: String) -> String? {
    let colonIndex = acctValue.firstIndex(of: ":") ?? acctValue.startIndex
    let atIndex = acctValue.firstIndex(of: "@") ?? acctValue.endIndex
    return String(acctValue[acctValue.index(colonIndex, offsetBy: 1)..<atIndex])
}
