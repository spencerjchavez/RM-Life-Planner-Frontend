//
//  IDCollection.swift
//  Area Book - RM Edition
//
//  Created by spencer chavez on 7/28/23.
//

import Foundation

class IdsManager {
    
    private static var serverIdsByLocalId: [Int: Int] = [:]
    private static var localIdsByTypeAndServerId: [String: [Int: Int]] = [:]
    private static var nextLocalId: Int = -1
    
    static func generateId() throws -> Int {
        // only use negative ids for local side ids to distinguish them from server side ids which are always positive
        if nextLocalId == Int.min {
            ErrorManager.reportError(throwingFunction: "IdsManager.generateId()", loggingMessage: "Failed to generate new local side Id! ", messageToUser: "Unexpected error ocurred, please restart the app and try again.")
            throw RMLifePlannerError.clientError
        }
        nextLocalId -= 1
        return nextLocalId + 1
    }
    static func associateServerId(serverSideId: Int, with localSideId: Int, modelType: String) {
        if localIdsByTypeAndServerId[modelType] == nil {
            localIdsByTypeAndServerId[modelType] = [:]
        }
        serverIdsByLocalId[localSideId] = serverSideId
        localIdsByTypeAndServerId[modelType]?[serverSideId] = localSideId
    }
    static func getServerId(from localSideId: Int) -> Int? {
        return serverIdsByLocalId[localSideId]
    }
    static func getLocalId(from serverSideId: Int, modelType: String) -> Int? {
        return localIdsByTypeAndServerId[modelType]?[serverSideId]
    }
    static func getOrGenerateLocalId(from serverSideId: Int, modelType: String) throws -> Int {
        if let localSideID = getLocalId(from: serverSideId, modelType: modelType) {
            return localSideID
        } else {
            let localSideID = try generateId()
            associateServerId(serverSideId: serverSideId, with: localSideID, modelType: modelType)
            return localSideID
        }
    }
    static func deleteLocalId(localSideId: Int) {
        serverIdsByLocalId[localSideId] = nil
    }
}
