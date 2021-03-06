//
//  File.swift
//  
//
//  Created by Grey Patterson on 5/9/20.
//

import Vapor
import OpenCombine
import Ink
import NIO

class ChatController {
    private let decoder = JSONDecoder()
    private let encoder: JSONEncoder = {
        let res = JSONEncoder()
        res.dateEncodingStrategy = .millisecondsSince1970
        return res
    }()
    private let markdownParser = MarkdownParser()
    private static var rooms: [String: ChatRoom] = [:]
    
    private var subscriptions: [AnyCancellable] = []
    
    private func onDisconnect(_ res: Result<Void, Error>, user: inout ChatUser?, roomName: inout String?) {
        print("Socket disconnected")
        if let roomName = roomName, let user = user {
            guard let room = ChatController.rooms[roomName] else {
                print("User \(user) was in room \(roomName), but room was not found")
                return
            }
            print("\(user.username) left \(roomName)")
            room.users.remove(user)
            if (room.userCount == 0){
                print("Room \(roomName) is empty; removing.")
                ChatController.rooms.removeValue(forKey: roomName)
            } else {
                room.queue.send(.userLeft(user: user))
            }
        } else {
            print("Unable to determine room or user name; nothing to do")
        }
    }
    
    private func sendMessage(_ message: String, ws: WebSocket, user: ChatUser?, roomName: String?){
        guard let user = user, let roomName = roomName, let room = ChatController.rooms[roomName] else {
            print("User attempted to send a message without first joining a room.")
            return
        }
        if (message.starts(with: "/pm ")){
            let split = message.split(separator: " ", maxSplits: 2, omittingEmptySubsequences: true)
            guard split.count == 3 else {
                room.queue.send(.privateMessage(from: .system, to: user, body: #"<p>Invalid command "\#(split[0])"</p>"#))
                return
            }
            guard let toUser = room.users.first(where: { (roomUser) -> Bool in
                roomUser.username == split[1]
            }) else {
                print("Could not find user to send message to.")
                room.queue.send(.privateMessage(from: .system, to: user, body: "<p>User <strong>\(split[1])</strong> not found.</p>"))
                return
            }
            let body = self.markdownParser.html(from: String(split[2]))
            room.queue.send(.privateMessage(from: user, to: toUser, body: body))
        } else if message.starts(with: "/list"){
            let members = room.users.map { "- \($0.username)" }.sorted().joined(separator: "\n\n")
            let combined = "Users in the room: \n\n\(members)"
            let body = self.markdownParser.html(from: combined)
            room.queue.send(.privateMessage(from: .system, to: user, body: body))
        } else if message.starts(with: "/help"){
            let help = """
Available commands:

* `/list`: see users in the room
* `/help`: see this help message
* `/pm {username}`: send a private message to `{username}`

You can format your text using [Markdown](https://daringfireball.net/projects/markdown/).
"""
            let body = self.markdownParser.html(from: help)
            room.queue.send(.privateMessage(from: .system, to: user, body: body))
        } else {
            let body = self.markdownParser.html(from: message)
            room.queue.send(.message(user: user, body: body))
        }
    }
    
    func socket(_ req: Request, _ ws: WebSocket) -> () {
        ws.pingInterval = TimeAmount.seconds(10)
        
        print("Socket connected")
        var user: ChatUser? = nil
        var inRoom: String? = nil
        ws.onClose.whenComplete { (res) in
            self.onDisconnect(res, user: &user, roomName: &inRoom)
        }
        ws.onText { (ws, text) in
            print("Command received")
            guard let command = self.parseCommand(text) else {
                print("Unable to parse command.")
                return
            }
            switch command {
            case .joinRoom(let room, let username):
                if (username == "System"){
                    print("Chat: user attempted to join with illegal username 'System'")
                    return
                }
                print("Chat: \(username) requested to join \(room)")
                let chatRoom: ChatRoom
                if ChatController.rooms[room] == nil {
                    ChatController.rooms[room] = ChatRoom()
                }
                chatRoom = ChatController.rooms[room]!
                let asUser = ChatUser(username)
                chatRoom.queue.send(.userJoined(user: asUser))
                let subscription = chatRoom.queue.sink(receiveValue: { (event) in
                    switch (event){
                    case .privateMessage(let fromUser, let toUser, _), .invite(from: let fromUser, to: let toUser), .uninvite(from: let fromUser, to: let toUser), .accept(from: let fromUser, to: let toUser, gameID: _):
                        guard toUser == user || fromUser == user, let res = self.codableAsString(event) else {
                            return // not for you!
                        }
                        ws.send(res)
                    default:
                        print("Chat: sending event to \(username)")
                        if let res = self.codableAsString(event) {
                            ws.send(res)
                        }
                    }
                })
                self.subscriptions.append(subscription)
                let result: JoinRoomResponse = .success(room: room, username: username, membership: Array(chatRoom.users), game: chatRoom.game)
                guard let asString = self.codableAsString(ChatEvent.roomJoined(payload: result)) else {
                    return
                }
                ws.send(asString)
                user = asUser
                chatRoom.users.insert(asUser)
                inRoom = room
            case .sendMessage(let message):
                self.sendMessage(message, ws: ws, user: user, roomName: inRoom)
            case .invite(let toUser):
                guard let roomName = inRoom, let room = ChatController.rooms[roomName] else {
                    print("Invite: user \(user?.username ?? "unnamed user") is not in a room.")
                    return
                }
                guard let user = user else {
                    print("Invite: 'from' user is not defined")
                    return
                }
                room.queue.send(.invite(from: user, to: toUser))
            case .uninvite(let toUser):
                guard let roomName = inRoom, let room = ChatController.rooms[roomName] else {
                    print("Uninvite: user \(user?.username ?? "unnamed user") is not in a room.")
                    return
                }
                guard let user = user else {
                    print("Uninvite: 'from' user is not defined")
                    return
                }
                room.queue.send(.uninvite(from: user, to: toUser))
            case .accept(user: let toUser):
                guard let roomName = inRoom, let room = ChatController.rooms[roomName] else {
                    print("Accept: user \(user?.username ?? "unnamed user") is not in a room.")
                    return
                }
                guard let user = user else {
                    print("Accept: 'from' user is not defined")
                    return
                }
                let randomized = Bool.random()
                let newGame = Game(white: randomized ? user : toUser, black: randomized ? toUser : user)
                // create the room in advance, so it'll be there
                let newChatRoom: ChatRoom
                if ChatController.rooms[newGame.id.uuidString] == nil {
                    ChatController.rooms[newGame.id.uuidString] = ChatRoom()
                }
                newChatRoom = ChatController.rooms[newGame.id.uuidString]!
                newChatRoom.game = newGame
                room.queue.send(.accept(from: user, to: toUser, gameID: newGame.id))
            case .play(x: let x, y: let y):
                guard let roomName = inRoom, let room = ChatController.rooms[roomName], let game = room.game else {
                    print("Accept: user \(user?.username ?? "unnamed user") is not in a gameplay room.")
                    return
                }
                guard let user = user else {
                    print("Accept: 'from' user is not defined")
                    return
                }
                let isUserWhite = game.white.username == user.username
                guard game.whoseTurn == (isUserWhite ? .white : .black) else {
                    print("User attempted to play when it wasn't their turn")
                    return
                }
                game.play(row: y, column: x, player: isUserWhite ? .white : .black)
                room.queue.send(.gameUpdate(game: game))
            }
        }
    }
    
    // MARK: Helpers
    
    private func parseCommand(_ text: String) -> ChatCommand? {
        do {
            let jsonData = Data(text.utf8)
            return try decoder.decode(ChatCommand.self, from: jsonData)
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
    private func codableAsString<T: Encodable>(_ input: T) -> String? {
        do {
            let data = try encoder.encode(input)
            return String(bytes: data, encoding: .utf8)
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
}
