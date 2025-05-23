import ArgumentParser
import Hummingbird
import Logging
import Foundation

@main
struct App: AsyncParsableCommand, AppArguments {
    @Flag(name: .shortAndLong)
    var inMemoryDatabase: Bool = false

    var privateKey: String { "certs/server.key" }
    var certificateChain: String { "certs/server.crt" }

    @Option(name: .shortAndLong)
    var hostname: String = "127.0.0.1"

    @Option(name: .shortAndLong)
    var port: Int = 8080

    @Option(name: .shortAndLong)
    var logLevel: Logger.Level?

    func run() async throws {
        let app = try await buildApplication(self)
        try await app.runService()
    }
}

/// Extend `Logger.Level` so it can be used as an argument
#if hasFeature(RetroactiveAttribute)
extension Logger.Level: @retroactive ExpressibleByArgument {}
#else
extension Logger.Level: ExpressibleByArgument {}
#endif

public func serverURL() -> String {
    if let envServerName = ProcessInfo.processInfo.environment["SWIFTODON_HOSTNAME"] {
        return "https://" + envServerName
    }
    return "http://localhost:8080"
}

public func serverName() -> String {
    if let envServerName = ProcessInfo.processInfo.environment["SWIFTODON_HOSTNAME"] {
        return envServerName
    }
    return "localhost"
}
