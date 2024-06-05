//
//  ManagerTaskScheduler.swift
//  Area Book - RM Edition
//
//  Created by spencer chavez on 3/9/24.
//

import Foundation

class ManagerTaskScheduler {
    
    private var activeTasks: [Int: Task<Void, Never>] = [:]
    
    func schedule(syncId: Int, _ work: @escaping () async -> Void) {
        let toAwait = activeTasks[syncId]
        activeTasks[syncId] = Task {
            _ = await toAwait?.value
            _ = await work()
        }
    }
}
