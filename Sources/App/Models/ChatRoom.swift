//
//  File.swift
//  
//
//  Created by Grey Patterson on 5/17/20.
//

import Foundation
import OpenCombine

class ChatRoom {
    let queue = PassthroughSubject<ChatEvent, Never>()
    var users: Set<ChatUser> = []
    var game: Game?
    
    var userCount: Int {
        users.count
    }
    
    static var lobby: String {
        "lobby"
    }
}
