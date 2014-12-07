import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding {
    
    @IBOutlet weak var countLabel: UILabel!
    var count: Int = 0
    var airplaneModeDates = [NSDate]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        let sharedDefaults = NSUserDefaults(suiteName: "group.TrackerTeamA")
        self.count = sharedDefaults?.objectForKey("count") as Int
        self.countLabel.text = "Count: \(self.count)"
        completionHandler(NCUpdateResult.NewData)
    }
    
    
    @IBAction func openTracker(sender: AnyObject) {
        var url: NSURL = NSURL(fileURLWithPath: "hostingapp://home")!
        self.extensionContext?.openURL(url, completionHandler: nil)
    }
    
    @IBAction func buttonClicked(sender: AnyObject) {
        self.countLabel.text = "Record Saved"
        countLabel.alpha = 0
        self.count = self.count + 1
        // Fade In
        UIView.animateWithDuration(0.5, delay: 0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
            self.countLabel.alpha = 1.0
        }, completion:nil)
        // Fade Out
        UIView.animateWithDuration(1.0, delay: 2, options: UIViewAnimationOptions.CurveEaseOut, animations: {
            self.countLabel.alpha = 0.0
            }, completion: {
                
                (finished: Bool)->Void in
                self.countLabel.alpha = 1.0
                self.countLabel.text = "Count: \(self.count)"
        })
        /*
        self.airplaneModeDates.append(NSDate())
        NSUserDefaults.standardUserDefaults().setObject(self.airplaneModeDates, forKey: "records")
        println("Saving Record [\(NSDate())]to Phone")
        */
        let sharedDefaults = NSUserDefaults(suiteName: "group.TrackerTeamA")
        sharedDefaults?.setObject(NSDate(), forKey: "record")
        sharedDefaults?.synchronize()
    }
    
    // Function to reset the widget margins
    func widgetMarginInsetsForProposedMarginInsets(defaultMarginInsets: UIEdgeInsets) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
    }
    
    
}
