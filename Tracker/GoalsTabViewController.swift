//
//  GoalsTabViewController.swift
//  TrackerTeamA
//
//  Created by Amy Schmidt on 11/17/14.
//  Copyright (c) 2014 Amy Schmidt. All rights reserved.
//

import UIKit

class GoalsTabViewController: UIViewController {

    var model: cloudData!
    
    //daily, weekly, monthly, yearly labels
    @IBOutlet weak var dailyMax: UILabel!
    @IBOutlet weak var weeklyMax: UILabel!
    @IBOutlet weak var monthlyMax: UILabel!
    @IBOutlet weak var yearlyMax: UILabel!
    
    
    @IBOutlet weak var goalsSlider: UISlider!
    
    var goal: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        model = appDelegate.getCloudData()

    }

    
    //when slider value changes, update all labels to correct value
    @IBAction func sliderValueChanged(sender: UISlider) {

        var currentValue = Int(sender.value)
        
        dailyMax.text = "\(currentValue)"
        
        weeklyMax.text = "\(currentValue * 7)"
        
        monthlyMax.text = "\(currentValue * 30)"
        
        yearlyMax.text = "\(currentValue * 356)"
        
    }
    
    @IBAction func sliderStopped(sender: UISlider) {
        println("Stopped")
        
        goal = Int(sender.value)
        
        println("\(goal)")
        
        //call updateGoal with new goal data?
        model.updateGoal(goal)
    }
    
    

}
