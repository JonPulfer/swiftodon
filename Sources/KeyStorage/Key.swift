//
//  Key.swift
//  swiftodon
//
//  Created by Jonathan Pulfer on 04/11/2024.
//
import Foundation
import Hummingbird
import Security

final class Key: Model, HBResponseCodable {
    static let schema = "key"

    var id: UUID

    public let ownerId: String

    public let createdAt: Date

    public let key: SecKey?

    public init(ownerId: String) {
        self.ownerId = ownerId
        id = UUID().uuidString
        createdAt = Date()

        let tag = "swiftodon.keys." + id
        let attributes: [String: Any] =
            [
                kSecAttrKeyType as String: kSecAttrKeyTypeEC,
                kSecAttrKeySizeInBits as String: NSNumber(value: 256),
                kSecPrivateKeyAttrs as String:
                    [
                        kSecAttrIsPermanent as String: true,
                        kSecAttrApplicationTag as String: tag.data(using: .utf8)!,
                    ],
            ]

        var error: Unmanaged<CFError>?
        guard let privateKey = SecKeyCreateRandomKey(attributes as CFDictionary, &error) else {
            print("error creating key: \(error!)")
            key = nil
            return
        }

        key = privateKey
    }
}
