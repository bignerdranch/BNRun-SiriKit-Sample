//
//  Workout.swift
//  BNRun
//
//  Created by hsoi on 6/28/17.
//  Copyright © 2017 Big Nerd Ranch, LLC. All rights reserved.
//

import Foundation

public struct Workout: Codable {

    public enum WorkoutType: String, Codable {
        case walk
        case run
        case swim
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
