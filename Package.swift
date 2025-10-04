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
        .library(name: "Storage", targets: ["Storage"]),
    ],
    dependencies: [
        .package(url: "https://github.com/hummingbird-project/hummingbird.git", from: "2.0.0"),
        .package(url: "https://github.com/hummingbird-project/hummingbird-auth.git", from: "2.0.0"),
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.3.0"),
        .package(url: "https://github.com/hummingbird-project/hummingbird-fluent.git", from: "2.0.0-beta.5"),
        .package(url: "https://github.com/swift-server/webauthn-swift.git", from: "1.0.0-alpha.2"),
        .package(url: "https://github.com/hummingbird-project/swift-mustache.git", from: "2.0.0-beta.1"),
        .package(url: "https://github.com/vapor/fluent-sqlite-driver.git", from: "4.0.0"),
        .package(url: "https://github.com/vapor/jwt-kit.git", from: "5.0.0"),
        .package(url: "https://github.com/apple/swift-crypto.git", "1.0.0"..<"4.0.0"),
        .package(url: "https://github.com/apple/swift-asn1.git", .upToNextMajor(from: "1.0.0")),
		.package(url: "https://github.com/swift-otel/swift-otel.git", from: "1.0.0"),
		.package(url: "https://github.com/apple/swift-configuration", .upToNextMinor(from: "0.1.0")),

        // other dependencies
        .package(url: "https://github.com/swiftlang/swift-docc-plugin", from: "1.1.0"),
    ],
    targets: [
        .executableTarget(
            name: "App",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "Hummingbird", package: "hummingbird"),
                .product(name: "HummingbirdAuth", package: "hummingbird-auth"),
                .product(name: "HummingbirdRouter", package: "hummingbird"),
                .product(name: "HummingbirdFluent", package: "hummingbird-fluent"),
                .product(name: "FluentSQLiteDriver", package: "fluent-sqlite-driver"),
                .product(name: "WebAuthn", package: "webauthn-swift"),
                .product(name: "Mustache", package: "swift-mustache"),
                .product(name: "JWTKit", package: "jwt-kit"),
                .product(name: "SwiftASN1", package: "swift-asn1"),
				.product(name: "OTel", package: "swift-otel"),
				.product(name: "Configuration", package: "swift-configuration"),
                "MastodonData",
                "Storage",
            ],
            path: "Sources/App",
            resources: [.process("Resources")]
        ),
        .target(
            name: "MastodonData",
            dependencies: [
                .product(name: "Hummingbird", package: "hummingbird")
            ],
            path: "Sources/MastodonData"
        ),
        // .target(name: "KeyStorage", dependencies: []),
        .target(name: "Storage", dependencies: [], path: "Sources/Storage"),
        .testTarget(
            name: "MastodonDataTests",
            dependencies: [
                .byName(name: "MastodonData"),
                .byName(name: "Storage"),
            ],
            path: "Tests/MastodonData"
        ),
        .testTarget(
            name: "AppTests",
            dependencies: [
                .byName(name: "App"),
                .product(name: "HummingbirdTesting", package: "hummingbird"),
            ],
            path: "Tests/AppTests"
        ),
        .testTarget(
            name: "SignatureMiddlewareTests",
            dependencies: [
                // .byName(name: "KeyStorage")
                .product(name: "Crypto", package: "swift-crypto"),
                .product(name: "SwiftASN1", package: "swift-asn1"),
            ],
            path: "Tests/SignatureMiddleware"
        ),
    ]
)
