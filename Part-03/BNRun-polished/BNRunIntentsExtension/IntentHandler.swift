//
//  IntentHandler.swift
//  BNRunIntentsExtension
//
//  Created by hsoi on 8/15/17.
//  Copyright © 2017 Big Nerd Ranch, LLC. All rights reserved.
//

import Intents

class IntentHandler: INExtension {
    
    override func handler(for intent: INIntent) -> Any? {
        if intent is INStartWorkoutIntent {
            return StartWorkoutIntentHandler()
        }
        else if intent is INEndWorkoutIntent {
            return StopWorkoutIntentHandler()
        }

        return nil
    }
}

