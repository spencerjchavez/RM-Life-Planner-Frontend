//
//  GoalAchievingReport.swift
//  Area Book - RM Edition
//
//  Created by spencer chavez on 8/6/23.
//

import Foundation

struct GoalAchievingReport {
    let startDate: Date
    let endDate: Date
    let desires: [DesireLM]
    let goals: [GoalLM]
    let todosByGoalId: [Int: [TodoLM]]
    let eventsByGoalId: [Int: [CalendarEventLM]]
    
    var totalProgress: Double
    var desiresProgress: [Int: Double] // [desireid: amount completed in decimal [0-1]]
    var fulfilledDesires: Int
    var partiallyFulfilledDesires: Int
    var unfulfilledDesires: Int
    
    var goalsByDesireId: [Int: [GoalLM]] = [:]
    var goalsHowMuchPlanned: [Int: Double]
    var goalsHowMuchAccomplished: [Int: Double] // [goalId: %completed]
    var completedGoals: Int
    var partiallyCompletedGoals: Int
    var uncompletedGoals: Int
    
    var futureGoals: [GoalLM]
    var futureGoalshowMuchPlanned: [Int: Double]
    var futureGoalsHowMuchAccomplished: [Int: Double]

    init(startDate: Date, endDate: Date, desires: [DesireLM], goals: [GoalLM], todosByGoalId: [Int: [TodoLM]], eventsByGoalId: [Int: [CalendarEventLM]]) {
        self.startDate = startDate
        self.endDate = endDate
        self.desires = desires.sorted(by: { d1, d2 in
            return d1.desireId < d2.desireId
        })
        self.goals = goals
        self.todosByGoalId = todosByGoalId
        self.eventsByGoalId = eventsByGoalId
        
        self.totalProgress = 0.0

        desiresProgress = [:]
        self.fulfilledDesires = 0
        self.partiallyFulfilledDesires = 0
        self.unfulfilledDesires = 0
        
        self.goalsHowMuchPlanned = [:]
        self.goalsHowMuchAccomplished = [:]
        self.completedGoals = 0
        self.partiallyCompletedGoals = 0
        self.uncompletedGoals = 0
        
        self.futureGoals = []
        self.futureGoalshowMuchPlanned = [:]
        self.futureGoalsHowMuchAccomplished = [:]
                
        // init goalsByDesireId
        self.goalsByDesireId = [:]
        for goal in goals {
            if goal.deadlineDate ?? Date.distantFuture > endDate {
                // if goals deadline hasn't passed, put it in future goals report instead
                futureGoals.append(goal)
                continue
            }
            if self.goalsByDesireId[goal.desireId] == nil {
                self.goalsByDesireId[goal.desireId] = []
            }
            self.goalsByDesireId[goal.desireId]?.append(goal)
        }
        
        for desire in desires {
            let goals = goalsByDesireId[desire.desireId] ?? []
            var desireProgress = 0.0
            var isDesireFulfilled = true
            var isDesireUnfulfilled = true
            for goal in goals {
                let goalTodos = todosByGoalId[goal.goalId] ?? []
                // set goalsHowMuchPlanned
                var goalHowMuchPlanned = 0.0
                for goalTodo in goalTodos {
                    goalHowMuchPlanned += goalTodo.howMuchPlanned
                }
                goalsHowMuchPlanned[goal.goalId] = goalHowMuchPlanned
                let goalEvents = eventsByGoalId[goal.goalId] ?? []
                // set goalsHowMuchCompleted
                var goalHowMuchAccomplished = 0.0
                for goalEvent in goalEvents {
                    goalHowMuchAccomplished += goalEvent.howMuchAccomplished ?? 0
                }
                goalsHowMuchAccomplished[goal.goalId] = goalHowMuchAccomplished

                if let howMuchCompleted = goalsHowMuchAccomplished[goal.goalId] {
                    if howMuchCompleted >= goal.howMuch {
                        // completed goal
                        isDesireUnfulfilled = false
                        completedGoals += 1
                    } else if howMuchCompleted == 0 {
                        // uncompleted goal
                        isDesireFulfilled = false
                        uncompletedGoals += 1
                    } else {
                        // partially completed goal
                        isDesireFulfilled = false
                        isDesireUnfulfilled = false
                        partiallyCompletedGoals += 1
                    }
                    desireProgress += howMuchCompleted / goal.howMuch / Double(goals.count)
                }
            }
            desiresProgress[desire.desireId] = (desireProgress * 100).rounded() / 100
            totalProgress += desiresProgress[desire.desireId] ?? 0
            if desireProgress < 1.0 && desireProgress > 0.0 {
                partiallyFulfilledDesires += 1
            } else if isDesireFulfilled {
                fulfilledDesires += 1
            } else if isDesireUnfulfilled {
                unfulfilledDesires += 1
            }
            
            // future goals
            for futureGoal in futureGoals {
                var howMuchPlanned = 0.0
                for todo in todosByGoalId[futureGoal.goalId] ?? [] {
                    howMuchPlanned += todo.howMuchPlanned
                }
                futureGoalshowMuchPlanned[futureGoal.goalId] = howMuchPlanned
                
                var howMuchAccomplished = 0.0
                for event in eventsByGoalId[futureGoal.goalId] ?? [] {
                    howMuchAccomplished += event.howMuchAccomplished ?? 0
                }
                futureGoalsHowMuchAccomplished[futureGoal.goalId] = howMuchAccomplished
            }
        }
    }
}
