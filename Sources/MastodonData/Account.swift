//
//  Person.swift
//  swiftodon
//
//  Created by Jonathan Pulfer on 21/09/2024.
//
import Foundation
import Hummingbird

/// Account from a Mastodon instance.
public struct MastodonAccount: ResponseEncodable, Codable, Equatable {
    var id: String
    var username: String
    var account: String
    var displayName: String
    var locked: Bool
    var bot: Bool
    var discoverable: Bool
    var indexable: Bool?
    var group: Bool
    var createdAt: String
    var note: String
    var url: String?
    var uri: String?
    var avatar: String
    var avatarStatic: String
    var header: String
    var headerStatic: String
    var followersCount: UInt64
    var followingCount: UInt64
    var statusesCount: UInt64
    var lastStatusAt: String
    var hideCollections: Bool?
    var noindex: Bool?
    var fields: [AccountField]

    public enum CodingKeys: String, CodingKey {
        case id = "id"
        case username = "username"
        case account = "acct"
        case displayName = "display_name"
        case locked = "locked"
        case bot = "bot"
        case discoverable = "discoverable"
        case indexable = "indexable"
        case group = "group"
        case createdAt = "created_at"
        case note = "note"
        case url = "url"
        case uri = "uri"
        case avatar = "avatar"
        case avatarStatic = "avatar_static"
        case header = "header"
        case headerStatic = "header_static"
        case followersCount = "followers_count"
        case followingCount = "following_count"
        case statusesCount = "statuses_count"
        case lastStatusAt = "last_status_at"
        case hideCollections = "hide_collections"
        case noindex = "no_index"
        case fields = "fields"
    }

    public init(
        id: String,
        username: String,
        account: String,
        displayName: String,
        locked: Bool = false,
        bot: Bool = false,
        discoverable: Bool = false,
        indexable: Bool = false,
        group: Bool = false,
        createdAt: Date,
        note: String,
        url: String,
        uri: String,
        avatar: String,
        header: String,
        followersCount: UInt64 = 0,
        followingCount: UInt64 = 0,
        statusesCount: UInt64 = 0,
        lastStatusAt: Date,
        hideCollections: Bool = false,
        noindex: Bool = false,
        fields: [AccountField] = []
    ) {
        self.id = id
        self.username = username
        self.account = account
        self.displayName = displayName
        self.locked = locked
        self.bot = bot
        self.discoverable = discoverable
        self.indexable = indexable
        self.group = group
        self.createdAt = createdAt.formatted(.iso8601.locale(Locale(identifier: "en_US_POSIX")))
        self.note = note
        self.url = url
        self.uri = uri
        self.avatar = avatar
        avatarStatic = avatar
        self.header = header
        headerStatic = header
        self.followersCount = followersCount
        self.followingCount = followingCount
        self.statusesCount = statusesCount
        self.lastStatusAt = lastStatusAt.formatted(.iso8601.year().month().day())
        self.hideCollections = hideCollections
        self.noindex = noindex
        self.fields = fields
    }
}

struct PersonEndpoints: ResponseEncodable, Codable, Equatable {
    var sharedInbox: String

    public enum CodingKeys: String, CodingKey {
        case sharedInbox = "shared_inbox"
    }
}

public struct AccountField: ResponseEncodable, Codable, Equatable {
    var name: String
    var value: String
    var verifiedAt: String?

    public enum CodingKeys: String, CodingKey {
        case name = "name"
        case value = "value"
        case verifiedAt = "verified_at"
    }
}
