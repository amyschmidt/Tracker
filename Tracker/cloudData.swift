//
//  cloudData.swift
//  TrackerTeamA
//
//  Created by Ryan Pliske on 11/15/14.
//  Copyright (c) 2014 Amy Schmidt. All rights reserved.
//

import CloudKit
import Foundation

class cloudData {
    // namespace for Tracker App
    var container: CKContainer
    // container is divided into 2 databases, public and private
    let privateDB: CKDatabase
    
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
        // https://developer.apple.com/library/ios/documentation/cocoa/Conceptual/DataFormatting/Articles/dfDateFormatting10_4.html
        var date = NSDate()
        var formatter = NSDateFormatter()
        // let currentLocale = NSLocale.currentLocale()
        // formatter.timeStyle = .ShortStyle
        formatter.dateFormat = "MM-dd-yyyy hh:mm:ss"
        var DateString:String = formatter.stringFromDate(date)
        // println(DateString)
        record.setObject(DateString, forKey: "date")
        privateDB.saveRecord(record, completionHandler: { (record, error) -> Void in
            NSLog("Saved to cloud kit")
        })
    }
   
}
let CloudData = cloudData()
