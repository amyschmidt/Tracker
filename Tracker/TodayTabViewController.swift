//
//  TodayTabViewController.swift
//  Tracker
//
//  Created by Amy Schmidt on 11/12/14.
//  Copyright (c) 2014 Amy Schmidt. All rights reserved.
//

import UIKit
import CloudKit

class TodayTabViewController: UIViewController, CloudKitDelegate{
    let model: cloudData = cloudData.sharedInstance()

    //daily count Label
    @IBOutlet weak var dailyCount: UILabel!
    
    //stepper
    @IBOutlet weak var tracker: UIStepper!
    
    // var appleDelegate:AppDelegate
    // var CloudData:cloudData
    
    override func viewDidLoad() {
        super.viewDidLoad()
        model.delegate = self;
        
        // let appleDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        // let CloudData = appleDelegate.getCloudData()
        
        CloudDataObject.update_records()
        // dailyCount.text = String(CloudDataObject.LogRecords.count)
        
        
        //initializing stepper
        tracker.wraps = true
        tracker.autorepeat = true
        tracker.maximumValue = 60
        
    }
    
    //changes dailyCount label according to the value of the stepper
    @IBAction func trackerValueChanged(sender:UIStepper) {
        dailyCount.text = Int(sender.value).description
        var countString = sender.value.description
        var count = Int(sender.value)
        
        // let appleDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        // let CloudData = appleDelegate.getCloudData()

        CloudDataObject.save_record(count)
        
    }
    
    func errorUpdating(error: NSError) {
        let message = error.localizedDescription
        let alert = UIAlertView(title: "Error Loading Cloud Data",
            message: message, delegate: nil, cancelButtonTitle: "OK")
        alert.show()
    }
    
    func countUpdated() {
        NSLog("Model refreshed \(CloudDataObject.LogRecords.count)")
        dailyCount.text = String(CloudDataObject.LogRecords.count)
        // Refresh view Controller?
    }
    
}
