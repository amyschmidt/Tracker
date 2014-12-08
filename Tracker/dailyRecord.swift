//
//  dailyRecord.swift
//  TrackerTeamA
//


import Foundation
import CloudKit

class dailyRecord: NSObject
{
    var record : CKRecord!
    var dateString : String!
    var date_NS : NSDate!
    var month : Int!
    var year : Int!

    weak var database : CKDatabase!
    
    init(record : CKRecord, database: CKDatabase)
    {
        self.record = record
        self.database = database
        self.dateString = record.objectForKey("date") as String!
        self.date_NS = record.objectForKey("NSDate") as NSDate!
        self.month = record.objectForKey("month") as Int!
        self.year = record.objectForKey("year") as Int!
    }
}
