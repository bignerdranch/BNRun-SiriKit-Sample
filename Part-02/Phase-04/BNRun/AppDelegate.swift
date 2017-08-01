//
//  AppDelegate.swift
//  BNRun
//
//  Created by hsoi on 8/15/17.
//  Copyright © 2017 Big Nerd Ranch, LLC. All rights reserved.
//

import UIKit
import BNRunCore
import Intents

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
    }

    func applicationWillTerminate(_ application: UIApplication) {
    }

    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        guard
            let navigationController = window?.rootViewController as? UINavigationController,
            let workoutVC = navigationController.viewControllers[0] as? WorkoutViewController
            else {
                return true
        }

        restorationHandler([workoutVC])

        return true
    }
    
    @available(iOS 11.0, *)
    func application(_ application: UIApplication, handle intent: INIntent, completionHandler: @escaping (INIntentResponse) -> Void) {
        let response: INIntentResponse

        if let startIntent = intent as? INStartWorkoutIntent, let workout = Workout(startWorkoutIntent: startIntent) {
            var log = WorkoutLog.load()
            log.start(workout: workout)
            response = INStartWorkoutIntentResponse(code: .success, userActivity: nil)
        }
        else if let _ = intent as? INEndWorkoutIntent {
            var log = WorkoutLog.load()
            log.endActiveWorkout()
            response = INEndWorkoutIntentResponse(code: .success, userActivity: nil)
        }
        else {
            response = INStartWorkoutIntentResponse(code: .failure, userActivity: nil)
        }

        completionHandler(response)
    }
}

