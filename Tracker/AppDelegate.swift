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
    var isInInitialSession = true
    // Widget Sharing Capabilities
    let sharedDefaults = NSUserDefaults(suiteName: "group.TrackerTeamA")
    // var NumberOfDailyRecords : Int = 0
    
    /* Function for any ViewController to grab the instantiated CloudDataObject */
    func getCloudData() ->cloudData{
        return CloudDataObject
    }
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        self.appIsActive = true
        let activeString:String = self.appIsActive ? "Active":"Not Active"
        println("Tracker Launched. App is \(activeString).")
        self.isInInitialSession = true
        CloudDataObject.requestAttempts = 0
        // Grab Records
        CloudDataObject.grab_todays_records()
        CloudDataObject.grabAllRecords()
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        // App is Inactive
        self.appIsActive = false
        let activeString:String = self.appIsActive ? "Active":"Not Active"
        println("Tracker is about to be \(activeString).")
        self.isInInitialSession = false
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        self.appIsActive = false
        println("Tracker was sent to the Background..")
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        self.appIsActive = true
        println("Tracker Returned from the Background.")
        // Grab Records
        CloudDataObject.grab_todays_records()
        CloudDataObject.grabAllRecords()
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        self.appIsActive = true
        let activeString:String = self.appIsActive ? "Active":"Not Active"
        println("Tracker Became \(activeString).")
        CloudDataObject.requestAttempts = 0
        // If there is a date saved from the Widget
        if let date = self.sharedDefaults?.objectForKey("record") as? NSDate {

            println("There is a record from the Widget. Attempting to Save it.")
            if (!self.isInInitialSession)
            {
                println("This is not initial Session. OKAY to Save")
                CloudDataObject.save_record_to_cloud(date, savedForWidget: true)
                // CloudDataObject.grab_todays_records()
                // Clear Out Records From Widget
                sharedDefaults?.setObject(nil, forKey: "record")
                sharedDefaults?.synchronize()
            }
        }
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

