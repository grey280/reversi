//
//  File.swift
//  
//
//  Created by Grey Patterson on 5/9/20.
//

import Vapor
import Combine

class ChatController {
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    private static var rooms: [String: PassthroughSubject<ChatEvent, Never>] = [:]
    
    private var subscriptions: [AnyCancellable] = []
    
    func socket(_ req: Request, _ ws: WebSocket) -> () {
        print("Socket connected")
         ws.onClose.whenComplete { (res) in
            print("Socket disconnected")
        }
        ws.onText { (ws, text) in
            guard let command = self.parseCommand(text) else {
                return
            }
            switch command {
            case .joinRoom(let room, let username):
                let chatRoom: PassthroughSubject<ChatEvent, Never>
                if ChatController.rooms[room] == nil {
                    ChatController.rooms[room] = PassthroughSubject<ChatEvent, Never>()
                }
                chatRoom = ChatController.rooms[room]!
                chatRoom.send(.userJoined(name: username))
                let subscription = chatRoom.sink(receiveValue: { (event) in
                    if let res = self.parseEvent(event) {
                        ws.send(res)
                    }
                })
                self.subscriptions.append(subscription)
                let result: JoinRoomResponse = .success(room: room, username: username, membership: <#T##Int#>)
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
    
    private func parseEvent(_ event: ChatEvent) -> String? {
        do {
            let foo = try encoder.encode(event)
            return String(bytes: foo, encoding: .utf8)
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
    
    
}


