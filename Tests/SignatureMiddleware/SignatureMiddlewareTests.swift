//
//  SignatureMiddlewareTests.swift
//  swiftodon
//
//  Created by Jonathan Pulfer on 05/10/2024.
//

import Crypto
import Foundation
import Testing

@Suite struct KeyTests {
    
    // Valid Curve25519 key details verified by openssl.
    let privateKeyBase64 = "sffPc3mtiJDKdGkN7TiascPiMeXm7UZqfXdBlYG7iyc="
    let expectedPublicKeyPem =
        "-----BEGIN PUBLIC KEY-----\nMCowBQYDK2VuAyEAtV5dzF+zZV9Yup+riEAqaCNol/JumbAPjrT6CkEdpGg=\n-----END PUBLIC KEY-----\n"

    @Test func TestLoadingKeyFromBase64Data() throws {
        let keyData = Data(base64Encoded: privateKeyBase64)!
        let privateKey = try Curve25519.Signing.PrivateKey.init(rawRepresentation: keyData)
        #expect(privateKey.publicKey.exportAsPem() == expectedPublicKeyPem)
    }
}

extension Curve25519.Signing.PublicKey {
    func exportAsPem() -> String {
        let prefix = Data([0x30, 0x2A, 0x30, 0x05, 0x06, 0x03, 0x2B, 0x65, 0x6E, 0x03, 0x21, 0x00])
        let subjectPublicKeyInfo = prefix + self.rawRepresentation
        return
            "-----BEGIN PUBLIC KEY-----\n\(subjectPublicKeyInfo.base64EncodedString())\n-----END PUBLIC KEY-----\n"
    }
}
