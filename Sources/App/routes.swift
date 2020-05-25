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
        let safeName = name.replacingOccurrences(of: "'", with: "")
        return req.view.render("lobby", User(username: safeName))
    }
    
    app.get("game") { req -> EventLoopFuture<View> in
        var name: String? = req.query["username"]
        if (name == nil || name == ""){
            name = "Anonymous_\(Int.random(in: 1..<100))"
        }
        name = name!.replacingOccurrences(of: "'", with: "")
        guard let game: GameConfig.ID = req.query["gameID"] else {
            return req.view.render("lobby", User(username: name!))
        }
        return req.view.render("game", GameConfig(username: name!, gameID: game))
    }

    app.get("hello") { req -> String in
        return "Hello, world!"
    }
    
    let chat = ChatController()
    app.webSocket("socket", onUpgrade: chat.socket)

//    let todoController = TodoController()
//    app.get("todos", use: todoController.index)
//    app.post("todos", use: todoController.create)
//    app.delete("todos", ":todoID", use: todoController.delete)
}
