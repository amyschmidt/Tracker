//
//  grabbedRecord.swift
//  TrackerTeamA
//
//  Created by Ryan Pliske on 11/17/14.
//  Copyright (c) 2014 Amy Schmidt. All rights reserved.
//

import Foundation
import CloudKit

class grabbedRecord: NSObject {
    var record : CKRecord!
    var dateString : String!
    var timeString : String!
    weak var database : CKDatabase!
    var date: NSDate
    init(record : CKRecord, database: CKDatabase) {
        self.record = record
        self.database = database
        self.dateString = record.objectForKey("date") as String!
        self.timeString = record.objectForKey("time") as String!
        self.date = record.creationDate
    }
}
