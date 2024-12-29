//
//  html.swift
//  swiftodon
//
//  Created by Jonathan Pulfer on 27/12/2024.
//
import Hummingbird

/// Type wrapping HTML code. Will convert to HBResponse that includes the correct
/// content-type header
struct HTML: ResponseGenerator {
    let html: String

    public func response(from _: Request, context _: some RequestContext) throws -> Response {
        let buffer = ByteBuffer(string: html)
        return .init(status: .ok, headers: [.contentType: "text/html"], body: .init(byteBuffer: buffer))
    }
}
