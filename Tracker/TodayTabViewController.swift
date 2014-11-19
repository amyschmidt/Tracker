//
//  TodayTabViewController.swift
//  Tracker
//

import UIKit
import CloudKit

class TodayTabViewController: UIViewController, CloudKitDelegate{

    var model: cloudData!
    //daily count Label
    @IBOutlet weak var dailyCount: UILabel!
    
    //stepper
    @IBOutlet weak var tracker: UIStepper!
    
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
    }
    
    /* Function for when the Increment Button is clicked */
    @IBAction func incrementerClicked(sender: AnyObject) {
        var count: Int = NSString(string: dailyCount.text!).integerValue
        count = count + 1
        // NOTE: There is a difference when concatenating strings with other values like integers/floats
        // For example: println("Before: \(dailyCount.text)") concatenates the literal value
        dailyCount.text = "\(count)"
        model.save_record()
    }
    
    /* Delegate function is defined here but is actually a part of cloudData.swift 
        This function displays an error if the user is not connected to the internet */
    func errorUpdating(error: NSError) {
        let message = error.localizedDescription
        let alert = UIAlertView(title: "Error Loading Cloud Data. Please Check your Internet Connection",
            message: message, delegate: nil, cancelButtonTitle: "OK")
        alert.show()
    }
    
    /* Delegate functino is defined here but is actually a part of cloudData.swift 
        This function updates the count */
    func countUpdated() {
        NSLog("Upon Load the 'count' has been updated to: \(model.LogRecords.count)")
        dailyCount.text = String(model.LogRecords.count)
    }
    
}
