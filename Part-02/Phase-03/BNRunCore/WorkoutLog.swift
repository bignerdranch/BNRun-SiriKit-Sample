//
//  WorkoutLog.swift
//  BNRun
//
//  Created by hsoi on 6/28/17.
//  Copyright © 2017 Big Nerd Ranch, LLC. All rights reserved.
//

import Foundation

public struct WorkoutLog {
    fileprivate var workouts: [Workout]

    public var count: Int {
        return workouts.count
    }

    public subscript(index: Int) -> Workout {
        get {
            return workouts[index]
        }
        set {
            workouts[index] = newValue
        }
    }
}


// Data management
extension WorkoutLog {

    private static func userDefaults() -> UserDefaults {
        guard let defaults = UserDefaults(suiteName: "group.com.bignerdranch.sirikit.BNRun") else {
            fatalError("failed to create UserDefaults suite")
        }
        return defaults
    }

    private static let workoutsKey = "workouts"

    public static func load() -> WorkoutLog {
        var workouts = [Workout]()

        if let savedEncodedWorkouts = WorkoutLog.userDefaults().data(forKey: WorkoutLog.workoutsKey) {
            let plistDecoder = PropertyListDecoder()
            guard let decodedWorkouts = try? plistDecoder.decode([Workout].self, from: savedEncodedWorkouts) else {
                fatalError("failed to decode workouts - it's sample code, so we'll just fail")
            }
            workouts = decodedWorkouts
        }

        return WorkoutLog(workouts: workouts)
    }

    public func save() {
        let plistEncoder = PropertyListEncoder()
        guard let encodedWorkouts = try? plistEncoder.encode(workouts) else {
            fatalError("Failed to encode the workouts for saving - it's sample code, so we'll just fail")
        }
        WorkoutLog.userDefaults().set(encodedWorkouts, forKey: WorkoutLog.workoutsKey)
    }
}

// Workout Management
extension WorkoutLog {

    public var activeWorkout: Workout? {
        get {
            guard let workout = workouts.first, workout.state == .active else {
                return nil
            }
            return workout
        }
    }

    public mutating func start(workout: Workout) {
        var newWorkout = workout
        newWorkout.state = .active
        endActiveWorkout()
        workouts.insert(workout, at: 0) // insert at start, for reverse-chronological order; simplified for sample code.
        save()
    }

    public mutating func end(workout: Workout) {
        guard let workoutIndex = workouts.index(of: workout) else {
            fatalError("couldn't find existing Workout in our list of workouts")
        }
        var newWorkout = workout
        newWorkout.state = .finished
        workouts[workoutIndex] = newWorkout
        save()
    }

    public mutating func endActiveWorkout() {
        guard let workout = workouts.first else {
            return
        }
        end(workout: workout)
    }
}

