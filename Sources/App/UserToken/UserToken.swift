import Foundation
import Hummingbird
import JWTKit

struct UserPayload: JWTPayload {
    let userID: String
    let expiration: ExpirationClaim
    //let roles: RoleClaim

    enum CodingKeys: String, CodingKey {
        case userID = "user_id"
        case expiration = "exp"
        //case roles
    }

    func verify(using key: some JWTAlgorithm) throws {
        try expiration.verifyNotExpired()
        //try roles.verifyAdmin()
    }

    init(from userId: String) {
        self.userID = userId
        self.expiration = .init(value: .init(timeIntervalSinceNow: 3600))  // Token expires in 1 hour
    }
}

struct RoleClaim: JWTClaim {
    var value: [String]

    func verifyAdmin() throws {
        guard value.contains("admin") else {
            throw JWTError.claimVerificationFailure(
                failedClaim: self,
                reason: "User is not an admin"
            )
        }
    }
}

struct TokenResponse: ResponseEncodable {
    let token: String
    let expiry: Date
}
