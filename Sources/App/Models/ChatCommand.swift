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
    case invite(user: ChatUser)
    case uninvite(user: ChatUser)
    case accept(user: ChatUser)
    case play(x: Int, y: Int)
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
        case .invite:
            let user = try container.decode(ChatUser.self, forKey: .user)
            self = .invite(user: user)
        case .uninvite:
            let user = try container.decode(ChatUser.self, forKey: .user)
            self = .uninvite(user: user)
        case .accept:
            let user = try container.decode(ChatUser.self, forKey: .user)
            self = .accept(user: user)
        case .play:
            let x = try container.decode(Int.self, forKey: .x)
            let y = try container.decode(Int.self, forKey: .y)
            self = .play(x: x, y: y)
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
        case .invite(let user):
            try container.encode(CommandType.invite.rawValue, forKey: .command)
            try container.encode(user, forKey: .user)
        case .uninvite(let user):
            try container.encode(CommandType.uninvite.rawValue, forKey: .command)
            try container.encode(user, forKey: .user)
        case .accept(user: let user):
            try container.encode(CommandType.accept.rawValue, forKey: .command)
            try container.encode(user, forKey: .user)
        case .play(x: let x, y: let y):
            try container.encode(x, forKey: .x)
            try container.encode(y, forKey: .y)
        }
    }
    
    fileprivate enum CodingKeys: String, CodingKey {
        case command
        case room
        case username
        case messageBody
        case user
        case x
        case y
    }
    
    fileprivate enum CommandType: String {
        case joinRoom
        case sendMessage
        case invite
        case uninvite
        case accept
        case play
    }
    
}

extension ChatCommand.CommandType: Codable { }
