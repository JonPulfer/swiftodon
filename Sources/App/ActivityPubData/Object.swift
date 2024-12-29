//
//  Object.swift
//
//
//  Created by Jonathan Pulfer on 08/09/2024.
//

import Foundation

/// Object definition taken from specification at [w3c ActivityPub spec](https://www.w3.org/TR/activitystreams-vocabulary/#types).
/// This will always be the parent container type holding lists that can contain a mixture of `Object` or `Link` elements.
final class Object: ObjectOrLink, Codable {
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

    var content: Object?

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
        case content
    }

    func encode(to _: any Encoder) throws {
        // TODO: implement me
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        processingContext = try container.decode(String.self, forKey: .processingContext)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        type = try container.decode(String.self, forKey: .type)

        // attachment
        do {
            let attachmentContainer = try container.nestedUnkeyedContainer(forKey: .attachment)

            attachment = DecodeArrayOfObjectOrLink(unkeyedContainer:
                attachmentContainer)
        } catch {
            attachment = []
        }

        // attributedTo
        do {
            let attributedToContainer = try container.nestedUnkeyedContainer(forKey: .attributedTo)

            attributedTo = DecodeArrayOfObjectOrLink(unkeyedContainer:
                attributedToContainer)
        } catch {
            attributedTo = []
        }

        // audience
        do {
            let audienceContainer = try container.nestedUnkeyedContainer(forKey: .audience)

            audience = DecodeArrayOfObjectOrLink(unkeyedContainer:
                audienceContainer)
        } catch {
            audience = []
        }

        // content
        do {
            let contentObject = try container.decode(Object.self, forKey: .content)
            content = contentObject
        } catch {
            content = nil
        }
    }
}
