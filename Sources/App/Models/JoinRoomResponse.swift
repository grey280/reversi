//
//  File.swift
//  
//
//  Created by Grey Patterson on 5/9/20.
//

import Foundation
enum JoinRoomResponse {
    case success(room: String, username: String, membership: [ChatUser], game: Game?)
    case failure(message: String)
}

extension JoinRoomResponse: Codable {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(JoinRoomResponseState.self, forKey: .state)
        switch type {
        case .success:
            let room = try container.decode(String.self, forKey: .room)
            let username = try container.decode(String.self, forKey: .username)
            let membership = try container.decode([ChatUser].self, forKey: .membership)
            let game = try? container.decode(Game.self, forKey: .game)
            self = .success(room: room, username: username, membership: membership, game: game)
        case .failure:
            let message = try container.decode(String.self, forKey: .message)
            self = .failure(message: message)
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .success(let room, let username, let membership, let game):
            try container.encode(JoinRoomResponseState.success.rawValue, forKey: .state)
            try container.encode(room, forKey: .room)
            try container.encode(username, forKey: .username)
            try container.encode(membership, forKey: .membership)
            if let game = game {
                try container.encode(game, forKey: .game)
            }
        case .failure(let message):
            try container.encode(JoinRoomResponseState.failure.rawValue, forKey: .state)
            try container.encode(message, forKey: .message)
        }
    }
    
    fileprivate enum CodingKeys: String, CodingKey {
        case state
        case room
        case username
        case membership
        case message
        case game
    }
    
    fileprivate enum JoinRoomResponseState: String, Codable {
        case success
        case failure
    }
}
