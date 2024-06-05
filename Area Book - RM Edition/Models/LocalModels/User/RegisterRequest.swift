//
//  RegisterRequest.swift
//  Area Book - RM Edition
//
//  Created by spencer chavez on 3/25/24.
//

import Foundation



struct RegisterRequest : Codable {
    
    var username: String
    var password: String
    var email: String
    
    init(username: String, password: String, email: String) {
        self.username = username
        self.password = password
        self.email = email
    }
}
