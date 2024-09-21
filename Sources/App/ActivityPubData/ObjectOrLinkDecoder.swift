//
//  ObjectOrLinkDecoder.swift
//  swiftodon
//
//  Created by Jonathan Pulfer on 21/09/2024.
//

func DecodeArrayOfObjectOrLink(unkeyedContainer: UnkeyedDecodingContainer) -> [ObjectOrLink] {
	var results: [ObjectOrLink] = []
	var container: UnkeyedDecodingContainer = unkeyedContainer
	while !container.isAtEnd {
		do {
			let decodedObject = try container.decode(Object.self)
			results.append(decodedObject)
			continue
		} catch {
			// print(error)
		}
		do {
			let decodedLink = try container.decode(Link.self)
			results.append(decodedLink)
			continue
		} catch {
			// print(error)
		}
	}
	
	return results
}
