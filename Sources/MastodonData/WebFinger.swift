//
//  WebFinger.swift
//  swiftodon
//
//  Created by Jonathan Pulfer on 21/09/2024.
//

public struct WebFinger: Codable {
	public var subject: String
	public var links: [Link] = []
	
	enum CodingKeys: String, CodingKey {
		case subject
		case links
	}
	
	public init(from decoder: any Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.subject = try container.decode(String.self, forKey: .subject)
		self.links = try container.decode([Link].self, forKey: .links)
	}
}
