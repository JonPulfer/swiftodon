import Foundation
import Hummingbird
import HummingbirdFluent
import HummingbirdTesting
import Logging
import Testing

@testable import App

@Suite struct AppTests {
    struct TestAppArguments: AppArguments {
        var privateKey: String { "certs/server.key" }
        var certificateChain: String { "certs/server.crt" }

        let inMemoryDatabase = true
        let hostname = "127.0.0.1"
        let port = 0
        let logLevel: Logger.Level? = .trace
    }

    var app: any ApplicationProtocol

    init() async throws {
        self.app = try await buildApplication(TestAppArguments())
    }

    @Test func testAppBuilds() async throws {
        try await app.test(.router) { client in
            try await client.execute(uri: "/health", method: .get) { response in
                #expect(response.status == .ok)
            }
        }
    }
}

@Suite struct PersonTests {
    struct TestAppArguments: AppArguments {
        var privateKey: String { "certs/server.key" }
        var certificateChain: String { "certs/server.crt" }

        let inMemoryDatabase = true
        let hostname = "127.0.0.1"
        let port = 0
        let logLevel: Logger.Level? = .trace
    }

    var app: any ApplicationProtocol

    init() async throws {
        self.app = try await buildApplication(TestAppArguments())
    }

    @Test func testPersonCreate() async throws {
        try await app.test(.live) { client in
            let personRepos = FluentPersonStorage(fluent: app.services[0] as! Fluent)
            if let person = try personRepos.create(from: CreatePerson(name: "testperson", fullName: "a test")) {
                #expect(person.name == "testperson")
            }
        }
    }

    @Test func testPersonGet() async throws {
        try await app.test(.live) { client in
            let personRepos = FluentPersonStorage(fluent: app.services[0] as! Fluent)
            let person = try personRepos.create(from: CreatePerson(name: "testperson", fullName: "a test"))!

            let getCriteria = PersonCriteria(handle: nil, id: person.id)
            let fetchedPerson = await personRepos.get(criteria: getCriteria)
            #expect(fetchedPerson != nil)
            #expect(fetchedPerson?.fullName == person.fullName)
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
