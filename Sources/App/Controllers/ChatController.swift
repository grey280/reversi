//
//  File.swift
//  
//
//  Created by Grey Patterson on 5/9/20.
//

import Vapor
import OpenCombine
import Ink

class ChatController {
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    private let markdownParser = MarkdownParser()
    private static var rooms: [String: ChatRoom] = [:]
    
    private var subscriptions: [AnyCancellable] = []
    
    // Session variables
    var user: ChatUser? = nil
//    var userName: String? = nil
    var joinedChatRoom: String? = nil
    
    private func onDisconnect(_ res: Result<Void, Error>) {
        print("Socket disconnected")
        if let roomName = joinedChatRoom, let user = user {
            guard let room = ChatController.rooms[roomName] else {
                print("User \(user) was in room \(roomName), but room was not found")
                return
            }
            print("\(user.username) left \(roomName)")
            room.users.remove(user)
            if (room.userCount == 0){
                print("Room \(roomName) is empty; removing.")
                ChatController.rooms.removeValue(forKey: roomName)
            }
        } else {
            print("Unable to determine room or user name; nothing to do")
        }
    }
    private func routeCommand(_ ws: WebSocket, _ text: String){
        print("Command received")
        guard let command = self.parseCommand(text) else {
            print("Unable to parse command.")
            return
        }
        switch command {
        case .joinRoom(let room, let username):
            self.joinRoom(room: room, username: username, ws: ws)
        case .sendMessage(let message):
            self.sendMessage(message, ws: ws)
        }
    }
    
    private func sendMessage(_ message: String, ws: WebSocket){
        guard let user = self.user, let roomName = self.joinedChatRoom, let room = ChatController.rooms[roomName] else {
            print("User attempted to send a message without first joining a room.")
            return
        }
        let body = self.markdownParser.html(from: message)
        room.queue.send(.message(user: user, body: body))
    }
    
    private func joinRoom(room: String, username: String, ws: WebSocket){
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
        self.user = asUser
        chatRoom.users.insert(asUser)
        self.joinedChatRoom = room
    }
    
    func socket(_ req: Request, _ ws: WebSocket) -> () {
        print("Socket connected")
        ws.onClose.whenComplete(onDisconnect(_:))
        ws.onText(routeCommand(_:_:))
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
