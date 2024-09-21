//
//  MastodonDataTests.swift
//  swiftodon
//
//  Created by Jonathan Pulfer on 21/09/2024.
//

import Testing
import MastodonData
import Foundation

@Suite struct TestDecoding {
	let webFingerExample:String = """
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
	
	@Test func TestDecodingWebFingerExample() throws {
		let jsonData = webFingerExample.data(using: .utf8)!
		let decodedObject: WebFinger = try! JSONDecoder().decode(WebFinger.self, from: jsonData)
		#expect(decodedObject.subject == "acct:bugle@bugle.lol")
		#require(decodedObject.links.count == 1)
		#expect(decodedObject.links[0].rel == "self")
		#expect(decodedObject.links[0].type == "application/activity+json")
		#expect(decodedObject.links[0].href == "https://bugle.lol/@bugle")
	}
}
