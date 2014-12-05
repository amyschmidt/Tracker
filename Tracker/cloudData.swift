//
//  cloudData.swift
//  TrackerTeamA
//

import CloudKit
import Foundation

// protocol functions will be implemented in the TodayTabViewController
protocol CloudKitDelegate {
    func errorUpdating(error: NSError)
    func countUpdated(timeOfLastCig:NSDate)
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
    var LastRecord = [grabbedRecord]()
    // Today's records
    var todaysRecords = [grabbedRecord]()

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
        
        formatter.dateFormat = "hh:mm:ss a"
        var TimeString:String = formatter.stringFromDate(date)
        
        var records_loaded: Int = 0
        records_loaded = LogRecords.count
        // Append Information to the insert query
        // These fields will be used for query purposes
        record.setObject(DateString, forKey: "date")
        record.setObject(TimeString, forKey: "time")
        // This field will be used for grabbing new data when the user is in the app. (Because we will already have some records upon Load)
        record.setValue(records_loaded, forKey: "records_loaded_at_start")
        // This field will be used for dealing with NSDate and NSTimer.
        record.setObject(date, forKey: "NSDate")
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
        let sort = NSSortDescriptor(key: "NSDate", ascending: true)
        // Build the Query: This query is similar to SELECT * FROM Log WHERE date = ''
        let query = CKQuery(recordType: "Log", predicate: predicate)
        query.sortDescriptors = [sort]
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
            // Fetch todays data
            else
            {
                NSLog("Fetching Data From Today")
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
                // Find Date of Last Cigarette
                var dateOfLastCig:NSDate = NSDate()
                // If no records from today, then grab the last cigarette from a different day (Not Today)
                if (i==0)
                {
                    NSLog("No Records from Today, Fetching All Data")
                    self.grabLastCig()
                }
                // else use the last cigarette from Today.
                else
                {
                    dateOfLastCig = self.LogRecords[self.LogRecords.count-1].date_NS
                }
                
                // Tell the ViewController that the Data has returned and update the "Count" in the View.
                // Run countUpdated() on the main thread, because that is the only thread that allows the Interface to be updated.
                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                    // Forces an optional to non optional (Runs only if the optional is not nil)
                    if let aDelegate = self.delegate {
                        aDelegate.countUpdated(dateOfLastCig)
                    }
                })
            }
        }
    }
    /* Function to grab the last record if there are no records for the current day */
    func grabLastCig()
    {
        let predicate = NSPredicate(value: true)
        let sort = NSSortDescriptor(key: "NSDate", ascending: false)
        let query = CKQuery(recordType: "Log", predicate: predicate)
        query.sortDescriptors = [sort]
        
        let request = CKQueryOperation(query: query)
        request.resultsLimit = 1
        request.desiredKeys = ["NSDate"]
        var results = NSMutableArray()
        
        request.recordFetchedBlock = { (record: CKRecord!) in
                let grabRecord = grabbedRecord(record: record as CKRecord, database: self.privateDB)
                self.LastRecord.append(grabRecord)
                println("Result: \(self.LastRecord[0].date_NS)")
                results.addObject(record)
            NSNotificationCenter.defaultCenter().postNotificationName("fetchAllRecords", object: nil)
            }
        
        self.privateDB.addOperation(request)
        return
    }
    
    /*Function to update the goal data*/
    func updateGoal() {
        println("updating Goal")
        // Object that decides which Record (or Table) to save to.
        let record = CKRecord(recordType: "Goals")
        
        var dailyMax:Int = 1
        // dailyMax =
        // Append Information to the insert query
        // These fields will be used for query purposes
        record.setObject(dailyMax, forKey: "DailyMax")
        

        
    }
}
