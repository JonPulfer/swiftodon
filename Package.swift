// swift-tools-version:6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
	name: "swiftodon",
	platforms: [.macOS(.v15)],
	products: [
		.executable(name: "App", targets: ["App"]),
		.library(name: "MastodonData", targets: ["MastodonData"]),
		// .library(name: "KeyStorage", targets: ["KeyStorage"]),
		.library(name: "PersonStorage", targets: ["PersonStorage"]),
		.library(name: "Storage", targets: ["Storage"])
	],
	dependencies: [
		.package(url: "https://github.com/hummingbird-project/hummingbird.git", from: "2.0.0"),
		.package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.3.0"),
		.package(url: "https://github.com/hummingbird-project/hummingbird-fluent.git", from: "2.0.0-beta.5"),
		.package(url: "https://github.com/vapor/fluent-sqlite-driver.git", from: "4.0.0")
	],
	targets: [
		.executableTarget(name: "App",
		                  dependencies: [
		                  	.product(name: "ArgumentParser", package: "swift-argument-parser"),
		                  	.product(name: "Hummingbird", package: "hummingbird"),
		                  	"MastodonData",
		                  	"PersonStorage"
		                  ],
		                  path: "Sources/App"),
		.target(name: "MastodonData", dependencies: [
			.product(name: "Hummingbird", package: "hummingbird")
		], path: "Sources/MastodonData"),
		// .target(name: "KeyStorage", dependencies: []),
		.target(name: "Storage", dependencies: [], path: "Sources/Storage"),
		.target(name: "PersonStorage", dependencies: [
			"Storage",
			"MastodonData",
			.product(name: "FluentSQLiteDriver", package: "fluent-sqlite-driver"),
			.product(name: "HummingbirdFluent", package: "hummingbird-fluent")
		], path: "Sources/PersonStorage"),
		.testTarget(name: "MastodonDataTests",
		            dependencies: [
		            	.byName(name: "MastodonData"),
		            	.byName(name: "Storage"),
		            	.byName(name: "PersonStorage")
		            ],
		            path: "Tests/MastodonData"),
		.testTarget(name: "AppTests",
		            dependencies: [
		            	.byName(name: "App"),
		            	.byName(name: "PersonStorage"),
		            	.product(name: "HummingbirdTesting", package: "hummingbird")
		            ],
		            path: "Tests/AppTests"),
		.testTarget(name: "SignatureMiddlewareTests",
		            dependencies: [
		            	// .byName(name: "KeyStorage")
		            ],
		            path: "Tests/SignatureMiddleware")
	]
)
