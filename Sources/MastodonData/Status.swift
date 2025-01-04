//
//  Status.swift
//  swiftodon
//
//  Created by Jonathan Pulfer on 01/01/2025.
//
import Foundation
import Hummingbird

public struct Status: ResponseEncodable, Codable, Equatable {
    let id: String
    let uri: String
    let text: String
    let createdAt: String
    let updatedAt: String
    let inReplyToId: String
    let reblogOfId: String
    let url: String
    let sensitive: Bool
    let visibility: String
    let spoilerText: String
    let reply: Bool
    let language: String
    let conversationId: String
    let local: Bool
    let accountId: String
    let applicationId: String
    let inReplyToAccountId: String
    let pollId: String
    let deletedAt: String
    let editedAt: String
    let trendable: Bool
    let orderedMediaAttachments: [String]
}
