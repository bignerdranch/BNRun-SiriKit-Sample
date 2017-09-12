//
//  StartWorkoutIntentHandler.swift
//  BNRun
//
//  Created by hsoi on 6/29/17.
//  Copyright © 2017 Big Nerd Ranch, LLC. All rights reserved.
//

import Foundation
import Intents
import BNRunCore

class StartWorkoutIntentHandler: NSObject, INStartWorkoutIntentHandling {

    func resolveWorkoutName(for intent: INStartWorkoutIntent, with completion: @escaping (INSpeakableStringResolutionResult) -> Void) {
        let result: INSpeakableStringResolutionResult

        if let workoutName = intent.workoutName {
            if let workoutType = Workout.WorkoutType(intentWorkoutName: workoutName) {
                result = INSpeakableStringResolutionResult.success(with: workoutType.speakableString)
            }
            else {
                let possibleNames = [
                    Workout.WorkoutType.walk.speakableString,
                    Workout.WorkoutType.run.speakableString,
                    Workout.WorkoutType.swim.speakableString
                ]
                result = INSpeakableStringResolutionResult.disambiguation(with: possibleNames)
            }
        }
        else {
            result = INSpeakableStringResolutionResult.needsValue()
        }

        completion(result)
    }


    func resolveGoalValue(for intent: INStartWorkoutIntent, with completion: @escaping (INDoubleResolutionResult) -> Void) {
        let result: INDoubleResolutionResult

        let unit = intent.workoutGoalUnitType
        if unit == .mile, let value = intent.goalValue {    // only supporting miles, to keep the sample simple.
            result = INDoubleResolutionResult.success(with: value)
        }
        else if unit == .unknown, let open = intent.isOpenEnded, open == true {
            result = INDoubleResolutionResult.notRequired()
        }
        else {
            // Alas, there's no way to specify back to Siri that only units of distance are supported. What will happen is Siri
            // will prompt the user asking "What is your duration, distance, or calorie goal for this workout?" We will never
            // support duration nor calories, so it'll be frustrating to be prompted for those but not being able to support
            // them. It'd be nice if in our result we could specify what we do support so Siri's prompt could be more focused
            // and accurate. RADAR 33076484
            result = INDoubleResolutionResult.needsValue()
        }

        completion(result)
    }

    func resolveIsOpenEnded(for intent: INStartWorkoutIntent, with completion: @escaping (INBooleanResolutionResult) -> Void) {
        let result: INBooleanResolutionResult

        if let openEnded = intent.isOpenEnded {
            result = INBooleanResolutionResult.success(with: openEnded)
        }
        else {
            result = INBooleanResolutionResult.notRequired()
        }

        completion(result)
    }

    func confirm(intent: INStartWorkoutIntent, completion: @escaping (INStartWorkoutIntentResponse) -> Void) {
        let response: INStartWorkoutIntentResponse

        if let workout = Workout(startWorkoutIntent: intent) {
            if #available(iOS 11, *) {
                response = INStartWorkoutIntentResponse(code: .ready, userActivity: nil)
            }
            else {
                let userActivity = NSUserActivity(bnrActivity: .startWorkout(workout))
                response = INStartWorkoutIntentResponse(code: .ready, userActivity: userActivity)
            }
        }
        else {
            response = INStartWorkoutIntentResponse(code: .failure, userActivity: nil)
        }

        completion(response)
    }

    func handle(intent: INStartWorkoutIntent, completion: @escaping (INStartWorkoutIntentResponse) -> Void) {
        let response: INStartWorkoutIntentResponse

        if #available(iOS 11, *) {
            response = INStartWorkoutIntentResponse(code: .handleInApp, userActivity: nil)
        }
        else {
            if let workout = Workout(startWorkoutIntent: intent) {
                let userActivity = NSUserActivity(bnrActivity: .startWorkout(workout))
                response = INStartWorkoutIntentResponse(code: .continueInApp, userActivity: userActivity)
            }
            else {
                response = INStartWorkoutIntentResponse(code: .failure, userActivity: nil)
            }
        }

        completion(response)
    }
}
