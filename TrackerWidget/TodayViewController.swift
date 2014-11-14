//
//  TodayViewController.swift
//  TrackerWidget
//
//  Created by Ryan Pliske on 11/13/14.
//  Copyright (c) 2014 Amy Schmidt. All rights reserved.
//

import UIKit
import NotificationCenter
import CloudKit

class TodayViewController: UIViewController, NCWidgetProviding {
    
    
    @IBOutlet weak var countLabel: UILabel!
    
    @IBOutlet weak var stepper: UIStepper!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //initializing stepper
        stepper.wraps = true
        stepper.autorepeat = true
        stepper.maximumValue = 40
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void)!) {
        // Perform any setup necessary in order to update the view.

        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData

        completionHandler(NCUpdateResult.NewData)
    }
    
    @IBAction func countStepper(sender: UIStepper) {
        countLabel.text = Int(sender.value).description
        var count = Int(sender.value)
    }
    
    // Function to reset the widget margins
    func widgetMarginInsetsForProposedMarginInsets(defaultMarginInsets: UIEdgeInsets) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
    }
    
}
