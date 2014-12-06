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
    weak var database : CKDatabase!
    
    init(record : CKRecord, database: CKDatabase)
    {
        self.record = record
        self.database = database
        self.dateString = record.objectForKey("date") as String!
        self.date_NS = record.objectForKey("NSDate") as NSDate!
    }
    
}
