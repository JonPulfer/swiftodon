//
//  MastodonDataTests.swift
//  swiftodon
//
//  Created by Jonathan Pulfer on 21/09/2024.
//

import Foundation
import MastodonData
import Testing

@Suite struct TestDecoding {
	let webFingerExample: String = """
	 {

	   "subject": "acct:bugle@bugle.lol",
	   "links": [
		 {
		   "rel": "self",
		   "type": "application/activity+json",
		   "href": "https://bugle.lol/@bugle"
		 }
	   ]
	 }
	"""

	@Test func TestDecodingWebFingerExample() {
		let jsonData = webFingerExample.data(using: .utf8)!
		let decodedObject: WebFinger = try! JSONDecoder().decode(WebFinger.self, from: jsonData)
		#expect(decodedObject.subject == "acct:bugle@bugle.lol")
		do {
			try #require(decodedObject.links.count == 1)
			#expect(decodedObject.links[0].rel == "self")
			#expect(decodedObject.links[0].type == "application/activity+json")
			#expect(decodedObject.links[0].href == "https://bugle.lol/@bugle")
		} catch {}
	}
}

@Suite struct TestEncoding {
	@Test func TestEncodingWebFingerExample() {
		// encode the object to JSON
		let encodeObject = WebFinger(
			subject: "acct:bugle@bugle.lol",
			links: [
				Link(rel: "self", type: "application/activity+json", href: "https://bugle.lol/@bugle"),
			])
		let encoder = JSONEncoder()
		encoder.outputFormatting = .withoutEscapingSlashes
		let encodedJsonData = try! encoder.encode(encodeObject)

		// Decode the JSON back to an object and compare it with the original
		let decodedObject: WebFinger = try! JSONDecoder().decode(WebFinger.self, from: encodedJsonData)
		#expect(decodedObject.subject == encodeObject.subject)
		do {
			try #require(decodedObject.links.count == 1)
			#expect(decodedObject.links[0].rel == encodeObject.links[0].rel)
			#expect(decodedObject.links[0].type == encodeObject.links[0].type)
			#expect(decodedObject.links[0].href == encodeObject.links[0].href)
		} catch {}
	}
}
