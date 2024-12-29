//
//  ObjectProtocols.swift
//
//
//  Created by Jonathan Pulfer on 08/09/2024.
//

import Foundation

protocol AttributeTo {
    var attributableTo: String { get }
}

protocol ObjectOrLink: Codable {
    var isObject: Bool { get }
    var isLink: Bool { get }
}
