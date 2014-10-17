//
//  ViewController.swift
//  Tracker
//
//  Created by Amy Schmidt on 10/14/14.
//  Copyright (c) 2014 Amy Schmidt. All rights reserved.
//

import UIKit

class LoadingViewController: UIViewController {
    
    @IBOutlet var valueLabel: UILabel!
    @IBOutlet var stepper: UIStepper!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        stepper.wraps = true
        stepper.autorepeat = true
        stepper.maximumValue = 30
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    @IBAction func stepperValueChanged(sender: UIStepper) {
        valueLabel.text = Int(sender.value).description
    }
}

