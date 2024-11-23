//
//  PublicKeySignature.swift
//  swiftodon
//
//  Created by Jonathan Pulfer on 05/10/2024.
//
import Foundation
import Hummingbird
import KeyStorage

struct PublicKeySignatureMiddleware<Repository: KeyStorage> {
	let repository: Repository
}
