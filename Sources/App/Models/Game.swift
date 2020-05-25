//
//  File.swift
//  
//
//  Created by Grey Patterson on 5/24/20.
//

import Vapor

struct Game: Encodable {
    typealias ID = UUID
    let username: String
    let gameID: ID = UUID()
    
    init(username: String){
        self.username = username
    }
}
