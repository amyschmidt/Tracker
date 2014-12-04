//
//  grabbedRecord.swift
//  TrackerTeamA
//


// import Foundation
import CloudKit

class grabbedRecord: NSObject
{
    var record : CKRecord!
    var dateString : String!
    var timeString : String!
    var recordsLoadedInitially :Int!
    var date_NS : NSDate!
    weak var database : CKDatabase!
    var date: NSDate
    
    init(record : CKRecord, database: CKDatabase)
    {
        self.record = record
        self.database = database
        self.dateString = record.objectForKey("date") as String!
        self.timeString = record.objectForKey("time") as String!
        self.recordsLoadedInitially = record.objectForKey("records_loaded_at_start") as Int!
        self.date_NS = record.objectForKey("NSDate") as NSDate!
        self.date = record.creationDate
    }
}
