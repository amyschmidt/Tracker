//
//  cloudData.swift
//  TrackerTeamA
//
//  Created by Ryan Pliske on 11/15/14.
//  Copyright (c) 2014 Amy Schmidt. All rights reserved.
//

import CloudKit
import Foundation

// protocol functions will be implemented in the TodayTabViewController
protocol CloudKitDelegate {
    func errorUpdating(error: NSError)
    // func modelUpdated()
}

class cloudData
{
    // namespace for Tracker App
    var container: CKContainer
    // container is divided into 2 databases, public and private
    let privateDB: CKDatabase
    
    var delegate: CloudKitDelegate?
    
    class func sharedInstance() -> cloudData{
        return CloudData
    }
    
    init(){
        container = CKContainer.defaultContainer()
        privateDB = container.privateCloudDatabase
    }
    
    func save_record(todo: Int)
    {
        let record = CKRecord(recordType: "Log")
        record.setValue(todo, forKey: "count")
        
        // Grab the current date, then format the date.
        var date = NSDate()
        var formatter = NSDateFormatter()
        // let currentLocale = NSLocale.currentLocale()
        // formatter.timeStyle = .ShortStyle
        formatter.dateFormat = "MM-dd-yyyy hh:mm:ss"
        var DateString:String = formatter.stringFromDate(date)
        // println(DateString)
        record.setObject(DateString, forKey: "date")
        self.privateDB.saveRecord(record, completionHandler: { (record, error) -> Void in
            NSLog("Saved to cloud kit")
        })
    }
    
    func update_records()
    {
        // Predicate is the condition on which the record should be matched against
        let predicate = NSPredicate(value: true)
        // Query similary to relaitonal db
        let query = CKQuery(recordType: "Log", predicate: predicate)
        self.privateDB.performQuery(query,inZoneWithID: nil)
        {
            results, error in
            // If we have an error than display it
            if error != nil
            {
                dispatch_async(dispatch_get_main_queue())
                {
                    self.delegate?.errorUpdating(error)
                    return
                }
                
            }
            else
            {
                NSLog("Fetching Data")
            }
            
        }
        
    }
   
}
let CloudData = cloudData()
