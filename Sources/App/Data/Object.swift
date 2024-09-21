//
//  Object.swift
//
//
//  Created by Jonathan Pulfer on 08/09/2024.
//

import Foundation

/// Object definition taken from specification at [w3c ActivityPub spec](https://www.w3.org/TR/activitystreams-vocabulary/#types).
/// This will always be the parent container type holding lists that can contain a mixture of `Object` or `Link` elements.
struct Object: ObjectOrLink, Codable {
	/// [json-LD](https://www.w3.org/TR/activitystreams-core/#jsonld)
	/// This special context value identifies the processing context.
	/// Generally, this is going to be `https://www.w3.org/ns/activitystreams`
	var processingContext: String = "https://www.w3.org/ns/activitystreams"
	
	var id: String
	var name: String
	
	/// The ActivityPub spec defines this will contain "Object" for Object types.
	var type: String
	
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
		case attributedTo
		case audience
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
		
		// attachment
		do {
			let attachmentContainer = try container.nestedUnkeyedContainer(forKey: .attachment)
			
			self.attachment = DecodeArrayOfObjectOrLink(unkeyedContainer:
				attachmentContainer)
		} catch {
			self.attachment = []
		}
		
		// attributedTo
		do {
			let attributedToContainer = try container.nestedUnkeyedContainer(forKey: .attributedTo)
			
			self.attributedTo = DecodeArrayOfObjectOrLink(unkeyedContainer:
				attributedToContainer)
		} catch {
			self.attributedTo = []
		}
		
		// audience
		do {
			let audienceContainer = try container.nestedUnkeyedContainer(forKey: .audience)
			
			self.audience = DecodeArrayOfObjectOrLink(unkeyedContainer:
				audienceContainer)
		} catch {
			self.audience = []
		}
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
}
