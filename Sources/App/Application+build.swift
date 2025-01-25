import FluentSQLiteDriver
import Foundation
import Hummingbird
import HummingbirdAuth
import HummingbirdFluent
import HummingbirdRouter
import JWTKit
import Logging
import Mustache

/// Application arguments protocol. We use a protocol so we can call
/// `buildApplication` inside Tests as well as in the App executable.
/// Any variables added here also have to be added to `App` in App.swift and
/// `TestArguments` in AppTest.swift
public protocol AppArguments {
    var hostname: String { get }
    var port: Int { get }
    var logLevel: Logger.Level? { get }
    var inMemoryDatabase: Bool { get }
    var certificateChain: String { get }
    var privateKey: String { get }
}

// Request context used by application
typealias AppRequestContext = BasicSessionRequestContext<UUID, Person>

///  Build application
/// - Parameter arguments: application arguments
public func buildApplication(_ arguments: some AppArguments) async throws -> some ApplicationProtocol {
    let environment = Environment()
    let logger = {
        var logger = Logger(label: "swiftodon")
        logger.logLevel =
            arguments.logLevel ?? environment.get("LOG_LEVEL").map { Logger.Level(rawValue: $0) ?? .debug } ?? .info
        return logger
    }()

    /// Fluent is being used for storing relational data.
    ///
    /// To change the underlying datastore to a different RDBMS:
    ///  - Change the dependencies in the 'Package' file
    ///  - Change the imports to use the new driver
    ///  - Change the database settings here
    let fluent = Fluent(logger: logger)
    if arguments.inMemoryDatabase {
        fluent.databases.use(.sqlite(.memory), as: .sqlite)
    } else {
        fluent.databases.use(.sqlite(.file("db.sqlite"), sqlLogLevel: .info), as: .sqlite)
    }
    let persist = await FluentPersistDriver(fluent: fluent)
    await AddPersonMigrations(fluent: fluent)
    await fluent.migrations.add(CreateFluentWebAuthnCredential())
    await AddStatusMigrations(fluent: fluent)
    try await fluent.migrate()

    // load mustache template library
    let library = try await MustacheLibrary(directory: Bundle.module.resourcePath!)

    let personRepos = FluentPersonStorage(fluent: fluent)

    /// Authenticator storing the user
    let webAuthnSessionAuthenticator = SessionAuthenticator(
        users: personRepos,
        context: WebAuthnRequestContext.self
    )

    /// JWT set up
    let keyCollection = JWTKeyCollection()
    guard
        let jwtSecret = ProcessInfo.processInfo.environment["JWT_SECRET"]
    else {
        logger.error("JWT_SECRET is not found in environment")
        throw JWTError.generic(identifier: "JWTKeyCollection", reason: "JWT_SECRET missing from env")
    }
    await keyCollection.add(hmac: HMACKey.init(stringLiteral: jwtSecret), digestAlgorithm: .sha256)

    let router = RouterBuilder(context: WebAuthnRequestContext.self) {
        // logging middleware
        LogRequestsMiddleware(.info)
        // add file middleware to server HTML files
        FileMiddleware(searchForIndexHtml: true, logger: logger)
        // session middleware
        SessionMiddleware(storage: persist)

        HTMLController(
            mustacheLibrary: library,
            fluent: fluent,
            webAuthnSessionAuthenticator: webAuthnSessionAuthenticator
        )

        RouteGroup("api") {
            WebAuthnController(
                webauthn: .init(
                    config: .init(
                        relyingPartyID: "localhost",
                        relyingPartyName: "swiftodon",
                        relyingPartyOrigin: "http://localhost:8080"
                    )
                ),
                fluent: fluent,
                webAuthnSessionAuthenticator: webAuthnSessionAuthenticator,
                jwtKeyCollection: keyCollection
            )

            /// API tree based on the Mastodon API: https://docs.joinmastodon.org/dev/routes/#api
            RouteGroup("v1") {
                // RouteGroup("statuses") {
                //     // StatusController
                // }
                RouteGroup("accounts") {
                    PersonController(
                        repository: personRepos,
                        webAuthnSessionAuthenticator: webAuthnSessionAuthenticator
                    )
                }
            }
        }

        Get("/health") { _, _ -> HTTPResponse.Status in
            return .ok
        }
    }

    var app = Application(
        router: router,
        configuration: .init(
            address: .hostname(arguments.hostname, port: arguments.port),
            serverName: "swiftodon"
        ),
        logger: logger
    )

    app.addServices(fluent)

    return app
}
