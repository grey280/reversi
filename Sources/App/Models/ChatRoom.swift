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
    var users: Set<String> = []
    
    var userCount: Int {
        users.count
    }
}
