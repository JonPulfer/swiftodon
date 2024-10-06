//
//  InMemoryKeyStorage.swift
//  swiftodon
//
//  Created by Jonathan Pulfer on 05/10/2024.
//
import Foundation

public actor InMemoryKeyStorage {
	let storage: InMemoryStore = .init()
}

final class InMemoryStore {
	var storageByOwnerId: [String: KeyModel] = [:]
	var storageByKeyId: [String: KeyModel] = [:]
	
	func store(keyModel: KeyModel) -> KeyModel {
		storageByOwnerId[keyModel.ownerId] = keyModel
		storageByKeyId[keyModel.keyId] = keyModel
		
		return keyModel
	}
	
	func get(ownerId: String) -> KeyModel? {
		return storageByOwnerId[ownerId]
	}
	
	func get(keyId: String) -> KeyModel? {
		return storageByKeyId[keyId]
	}
}
