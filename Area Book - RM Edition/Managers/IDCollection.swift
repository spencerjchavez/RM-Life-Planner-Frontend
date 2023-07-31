//
//  IDCollection.swift
//  Area Book - RM Edition
//
//  Created by spencer chavez on 7/28/23.
//

import Foundation

class IDCollection {
    private var serverIdsByClientId: [Int: Int] = [:]
    private var clientIdsByServierId: [Int: Int] = [:]
    private var nextClientId: Int = Int.min
    
    func generateId() throws -> Int {
        if nextClientId == Int.max {
            throw RMLifePlannerError.unexpectedClientSideError
        }
        nextClientId += 1
        return nextClientId - 1
    }
    func associateServerSideId(serverSideId: Int, with clientSideId: Int) {
        serverIdsByClientId[clientSideId] = serverSideId
        clientIdsByServierId[serverSideId] = clientSideId
    }
    func getServerSideId(from clientSideId: Int) -> Int? {
        return serverIdsByClientId[clientSideId]
    }
    func getClientSideId(from serverSideId: Int) -> Int? {
        return clientIdsByServierId[serverSideId]
    }
    func getOrGenerateClientSideId(from serverSideId: Int) throws -> Int {
        if let clientSideID = getClientSideId(from: serverSideId) {
            return clientSideID
        } else {
            let clientSideID = try generateId()
            associateServerSideId(serverSideId: serverSideId, with: clientSideID)
            return clientSideID
        }
    }
    func deleteClientSideId(clientSideId: Int) {
        serverIdsByClientId[clientSideId] = nil
    }
}
