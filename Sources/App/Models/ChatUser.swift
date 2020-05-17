//
//  File.swift
//  
//
//  Created by Grey Patterson on 5/17/20.
//

import Foundation

class ChatUser: Hashable {
    static func == (lhs: ChatUser, rhs: ChatUser) -> Bool {
        lhs.username == rhs.username
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(username)
    }
    
    let username: String
    init(_ username: String){
        self.username = username
    }
}
