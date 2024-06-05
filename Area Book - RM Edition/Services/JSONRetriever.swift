//
//  JSONRetriever.swift
//  Area Book - RM Edition
//
//  Created by spencer chavez on 9/5/23.
//

import Foundation

struct JSONRetriever {
    // I can't figure out how to call the getJson function below with nil for httpBodyToEncode without compile time errors, so I rewrote it here without that parameter :(
    static func getJson(url: URL, httpMethod: String, queryItems: [URLQueryItem]? = nil) async throws -> Data {
        do {
            var req = URLRequest(url: url, timeoutInterval: 60)
            req.httpMethod = httpMethod
            if let queryItems = queryItems {
                req.url?.append(queryItems: queryItems)
            }
            let (data, _) = try await URLSession.shared.data(for: req)
            if let json = try JSONSerialization.jsonObject(with: data) as? [String : Any] {
                if let errMsg = json["detail"] as? String {
                    throw RMLifePlannerError.serverError(errMsg)
                }
                return data
            } else {
                throw RMLifePlannerError.serverError("couldn't parse server response data to json: \(data )")
            }
        } catch let err {
            throw RMLifePlannerError.serverError("\(err)")
        }
    }
    
    static func getJson<T: Encodable>(url: URL, httpMethod: String,  httpBodyToEncode: T, queryItems: [URLQueryItem]? = nil) async throws -> Data {
        do {
            var req = URLRequest(url: url, timeoutInterval: 60)
            req.httpMethod = httpMethod
            req.setValue("application/json", forHTTPHeaderField: "Content-Type")
            req.httpBody = try JSONEncoder().encode(httpBodyToEncode)
            if let queryItems = queryItems {
                req.url?.append(queryItems: queryItems)
            }
            let (data, _) = try await URLSession.shared.data(for: req)
            if let json = try JSONSerialization.jsonObject(with: data) as? [String : Any] {
                if let errMsg = json["detail"] as? String {
                    throw RMLifePlannerError.serverError(errMsg)
                }
                return data
            } else {
                throw RMLifePlannerError.serverError("couldn't parse server response data to json: \(data )")
            }
        } catch let err {
            throw RMLifePlannerError.serverError("Server error. Received: \(err)")
        }
    }
}
