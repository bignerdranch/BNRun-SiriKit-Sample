//
//  IntentViewController.swift
//  BNRRunIntentsUIExtension
//
//  Created by hsoi on 9/6/17.
//  Copyright © 2017 Big Nerd Ranch, LLC. All rights reserved.
//

import IntentsUI
import BNRunCore

class IntentViewController: UIViewController {
    private let measurementFormatter = MeasurementFormatter()
}


extension IntentViewController: INUIHostedViewSiriProviding {
    var displaysMessage: Bool {
        return true
    }
}


extension IntentViewController: INUIHostedViewControlling {

    // This is called under iOS 10 (tho in this specific case it may not be, given how iOS 10's Siri interacts with Workouts).
    //
    // This can also be called under iOS 11, but since `configureView(for:…)` is also defined it will not be called. To see this
    // called under iOS 11, comment out the `configureView(for:…)` function.
    func configure(with interaction: INInteraction, context: INUIHostedViewContext, completion: @escaping (CGSize) -> Void) {

        // debug info
        interaction.dump()

        guard extensionContext != nil else {
            completion(.zero)
            return
        }

        var viewSize = CGSize.zero

        if let startWorkoutIntent = interaction.intent as? INStartWorkoutIntent {
            viewSize = configureUI(with: startWorkoutIntent, of: interaction)
        }
        else if let endWorkoutIntent = interaction.intent as? INEndWorkoutIntent {
            viewSize = configureUI(with: endWorkoutIntent, of: interaction)
        }

        completion(viewSize)
    }

    @available(iOS 11.0, *)
    func configureView(for parameters: Set<INParameter>, of interaction: INInteraction, interactiveBehavior: INUIInteractiveBehavior, context: INUIHostedViewContext, completion: @escaping (Bool, Set<INParameter>, CGSize) -> Void) {

        // debug info
        interaction.dump()
        parameters.dump()
        print("\n** interactiveBehavior: \(interactiveBehavior)\n")
        
        guard extensionContext != nil else {
            completion(false, [], .zero)
            return
        }

        if parameters.count == 0 {
            _ = instantiateAndInstall(scene: "HeaderScene", ofType: HeaderViewController.self)
            let viewSize = view.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
            completion(true, [], viewSize)
        }
        else {
            let startIntentDescriptionParameter = INParameter(for: INStartWorkoutIntent.self, keyPath: #keyPath(INStartWorkoutIntent.intentDescription))
            let endIntentDescriptionParameter = INParameter(for: INEndWorkoutIntent.self, keyPath: #keyPath(INEndWorkoutIntent.intentDescription))

            if parameters.contains(startIntentDescriptionParameter), let startWorkoutIntent = interaction.intent as? INStartWorkoutIntent {
                let viewSize = configureUI(with: startWorkoutIntent, of: interaction)
                completion(true, [startIntentDescriptionParameter], viewSize)
            }
            else if parameters.contains(endIntentDescriptionParameter), let endWorkoutIntent = interaction.intent as? INEndWorkoutIntent {
                let viewSize = configureUI(with: endWorkoutIntent, of: interaction)
                completion(true, [endIntentDescriptionParameter], viewSize)
            }
            else {
                completion(false, [], .zero)
            }
        }
    }
}

extension IntentViewController {

    private func configureUI(with startWorkoutIntent: INStartWorkoutIntent, of interaction: INInteraction) -> CGSize {
        guard let workout = Workout(startWorkoutIntent: startWorkoutIntent) else {
            return .zero
        }

        var startText = "Start "
        switch workout.goal {
        case .open:
            startText += "Open "
        case .distance(let miles):
            let measurement = Measurement(value: miles, unit: UnitLength.miles)
            startText += "\(measurementFormatter.string(from: measurement)) "
        }
        switch workout.type {
        case .run:
            startText += "Run 🏃‍♀️💨"
        case .walk:
            startText += "Walk 🏃"
        case .swim:
            startText += "Swim 🏊‍♀️"
        }

        var responseTypeText = "none"
        if let intentResponse = interaction.intentResponse {
            if let startWorkoutIntentResponse = intentResponse as? INStartWorkoutIntentResponse {
                responseTypeText = String(describing: startWorkoutIntentResponse.code)
            }
            else {
                responseTypeText = "unknown response type"
            }
        }
        let responseText = "Response: \(responseTypeText)"
        let statusText = "Status: \(String(describing: interaction.intentHandlingStatus))"
        let directionText = "Direction: \(String(describing: interaction.direction))"

        loadAndConfigureWorkoutInfo(startStopText: startText, responseText: responseText, statusText: statusText, directionText: directionText)

        let viewSize = view.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
        return viewSize
    }

    private func configureUI(with endWorkoutIntent: INEndWorkoutIntent, of interaction: INInteraction) -> CGSize {
        var workoutTypeString = "Workout"
        if let workoutName = endWorkoutIntent.workoutName, let workoutType = Workout.WorkoutType(intentWorkoutName: workoutName) {
            workoutTypeString = workoutType.rawValue.capitalized
        }
        let stopText = "\(workoutTypeString) Stopped 😅"

        var responseTypeText = "none"
        if let intentResponse = interaction.intentResponse {
            if let endWorkoutIntentResponse = intentResponse as? INEndWorkoutIntentResponse {
                responseTypeText = String(describing: endWorkoutIntentResponse.code)
            }
            else {
                responseTypeText = "unknown response type"
            }
        }
        let responseText = "Response: \(responseTypeText)"
        let statusText = "Status: \(String(describing: interaction.intentHandlingStatus))"
        let directionText = "Direction: \(String(describing: interaction.direction))"

        loadAndConfigureWorkoutInfo(startStopText: stopText, responseText: responseText, statusText: statusText, directionText: directionText)

        let viewSize = view.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
        return viewSize
    }
}


extension IntentViewController {
    private func instantiateAndInstall<VC: UIViewController> (scene identifier: String, ofType type: VC.Type) -> VC {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: identifier) as? VC else {
            fatalError("failed to instantiate storyboard scene: '\(identifier)' as type: \(type)")
        }
        vc.loadViewIfNeeded()   // ensure IBOutlets are hooked up. Not something I'd normally do, but to keep the sample code simple…

        vc.view.translatesAutoresizingMaskIntoConstraints = false

        addChildViewController(vc)
        view.addSubview(vc.view)
        vc.view.frame = view.bounds
        vc.didMove(toParentViewController: self)

        vc.view.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        vc.view.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        vc.view.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        vc.view.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true

        return vc
    }

    private func loadAndConfigureWorkoutInfo(startStopText: String, responseText: String, statusText: String, directionText: String) {
        let fullViewController = instantiateAndInstall(scene: "WorkoutInfoScene", ofType: WorkoutInfoViewController.self)
        fullViewController.startStopLabel.text = startStopText
        fullViewController.responseLabel.text = responseText
        fullViewController.statusLabel.text = statusText
        fullViewController.directionLabel.text = directionText
    }
}
