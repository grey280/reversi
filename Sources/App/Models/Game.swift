//
//  File.swift
//  
//
//  Created by Grey Patterson on 5/25/20.
//

import Foundation

class Game {
    var board: [[Token]]
    var lastMove: Date
    var whoseTurn: Player
    
    init(){
        lastMove = Date()
        whoseTurn = .white
        board = [[Token]](repeating: [Token](repeating: .clear, count: 8), count: 8)
    }
}

enum Token: String, Codable {
    case black, white, clear, error
}

enum Player: String, Codable {
    case black, white
}
