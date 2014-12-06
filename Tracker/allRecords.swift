//
//  allRecords.swift
//  TrackerTeamA
//
//  Created by Kyle Carlson on 12/5/14.
//  Copyright (c) 2014 Amy Schmidt. All rights reserved.
//

import Foundation
import CloudKit

class allRecords: NSObject {

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
