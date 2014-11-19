//
//  cloudData.swift
//  TrackerTeamA
//

import CloudKit
import Foundation

// protocol functions will be implemented in the TodayTabViewController
protocol CloudKitDelegate {
    func errorUpdating(error: NSError)
    func countUpdated()
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

    init(){
        container = CKContainer.defaultContainer()
        privateDB = container.privateCloudDatabase
    }
    
    func save_record()
    {
        // Object that decides which Record (or Table) to save to.
        let record = CKRecord(recordType: "Log")
        // Grab the current date, then format the date.
        var date = NSDate()
        var formatter = NSDateFormatter()
        // Format the day and time into string. (Might change this to date format)
        formatter.dateFormat = "MM-dd-yyyy"
        var DateString:String = formatter.stringFromDate(date)
        formatter.dateFormat = "hh:mm:ss-a"
        var TimeString:String = formatter.stringFromDate(date)
        // Append the date and time to the insert query
        record.setObject(DateString, forKey: "date")
        record.setObject(TimeString, forKey: "time")
        // Save record is the function used similar to Insert Statement in RDBMS
        self.privateDB.saveRecord(record, completionHandler: { (record, error) -> Void in
            NSLog("New Record has been Saved to cloud kit")
        })
    }
    
    func update_records()
    {
        // Predicate is the condition on which the record should be matched against
        // First, Grab the current date, then format the date.
        var date = NSDate()
        var formatter = NSDateFormatter()
        formatter.dateFormat = "MM-dd-yyyy"
        var queryDate:String = formatter.stringFromDate(date)
        let predicate = NSPredicate(format: "date==%@", queryDate)
        // Build the Query: This query is similar to SELECT * FROM Log WHERE date = '' to relaitonal db.
        let query = CKQuery(recordType: "Log", predicate: predicate)
        // Execute the Query
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
                NSLog("Fetching Data From User's Private Cloud")
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
                // Tell the ViewController that the Data has returned and update the "Count" in the View.
                self.delegate?.countUpdated()
            }
        }
    }
}
