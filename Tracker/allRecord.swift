//
//  allRecord.swift
//  TrackerTeamA
//


import Foundation
import CloudKit

class allRecord: NSObject {

    var record : CKRecord!
    var dateString : String!
    var date_NS : NSDate!
    var month : String!
    var year : String!
    weak var database : CKDatabase!
    
    init(record : CKRecord, database: CKDatabase)
    {
        self.record = record
        self.database = database
        self.dateString = record.objectForKey("date") as String!
        self.date_NS = record.objectForKey("NSDate") as NSDate!
        self.month = record.objectForKey("month") as String!
        self.year = record.objectForKey("year") as String!
    }
    
}
