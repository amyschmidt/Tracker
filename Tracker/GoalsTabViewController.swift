//
//  GoalsTabViewController.swift
//  TrackerTeamA

import UIKit

class GoalsTabViewController: UIViewController {

    var model: cloudData!
    var goal: Int!
    //daily, weekly, monthly, yearly labels
    @IBOutlet weak var dailyMax: UILabel!
    @IBOutlet weak var weeklyMax: UILabel!
    @IBOutlet weak var monthlyMax: UILabel!
    @IBOutlet weak var yearlyMax: UILabel!
    @IBOutlet weak var goalsSlider: UISlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        model = appDelegate.getCloudData()
        // May need to uncomment next line IF experiecing bugs or Lag
        // NSNotificationCenter.defaultCenter().addObserver(self, selector: "setGoal", name: "fetchGoal", object: nil)
        self.setGoal()
    }
    
    // set the labels according to the record pulled from the cloud
    func setGoal(){
        if (model.maxGoal > 0)
        {
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
    }

    
    // when slider value changes, update all labels to correct value
    @IBAction func sliderValueChanged(sender: UISlider) {
        var currentValue = Int(sender.value)
        dailyMax.text = "\(currentValue)"
        weeklyMax.text = "\(currentValue * 7)"
        monthlyMax.text = "\(currentValue * 30)"
        yearlyMax.text = "\(currentValue * 356)"
    }
    // when slider stops (Technically user "untouches" the screen) then save goal
    @IBAction func sliderStopped(sender: UISlider) {
        self.goal = Int(sender.value)
        //calls function in cloudData.swift
        model.saveGoal(self.goal)
    }
}
