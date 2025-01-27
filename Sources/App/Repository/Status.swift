import Foundation
import MastodonData

public struct Status: Codable {
    var id: UUID?
    var uri: String
    var content: String
    var createdAt: String
    var updatedAt: String?
    var inReplyToId: String?
    var reblogOfId: String?
    var url: String
    var sensitive: Bool
    var visibility: String
    var spoilerText: String?
    var reply: Bool
    var language: String
    var conversationId: String?
    var local: Bool
    var accountId: String?
    var applicationId: String?
    var inReplyToAccountId: String?
    var pollId: String?
    var deletedAt: String?
    var editedAt: String?
    var trendable: Bool?
    var orderedMediaAttachments: [String]

    init(fromMastodonStatus: MastodonStatus) {
        id = (UUID(uuidString: (fromMastodonStatus.id ?? "")) ?? UUID())
        uri = fromMastodonStatus.uri
        content = fromMastodonStatus.content
        createdAt = fromMastodonStatus.createdAt
        updatedAt = fromMastodonStatus.updatedAt
        inReplyToId = fromMastodonStatus.inReplyToId
        reblogOfId = fromMastodonStatus.reblogOfId
        url = fromMastodonStatus.url
        sensitive = fromMastodonStatus.sensitive
        visibility = fromMastodonStatus.visibility
        spoilerText = fromMastodonStatus.spoilerText
        reply = fromMastodonStatus.reply ?? false
        language = fromMastodonStatus.language
        conversationId = fromMastodonStatus.conversationId
        local = fromMastodonStatus.local ?? false
        accountId = fromMastodonStatus.accountId
        applicationId = fromMastodonStatus.applicationId
        inReplyToAccountId = fromMastodonStatus.inReplyToAccountId
        pollId = fromMastodonStatus.pollId
        deletedAt = fromMastodonStatus.deletedAt
        editedAt = fromMastodonStatus.editedAt
        trendable = fromMastodonStatus.trendable
        orderedMediaAttachments = fromMastodonStatus.orderedMediaAttachments
    }
}

public struct StatusCriteria: Sendable {
    public let id: String
}

public protocol StatusStorage: Sendable {
    func get(criteria: StatusCriteria) async -> Status?
}
