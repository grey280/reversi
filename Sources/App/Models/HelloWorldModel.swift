//
//  File.swift
//  
//
//  Created by Grey Patterson on 5/3/20.
//

import Vapor

final class HelloWorldModel: Encodable {
    let time = Date()
    let formattedTime: String
    
    init(){
        formattedTime = HelloWorldModel.formatter.string(from: time)
    }
    
    private static let formatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US")
        f.dateFormat = "HH:mm' on 'yyyy-MM-dd"
        return f
    }()
}
