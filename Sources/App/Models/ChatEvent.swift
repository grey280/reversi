//
//  File.swift
//  
//
//  Created by Grey Patterson on 5/9/20.
//

import Foundation

enum ChatEvent{
    case userJoined(user: ChatUser)
    case message(user: ChatUser, body: String)
    case userLeft(user: ChatUser)
}

extension ChatEvent: Codable {
    fileprivate enum CodingKeys: String, CodingKey {
        case type
        case user
        case message
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(ChatEventType.self, forKey: .type)
        switch type {
        case .message:
            let message = try container.decode(String.self, forKey: .message)
            let user = try container.decode(ChatUser.self, forKey: .user)
            self = .message(user: user, body: message)
        case .userJoined:
            let user = try container.decode(ChatUser.self, forKey: .user)
            self = .userJoined(user: user)
        case .userLeft:
            let user = try container.decode(ChatUser.self, forKey: .user)
            self = .userLeft(user: user)
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .message(let user, let body):
            try container.encode(ChatEventType.message.rawValue, forKey: .type)
            try container.encode(user, forKey: .user)
            try container.encode(body, forKey: .message)
        case .userJoined(let user):
            try container.encode(ChatEventType.userJoined.rawValue, forKey: .type)
            try container.encode(user, forKey: .user)
        case .userLeft(let user):
            try container.encode(ChatEventType.userLeft.rawValue, forKey: .type)
            try container.encode(user, forKey: .user)
        }
    }
    
    fileprivate enum ChatEventType: String, Codable {
        case userJoined
        case message
        case userLeft
    }
}
