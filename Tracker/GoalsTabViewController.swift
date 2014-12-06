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
        // Grab the goal from the cloud
        // model.grabGoal()
        // NSNotificationCenter.defaultCenter().addObserver(self, selector: "setGoal", name: "fetchGoal", object: self.goal)
    }
    
    override func viewWillAppear(animated: Bool) {
        model.grabGoal()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "setGoal", name: "fetchGoal", object: self.goal)
    }
    
    func setGoal(){
        println("Setting the Slider to: \(model.maxGoal)")
        // Set label text equal to the goal
        self.dailyMax.text = "\(model.maxGoal)"
        // Set the actual slider equal to the goal
        goalsSlider.value = Float(model.maxGoal)
        // Set rest of the labels
        dailyMax.text = "\(model.maxGoal)"
        weeklyMax.text = "\(model.maxGoal * 7)"
        monthlyMax.text = "\(model.maxGoal * 30)"
        yearlyMax.text = "\(model.maxGoal * 356)"
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
        goal = Int(sender.value)
        //calls function in cloudData.swift
        model.saveGoal(goal)
    }
}
