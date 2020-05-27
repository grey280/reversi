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
    case privateMessage(from: ChatUser, to: ChatUser, body: String)
    case userLeft(user: ChatUser)
    case invite(from: ChatUser, to: ChatUser)
    case uninvite(from: ChatUser, to: ChatUser)
    case roomJoined(payload: JoinRoomResponse)
    case accept(from: ChatUser, to: ChatUser, gameID: GameConfig.ID)
    case gameUpdate(game: Game)
    
    enum ChatEventType: String, Codable {
        case userJoined
        case message
        case privateMessage
        case userLeft
        case invite
        case uninvite
        case accept
        case roomJoined
        case gameUpdate
    }
}

extension ChatEvent {
    var eventType: ChatEventType {
        switch self {
        case .message:
            return .message
        case .privateMessage:
            return .privateMessage
        case .userJoined:
            return .userJoined
        case .userLeft:
            return .userLeft
        case .invite:
            return .invite
        case .uninvite:
            return .uninvite
        case .roomJoined:
            return .roomJoined
        case .accept:
            return .accept
        case .gameUpdate:
            return .gameUpdate
        }
    }
}

extension ChatEvent: Codable {
    fileprivate enum CodingKeys: String, CodingKey {
        case type
        case user
        case toUser
        case message
        case payload
        case gameID
        case game
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
        case .privateMessage:
            let fromUser = try container.decode(ChatUser.self, forKey: .user)
            let toUser = try container.decode(ChatUser.self, forKey: .toUser)
            let body = try container.decode(String.self, forKey: .message)
            self = .privateMessage(from: fromUser, to: toUser, body: body)
        case .invite:
            let fromUser = try container.decode(ChatUser.self, forKey: .user)
            let toUser = try container.decode(ChatUser.self, forKey: .toUser)
            self = .invite(from: fromUser, to: toUser)
        case .uninvite:
            let fromUser = try container.decode(ChatUser.self, forKey: .user)
            let toUser = try container.decode(ChatUser.self, forKey: .toUser)
            self = .uninvite(from: fromUser, to: toUser)
        case .accept:
            let fromUser = try container.decode(ChatUser.self, forKey: .user)
            let toUser = try container.decode(ChatUser.self, forKey: .toUser)
            let gameID = try container.decode(GameConfig.ID.self, forKey: .gameID)
            self = .accept(from: fromUser, to: toUser, gameID: gameID)
        case .roomJoined:
            let payload = try container.decode(JoinRoomResponse.self, forKey: .payload)
            self = .roomJoined(payload: payload)
        case .gameUpdate:
            let game = try container.decode(Game.self, forKey: .game)
            self = .gameUpdate(game: game)
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.eventType.rawValue, forKey: .type)
        switch self {
        case .message(let user, let body):
            try container.encode(user, forKey: .user)
            try container.encode(body, forKey: .message)
        case .userJoined(let user):
            try container.encode(user, forKey: .user)
        case .userLeft(let user):
            try container.encode(user, forKey: .user)
        case .privateMessage(let fromUser, let toUser, let body):
            try container.encode(fromUser, forKey: .user)
            try container.encode(toUser, forKey: .toUser)
            try container.encode(body, forKey: .message)
        case .invite(let fromUser, let toUser), .uninvite(let fromUser, let toUser):
            try container.encode(fromUser, forKey: .user)
            try container.encode(toUser, forKey: .toUser)
        case .accept(let fromUser, let toUser, let gameID):
            try container.encode(fromUser, forKey: .user)
            try container.encode(toUser, forKey: .toUser)
            try container.encode(gameID, forKey: .gameID)
        case .roomJoined(payload: let payload):
            try container.encode(payload, forKey: .payload)
        case .gameUpdate(game: let game):
            try container.encode(game, forKey: .game)
        }
    }
}
