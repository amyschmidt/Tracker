//  TodayTabViewController.swift

import UIKit
import CloudKit
/* By extending this ViewController as a delegate of the cloudData class, 
it gives responsibility to this ViewController to implement cloudData's protocols */
class TodayTabViewController: UIViewController, CloudKitDelegate {
    // class variable for accessing cloudDate variables and methods
    var model: cloudData!
    // Storyboard items
    @IBOutlet weak var dailyCountLabel: UILabel!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var plusButton: UIButton!
    @IBOutlet weak var timeSinceLastSmokeLabel: UILabel!
    @IBOutlet weak var refreshButton: UIButton!
    // Initialize Count
    var count:Int = 0
    // Timer items
    var timer = NSTimer()
    var startDate = NSDate()
    var requestMonitoringTimer = NSTimer()
    // Airplane mode
    var airplaneMode = false
    var airplaneDate : NSDate!
    // Widget Sharing Capabilities
    let sharedDefaults = NSUserDefaults(suiteName: "group.TrackerTeamA")
    let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
    var receivedRecordFromWidget = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // First, Create a cloudData object to access the delegate from the AppDelegate
        model = self.appDelegate.getCloudData()
        // Set the delegate of this ViewController class
        model.delegate = self

        // Show Loading Animation
        activityIndicatorView.startAnimating()
        // Disable Buttons
        plusButton.enabled = false
        self.tabBarController?.tabBar.userInteractionEnabled = false
        // Start timeOut Timer if the request takes too long
        println("Monitoring the Request Time...")
        let aSelector:Selector = "monitorRequestTime"
        self.requestMonitoringTimer = NSTimer()
        self.requestMonitoringTimer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: aSelector, userInfo: nil, repeats: true)
        // listen for when the last Record comes back
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "grabLastCigIsFinished_UseItsDate", name: "fetchLastRecord", object: nil)
        // listen for dates saved by the Widget
        self.airplaneDate = sharedDefaults?.objectForKey("record") as NSDate?
        // NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateCountFromWidget", name: "saveRecordFromWidget", object: nil)
    }
    
    /*
    /* CloudKit Delegate function to update the Count From the Widget */
    func updateCountFromWidget()
    {
        // Skip calling this method when the app Loads
        if (!self.appDelegate.appIsActive)
        {
            self.count++
            println("Receiving Records from Widget: Updating Count to: \(self.count) ")
            // dailyCountLabel.text = String(self.count)
            /*
            if (receivedRecordFromWidget)
            {
                model.save_record_to_cloud(NSDate())
            }
            */
        }
        // Clear Out the recent save from the Widget
        // self.airplaneDate = nil
        sharedDefaults?.setObject(nil, forKey: "record")
        sharedDefaults?.synchronize()
    }
*/
    
    
    @IBAction func refreshCount(sender: AnyObject) {
        // Call update records from cloudData.swift
        model.grab_todays_records()
        // Show Loading Animation
        activityIndicatorView.startAnimating()
    }
    
    /* Function for when the Increment Button is clicked */
    @IBAction func incrementerClicked(sender: AnyObject) {
        println("Incrementer Clicked")
        // If airplane mode is enabled
        if (self.airplaneMode)
        {
            let message = "Once you regain connection in iCloud, you can edit this entry."
            let alert = UIAlertView(title: "Notice: You're in Airplane Mode",
                message: message, delegate: nil, cancelButtonTitle: "OK")
            alert.show()
            // Save Record to an array of objects locally to be used in GoalsTAB
            model.save_record_to_phone(NSDate())
        }
        else
        {
            // Save Record to the cloud
            model.save_record_to_cloud(NSDate(), savedForWidget: false)
        }
    }
    /* Monitor the initial download time */
    func monitorRequestTime()
    {
        var now = NSDate()
        var elapsedTime:NSTimeInterval = now.timeIntervalSinceDate(self.startDate)
        // If we haven't heard from iCloud
        if elapsedTime > 12 && !model.iCloudResponse
        {
            // Display Error Message to User
            let message = "Tracker cannot access your data because the network connection was lost."
            let alert = UIAlertView(title: "Your Request Has Timed Out.",
                message: message, delegate: nil, cancelButtonTitle: "OK")
            alert.show()
            // Stop requestTimer
            self.requestMonitoringTimer.invalidate()
            println("Request Timer Stopped.")
            // Display Airplane Mode
            self.displayAirplaneMode()
        }
        // Else we heard from iCloud but got an Error and are therefore in Airplane Mode, we don't want this timer to keep running so I shut it off after 8 seconds.
        else if elapsedTime > 12 && model.iCloudResponse
        {
            // Stop requestTimer
            self.requestMonitoringTimer.invalidate()
            println("Request Timer Stopped.")
        }
        // Else we heard from iCloud and got our Today Records and therefore should shut off the timer immediately.
        else if model.iCloudResponse
        {
            // Stop requestTimer
            self.requestMonitoringTimer.invalidate()
            println("Request Timer Stopped.")
        }
    }
    /* Start the Viewable timer */
    func startViewableTimer(date:NSDate)
    {
        self.startDate = date
        let aSelector:Selector = "updateViewableTimer"
        self.timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: aSelector, userInfo: nil, repeats: true)
        return
    }
    
    /* Display Airplane Mode */
    func displayAirplaneMode()
    {
        activityIndicatorView.stopAnimating()
        dailyCountLabel.text = "0"
        plusButton.enabled = true
        self.tabBarController?.tabBar.userInteractionEnabled = false
        // Show refresh button
        self.refreshButton.hidden = false
        self.refreshButton.userInteractionEnabled = true
        // set Airplane Mode
        self.airplaneMode = true
        return
    }
    /* CloudKit Delegate function to handle errors from grabbing from the server */
    func errorUpdating(error: NSError) {
        // Force User to Go to and be trapped on TodayTab
        // self.navigationController?.pushViewController(self, animated: true)
        self.navigationController?.popToRootViewControllerAnimated(true)
        // Error Code 4 is Network Failure
        if error.code == 4
        {
            let message = "You do not have internet access. Please Try again Later."
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
        self.displayAirplaneMode()

        // Start Timer
        self.startViewableTimer(NSDate())

        return
    }
    
    /* CloudKit Delegate function to handle errors from saving to the server */
    func successfulSave() {
        // Increment count Label
        self.count = NSString(string: dailyCountLabel.text!).integerValue
        self.count++
        dailyCountLabel.text = "\(self.count)"
        // start/reset timer
        self.startDate = NSDate()
        let aSelector:Selector = "updateViewableTimer"
        self.timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: aSelector, userInfo: nil, repeats: true)
        // refresh Today Widget values
        self.sharedDefaults?.setObject(self.count, forKey: "count")
        self.sharedDefaults?.synchronize()
    }
    
    /* CloudKitDelegate function that Sets the Labels for the count and timer */
    func successfulGrab_UpdateCount(timeOfLastCig:NSDate) {
        // Save the Count
        self.count = model.NumberOfDailyRecords
        dailyCountLabel.text = String(self.count)
        NSLog("Upon Load 'Today's Count' has been updated to: \(self.count)")
        activityIndicatorView.stopAnimating()
        plusButton.enabled = true
        self.tabBarController?.tabBar.userInteractionEnabled = true

        // Initialize Timer
        self.startViewableTimer(timeOfLastCig)
        // refresh Today Widget values
        self.sharedDefaults?.setObject(self.count, forKey: "count")
        self.sharedDefaults?.synchronize()
        // Hide refresh button
        self.refreshButton.hidden = true
        self.refreshButton.userInteractionEnabled = false
    }
    /* Func is fired off by the Notifaction Center */
    func grabLastCigIsFinished_UseItsDate()
    {
        self.startDate = model.lastRecord[0].date_NS
    }
    
    /* Function to create dynamic stopwatch feature by calculating days, hours, minutes and then displaying them. This function
    gets called by a Selector controlled by NSTimer. So this function literally gets called every second over and over again */
    func updateViewableTimer(){
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
            timeSinceLastSmokeLabel.text = "\(strDays):\(strHours):\(strMinutes)"
        }
        else {
            timeSinceLastSmokeLabel.text = "\(strDays) \(strHours) \(strMinutes)"
        }
    }
    
    
}
