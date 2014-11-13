//
//  TodayTabViewController.swift
//  Tracker
//
//  Created by Amy Schmidt on 11/12/14.
//  Copyright (c) 2014 Amy Schmidt. All rights reserved.
//

import UIKit

class TodayTabViewController: UIViewController {

    //daily count Label
    @IBOutlet weak var dailyCount: UILabel!
    
    //stepper
    @IBOutlet weak var tracker: UIStepper!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //initializing stepper
        tracker.wraps = true
        tracker.autorepeat = true
        tracker.maximumValue = 40
        
    }
    
    //changes dailyCount label according to the value of the stepper
    @IBAction func trackerValueChanged(sender:UIStepper) {
        dailyCount.text = Int(sender.value).description
    }
    
}
