//
//  Workout.swift
//  BNRun
//
//  Created by hsoi on 6/28/17.
//  Copyright © 2017 Big Nerd Ranch, LLC. All rights reserved.
//

import Foundation
import Intents

public struct Workout: Codable {

    public enum WorkoutType: String, Codable {
        case walk
        case run
        case swim

        public init?(intentWorkoutName: INSpeakableString) {
            switch intentWorkoutName.spokenPhrase.lowercased() {
            case "walk":
                self = .walk

            case "run", "jog", "sprint":
                self = .run

            case "swim":
                self = .swim

            default:
                return nil
            }
        }

        public var speakableString: INSpeakableString {
            let identifier: String
            let phrase: String
            let hint: String

            switch self {
            case .walk:
                identifier = "id-workouttype-walk"
                phrase = "Walk"
                hint = "walk"
            case .run:
                identifier = "id-workouttype-run"
                phrase = "Run"
                hint = "run"
            case .swim:
                identifier = "id-workouttype-swim"
                phrase = "Swim"
                hint = "swim"
            }

            if #available(iOS 11.0, *) {
                return INSpeakableString(vocabularyIdentifier: identifier, spokenPhrase: phrase, pronunciationHint: hint)
            }
            else {
                return INSpeakableString(identifier: identifier, spokenPhrase: phrase, pronunciationHint: hint)
            }
        }
    }

    public enum Goal: Codable {
        case open
        case distance(miles: Double)

        enum CodingKeys: String, CodingKey {
            case identity
            case open
            case distance
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            let identity: String
            switch self {
            case .open:
                identity = CodingKeys.open.rawValue
            case .distance(let miles):
                identity = CodingKeys.distance.rawValue
                try container.encode(miles, forKey: .distance)
            }
            try container.encode(identity, forKey: .identity)
        }

        public init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            let identity = try values.decode(String.self, forKey: .identity)
            switch identity {
            case CodingKeys.open.rawValue:
                self = .open
            case CodingKeys.distance.rawValue:
                let miles = try values.decode(Double.self, forKey: .distance)
                self = .distance(miles: miles)
            default:
                let context = DecodingError.Context(codingPath: [CodingKeys.identity], debugDescription: "Unsupported CodingKey.identity value \(identity)")
                throw DecodingError.valueNotFound(String.self, context)
            }
        }
    }

    public enum State: String, Codable {
        case active
        case finished
    }

    public let type: WorkoutType
    public let goal: Goal
    public var state: State
    public let startDate: Date

    public init(type: WorkoutType, goal: Goal, state: State = .active) {
        self.type = type
        self.goal = goal
        self.state = state
        self.startDate = Date()
    }

    public init?(startWorkoutIntent intent: INStartWorkoutIntent) {
        guard let workoutName = intent.workoutName, let workoutType = WorkoutType(intentWorkoutName: workoutName) else {
            return nil
        }
        self.type = workoutType

        if let open = intent.isOpenEnded, open == true {
            self.goal = .open
        }
        else if let goalValue = intent.goalValue {
            self.goal = .distance(miles: goalValue)
        }
        else {
            return nil
        }

        self.state = .active
        self.startDate = Date()
    }
}


extension Workout: Equatable { }

public func ==(lhs: Workout, rhs: Workout) -> Bool {
    if lhs.type == rhs.type && lhs.goal == rhs.goal && lhs.state == rhs.state && lhs.startDate == rhs.startDate {
        return true
    }
    return false
}

extension Workout.Goal: Equatable {}

public func ==(lhs: Workout.Goal, rhs: Workout.Goal) -> Bool {
    switch (lhs, rhs) {
    case (.open, .open):
        return true

    case (.distance(let lhsDistance), .distance(let rhsDistance)):
        return lhsDistance == rhsDistance

    default:
        return false
    }
}
