//
//  KeyStorage.swift
//  swiftodon
//
//  Created by Jonathan Pulfer on 05/10/2024.
//
import Crypto
import Foundation

public struct KeyModel {
	public let ownerId: String
	public let keyId: String
	public let createdAt: Date
	public let key: SecKey?

	init(ownerId: String) {
		self.ownerId = ownerId
		self.keyId = UUID().uuidString
		self.createdAt = Date()

		let tag = "swiftodon_key"
		let algorithm: SecKeyAlgorithm = .rsaEncryptionOAEPSHA256
		var error: Unmanaged<CFError>?

		let attributes: CFDictionary =
			[kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
			 kSecAttrKeySizeInBits as String: 2048,
			 kSecPrivateKeyAttrs as String:
			 	[kSecAttrIsPermanent as String: true,
			 	 kSecAttrApplicationTag as String: tag]] as CFDictionary

		if let secKey = SecKeyCreateRandomKey(attributes, &error) {
			self.key = secKey
			print("key created")
		} else {
			self.key = nil
		}
	}
}

public struct KeyCriteria: Sendable {
	let ownerId: String?
	let keyId: String?
}

public struct KeyCreateDetails: Sendable {
	let ownerId: String
}

public protocol KeyStorage: Sendable {
	func get(keyCriteria: KeyCriteria) async throws -> KeyModel?
	func create(from: KeyCreateDetails) async throws -> KeyModel?
}
