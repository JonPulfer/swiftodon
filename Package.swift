// swift-tools-version:6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
	name: "swiftodon",
	platforms: [.macOS(.v14), .iOS(.v17), .tvOS(.v17)],
	products: [
		.executable(name: "App", targets: ["App"]),
		.library(name: "MastodonData", targets: ["MastodonData"])
	],
	dependencies: [
		.package(url: "https://github.com/hummingbird-project/hummingbird.git", from: "2.0.0"),
		.package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.3.0"),
		// swift-crypto 1.x, 2.x and 3.x are almost API compatible, so most clients
		// should allow any of them
		.package(url: "https://github.com/apple/swift-crypto.git", "1.0.0" ..< "4.0.0")
	],
	targets: [
		.executableTarget(name: "App",
		                  dependencies: [
		                  	.product(name: "ArgumentParser", package: "swift-argument-parser"),
		                  	.product(name: "Hummingbird", package: "hummingbird"),
		                  	"MastodonData",
		                  	"PersonStorage",
		                  	"SignatureMiddleware"
		                  ],
		                  path: "Sources/App"),
		.target(name: "MastodonData", dependencies: [
			.product(name: "Hummingbird", package: "hummingbird")
		], path: "Sources/MastodonData"),
		.target(name: "Storage", dependencies: [], path: "Sources/Storage"),
		.target(name: "PersonStorage", dependencies: [
			"Storage",
			"MastodonData"
		], path: "Sources/PersonStorage"),
		.target(name: "KeyStorage", dependencies: [
			.product(name: "Crypto", package: "swift-crypto")
		],
		path: "Sources/KeyStorage"),
		.target(name: "SignatureMiddleware", dependencies: [
			.product(name: "Crypto", package: "swift-crypto")
		], path: "Sources/SignatureMiddleware"),
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
		            	"SignatureMiddleware",
		            	.product(name: "Crypto", package: "swift-crypto")
		            ],
		            path: "Tests/SignatureMiddleware")
	]
)
