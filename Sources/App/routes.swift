import Fluent
import Vapor

func routes(_ app: Application) throws {
    app.get { req  in
        req.view.render("index")
    }
    app.get("about") { req in
        req.view.render("about")
    }
    app.get("name") { req in
        req.view.render("name")
    }
    app.get("lobby") { req -> EventLoopFuture<View> in
        guard let name: String = req.query["username"], name != "" else {
            return req.view.render("lobby", User(username: "Anonymous_\(Int.random(in: 1..<100))"))
        }
        return req.view.render("lobby", User(username: name))
    }

    app.get("hello") { req -> String in
        return "Hello, world!"
    }
    
    app.webSocket("socket") { req, ws in
        print("Socket connected")
        ws.onClose.whenComplete { (res) in
            print("Socket disconnected")
        }
    }

//    let todoController = TodoController()
//    app.get("todos", use: todoController.index)
//    app.post("todos", use: todoController.create)
//    app.delete("todos", ":todoID", use: todoController.delete)
}
