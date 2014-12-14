//
//  cloudData.swift
//  TrackerTeamA
//

import CloudKit
import Foundation

// protocol functions will be implemented in the TodayTabViewController
protocol CloudKitDelegate {
    func successfulSave()
    func unsuccessfulSave(error : NSError)
    func errorUpdating(error: NSError)
    func successfulGrab_UpdateCount(timeOfLastCig:NSDate)
    // func updateCountFromWidget()
}

class cloudData
{
    // namespace for Tracker App
    var container: CKContainer
    // container is divided into 2 databases, public and private
    let privateDB: CKDatabase
    // delegate for TodayTabViewController to display if error or success, etc.
    var delegate: CloudKitDelegate?
    // Instantiate an array of the dailyRecord Object which is used to grab records from the Cloud
    var dailyRecords = [dailyRecord]()
    var lastRecord = [dailyRecord]()
    //Instantiate an array for the monthlyRecord Object and yearlyRecord Object
    var monthlyRecords = [monthlyRecord]()
    
    // Current session records
    var sessionRecords = [sessionRecord]()
    // AirplaneMode records
    var airplaneModeRecords = [sessionRecord]()
    var airplaneModeRecord : sessionRecord?
    var airplaneModeDates = [NSDate]()
    // All Records
    var allRecords = [allRecord]()
    // Goal (record)
    var goalRecord: CKRecord!
    var maxGoal: Int = 0
    // date of Last Cig
    var dateOfLastCig:NSDate = NSDate()
    // HTTP Request Variables for Network Issues
    var airPlaneMode = true
    var requestAttempts : Int = 0
    var NumberOfDailyRecords : Int = 0

    init(){
        container = CKContainer.defaultContainer()
        privateDB = container.privateCloudDatabase
        
        // Begin process of Grabbing the Goal
        // self.grabGoal(false, newGoal: 0)
    }
    
    func checkForAirplaneRecords_AttemptToUploadThem()
    {
        // Unarchive + Load any records if user incremented during Airplane Mode or using the Widget.
        if let savedDates = NSUserDefaults.standardUserDefaults().objectForKey("records") as? [NSDate]
        {
            println("Found record(s) saved during Airplane Mode. Attempting to Upload them to iCloud...")
            // airplaneModeDates can be used in other ViewControllers if someone needs them.
            self.airplaneModeDates = savedDates
            // Save All the Records to the Cloud
            var i:Int=0
            for records in self.airplaneModeDates
            {
                // If savedForWidget is true, then it will grab the records after it's called.
                self.save_record_to_cloud(records, savedForWidget: false)
                i++
            }
            println("Clearing \(i) airplane record(s) from User's Phone.")
            // Clear out the local data from NSUserDefaults
            var appDomain = NSBundle.mainBundle().bundleIdentifier
            // NSUserDefaults.removePersistentDomainForName(appDomain)
            NSUserDefaults.standardUserDefaults().removePersistentDomainForName(appDomain!)
        }
    }
    
    func save_record_to_phone(date : NSDate)
    {
        self.airplaneModeDates.append(date)
        NSUserDefaults.standardUserDefaults().setObject(self.airplaneModeDates, forKey: "records")
        println("Saving Record [\(NSDate())]to Phone")
    }
    
    func save_record_to_cloud(date: NSDate, savedForWidget: Bool)
    {
        
        if !savedForWidget
        {
            // Save to current session's records array
            let today = sessionRecord()
            self.sessionRecords.append(today)
        }
        
        // Object that decides which Record (or Table) to save to.
        let record = CKRecord(recordType: "Log")

        var formatter = NSDateFormatter()
        // Format the day and time into string.
        formatter.dateFormat = "MM-dd-yyyy"
        var DateString:String = formatter.stringFromDate(date)
        
        //format the month and year variables
        formatter.dateFormat = "MM"
        var month:String = formatter.stringFromDate(date)
        
        formatter.dateFormat = "yyyy"
        var year:String = formatter.stringFromDate(date)
        
        // var records_loaded: Int = 0
        // records_loaded = dailyRecords.count
        // Append Information to the insert query
        // These fields will be used for query purposes
        record.setObject(DateString, forKey: "date")
        // record.setObject(TimeString, forKey: "time")
        // This field will be used for grabbing new data when the user is in the app. (Because we will already have some records upon Load)
        // record.setValue(records_loaded, forKey: "records_loaded_at_start")
        // This field will be used for dealing with NSDate and NSTimer.
        record.setObject(date, forKey: "NSDate")
        
        //Append Month and Year info to insert query
        record.setObject(month, forKey: "month")
        record.setObject(year, forKey: "year")
        
        // Save record is the function used similar to Insert Statement in RDBMS
        self.privateDB.saveRecord(record, completionHandler: { (record, error) -> Void in
            if error != nil
            {
                dispatch_async(dispatch_get_main_queue())
                {
                        self.delegate?.unsuccessfulSave(error)
                        self.save_record_to_phone(date)
                        return
                }
            }
            else
            {
                dispatch_async(dispatch_get_main_queue())
                {
                    println("New Record has been Saved to cloud kit")
                    self.delegate?.successfulSave()
                    /*
                    if (savedForWidget)
                    {
                        self.grab_todays_records()
                    }*/
                    return
                }
            }
        
        })
    }
    
    /* This function grabs today's records based on date */
    func grab_todays_records()
    {
        
        self.requestAttempts++
        // Predicate is the condition on which the record should be matched against
        // First, Grab the current date, then format the date.
        var date = NSDate()
        var formatter = NSDateFormatter()
        formatter.dateFormat = "MM-dd-yyyy"
        // Set all paramaters we need to perform the Query
        var queryDate:String = formatter.stringFromDate(date)
        let predicate = NSPredicate(format: "date==%@", queryDate)
        let sort = NSSortDescriptor(key: "NSDate", ascending: true)
        let query = CKQuery(recordType: "Log", predicate: predicate)
        query.sortDescriptors = [sort]
        /*  performQuery() asynchronously searches the indicated zone. In this case we search the user's private Database. The error handling block only runs if we get a message back from iCloud. During our first presentation thish block never got executed because we had a weak connection to Mizzou's WiFi. We never got a response, thus the error handling functionality was never fired. In order to solve this solution I tried multiple attempts to handle a weak connection on my own by building custom functions. But then I realized someone must have already done this so I began searching Apple's SDK looking for a library that I could implement to handle our network issues. I came across multiple libraries like NSURLConnection, NSURLSession. but I then realized these libraries are prebuilt to handle their own HTTP requests, so I came back around to further studies in Advanced CloudKit */
        self.privateDB.performQuery(query,inZoneWithID: nil)
        {
            results, error in
            println("Fetching Today's Records")
            // If iCloud responds with an Error, then display the error to the User.
            if error != nil
            {
                dispatch_async(dispatch_get_main_queue())
                {
                    self.airPlaneMode = true
                    self.delegate?.errorUpdating(error)
                    return
                }
            }
            // If iCloud responds with our records, then display the count to the User.
            else
            {
                dispatch_async(dispatch_get_main_queue())
                {
                    self.airPlaneMode = false
                    var i = 0
                    // if grabbing today's records after the first time, then refresh the array (Before it was appending more and more records) 
                    
                    self.sessionRecords=[sessionRecord]()
                    self.dailyRecords = [dailyRecord]()
                    
                    // Records returned
                    
                    for record in results
                    {
                        // Initialize multiple dailyRecord Objects
                        var grabRecord = dailyRecord(record: record as CKRecord, database: self.privateDB)
                        // Append the record to array IF in first session
                        self.dailyRecords.append(grabRecord)
                        i++
                    }
                    
                    
                    
                    
                    // Save the Count
                    self.NumberOfDailyRecords = i
                    // Find Date of Last Cigarette
                    
                    // If no records from today, then grab the last cigarette from a different day (Not Today)
                    if (i==0)
                    {
                        println("No Records from Today, Fetching All Data")
                        self.grabLastCig()
                    }
                    // else use the last cigarette from Today.
                    else
                    {
                        self.dateOfLastCig = self.dailyRecords[self.dailyRecords.count-1].date_NS
                    }
                    // Tell the ViewController that the Data has returned and update the "Count" in the View.
                    self.delegate?.successfulGrab_UpdateCount(self.dateOfLastCig)
                    return
                }
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
                let grabRecord = dailyRecord(record: record as CKRecord, database: self.privateDB)
                self.lastRecord.append(grabRecord)
                println("Last Cigarette was: \(self.lastRecord[0].date_NS)")
                results.addObject(record)
            NSNotificationCenter.defaultCenter().postNotificationName("fetchLastRecord", object: nil)
            }
        
        self.privateDB.addOperation(request)
        return
    }
    
    // Function to tell grabGoal wether or not to Save
    func saveGoal(var goal: Int){
        grabGoal(true, newGoal: goal)
    }
    
    func saveNewGoal(newGoal: Int) {
        let record_id:CKRecordID = CKRecordID(recordName: "1")
        var record2: CKRecord!
        record2 = CKRecord(recordType: "Goals", recordID: record_id)
        record2.setObject(newGoal, forKey: "DailyMax")
        
        self.privateDB.saveRecord(record2, completionHandler: { record, error in
            if error != nil {
                println("Error occurred while saving \(error)")
                self.airPlaneMode = true
            }
            else
            {
                println("Saving Goal to iCloud As: \(newGoal)")
                self.maxGoal = newGoal
                self.airPlaneMode = false
            }
        })

    }
    
    // Function to grab the goal from the cloud AND THEN SAVE IF NECCESSARY
    func grabGoal(save : BooleanType, newGoal: Int){
        let record_id:CKRecordID = CKRecordID(recordName: "1")
        var record: CKRecord!
        var error: NSError!
        privateDB.fetchRecordWithID(record_id){
            (dbRecord, error) in
            // If error, then we can't connect to the Internet.
            if error != nil
            {
                dispatch_async(dispatch_get_main_queue())
                {
                    println("Error Grabbing Goal from iCloud \(error)")
                    self.airPlaneMode = true
                }
            }
            // Else if there just isn't a goal in the database, then save a new one.
            else if dbRecord == nil
            {
                if (save)
                {
                    self.saveNewGoal(newGoal)
                }
            }
            // Else we received a goal, now we need to replace it
            else
            {
                // Push this block to main thread
                dispatch_async(dispatch_get_main_queue())
                {
                    self.airPlaneMode = false
                    // Set maxGoal
                    self.maxGoal = dbRecord.objectForKey("DailyMax") as Int!
                    println("Received Goal from iCloud as: \(self.maxGoal)")
                    // If user wants to save, then push to Cloud, else don't push to Cloud
                    if (save)
                    {
                        dbRecord.setObject(newGoal, forKey: "DailyMax")
                        self.privateDB.saveRecord(dbRecord, completionHandler: { record, error in
                            if error != nil {
                                println("Error occurred while saving \(error)")
                            }
                            else
                            {
                                println("Saving Goal to iCloud As: \(newGoal)")
                                // Set maxGoal
                                self.maxGoal = newGoal
                            }
                            
                        })
                    }
                    else
                    {
                        // Post to Notification Center to let GoalsTab Know that the Goal was successfuly GRABBED
                        NSNotificationCenter.defaultCenter().postNotificationName("fetchGoal", object: nil)
                    }
                }
            }
        }
        return
    }
    
    func grabAllRecords() {
        // First, Grab the current date, then format the date.
        var date = NSDate()
        var formatter = NSDateFormatter()
        formatter.dateFormat = "MM-dd-yyyy"
        var queryDate:String = formatter.stringFromDate(date)
        let predicate = NSPredicate(value: true)
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
                        self.airPlaneMode = true
                        self.delegate?.errorUpdating(error)
                        return
                }
                
            }
            // Fetch todays data
            else
            {
                self.airPlaneMode = false
                println("Fetching All Data")
                var i = 0
                // Records returned
                for record in results
                {
                    // Initialize multiple allRecord Objects
                    let aRecord = allRecord(record: record as CKRecord, database: self.privateDB)
                    // Append the record to LogRecords Object which is local to this class.
                    self.allRecords.append(aRecord)
                    i++
                }
                
                NSNotificationCenter.defaultCenter().postNotificationName("fetchAllRecords", object: nil)
            }
    
        }
       
    }
    /*
    func save_record_from_Widget()
    {
        if (true)
        {
            // I still need to grab actual record and not just use NSDate here...
            self.save_record_to_cloud(NSDate())
        }
        else
        {
            self.save_record_to_phone()
        }
    }
    */
    
    
    func deleteRecord(record: CKRecord){
        
        var error: NSError!
        
        
    
        var recordsToSave: CKRecord!
        
        var recordIDsToDelete: CKRecordID!
        
        let returnRecord = record
        
        recordIDsToDelete = record.recordID
    
        
        privateDB.deleteRecordWithID(record.recordID, completionHandler: ({returnRecord, error in
            if let err = error {
                dispatch_async(dispatch_get_main_queue()) {
                    self.airPlaneMode = true
                    // self.notifyUser("Delete Error", message: err.localizedDescription)
                    
                }
            } else {
                dispatch_async(dispatch_get_main_queue()) {
                    self.airPlaneMode = false
                    // self.notifyUser("Success", message: "Record deleted successfully")
                }
            }
        }))
        
    }
    
    
}
