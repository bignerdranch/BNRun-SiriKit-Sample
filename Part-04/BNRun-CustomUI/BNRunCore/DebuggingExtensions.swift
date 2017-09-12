//
//  DebuggingExtensions.swift
//  BNRunCore
//
//  Created by hsoi on 9/7/17.
//  Copyright © 2017 Big Nerd Ranch, LLC. All rights reserved.
//

import Foundation
import Intents
import IntentsUI


extension INInteraction {

    public func dump() {
        print("\n** INInteraction dump start:")
        print("interaction.intent: \(String(describing:intent))")

        var responseString = "none"
        if let response = intentResponse {
            responseString = String(describing:response)
        }
        print("interaction.intentResponse: \(responseString))")

        print("interaction.intentHandlingStatus: \(String(describing:intentHandlingStatus))")

        print("interaction.direction: \(String(describing:direction))")

        print("** INInteraction dump end\n")
    }
}

extension INIntentHandlingStatus: CustomStringConvertible {

    public var description: String {
        switch self {
        case .unspecified:
            return "unspecified"
        case .ready:
            return "ready"
        case .inProgress:
            return "in progress"
        case .success:
            return "success"
        case .failure:
            return "failure"
        case .deferredToApplication:
            return "deferred to application"
        }
    }
}

extension INInteractionDirection: CustomStringConvertible {

    public var description: String {
        switch self {
        case .unspecified:
            return "unspecified"
        case .outgoing:
            return "outgoing"
        case .incoming:
            return "incoming"
        }
    }
}

extension INStartWorkoutIntentResponseCode: CustomStringConvertible {

    public var description: String {
        switch self {
        case .continueInApp:
            return "continue in app"
        case .failure:
            return "failure"
        case .failureNoMatchingWorkout:
            return "failure, no matching workout"
        case .failureOngoingWorkout:
            return "failure, ongoing workout"
        case .failureRequiringAppLaunch:
            return "failure, requiring app launch"
        case .handleInApp:
            return "handle in app"
        case .ready:
            return "ready"
        case .success:
            return "success"
        case .unspecified:
            return "unspecified"
        }
    }
}

extension INEndWorkoutIntentResponseCode: CustomStringConvertible {

    public var description: String {
        switch self {
        case .continueInApp:
            return "continue in app"
        case .failure:
            return "failure"
        case .failureNoMatchingWorkout:
            return "failure, no matching workout"
        case .failureRequiringAppLaunch:
            return "failure, requiring app launch"
        case .handleInApp:
            return "handle in app"
        case .ready:
            return "ready"
        case .success:
            return "success"
        case .unspecified:
            return "unspecified"
        }
    }
}

@available(iOS 11.0, *)
extension INParameter {

    public func dump() {
        print(String(describing: self))
    }
}

@available(iOS 11.0, *)
extension Set where Element == INParameter {

    public func dump() {
        print("\n** Set<INParameter> dump start:")
        print("parameters count: \(count)")
        forEach { print(String(describing: $0)) }
        print("** Set<INParameter> dump end\n")
    }
}

@available(iOS 11.0, *)
extension INUIInteractiveBehavior: CustomStringConvertible {

    public var description: String {
        switch self {
        case .genericAction:
            return "generic action"
        case .launch:
            return "launch"
        case .nextView:
            return "next view"
        case .none:
            return "none"
        }
    }
}


