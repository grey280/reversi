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
    
    var whiteCount: Int {
        board.reduce(0) { (result, array) in
            array.reduce(into: result) { (res, square) in
                if (square == .white){
                    res += 1
                }
            }
        }
    }
    var blackCount: Int {
        board.reduce(0) { (result, array) in
            array.reduce(into: result) { (res, square) in
                if (square == .black){
                    res += 1
                }
            }
        }
    }
    var isGameOver: Bool {
        blackCount + whiteCount == 8*8
    }
    
    init(white: ChatUser, black: ChatUser, id: GameConfig.ID = UUID()){
        lastMove = Date()
        whoseTurn = .white
        board = [[Token]](repeating: [Token](repeating: .clear, count: 8), count: 8)
        board[3][3] = .white
        board[3][4] = .black
        board[4][3] = .black
        board[4][4] = .white
        self.white = white
        self.black = black
        self.id = id
    }
}

extension Game: Codable {
    fileprivate enum CodingKeys: String, CodingKey {
        case board, lastMove, whoseTurn, white, black, id, whiteCount, blackCount, isGameOver
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(board, forKey: .board)
        try container.encode(lastMove, forKey: .lastMove)
        try container.encode(whoseTurn, forKey: .whoseTurn)
        try container.encode(white, forKey: .white)
        try container.encode(black, forKey: .black)
        try container.encode(id, forKey: .id)
        try container.encode(whiteCount, forKey: .whiteCount)
        try container.encode(blackCount, forKey: .blackCount)
        try container.encode(isGameOver, forKey: .isGameOver)
    }
    
    convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let white = try container.decode(ChatUser.self, forKey: .white)
        let black = try container.decode(ChatUser.self, forKey: .black)
        let id = try container.decode(GameConfig.ID.self, forKey: .id)
        self.init(white: white, black: black, id: id)
        whoseTurn = try container.decode(Player.self, forKey: .whoseTurn)
        lastMove = try container.decode(Date.self, forKey: .lastMove)
        board = try container.decode([[Token]].self, forKey: .board)
    }
}

enum Token: String, Codable {
    case black, white, clear, error
}

enum Player: String, Codable {
    case black, white
}
