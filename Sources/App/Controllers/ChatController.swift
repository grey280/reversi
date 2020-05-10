//
//  File.swift
//  
//
//  Created by Grey Patterson on 5/9/20.
//

import Vapor
import Combine

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
    private static var rooms: [String: ChatRoom] = [:]
    
    private var subscriptions: [AnyCancellable] = []
    
    func socket(_ req: Request, _ ws: WebSocket) -> () {
        print("Socket connected")
        var userName: String? = nil
        var joinedChatRoom: String? = nil
         ws.onClose.whenComplete { (res) in
            print("Socket disconnected")
            if let roomName = joinedChatRoom, let user = userName {
                guard let room = ChatController.rooms[roomName] else {
                    print("User \(user) was in room \(roomName), but room was not found")
                    return
                }
                room.users.remove(user)
            }
        }
        ws.onText { (ws, text) in
            guard let command = self.parseCommand(text) else {
                return
            }
            switch command {
            case .joinRoom(let room, let username):
                let chatRoom: ChatRoom
                if ChatController.rooms[room] == nil {
                    ChatController.rooms[room] = ChatRoom()
                }
                chatRoom = ChatController.rooms[room]!
                chatRoom.queue.send(.userJoined(name: username))
                let subscription = chatRoom.queue.sink(receiveValue: { (event) in
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

