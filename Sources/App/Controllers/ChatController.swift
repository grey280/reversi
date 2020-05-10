//
//  File.swift
//  
//
//  Created by Grey Patterson on 5/9/20.
//

import Vapor

struct ChatController {
    private let decoder = JSONDecoder()
    
    func socket(_ req: Request, _ ws: WebSocket) -> () {
        print("Socket connected")
         ws.onClose.whenComplete { (res) in
            print("Socket disconnected")
        }
        ws.onText { (ws, text) in
            guard let command = self.parseCommand(text) else {
                return
            }
            
        }
    }
    
    private func parseCommand(_ text: String) -> ChatCommand? {
        do {
            let jsonData = Data(text.utf8)
            return try decoder.decode(ChatCommand.self, from: jsonData)
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
    
    
}


