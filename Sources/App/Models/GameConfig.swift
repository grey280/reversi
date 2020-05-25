//
//  File.swift
//  
//
//  Created by Grey Patterson on 5/24/20.
//

import Vapor

struct GameConfig: Encodable {
    typealias ID = UUID
    let username: String
    let gameID: ID
    
    init(username: String, gameID: ID = UUID()){
        self.username = username
        self.gameID = gameID
    }
}
