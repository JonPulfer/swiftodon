//
//  Object.swift
//
//
//  Created by Jonathan Pulfer on 08/09/2024.
//

import Foundation

/// Object definition taken from specification at [w3c ActivityPub spec](https://www.w3.org/TR/activitystreams-vocabulary/#types).
/// This will always be the parent container
struct Object: ObjectOrLink, Codable {
	/// json-LD: https://www.w3.org/TR/activitystreams-core/#jsonld
	/// This special context value identifies the processing context.
	/// Generally, this is going to be `https://www.w3.org/ns/activitystreams`
	var processingContext: String = "https://www.w3.org/ns/activitystreams"
	
	var id: String
	
	/// The ActivityPub spec defines this will contain "Object" for Object types.
	var type: String
	var name: String
	var attachment: [ObjectOrLink]
	var attributedTo: [ObjectOrLink]
	var audience: [ObjectOrLink]
	
	let isObject: Bool = true
	let isLink: Bool = false
	
	enum CodingKeys: String, CodingKey {
		case processingContext = "@context"
		case id
		case type
		case name
		case attachment
	}
	
	func encode(to encoder: any Encoder) throws {
		// TODO: implement me
	}
	
	init(from decoder: any Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.processingContext = try container.decode(String.self, forKey: .processingContext)
		self.id = try container.decode(String.self, forKey: .id)
		self.name = try container.decode(String.self, forKey: .name)
		self.type = try container.decode(String.self, forKey: .type)
		var attachmentsContainer = try container.nestedUnkeyedContainer(forKey: .attachment)
		var attachments: [ObjectOrLink] = []
		while !attachmentsContainer.isAtEnd {
			do {
				let decodedObject = try attachmentsContainer.decode(Object.self)
				attachments.append(decodedObject)
				continue
			} catch {
				// print(error)
			}
			do {
				let decodedLink = try attachmentsContainer.decode(Link.self)
				attachments.append(decodedLink)
				continue
			} catch {
				// print(error)
			}
		}
		self.attachment = attachments
		self.attributedTo = []
		self.audience = []
	}
}

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
	
//	init(from decoder: any Decoder) throws {
//		let container = try decoder.container(keyedBy: CodingKeys.self)
//		self.href = try container.decode(String.self, forKey: .href)
//		self.type = try container.decode(String.self, forKey: .type)
//		self.rel = try container.decode(URL.self, forKey: .rel)
//		self.mediaType = try container.decode(String.self, forKey: .mediaType)
//	}
}
