//
//  File.swift
//  
//
//  Created by Grey Patterson on 5/25/20.
//

import Foundation

final class Game {
    private var board: [[Token]]
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
        if (blackCount + whiteCount == 8*8){
            return true
        }
        let whiteHasMoves = getValidMoves(for: .white)
        if (whiteHasMoves.contains(where: { (arr) -> Bool in
            arr.contains(true)
        })){
            return false
        }
        let blackHasMoves = getValidMoves(for: .white)
        if (blackHasMoves.contains(where: { (arr) -> Bool in
            arr.contains(true)
        })){
            return false
        }
        return true
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
    
    func play(row: Int, column: Int, player: Player){
        guard row >= 0 && row < 8 && column >= 0 && column < 8 else {
            return
        }
        guard player == whoseTurn else {
            return
        }
        guard isValidMove(player: player, row: row, column: column) else {
            return
        }
        board[column][row] = player == .white ? .white : .black
        // Flip any tokens that need to be flipped
        let directions = [(-1, -1), (-1, 0), (-1, 1), (0, -1), (0, 1), (1, -1), (1, 0), (1, 1)]
        let res = directions.map({ (dX, dY) -> Bool in
            flipLine(player: player, dRow: dY, dColumn: dX, row: row, column: column)
        })
        if (!res.contains(true)){
            print("Error while flipping - no valid flips")
        }
        whoseTurn = whoseTurn == .white ? .black : .white
        // Check - if they have no moves, skip their turn
        let validMoves = getValidMoves(for: whoseTurn)
        if (!validMoves.contains(where: { (arr) -> Bool in
            arr.contains(true)
        })){
            whoseTurn = whoseTurn == .white ? .black : .white
            // don't recurse - if they *also* don't have any moves, isGameOver will be true
        }
        lastMove = Date()
    }
}

extension Game {
    func getValidMoves(for player: Player, checkingTurn: Bool = false) -> [[Bool]] {
        var result = [[Bool]](repeating: [Bool](repeating: false, count: 8), count: 8)
        if checkingTurn && whoseTurn != player {
            return result // not your turn, no moves available
        }
        for x in 0..<8{
            for y in 0..<8{
                if board[x][y] == .clear {
                    result[x][y] = isValidMove(player: player, row: y, column: x)
                }
            }
        }
        return result
    }
    
    private func flipLine(player: Player, dRow: Int, dColumn: Int, row: Int, column: Int) -> Bool{
        guard row + dRow >= 0 && row + dRow < 8 && column + dColumn >= 0 && column + dColumn < 8 else {
            return false
        }
        if board[column + dColumn][row + dRow] == .clear {
            return false
        }
        let who = player == .white ? Token.white : Token.black
        if board[column + dColumn][row + dRow] == who {
            return true
        }
        if (flipLine(player: player, dRow: dRow, dColumn: dColumn, row: row + dRow, column: column + dColumn)){
            board[column + dColumn][row + dRow] = who
            return true
        }
        return false
    }
    
    private func checkLineMatch(player: Player, dRow: Int, dColumn: Int, row: Int, column: Int) -> Bool {
        let check = player == .white ? Token.white : Token.black
        if board[row][column] == check {
            return true
        }
        guard row + dRow >= 0 && row + dRow < 8 else {
            return false
        }
        guard column + dColumn >= 0 && column + dColumn < 8 else {
            return false
        }
        return checkLineMatch(player: player, dRow: dRow, dColumn: dColumn, row: row + dRow, column: column + dColumn)
    }
    
    private func isValidMove(player: Player, row: Int, column: Int) -> Bool {
        let directions = [(-1, -1), (-1, 0), (-1, 1), (0, -1), (0, 1), (1, -1), (1, 0), (1, 1)]
        return directions.contains(where: { (dX, dY) -> Bool in
            isValidMove(player: player, dRow: dY, dColumn: dX, row: row, column: column)
        })
    }
    
    private func isValidMove(player: Player, dRow: Int, dColumn: Int, row: Int, column: Int) -> Bool {
        let other = player == .white ? Token.black : Token.white
        // TODO: Have an alternate mode where the 'hit the edge' check returns true? Could be an interesting alternate game mode.
        guard row + dRow >= 0 && row + dRow < 8 else {
            return false
        }
        guard column + dColumn >= 0 && column + dColumn < 8 else {
            return false
        }
        guard board[column + dColumn][row + dRow] == other else {
            return false
        }
        guard row + dRow + dRow >= 0 && row + dRow + dRow < 8 else {
            return false
        }
        guard column + dColumn + dColumn >= 0 && column + dColumn + dColumn < 8 else {
            return false
        }
        return checkLineMatch(player: player, dRow: dRow, dColumn: dColumn, row: row, column: column)
    }
}

extension Game: Codable {
    fileprivate enum CodingKeys: String, CodingKey {
        case board, lastMove, whoseTurn, white, black, id, whiteCount, blackCount, isGameOver, validMovesWhite, validMovesBlack
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
        try container.encode(getValidMoves(for: .white, checkingTurn: true), forKey: .validMovesWhite)
        try container.encode(getValidMoves(for: .black, checkingTurn: true), forKey: .validMovesBlack)
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
