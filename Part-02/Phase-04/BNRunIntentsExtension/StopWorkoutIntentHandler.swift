//
//  StopWorkoutIntentHandler.swift
//  BNRun
//
//  Created by hsoi on 6/30/17.
//  Copyright © 2017 Big Nerd Ranch, LLC. All rights reserved.
//

import Foundation
import Intents
import BNRunCore

class StopWorkoutIntentHandler: NSObject, INEndWorkoutIntentHandling {

    func confirm(intent: INEndWorkoutIntent, completion: @escaping (INEndWorkoutIntentResponse) -> Void) {
        let response: INEndWorkoutIntentResponse

        let workouts = WorkoutLog.load()
        if workouts.activeWorkout != nil {
            if #available(iOS 11, *) {
                response = INEndWorkoutIntentResponse(code: .ready, userActivity: nil)
            }
            else {
                let activity = NSUserActivity(bnrActivity: .stopWorkout)
                response = INEndWorkoutIntentResponse(code: .continueInApp, userActivity: activity)
            }
        }
        else {
            response = INEndWorkoutIntentResponse(code: .failureNoMatchingWorkout, userActivity: nil)
        }

        completion(response)
    }

    func handle(intent: INEndWorkoutIntent, completion: @escaping (INEndWorkoutIntentResponse) -> Void) {
        let response: INEndWorkoutIntentResponse

        if #available(iOS 11, *) {
            response = INEndWorkoutIntentResponse(code: .handleInApp, userActivity: nil)
        }
        else {
            let workouts = WorkoutLog.load()
            if workouts.activeWorkout != nil {
                let activity = NSUserActivity(bnrActivity: .stopWorkout)
                response = INEndWorkoutIntentResponse(code: .continueInApp, userActivity: activity)
            }
            else {
                response = INEndWorkoutIntentResponse(code: .failureNoMatchingWorkout, userActivity: nil)
            }
        }

        completion(response)
    }
}
