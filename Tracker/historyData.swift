//
//  historyData.swift
//  TrackerTeamA
//
//  Created by Amy Schmidt on 12/4/14.
//  Copyright (c) 2014 Amy Schmidt. All rights reserved.
//

import UIKit

class historyData: NSObject {
    
    let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate

    historyCloudData = appDelegate.getCloudData()
    
    // grab total
    todaysCount = historyCloudData.LogRecords.count
    //println("(historyCloudData.LogRecords.count)")
    
    for count in historyCloudData.LogRecords[] {
    
    }
    
    // how to grab from LogRecords Array (date_NS "types" are declared in grabbedRecord.swift)
    // historyData.LogRecords[0].date_NS)
    // historyData.LogRecords[0].dateString)

    
}
