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

    func toMastodonStatus() -> MastodonStatus {
        MastodonStatus.init(
            id: self.id?.uuidString ?? "",
            uri: self.uri,
            content: self.content,
            account: nil,
            createdAt: self.createdAt,
            updatedAt: self.updatedAt ?? "",
            inReplyToId: self.inReplyToId ?? "",
            reblogOfId: self.reblogOfId ?? "",
            url: self.url,
            sensitive: self.sensitive,
            visibility: self.visibility,
            spoilerText: self.spoilerText ?? "",
            language: self.language,
            conversationId: self.conversationId!,
            accountId: self.accountId ?? "",
            applicationId: self.applicationId ?? "",
            inReplyToAccountId: self.inReplyToAccountId!,
            pollId: self.pollId ?? "",
            deletedAt: self.deletedAt!,
            editedAt: self.editedAt ?? "",
            orderedMediaAttachments: self.orderedMediaAttachments
        )
    }
}

public struct StatusCriteria: Sendable {
    public let id: String
}

public protocol StatusStorage: Sendable {
    func get(criteria: StatusCriteria) async -> Status?
    func create(from status: Status) async throws
}
