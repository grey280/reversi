//
//  File.swift
//  
//
//  Created by Grey Patterson on 5/25/20.
//

import Foundation

final class Game {
    var board: [[Token]]
    var lastMove: Date
    var whoseTurn: Player
    
    let white: ChatUser
    let black: ChatUser
    let id: GameConfig.ID
    
    init(white: ChatUser, black: ChatUser, id: GameConfig.ID = UUID()){
        lastMove = Date()
        whoseTurn = .white
        board = [[Token]](repeating: [Token](repeating: .clear, count: 8), count: 8)
        self.white = white
        self.black = black
        self.id = id
    }
}

extension Game: Codable { }

enum Token: String, Codable {
    case black, white, clear, error
}

enum Player: String, Codable {
    case black, white
}
