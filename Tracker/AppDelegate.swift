//
//  AppDelegate.swift
//  TrackerTeamA

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    // Manages and Coordinates the Views of our App
    var window: UIWindow?
    // instantiate a cloudData Object
    var CloudDataObject:cloudData = cloudData()
    // Successfully launched app flag
    var appIsActive = false
    // Widget Sharing Capabilities
    let sharedDefaults = NSUserDefaults(suiteName: "group.TrackerTeamA")
    
    /* Function for any ViewController to grab the instantiated CloudDataObject */
    func getCloudData() ->cloudData{
        return CloudDataObject
    }
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        println("Successfully Launched Tracker.")
        self.appIsActive = true
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        println("Tracker is about to be Inactive.")
        self.appIsActive = false
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        println("Tracker was sent to the Background..")
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        println("Tracker Returned from the Background.")
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        println("Tracker Returned from being Inactive.")
        // Reset the Count (Refresh TodayTabViewController)
        // CloudDataObject.save_record_from_Widget()
        
        var rootViewController = self.window!.rootViewController
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        var setViewController = mainStoryboard.instantiateViewControllerWithIdentifier("TodayTab") as TodayTabViewController
        // rootViewController.navigationController?.popToViewController(setViewController, animated: false)
        if let date = self.sharedDefaults?.objectForKey("record") as? NSDate {
            setViewController.receivedRecordFromWidget = true
            // setViewController.count = 90
            // setViewController.viewDidLoad()
            // var count = 90
            // setViewController.dailyCountLabel.text = "\(count)"
            CloudDataObject.save_record_to_cloud(date)
            CloudDataObject.grab_todays_records()
        }
        setViewController.updateCountFromWidget()
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

