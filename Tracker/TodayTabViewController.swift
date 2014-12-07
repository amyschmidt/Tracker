//  TodayTabViewController.swift

import UIKit
import CloudKit

class TodayTabViewController: UIViewController, CloudKitDelegate {
    // class variable for accessing cloudDate variables and methods
    var model: cloudData!
    // Storyboard items
    @IBOutlet weak var dailyCount: UILabel!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var plusButton: UIButton!
    @IBOutlet weak var timeSinceLastSmokeLabel: UILabel!
    // Timer items
    var timer = NSTimer()
    var startDate = NSDate()
    // Airplane mode
    var airplaneMode = false
    var airplaneDate : NSDate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        /* Allows this ViewController access to the cloudData's functionality via
        extending this viewControllers class as a delegate of the cloudData class */
        // First, Create a cloudData object to access the delegate from the AppDelegate
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        model = appDelegate.getCloudData()
        // Set the delegate of this ViewController class
        model.delegate = self
        // Call update records from cloudData.swift
        model.update_records()
        // Grab Goal for GoalsTab
        model.grabGoal(false, newGoal: 0)
        // Show Loading Animation
        activityIndicatorView.startAnimating()
        // Disable Buttons
        plusButton.enabled = false
        self.tabBarController?.tabBar.userInteractionEnabled = false
    }
    
    override func viewWillAppear(animated: Bool) {
        // Upload dates saved by the Widget
        // model.update_records()
        let sharedDefaults = NSUserDefaults(suiteName: "group.TrackerTeamA")
        self.airplaneDate = sharedDefaults?.objectForKey("record") as NSDate?
        if (self.airplaneDate != nil)
        {
            model.save_record_to_cloud(self.airplaneDate!)
            dailyCount.text = String(model.dailyRecords.count+1)
        }
        // Clear Out the recent save from the Widget
        self.airplaneDate = nil
        sharedDefaults?.setObject(nil, forKey: "record")
        sharedDefaults?.synchronize()
    }
    
    /* Function for when the Increment Button is clicked */
    @IBAction func incrementerClicked(sender: AnyObject) {
        // If airplane mode is enabled
        if (self.airplaneMode)
        {
            let message = "Once you regain connection iCloud, you can edit this entry."
            let alert = UIAlertView(title: "Notice: You're in Airplane Mode",
                message: message, delegate: nil, cancelButtonTitle: "OK")
            alert.show()
            // Save Record to an array of objects locally to be used in GoalsTAB
            model.save_record_to_phone()
        }
        else
        {
            // Save Record to the cloud
            model.save_record_to_cloud(NSDate())
        }

        // Increment count Label
        var count: Int = NSString(string: dailyCount.text!).integerValue
        count = count + 1
        dailyCount.text = "\(count)"
        // start/reset timer
        self.startDate = NSDate()
        let aSelector:Selector = "updateTime"
        self.timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: aSelector, userInfo: nil, repeats: true)
    }
    
    /* Delegate function is defined here but is actually a part of cloudData.swift
    This function displays an error if the user is not connected to the internet */
    func errorUpdating(error: NSError) {
        // Error Code 4 is Network Failure
        if error.code == 4
        {
            let message = "You do not have internet access. Now Entering Air Plane Mode."
            let alert = UIAlertView(title: "Error Loading Cloud Data.",
                message: message, delegate: nil, cancelButtonTitle: "OK")
            alert.show()
        }
        // Error Code 9 is iCloud Not Setup
        else if error.code == 9
        {
            let message = "Please go to iPhone Settings->iCloud and sign in."
            let alert = UIAlertView(title: "This App Requires iCloud",
                message: message, delegate: nil, cancelButtonTitle: "OK")
            alert.show()
        }

        // Display Airplane Mode
        activityIndicatorView.stopAnimating()
        dailyCount.text = "0"
        self.startDate = NSDate()
        let aSelector:Selector = "updateTime"
        self.timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: aSelector, userInfo: nil, repeats: true)
        plusButton.enabled = true
        // set Airplane Mode
        self.airplaneMode = true
        self.view.backgroundColor = UIColor.blackColor()
        self.tabBarController?.tabBar.userInteractionEnabled = false
        
        return
    }
    
    /* Delegate function is defined here but is actually declared in cloudData.swift
    This function updates the count with an NSDate argument in order to update the Timer */
    func countUpdated(timeOfLastCig:NSDate) {
        dailyCount.text = String(model.dailyRecords.count)
        NSLog("Upon Load 'Today's Count' has been updated to: \(model.dailyRecords.count)")
        activityIndicatorView.stopAnimating()
        plusButton.enabled = true
        self.tabBarController?.tabBar.userInteractionEnabled = true
        // initiate timer (Uses starDate from today if there is a record, else calls grabLastCig)
        self.startDate = timeOfLastCig
        // listen for when the data comes back
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "grabLastCig", name: "fetchLastRecord", object: nil)
        let aSelector:Selector = "updateTime"
        self.timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: aSelector, userInfo: nil, repeats: true)
        // refresh Today Widget values
        let sharedDefaults = NSUserDefaults(suiteName: "group.TrackerTeamA")
        sharedDefaults?.setObject(model.dailyRecords.count, forKey: "count")
        sharedDefaults?.synchronize()
    }
    
    func grabLastCig()
    {
        self.startDate = model.lastRecord[0].date_NS
    }
    
    /* Function to create dynamic stopwatch feature by calculating days, hours, minutes and then displaying them. This function
    gets called by a Selector controlled by NSTimer. So this function literally gets called every second over and over again */
    func updateTime(){
        // get timestamp for right now
        var now = NSDate()
        // set time interval (in seconds) between now and last cigarette
        var elapsedTime:NSTimeInterval = now.timeIntervalSinceDate(self.startDate)
        // calculate number of days (60s/min*60min/hr*24hr) from elapsedTime (which is in seconds)
        let days = UInt8(elapsedTime / (60.0*60.0*24.0))
        // subtract that amount from the time
        elapsedTime -= (NSTimeInterval(days) * 60 * 60 * 24.0)
        // Repeat for hours and minutes
        let hours = UInt8(elapsedTime / (60.0*60.0))
        elapsedTime -= (NSTimeInterval(hours) * 60 * 60)
        
        let minutes = UInt8(elapsedTime / 60.0)
        elapsedTime -= (NSTimeInterval(minutes) * 60)
        
        // using Ternary Operator, create String variables: for values 1-9, display a leading zero
        let strDays:String = days > 9 ? String(days):"0\(String(days))"
        let strHours:String = hours > 9 ? String(hours):"0\(String(hours))"
        let strMinutes:String = minutes > 9 ? String(minutes):"0\(String(minutes))"
        // build the label
        if (UInt8(elapsedTime) % 2 == 0){
            timeSinceLastSmokeLabel.text = "\(strDays)d:\(strHours)h:\(strMinutes)m"
        }
        else {
            timeSinceLastSmokeLabel.text = "\(strDays)d \(strHours)h \(strMinutes)m"
        }
    }
    
    
}
