//
//  HelperFunctions.swift
//  Area Book - RM Edition
//
//  Created by spencer chavez on 8/2/23.
//

import Foundation

func encodeWithAuthentication(label: String, data: Encodable) throws -> Data {
    var dict = [label: data]
    dict["authentication"] = GlobalVars.authentication
    try JSONEncoder().encode(dict)
}
