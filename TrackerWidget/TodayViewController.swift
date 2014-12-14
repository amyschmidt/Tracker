import UIKit
import NotificationCenter
import Foundation

class TodayViewController: UIViewController, NCWidgetProviding {
    
    @IBOutlet weak var gaugeView: UIWebView!
    @IBOutlet weak var countLabel: UILabel!
    var count: Int = 0
    var airplaneModeDates = [NSDate]()
    var stringHTML : String!
    
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
        self.drawGauge()
        completionHandler(NCUpdateResult.NewData)
    }
    
    
    @IBAction func openTracker(sender: AnyObject) {
        var url: NSURL = NSURL(fileURLWithPath: "TrackerTeamA://")!
        // self.extensionContext?.openURL(url, completionHandler: nil)
        var url2: NSExtensionContext = self.extensionContext!
        // NSExtensionContext.openURL(url2)
        url2.openURL(url, completionHandler: nil)
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
        // Post to Notification Center to let TodayTabViewController Know that the user pressed incrementer
        NSNotificationCenter.defaultCenter().postNotificationName("saveRecordFromWidget", object: nil)
        /*
        self.airplaneModeDates.append(NSDate())
        NSUserDefaults.standardUserDefaults().setObject(self.airplaneModeDates, forKey: "records")
        println("Saving Record [\(NSDate())]to Phone")
        */
        let sharedDefaults = NSUserDefaults(suiteName: "group.TrackerTeamA")
        sharedDefaults?.setObject(NSDate(), forKey: "record")
        sharedDefaults?.synchronize()
    }
    
    func drawGauge()
    {
        self.stringHTML = "<html> <head> <script type='text/javascript' src='https://www.google.com/jsapi'></script> <script type='text/javascript'> google.load('visualization', '1', {packages:['gauge']}); google.setOnLoadCallback(drawChart); function drawChart() { var data = google.visualization.arrayToDataTable([ ['Label', 'Value'], ['Cigs', 5], ]); var options = { backgroundColor: 'transparent',  width: 60, height: 60, greenFrom: 0, greenTo: 10, yellowFrom: 10, yellowTo: 20, redFrom: 20, redTo: 40, max: 40 }; var chart = new google.visualization.Gauge(document.getElementById('chart_div')); chart.draw(data, options);}</script> </head> <body><center><div id='chart_div' style='width: 60px; height: 60px;'></div></center></body></html>"
        gaugeView.loadHTMLString(stringHTML, baseURL: nil)
        gaugeView.scrollView.scrollEnabled = false
        gaugeView.scrollView.bounces = false
        gaugeView.opaque = false
    }
    
    // Function to reset the widget margins
    func widgetMarginInsetsForProposedMarginInsets(defaultMarginInsets: UIEdgeInsets) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
    }
    
    
}
