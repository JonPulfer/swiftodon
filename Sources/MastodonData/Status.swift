//
//  StatusMessage.swift
//  swiftodon
//
//  Created by Jonathan Pulfer on 01/01/2025.
//
import Foundation
import Hummingbird

public struct MastodonStatus: ResponseEncodable, Codable, Equatable {
    public let id: String
    public let uri: String
    public let text: String
    public let account: MastodonAccount
    public let createdAt: String
    public let updatedAt: String
    public let inReplyToId: String
    public let reblogOfId: String
    public let url: String
    public let sensitive: Bool
    public let visibility: String
    public let spoilerText: String
    public let reply: Bool
    public let language: String
    public let conversationId: String
    public let local: Bool
    public let accountId: String
    public let applicationId: String
    public let inReplyToAccountId: String
    public let pollId: String
    public let deletedAt: String
    public let editedAt: String
    public let trendable: Bool
    public let orderedMediaAttachments: [String]

    public init(
        id: String,
        uri: String,
        text: String,
        account: MastodonAccount,
        createdAt: String,
        updatedAt: String,
        inReplyToId: String,
        reblogOfId: String,
        url: String,
        sensitive: Bool,
        visibility: String,
        spoilerText: String,
        reply: Bool,
        language: String,
        conversationId: String,
        local: Bool,
        accountId: String,
        applicationId: String,
        inReplyToAccountId: String,
        pollId: String,
        deletedAt: String,
        editedAt: String,
        trendable: Bool,
        orderedMediaAttachments: [String]
    ) {
        self.id = id
        self.uri = uri
        self.text = text
        self.account = account
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.inReplyToId = inReplyToId
        self.reblogOfId = reblogOfId
        self.url = url
        self.sensitive = sensitive
        self.visibility = visibility
        self.spoilerText = spoilerText
        self.reply = reply
        self.language = language
        self.conversationId = conversationId
        self.local = local
        self.accountId = accountId
        self.applicationId = applicationId
        self.inReplyToAccountId = inReplyToAccountId
        self.pollId = pollId
        self.deletedAt = deletedAt
        self.editedAt = editedAt
        self.trendable = trendable
        self.orderedMediaAttachments = orderedMediaAttachments
    }
}
