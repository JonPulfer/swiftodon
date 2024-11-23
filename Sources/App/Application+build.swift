import Hummingbird
import Logging
import PersonStorage

/// Application arguments protocol. We use a protocol so we can call
/// `buildApplication` inside Tests as well as in the App executable.
/// Any variables added here also have to be added to `App` in App.swift and
/// `TestArguments` in AppTest.swift
public protocol AppArguments {
	var hostname: String { get }
	var port: Int { get }
	var logLevel: Logger.Level? { get }
}

// Request context used by application
typealias AppRequestContext = BasicRequestContext

///  Build application
/// - Parameter arguments: application arguments
public func buildApplication(_ arguments: some AppArguments) async throws -> some ApplicationProtocol {
	let environment = Environment()
	let logger = {
		var logger = Logger(label: "swiftodon")
		logger.logLevel =
			arguments.logLevel ??
			environment.get("LOG_LEVEL").map { Logger.Level(rawValue: $0) ?? .info } ??
			.info
		return logger
	}()
	let router = await buildRouter()
	let app = Application(
		router: router,
		configuration: .init(
			address: .hostname(arguments.hostname, port: arguments.port),
			serverName: "swiftodon"
		),
		logger: logger
	)

	return app
}

/// Build router
func buildRouter() async -> Router<AppRequestContext> {
	let router = Router(context: AppRequestContext.self)
	// Add middleware
	router.addMiddleware {
		// logging middleware
		LogRequestsMiddleware(.info)
	}
	// Add health endpoint
	router.get("/health") { _, _ -> HTTPResponse.Status in
		.ok
	}
	let repos = await SqlitePersonStorage(migrate: true)
	router.addRoutes(PersonController(repository: repos).endpoints, atPath: "/person/")
	return router
}
