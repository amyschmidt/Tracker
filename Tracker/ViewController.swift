//
//  ViewController.swift
//  Tracker
//
//  Created by Amy Schmidt on 10/14/14.
//  Copyright (c) 2014 Amy Schmidt. All rights reserved.
//

import UIKit

class LoadingViewController: UIViewController {

    
    //Create place in memory to render image
    let context = CIContext(options: nil)
    
    @IBOutlet weak var loadingView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    //What is this?
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let segueIdentifier = segue.identifier
        if segueIdentifier == "GoToYellow" {
            let yellowController:YellowViewController = segue.destinationViewController as YellowViewController
            yellowController.quote = textField?.text
        }
    }*/


}

