//
//  Post.swift
//  Post
//
//  Created by Erik HARTLEY on 1/28/18.
//  Copyright © 2018 Erik HARTLEY. All rights reserved.
//

import Foundation

struct Post: Codable {
    let username: String
    let text: String
    let timestamp: TimeInterval
    
    init(username: String, text: String, timestamp: TimeInterval = Date().timeIntervalSince1970) {
        self.username = username
        self.text = text
        self.timestamp = timestamp
    }
    
    var queryTimestamp: TimeInterval {
        return timestamp - 0.00001
    }
}
