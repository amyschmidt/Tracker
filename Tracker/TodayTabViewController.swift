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
        activityIndicatorView.startAnimating()
        plusButton.enabled = false
    }
    /* Function for when the Increment Button is clicked */
    @IBAction func incrementerClicked(sender: AnyObject) {
        // Change Count of the Label
        var count: Int = NSString(string: dailyCount.text!).integerValue
        count = count + 1
        dailyCount.text = "\(count)"
        // Save Record to the cloud
        model.save_record_to_THECLOUD()
        
        // Save Record to an array of objects locally to be used in GoalsTAB
        model.save_record_inArray()
        
        // initiate timer
        self.startDate = NSDate()
        let aSelector:Selector = "updateTime"
        self.timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: aSelector, userInfo: nil, repeats: true)
    }
    
    /* Delegate function is defined here but is actually a part of cloudData.swift
    This function displays an error if the user is not connected to the internet */
    func errorUpdating(error: NSError) {
        let message = error.localizedDescription
        let alert = UIAlertView(title: "Error Loading Cloud Data. Please Check your Internet Connection",
            message: message, delegate: nil, cancelButtonTitle: "OK")
        alert.show()
    }
    
    /* Delegate function is defined here but is actually declared in cloudData.swift
    This function updates the count with an NSDate argument in order to update the Timer */
    func countUpdated(timeOfLastCig:NSDate) {
        dailyCount.text = String(model.LogRecords.count)
        NSLog("Upon Load the 'count' has been updated to: \(model.LogRecords.count)")
        activityIndicatorView.stopAnimating()
        plusButton.enabled = true
        // initiate timer (Uses starDate from today if there is a record, else calls grabLastCig)
        self.startDate = timeOfLastCig
        // listen for when the data comes back
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "grabLastCig", name: "fetchAllRecords", object: nil)
        let aSelector:Selector = "updateTime"
        self.timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: aSelector, userInfo: nil, repeats: true)
    }
    
    func grabLastCig()
    {
        self.startDate = model.LastRecord[0].date_NS
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
