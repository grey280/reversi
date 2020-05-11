//
//  File.swift
//  
//
//  Created by Grey Patterson on 5/9/20.
//

import Foundation

enum ChatCommand {
    case joinRoom(room: String, username: String)
    case sendMessage(message: String)
}

extension ChatCommand: Codable {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(CommandType.self, forKey: .command)
        switch type {
        case .joinRoom:
            let room = try container.decode(String.self, forKey: .room)
            let username = try container.decode(String.self, forKey: .username)
            self = .joinRoom(room: room, username: username)
        case .sendMessage:
            let body = try container.decode(String.self, forKey: .messageBody)
            self = .sendMessage(message: body)
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .joinRoom(let room, let username):
            try container.encode(CommandType.joinRoom.rawValue, forKey: .command)
            try container.encode(room, forKey: .room)
            try container.encode(username, forKey: .username)
        case .sendMessage(let message):
            try container.encode(CommandType.sendMessage.rawValue, forKey: .command)
            try container.encode(message, forKey: .messageBody)
        }
    }
    
    fileprivate enum CodingKeys: String, CodingKey {
        case command
        case room
        case username
        case messageBody
    }
    
    fileprivate enum CommandType: String {
        case joinRoom
        case sendMessage
    }
    
}

extension ChatCommand.CommandType: Codable { }
