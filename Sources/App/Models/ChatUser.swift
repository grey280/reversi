//
//  File.swift
//  
//
//  Created by Grey Patterson on 5/17/20.
//

import Foundation

final class ChatUser {
    let username: String
    let isSystem: Bool
    init(_ username: String, isSystem: Bool = false){
        self.username = username
        self.isSystem = isSystem
    }
    
    static var system: ChatUser {
        ChatUser("System", isSystem: true)
    }
}

extension ChatUser: Hashable {
    static func == (lhs: ChatUser, rhs: ChatUser) -> Bool {
        lhs.username == rhs.username
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(username)
    }
}

extension ChatUser: Codable {
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(username, forKey: .username)
        try container.encode(hashValue, forKey: .id)
        try container.encode(isSystem, forKey: .isSystem)
    }
    
    fileprivate enum CodingKeys: String, CodingKey {
        case username
        case id
        case isSystem
    }
    
    convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let username = try container.decode(String.self, forKey: .username)
//        let isSystem = try container.decode(Bool.self, forKey: .isSystem)
        // don't decode 'isSystem' - never comes in from network, so can never be decoded
        self.init(username)
    }
}
