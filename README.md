<picture>
  <source media="(prefers-color-scheme: dark)" srcset="https://www.swift.org/assets/images/swift~dark.svg">
  <img src="https://www.swift.org/assets/images/swift.svg" alt="Swift logo" height="50">
</picture>

# swiftodon

## ActivityPub server
This is an [ActivityPub](https://www.w3.org/TR/activitypub/#social-web-working-group) server that is capable of federating with 
services such as [Mastodon](https://mastodon.social/about). [Documentation for Mastodon](https://docs.joinmastodon.org)

It is being built using the [Hummingbird](https://hummingbird.codes) v2 web framework and Swift 6. The intention is for it to have pluggable modules for 
infrastructure services such as object storage.

## Feature roadmap
My loose plan is to build out the features that I use so that I can run my own server.

 - [x] WebAuthN -> Register account
 - [x] JWT authenticated /api/v1 access control
 - [ ] home timeline
 - [ ] follow
 - [ ] boost
 - [ ] reply
 - [ ] media stored on S3 or similar
 - [ ] registration verification via email
 - [ ] follow hashtags
 - [ ] search users
