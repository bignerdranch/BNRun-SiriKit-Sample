//
//  WorkoutTableViewCell.swift
//  BNRun
//
//  Created by hsoi on 6/29/17.
//  Copyright © 2017 Big Nerd Ranch, LLC. All rights reserved.
//

import UIKit
import BNRunCore

class WorkoutTableViewCell: UITableViewCell {

    @IBOutlet weak var workoutTypeLabel: UILabel!
    @IBOutlet weak var workoutGoalLabel: UILabel!
    @IBOutlet weak var workoutDateLabel: UILabel!
    @IBOutlet weak var workoutStateLabel: UILabel!

    private let dateFormatter = DateFormatter()
    private let formatter = MeasurementFormatter()

    func configure(with workout: Workout) {
        workoutTypeLabel.text = workout.type.rawValue.capitalized

        switch workout.goal {
        case .open:
            workoutGoalLabel.text = "Open"
        case .distance(let miles):
            let measurement = Measurement(value: miles, unit: UnitLength.miles)
            workoutGoalLabel.text = formatter.string(from: measurement)
        }

        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .medium
        workoutDateLabel.text = dateFormatter.string(from: workout.startDate)

        workoutStateLabel.text = workout.state.rawValue.capitalized
        workoutStateLabel.textColor = workout.state == .active ? .red : .black
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        workoutDateLabel.text = nil
        workoutGoalLabel.text = nil
        workoutTypeLabel.text = nil
        workoutStateLabel.text = nil
        workoutStateLabel.textColor = .black
    }
}
