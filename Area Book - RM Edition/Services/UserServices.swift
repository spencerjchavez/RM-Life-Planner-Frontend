//
//  UserServices.swift
//  Area Book - RM Edition
//
//  Created by spencer chavez on 7/11/23.
//

import Foundation

struct UserServices {
    
    static var authentication: Authentication?
    
    static func login(username: String, password: String) async {
        if USER_ID != nil {
            return //user already logged in!
        }
    }
    static func logout() async {
        if USER_ID == nil {
            return
        }
        
    }
    static func createUser(user: User) async {
        if USER_ID != nil {
            return //logout first
        }
    }
    static func deleteUser() async {
        if USER_ID == nil {
            return
        }
    }
    static func updateUser(user: User) async {
        if USER_ID == nil {
            return
        }
    }
    static func getUser() async {
        if USER_ID == nil {
            return
        }
    }
}
