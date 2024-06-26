//
//  Authentication.swift
//  Area Book - RM Edition
//
//  Created by spencer chavez on 7/25/23.
//

import Foundation

struct Authentication : Codable {
    var user_id: Int
    var api_key: String
    
    func authQueryItems() -> [URLQueryItem] {
        return [URLQueryItem(name: "auth_user", value: String(user_id)),
                URLQueryItem(name: "api_key", value: api_key)]
    }
}
