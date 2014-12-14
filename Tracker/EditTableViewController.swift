//
//  EditTableViewController.swift
//  TrackerTeamA
//
//  Created by Will Pierson on 12/11/14.
//  Copyright (c) 2014 Amy Schmidt. All rights reserved.
//

import UIKit

class EditTableViewController: UIViewController, UITableViewDataSource {
    
    @IBOutlet var tableView: UITableView!
    
    
    
    var cloud: cloudData!
    
    var myData: NSMutableArray?

    override func viewDidLoad() {
        
        super.viewDidLoad()
        title = "Edit"
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        cloud = appDelegate.getCloudData()
        
        myData = NSMutableArray(array:reverse(cloud.dailyRecords))
        
       
        
        // Do any additional setup after loading the view.
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myData!.count
    }
    
    /*
    func performSegueWithIdentifier(identifier: "doneSegue", sender: AnyObject?) {
        
        //var todayTab: TodayTabViewController!
        
        //todayTab.viewDidLoad()
    }
*/
    
    
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath:indexPath) as UITableViewCell
        
        
        var timeFormatter: NSDateFormatter = NSDateFormatter()
        timeFormatter.dateFormat = "hh:mm a"
        
        var dateFormatter: NSDateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        
        let anItem = myData![indexPath.row] as dailyRecord
        
        
        var TimeString:String = timeFormatter.stringFromDate(anItem.date_NS)
        var date:String = dateFormatter.stringFromDate(anItem.date_NS)
        
        cell.textLabel?.text = "Cigarette"
        cell.detailTextLabel?.text = "Smoked at \(TimeString) on \(date)"
        
        return cell
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        let anItem = myData![indexPath.row] as dailyRecord
        
        var recordToRemove = anItem.record
        
        cloud.deleteRecord(recordToRemove)
        
        
        let removed = myData!.removeObjectAtIndex(indexPath.row)
        
        
        
        tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
        
        
        
    }
    
  
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        // segue.destinationViewController.
        // let destViewController = segue.destinationViewController as TodayTabViewController
        // destViewController.viewDidLoad()
        // cloud.grab_todays_records()
    }
    
}
