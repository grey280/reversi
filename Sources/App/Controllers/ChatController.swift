//
//  File.swift
//  
//
//  Created by Grey Patterson on 5/9/20.
//

import Vapor
import OpenCombine
import Ink

class ChatRoom {
    let queue = PassthroughSubject<ChatEvent, Never>()
    var users: Set<String> = []
    
    var userCount: Int {
        users.count
    }
}

class ChatController {
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    private let markdownParser = MarkdownParser()
    private static var rooms: [String: ChatRoom] = [:]
    
    private var subscriptions: [AnyCancellable] = []
    
    func socket(_ req: Request, _ ws: WebSocket) -> () {
        print("Socket connected")
        var userName: String? = nil
        var joinedChatRoom: String? = nil
         ws.onClose.whenComplete { (res) in
            print("Socket disconnected.")
            if let roomName = joinedChatRoom, let user = userName {
                guard let room = ChatController.rooms[roomName] else {
                    print("User \(user) was in room \(roomName), but room was not found")
                    return
                }
                print("\(user) left \(roomName)")
                room.users.remove(user)
            } else {
                print("Unable to determine room or user name; nothing to do")
            }
        }
        ws.onText { (ws, text) in
            print("Command received!")
            guard let command = self.parseCommand(text) else {
                return
            }
            switch command {
            case .joinRoom(let room, let username):
                print("Chat: \(username) requested to join \(room)")
                let chatRoom: ChatRoom
                if ChatController.rooms[room] == nil {
                    ChatController.rooms[room] = ChatRoom()
                }
                chatRoom = ChatController.rooms[room]!
                chatRoom.queue.send(.userJoined(username: username))
                let subscription = chatRoom.queue.sink(receiveValue: { (event) in
                    print("Chat: sending event to \(username)")
                    if let res = self.codableAsString(event) {
                        ws.send(res)
                    }
                })
                self.subscriptions.append(subscription)
                let result: JoinRoomResponse = .success(room: room, username: username, membership: chatRoom.userCount)
                guard let asString = self.codableAsString(result) else {
                    return
                }
                ws.send(asString)
                userName = username
                joinedChatRoom = room
            case .sendMessage(let message):
                guard let userName = userName, let roomName = joinedChatRoom, let room = ChatController.rooms[roomName] else {
                    print("User attempted to send a message without first joining a room.")
                    return
                }
                let body = self.markdownParser.html(from: message)
                room.queue.send(.message(username: userName, body: body))
            }
        }
    }
    
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
