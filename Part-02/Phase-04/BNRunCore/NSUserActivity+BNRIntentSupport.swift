//
//  NSUserActivity+BNRIntentSupport.swift
//  BNRun
//
//  Created by hsoi on 6/30/17.
//  Copyright © 2017 Big Nerd Ranch, LLC. All rights reserved.
//

import Foundation

let startWorkoutActivityTypeIdentifier = "com.bignerdranch.sirikit.BNRun.UserActivity.StartWorkout"
let stopWorkoutActivityTypeIdentifier = "com.bignerdranch.sirikit.BNRun.UserActivity.StopWorkout"

extension NSUserActivity {

    public enum BNRActivity {
        case startWorkout(Workout)
        case stopWorkout
    }

    public var bnrActivity: BNRActivity? {
        switch activityType {
        case startWorkoutActivityTypeIdentifier:
            guard let encodedWorkout = userInfo?["workout"] as? Data else {
                return nil
            }
            let plistDecoder = PropertyListDecoder()
            guard let decodedWorkout = try? plistDecoder.decode(Workout.self, from: encodedWorkout) else {
                fatalError("failed to decode workout for NSUserActivity - it's sample code, so we'll just fail")
            }
            return .startWorkout(decodedWorkout)

        case stopWorkoutActivityTypeIdentifier:
            return .stopWorkout

        default:
            return nil
        }
    }


    public convenience init(bnrActivity: BNRActivity) {
        switch bnrActivity {
        case .startWorkout(let workout):
            self.init(activityType: startWorkoutActivityTypeIdentifier)
            let plistEncoder = PropertyListEncoder()
            guard let encodedWorkout = try? plistEncoder.encode(workout) else {
                fatalError("Failed to encode the workout for NSUserActivity - it's sample code, so we'll just fail")
            }
            userInfo = ["workout": encodedWorkout]

        case .stopWorkout:
            self.init(activityType: stopWorkoutActivityTypeIdentifier)
        }
    }
}
