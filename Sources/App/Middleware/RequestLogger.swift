//
//  RequestLogger.swift
//
//
//  Created by Jonathan Pulfer on 18/04/2025.
//

import Foundation
import Hummingbird

public struct RequestLoggerMiddleware<Context: RequestContext>: RouterMiddleware {
    public func handle(
        _ request: Request,
        context: Context,
        next: (Request, Context) async throws -> Response
    ) async throws -> Response {

        var request = request
        var requestBody = try await request.collectBody(upTo: (1024 * 1024 * 4))

        context.logger.info("headers: \(request.headers)")
        context.logger.info("path: \(request.uri.path)")
        context.logger.info(
            "requestBody: \(String(data: requestBody.readData(length: requestBody.capacity) ?? Data(), encoding: .utf8) ?? "")"
        )

        return try await next(request, context)
    }
}
