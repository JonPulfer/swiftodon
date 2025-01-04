import FluentSQLiteDriver
import Foundation
import Hummingbird
import HummingbirdAuth
import HummingbirdFluent
import HummingbirdRouter
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
    await fluent.migrations.add(CreateFluentPerson())
    await fluent.migrations.add(CreateFluentWebAuthnCredential())
    await fluent.migrations.add(CreateFluentStatus())
    await fluent.migrations.add(CreateStatusAccountIdIndex())
    await fluent.migrations.add(CreateStatusConversationIdIndex())
    await fluent.migrations.add(CreateStatusInReplyToIdIndex())
    try await fluent.migrate()

    // load mustache template library
    let library = try await MustacheLibrary(directory: Bundle.module.resourcePath!)

    let personRepos = FluentPersonStorage(fluent: fluent)

    /// Authenticator storing the user
    let webAuthnSessionAuthenticator = SessionAuthenticator(
        users: personRepos,
        context: WebAuthnRequestContext.self
    )

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
                webAuthnSessionAuthenticator: webAuthnSessionAuthenticator
            )
        }

        RouteGroup("person") {
            PersonController(repository: personRepos, webAuthnSessionAuthenticator: webAuthnSessionAuthenticator)
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
