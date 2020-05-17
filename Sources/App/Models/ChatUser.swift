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

extension ChatUser: Encodable {
    
}

extension ChatUser: Decodable {
    
}
