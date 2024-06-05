//
//  Login.swift
//  Area Book - RM Edition
//
//  Created by spencer chavez on 3/25/24.
//

import Foundation

struct LoginRequest: Codable {
    var username: String
    var password: String
    
    init(username: String, password: String) {
        self.username = username
        self.password = password
    }
}
