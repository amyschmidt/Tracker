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
    // delegate for TodayTabViewController to display if error or success, etc.
    var delegate: CloudKitDelegate?
    // Instantiate an array of the grabbedRecord Object which is used to grab records from the Cloud
    var LogRecords = [grabbedRecord]()
    
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
        formatter.dateFormat = "MM-dd-yyyy"
        var DateString:String = formatter.stringFromDate(date)
        formatter.dateFormat = "hh:mm:ss-a"
        var TimeString:String = formatter.stringFromDate(date)
        // println(DateString)
        record.setObject(DateString, forKey: "date")
        record.setObject(TimeString, forKey: "time")
        self.privateDB.saveRecord(record, completionHandler: { (record, error) -> Void in
            NSLog("Saved to cloud kit")
        })
    }
    
    func update_records()
    {
        // Predicate is the condition on which the record should be matched against
        // let predicate = NSPredicate(value: true)
        // let predicate = NSPredicate(format: "date == '11-17-2014'")
        let queryDate: NSString = "11-17-2014"
        let predicate = NSPredicate(format: "date==%@", queryDate)
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
                var i = 0
                // Records returned
                for record in results
                {
                    // Initialize multiple grabbedRecord Objects
                    let grabRecord = grabbedRecord(record: record as CKRecord, database: self.privateDB)
                    // Append the record to LogRecords Object which is local to this class.
                    self.LogRecords.append(grabRecord)
                    i++
                }
            }
        }
    }
}
let CloudData = cloudData()
