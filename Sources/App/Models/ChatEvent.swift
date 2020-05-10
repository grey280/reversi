//
//  File.swift
//  
//
//  Created by Grey Patterson on 5/9/20.
//

import Foundation

enum ChatEvent{
    case userJoined(name: String)
    case message(body: String)
}

extension ChatEvent: Codable {
    fileprivate enum CodingKeys: String, CodingKey {
        case type
        case name
        case message
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(ChatEventType.self, forKey: .type)
        switch type {
        case .message:
            let message = try container.decode(String.self, forKey: .message)
            self = .message(body: message)
        case .userJoined:
            let name = try container.decode(String.self, forKey: .name)
            self = .userJoined(name: name)
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .message(let body):
            try container.encode(ChatEventType.message.rawValue, forKey: .type)
            try container.encode(body, forKey: .message)
        case .userJoined(let name):
            try container.encode(ChatEventType.userJoined.rawValue, forKey: .type)
            try container.encode(name, forKey: .name)
        }
    }
    
    fileprivate enum ChatEventType: String, Codable {
        case userJoined
        case message
    }
}
