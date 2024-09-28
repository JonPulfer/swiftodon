//
//  Person.swift
//  swiftodon
//
//  Created by Jonathan Pulfer on 21/09/2024.
//
import Hummingbird

/// Person from a Mastodon instance.
public struct Person: ResponseEncodable, Codable {
	var id: String
	var type: String
	var following: String
	var followers: String
	var inbox: String
	var outbox: String
	var featured: String
	var featuredTags: String
	var endpoints: PersonEndpoints

	public init(id: String, type: String, following: String, followers: String,
	     inbox: String, outbox: String, featured: String, featuredTags: String,
	     sharedInbox: String)
	{
		self.id = id
		self.type = type
		self.following = following
		self.followers = followers
		self.inbox = inbox
		self.outbox = outbox
		self.featured = featured
		self.featuredTags = featuredTags
		self.endpoints = PersonEndpoints(sharedInbox: sharedInbox)
	}
}

extension Person: Equatable {}

struct PersonEndpoints: ResponseEncodable, Codable {
	var sharedInbox: String
}

extension PersonEndpoints: Equatable {}
