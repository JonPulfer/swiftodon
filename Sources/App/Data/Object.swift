//
//  Object.swift
//
//
//  Created by Jonathan Pulfer on 08/09/2024.
//

struct Object {
	var name: String
	var attachment: Attachment
	var attributedTo: [AttributeTo]
}

struct Attachment {
	var type: String
	var content: String
	var url: String
}

struct Attribution: AttributeTo {
	var type: String
	var name: String
	
	var attributableTo: String {
		get {
			return "\(self.type) \(self.name)"
		}
	}
}

extension String: AttributeTo {
	var attributableTo: String {
		get {
			return self
		}
	}
}
