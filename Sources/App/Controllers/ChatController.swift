//
//  File.swift
//  
//
//  Created by Grey Patterson on 5/9/20.
//

import Vapor

struct ChatController {
    func socket(_ req: Request, _ ws: WebSocket) -> () {
        print("Socket connected")
        ws.onClose.whenComplete { (res) in
            print("Socket disconnected")
        }
    }
}
