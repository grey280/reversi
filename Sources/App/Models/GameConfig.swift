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
    
    let range = [0,1,2,3,4,5,6,7]
}
