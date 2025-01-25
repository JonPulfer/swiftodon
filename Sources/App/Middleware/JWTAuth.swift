import FluentKit
import Foundation
import Hummingbird
import HummingbirdAuth
import HummingbirdFluent
import JWTKit
import Logging

struct JWTAuth: AuthenticatorMiddleware {
    public typealias Context = WebAuthnRequestContext
    let jwtKeyCollection: JWTKeyCollection
    let logger: Logger
    let fluent: Fluent

    func authenticate(request: Request, context: WebAuthnRequestContext) async throws -> Person? {
        guard
            let bearerToken = request.headers.bearer
        else {
            return nil
        }
        let jwtToken = bearerToken.token
        let payload: UserPayload
        do {
            payload = try await jwtKeyCollection.verify(jwtToken, as: UserPayload.self)
        } catch {
            logger.warning("could not verify token: \(jwtToken)")
            return nil
        }
        context.sessions.setSession(
            .authenticated(userId: UUID(uuidString: payload.userID)!),
            expiresIn: .seconds(payload.expiration.value.timeIntervalSinceNow)
        )

        guard
            let person = try await FluentPersonModel.query(on: fluent.db())
                .filter(\.$id == UUID(uuidString: payload.userID)!)
                .first()
        else {
            return nil
        }

        return person.fluentModelToPersonModel()
    }
}
