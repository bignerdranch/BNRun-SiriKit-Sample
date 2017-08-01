//
//  WorkoutViewController.swift
//  BNRun
//
//  Created by hsoi on 6/28/17.
//  Copyright © 2017 Big Nerd Ranch, LLC. All rights reserved.
//

import UIKit
import BNRunCore

class WorkoutViewController: UITableViewController {

    fileprivate var workoutLog = WorkoutLog.load() {
        didSet {
            tableView?.reloadData()
        }
    }

    private var observerToken: NSObjectProtocol?

    deinit {
        if observerToken != nil {
            NotificationCenter.default.removeObserver(observerToken!)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        observerToken = NotificationCenter.default.addObserver(forName: .UIApplicationDidBecomeActive, object: nil, queue: OperationQueue.main) { [unowned self] _ in
            self.workoutLog = WorkoutLog.load()
        }
    }
}

extension WorkoutViewController {   // UITableViewDataSource

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return workoutLog.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let workoutCell = tableView.dequeueReusableCell(withIdentifier: "WorkoutCell", for: indexPath) as? WorkoutTableViewCell else {
            fatalError("failed to dequeue WorkoutTableViewCell")
        }
        let workout = workoutLog[indexPath.row]
        workoutCell.configure(with: workout)
        return workoutCell
    }
}

extension WorkoutViewController { // UITableViewDelegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let targetWorkout = workoutLog[indexPath.row]
        workoutLog.end(workout: targetWorkout)
    }
}

extension WorkoutViewController {

    // A series of alerts isn't the best UX, but it suffices for a sample app.

    @IBAction func addWorkout(sender: Any) {
        let addAlert = UIAlertController(title: "Add what type of Workout?", message: nil, preferredStyle: .actionSheet)

        let walkAction = UIAlertAction(title: "Walk", style: .default) { _ in
            self.promptForGoal(workoutType: .walk)
        }
        addAlert.addAction(walkAction)

        let runAction = UIAlertAction(title: "Run", style: .default) { _ in
            self.promptForGoal(workoutType: .run)
        }
        addAlert.addAction(runAction)

        let swimAction = UIAlertAction(title: "Swim", style: .default) { _ in
            self.promptForGoal(workoutType: .swim)
        }
        addAlert.addAction(swimAction)

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        addAlert.addAction(cancelAction)

        present(addAlert, animated: true, completion: nil)
    }

    fileprivate func promptForGoal(workoutType: Workout.WorkoutType) {
        let goalAlert = UIAlertController(title: "What is your goal for this \(workoutType.rawValue.capitalized)?", message: nil, preferredStyle: .actionSheet)

        let openAction = UIAlertAction(title: "Open-ended", style: .default) { _ in
            self.createWorkout(workoutType: workoutType, goal: .open)
        }
        goalAlert.addAction(openAction)

        let distanceAction = UIAlertAction(title: "Distance", style: .default) { (action) in
            self.promptForDistance(workoutType: workoutType)
        }
        goalAlert.addAction(distanceAction)

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        goalAlert.addAction(cancelAction)

        present(goalAlert, animated: true, completion: nil)
    }

    fileprivate func promptForDistance(workoutType: Workout.WorkoutType) {
        let distanceAlert = UIAlertController(title: "How many miles?", message: nil, preferredStyle: .alert)

        let okAction = UIAlertAction(title: "OK", style: .default) { [weak distanceAlert] _ in
            guard let text = distanceAlert?.textFields?[0].text, let miles = Double(text) else {
                print("couldn't extract/convert data -- data must be numeric")
                return
            }
            self.createWorkout(workoutType: workoutType, goal: .distance(miles: miles))
        }
        distanceAlert.addAction(okAction)
        okAction.isEnabled = false

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        distanceAlert.addAction(cancelAction)

        distanceAlert.addTextField { (textField) in
            textField.text = nil

            NotificationCenter.default.addObserver(forName: .UITextFieldTextDidChange, object: textField, queue: OperationQueue.main, using: { _ in
                var enabled = false
                if let text = textField.text, !text.isEmpty, let _ = Double(text) {
                    enabled = true
                }
                okAction.isEnabled = enabled
            })
        }

        present(distanceAlert, animated: true, completion: nil)
    }


    fileprivate func createWorkout(workoutType: Workout.WorkoutType, goal: Workout.Goal) {
        let workout = Workout(type: workoutType, goal: goal)
        startWorkout(workout: workout)
    }

    fileprivate func startWorkout(workout: Workout) {
        workoutLog.start(workout: workout)
        tableView.reloadData()
    }
}



extension WorkoutViewController {   // UIResponder

    override func restoreUserActivityState(_ activity: NSUserActivity) {
        super.restoreUserActivityState(activity)

        guard let activity = activity.bnrActivity else {
            return
        }

        switch activity {
        case .startWorkout(let workout):
            startWorkout(workout: workout)
        }
    }
}
