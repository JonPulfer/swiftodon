import Foundation
import Hummingbird
import HummingbirdTesting
import Logging
import Testing

@testable import swiftodon

@Suite struct AppTests {
	struct TestArguments: AppArguments {
		let hostname = "127.0.0.1"
		let port = 0
		let logLevel: Logger.Level? = .trace
	}

	@Test func testAppBuilds() async throws {
		let args = TestArguments()
		let app = try await buildApplication(args)
		try await app.test(.router) { client in
			try await client.execute(uri: "/health", method: .get) { response in
				#expect(response.status == .ok)
			}
		}
	}
}

@Suite struct ObjectDecoding {
	let goodObject: String = """
	 {
	   "@context": "https://www.w3.org/ns/activitystreams",
	   "type": "Object",
	   "id": "http://www.test.example/object/1",
	   "name": "A Simple, non-specific object",
	   "attachment": [
		 {
		   "@context": "https://www.w3.org/ns/activitystreams",
		   "type": "Link",
		   "href": "http://example.org/abc",
		   "hreflang": "en",
		   "mediaType": "text/html",
		   "name": "An example link"
		 }
	   ]
	 }
	"""

	@Test func TestObjectDecode() {
		let jsonData = goodObject.data(using: .utf8)!
		let decodedObject: Object = try! JSONDecoder().decode(Object.self, from: jsonData)
		#expect(decodedObject.name == "A Simple, non-specific object")
	}
}

@Test func Test() {}
