//
//  File.swift
//  
//
//  Created by Grey Patterson on 5/9/20.
//

import Vapor

struct ChatController {
    private let decoder = JSONDecoder()
    
    func socket(_ req: Request, _ ws: WebSocket) -> () {
        print("Socket connected")
         ws.onClose.whenComplete { (res) in
            print("Socket disconnected")
        }
        ws.onText { (ws, text) in
            guard let command = self.parseCommand(text) else {
                return
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
    
    enum ChatCommand {
        case joinRoom(room: String, username: String)
    }
    
    
}


extension ChatController.ChatCommand: Codable {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(CommandType.self, forKey: .command)
        switch type {
        case .joinRoom:
            let room = try container.decode(String.self, forKey: .room)
            let username = try container.decode(String.self, forKey: .username)
            self = .joinRoom(room: room, username: username)
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .joinRoom(let room, let username):
            try container.encode(CommandType.joinRoom.rawValue, forKey: .command)
            try container.encode(room, forKey: .room)
            try container.encode(username, forKey: .username)
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case command
        case room
        case username
    }
    
    enum CommandType: String {
        case joinRoom
    }
    
}
extension ChatController.ChatCommand.CommandType: Codable { }
