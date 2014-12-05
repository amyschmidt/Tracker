//
//  HistoryTabViewController.swift
//  TrackerTeamA
//
//  Created by Amy Schmidt on 11/23/14.
//  Copyright (c) 2014 Amy Schmidt. All rights reserved.
//

import UIKit

class HistoryTabViewController: UIViewController {

    //segmented control var
    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    //labels in segment control
    @IBOutlet weak var total: UILabel!
    @IBOutlet weak var barGraph: UILabel!
    @IBOutlet weak var average: UILabel!
    @IBOutlet weak var lastSmokeTimer: UILabel!
    @IBOutlet weak var mostSmokedDay: UILabel!
    
    var historyData : cloudData!
    var todaysCount : Int!
    
    @IBOutlet weak var dataLabel: UILabel!
    
    override func viewWillAppear(animated: Bool) {
        // Grab total records (Cloud records + Incremented Records)
        todaysCount = historyData.LogRecords.count + historyData.todaysRecords.count
        dataLabel.text = "\(todaysCount)"
        for records in historyData.todaysRecords{
            println("Incremented Record: \(records.date_NS)")
        }
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        historyData = appDelegate.getCloudData()
    }
    
    @IBAction func indexChanged(sender: UISegmentedControl) {
        
        //switch labels and values for each segment (day, week, month, year)
        switch segmentControl.selectedSegmentIndex
        {
        case 0:
            total.text = "Today's Total"
            
            // grab total
            todaysCount = historyData.LogRecords.count + historyData.todaysRecords.count
            
            dataLabel.text = "\(todaysCount)"
            
            barGraph.text = "Hourly"
            average.text = "Daily Average"
            lastSmokeTimer.text = "Time Since Last Smoke"
            lastSmokeTimer.font = UIFont(name: lastSmokeTimer.font.fontName, size: 24)
            mostSmokedDay.text = " "
            
        case 1:
            total.text = "This Week"
            barGraph.text = "Daily"
            average.text = "Weekly Average"
            lastSmokeTimer.text = "Average Time Between Cigarettes"
            lastSmokeTimer.font = UIFont(name: lastSmokeTimer.font.fontName, size: 22)
            mostSmokedDay.text = "Most Smoked Day"
        case 2:
            total.text = "This Month"
            barGraph.text = "Weekly"
            average.text = "Monthly Average"
            lastSmokeTimer.text = "Average Time Between Cigarettes"
            mostSmokedDay.text = "Most Smoked Day"
            lastSmokeTimer.font = UIFont(name: lastSmokeTimer.font.fontName, size: 22)
        case 3:
            total.text = "This Year"
            barGraph.text = "Monthly"
            average.text = "Yearly Average"
            lastSmokeTimer.text = "Average Time Between Cigarettes"
            mostSmokedDay.text = "Most Smoked Day"
            lastSmokeTimer.font = UIFont(name: lastSmokeTimer.font.fontName, size: 22)
        default:
            total.text = "Today's Total"
            
            // grab total
            todaysCount = historyData.LogRecords.count
            
            dataLabel.text = "\(todaysCount)"
            
            barGraph.text = "Hourly"
            average.text = "Daily Average"
            lastSmokeTimer.text = "Time Since Last Smoke"
            lastSmokeTimer.font = UIFont(name: lastSmokeTimer.font.fontName, size: 24)
            mostSmokedDay.text = " "
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
