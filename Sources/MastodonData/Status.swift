//
//  StatusMessage.swift
//  swiftodon
//
//  Created by Jonathan Pulfer on 01/01/2025.
//
import Foundation
import Hummingbird

public struct MastodonStatus: ResponseEncodable, Codable, Equatable {
    public let id: String?
    public let uri: String
    public let content: String
    public let account: MastodonAccount
    public let createdAt: String
    public let updatedAt: String?
    public let inReplyToId: String?
    public let reblogOfId: String?
    public let url: String
    public let sensitive: Bool
    public let visibility: String
    public let spoilerText: String?
    public let reply: Bool?
    public let language: String
    public let conversationId: String?
    public let local: Bool?
    public let accountId: String?
    public let applicationId: String?
    public let inReplyToAccountId: String?
    public let pollId: String?
    public let deletedAt: String?
    public let editedAt: String?
    public let trendable: Bool?
    public let orderedMediaAttachments: [String]

    public enum CodingKeys: String, CodingKey {
        case id = "id"
        case uri = "uri"
        case content = "content"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case inReplyToId = "in_reply_to_id"
        case reblogOfId = "reblog_of_id"
        case url = "url"
        case sensitive = "sensitive"
        case visibility = "visibility"
        case spoilerText = "spoiler_text"
        case reply = "reply"
        case language = "language"
        case conversationId = "conversation_id"
        case local = "local"
        case accountId = "account_id"
        case account = "account"
        case applicationId = "application_id"
        case inReplyToAccountId = "in_reply_to_account_id"
        case pollId = "pollId"
        case deletedAt = "deleted_at"
        case editedAt = "edited_at"
        case trendable = "trendable"
        case orderedMediaAttachments = "media_attachments"
    }

    public init(
        id: String,
        uri: String,
        content: String,
        account: MastodonAccount,
        createdAt: String,
        updatedAt: String,
        inReplyToId: String,
        reblogOfId: String,
        url: String,
        sensitive: Bool,
        visibility: String,
        spoilerText: String,
        reply: Bool = false,
        language: String,
        conversationId: String,
        local: Bool = false,
        accountId: String,
        applicationId: String,
        inReplyToAccountId: String,
        pollId: String,
        deletedAt: String,
        editedAt: String,
        trendable: Bool = false,
        orderedMediaAttachments: [String]
    ) {
        self.id = id
        self.uri = uri
        self.content = content
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
