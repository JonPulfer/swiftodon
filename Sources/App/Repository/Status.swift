import Foundation

public struct Status: Codable {
    var id: UUID?
    var uri: String
    var content: String
    var createdAt: String
    var updatedAt: String
    var inReplyToId: String
    var reblogOfId: String
    var url: String
    var sensitive: Bool
    var visibility: String
    var spoilerText: String
    var reply: Bool
    var language: String
    var conversationId: String
    var local: Bool
    var accountId: String
    var applicationId: String
    var inReplyToAccountId: String
    var pollId: String
    var deletedAt: String
    var editedAt: String
    var trendable: Bool
    var orderedMediaAttachments: [String]
}

public struct StatusCriteria: Sendable {
    public let id: String
}

public protocol StatusStorage: Sendable {
    func get(criteria: StatusCriteria) async -> Status?
}
