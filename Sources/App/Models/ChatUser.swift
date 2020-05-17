//
//  File.swift
//  
//
//  Created by Grey Patterson on 5/17/20.
//

import Foundation

final class ChatUser {
    let username: String
    init(_ username: String){
        self.username = username
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
    }
    
    fileprivate enum CodingKeys: String, CodingKey {
        case username
        case id
    }
    
    convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let username = try container.decode(String.self, forKey: .username)
        self.init(username)
    }
}
