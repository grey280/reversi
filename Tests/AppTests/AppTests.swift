@testable import App
import XCTVapor

final class AppTests: XCTestCase {
    func testHelloWorld() throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        try configure(app)

        try app.test(.GET, "hello") { res in
            XCTAssertEqual(res.status, .ok)
            XCTAssertEqual(res.body.string, "Hello, world!")
        }
    }
    
    func testIndex() throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        try configure(app)
        
        try app.test(.GET, "/") { res in
            XCTAssertEqual(res.status, .ok)
        }
    }
    
    func testLobby() throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        try configure(app)
        
        try app.test(.GET, "/lobby") { res in
            XCTAssertEqual(res.status, .ok)
        }
        
        try app.test(.GET, "/lobby?username=foo") { res in
            XCTAssertEqual(res.status, .ok)
        }
    }
    
    func testGame() throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        try configure(app)
        
        try app.test(.GET, "/game") { res in
            XCTAssertEqual(res.status, .ok)
        }
        
        try app.test(.GET, "/game?username=foo") { res in
            XCTAssertEqual(res.status, .ok)
        }
        
        try app.test(.GET, "/game?username=foo&gameID=1234") { res in
            XCTAssertEqual(res.status, .ok)
        }
    }
    
    func testStaticPages() throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        try configure(app)
        
        try app.test(.GET, "/") { res in
            XCTAssertEqual(res.status, .ok)
        }
        try app.test(.GET, "/about") { res in
            XCTAssertEqual(res.status, .ok)
        }
        try app.test(.GET, "/name") { res in
            XCTAssertEqual(res.status, .ok)
        }
    }
}
