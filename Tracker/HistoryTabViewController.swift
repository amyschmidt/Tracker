//
//  HistoryTabViewController.swift
//  TrackerTeamA
//
//  Created by Amy Schmidt on 11/23/14.
//  Copyright (c) 2014 Amy Schmidt. All rights reserved.
//

import UIKit

class HistoryTabViewController: UIViewController {

    // segmented control var
    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    // labels in segment control
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
        
        // Get Day chart as default
        chartHTML = buildDayChartHTML()
        // getChart(chartPeriod)
        drawChart(chartHTML)
        // For user to return to Day view
        segmentControl.selectedSegmentIndex = 0
        
        // Grab all records
        historyData.grabAllRecords()
    }

    // UIWebView for bar chart
    @IBOutlet weak var barChart: UIWebView!
    // Time period to display in bar chart (day view by default)
    // var chartPeriod: String! = "dayChart"
    
    // String for chart HTML (if we don't use external HTML files)
    // The string is just the compressed code from the HTML files
    var chartHTML: String!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        // Set the delegate of this ViewController class
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        historyData = appDelegate.getCloudData()
        
        webViewConfiguration()
        
        // Get Day chart as default
        chartHTML = buildDayChartHTML()
        
        // getChart(chartPeriod)
        drawChart(chartHTML)

    }
    
    @IBAction func indexChanged(sender: UISegmentedControl) {
        
        // switch labels and values for each segment (day, week, month, year)
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
            mostSmokedDay.text = " "
            // chartPeriod = "dayChart"
            // getChart(chartPeriod)
            
            chartHTML = buildDayChartHTML()
            drawChart(chartHTML)
            
        case 1:
            total.text = "This Week"
            barGraph.text = "Daily"
            average.text = "Weekly Average"
            lastSmokeTimer.text = "Average Time Between Cigarettes"
            mostSmokedDay.text = "Most Smoked Day"
            // chartPeriod = "weekChart"
            // getChart(chartPeriod)
            
            chartHTML = buildWeekChartHTML()
            drawChart(chartHTML)
            
        case 2:
            total.text = "This Month"
            barGraph.text = "Weekly"
            average.text = "Monthly Average"
            lastSmokeTimer.text = "Average Time Between Cigarettes"
            mostSmokedDay.text = "Most Smoked Day"
            // chartPeriod = "monthChart"
            // getChart(chartPeriod)
            
            chartHTML = buildMonthChartHTML()
            drawChart(chartHTML)
            
        case 3:
            total.text = "This Year"
            barGraph.text = "Monthly"
            average.text = "Yearly Average"
            lastSmokeTimer.text = "Average Time Between Cigarettes"
            mostSmokedDay.text = "Most Smoked Day"
            // chartPeriod = "yearChart"
            // getChart(chartPeriod)
            
            chartHTML = buildYearChartHTML()
            drawChart(chartHTML)
            
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

            break

        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Draw the chart from external HTML file
    /*
    func getChart(period:String) {
        let myURL = NSBundle.mainBundle().URLForResource(period, withExtension: "html")
        let requestObj = NSURLRequest(URL: myURL!)
        barChart.loadRequest(requestObj)
    }
    */

    // Draw chart from string
    func drawChart(chartHTML: String) {
        barChart.loadHTMLString(chartHTML, baseURL: nil)
    }
    
    func webViewConfiguration() {
        barChart.scrollView.scrollEnabled = false
        barChart.scrollView.bounces = false
        barChart.opaque = false
    }
    
    func buildDayChartHTML() -> NSString {
        
        // This array stories the count of cigs for each time interval ([0] = 12am - 4am, [1] = 4am - 8am, etc.)
        var dataArray: [Int] = [0, 0, 0, 0, 0, 0]
        var i = 0
        
        // Add data stored in cloud
        for entry in historyData.LogRecords {
            
            // Formatter to get 24-hour time from record
            var formatter: NSDateFormatter = NSDateFormatter()
            formatter.dateFormat = "HH"
            
            // Get hour from record's timestamp (24-hour)
            var TimeString:String = formatter.stringFromDate(historyData.LogRecords[i].date_NS)
            
            // Unused:
            // formatter.timeStyle = .ShortStyle
            // println("Date of Smoke: \(entry.dateString)")
            // println("\(model.LogRecords[0].date_NS)")
            
            // Debugging purposes:
            // println("Time of Smoke: \(TimeString)")
            // println(entry.date_NS)
            
            // Convert hour from string to int
            var hour: Int = TimeString.toInt()!
            println("Adding record with hour: \(hour)")
            // Increment index based upon hour
            switch hour {
            case 0..<4:
                dataArray[0]++
            case 4..<8:
                dataArray[1]++
            case 8..<12:
                dataArray[2]++
            case 12..<16:
                dataArray[3]++
            case 16..<20:
                dataArray[4]++
            case 20..<24:
                dataArray[5]++
            default:
                break
            }
            i++
        }
        
        i = 0
        // Add data from current session
        for record in historyData.todaysRecords{
            
            // Formatter to get 24-hour time from record
            var formatter: NSDateFormatter = NSDateFormatter()
            formatter.dateFormat = "HH"
            
            // Get hour from record's timestamp (24-hour)
            var TimeString:String = formatter.stringFromDate(historyData.todaysRecords[i].date_NS)
            
            // Convert hour from string to int
            var hour: Int = TimeString.toInt()!
            println("Adding record with hour: \(hour)")
            // Increment index based upon hour
            switch hour {
            case 0..<4:
                dataArray[0]++
            case 4..<8:
                dataArray[1]++
            case 8..<12:
                dataArray[2]++
            case 12..<16:
                dataArray[3]++
            case 16..<20:
                dataArray[4]++
            case 20..<24:
                dataArray[5]++
            default:
                break
            }
            i++
            // println("Incremented Record: \(record.date_NS)")
        }
        
        // Build HTML string with dataArray info inserted into graph
        var stringHTML: String = "<html><head><script type='text/javascript' src='https://www.google.com/jsapi'></script><script type='text/javascript'>google.load('visualization', '1', {packages:['corechart']});google.setOnLoadCallback(drawChart);function drawChart() { var data = google.visualization.arrayToDataTable([ ['Hour', 'Cigs', { role: 'style' } ], ['12am - 4am', \(dataArray[0]), 'color: white; opacity: 0.75'], ['4am - 8am', \(dataArray[1]), 'color: white; opacity: 0.75'], ['8am - 12pm', \(dataArray[2]), 'color: white; opacity: 0.75'], ['12pm - 4pm', \(dataArray[3]), 'color: white; opacity: 0.75'], ['4pm - 8pm', \(dataArray[4]), 'color: white; opacity: 0.75'], ['8pm - 12am', \(dataArray[5]), 'color: white; opacity: 0.75'] ]); var options = { width: '100%', height: '100%', legend: { position: 'none' }, bar: { groupWidth: '70%' }, backgroundColor: '#333333', backgroundColor: { strokeWidth: 0, fill: '#333333' }, chartArea: { left: 20, top: 10, width:'95%', height:'80%'}, fontSize: 8, Style: { color: 'white' }, hAxis: { textStyle:{color: '#FFF'} } }; var chart = new google.visualization.ColumnChart(document.getElementById('chart_div')); chart.draw(data, options);}</script><style> #chart_div { position: absolute; top: 0px; left: 0px; bottom: 0px; right: 0px; color: white; }</style></head><body> <div id='chart_div'></div></body></html>"
        
        // Return HTML string
        return stringHTML
    }
    
    func buildWeekChartHTML() -> NSString {
        return "<html><head><script type='text/javascript' src='https://www.google.com/jsapi'></script><script type='text/javascript'>google.load('visualization', '1', {packages:['corechart']});google.setOnLoadCallback(drawChart);function drawChart() { var data = google.visualization.arrayToDataTable([ ['Day', 'Cigs'], ['SUN', 10], ['MON', 12], ['TUE', 8], ['WED', 9], ['THU', 7], ['FRI', 10], ['SAT', 15] ]); var options = { width: '100%', height: '100%', legend: { position: 'none' }, bar: { groupWidth: '70%' }, backgroundColor: '#333333', backgroundColor: { strokeWidth: 0, fill: '#333333' }, chartArea: { left: 20, top: 10, width:'95%', height:'80%'}, fontSize: 10, Style: { color: 'white' }, hAxis: { textStyle:{color: '#FFF'} } }; var chart = new google.visualization.ColumnChart(document.getElementById('chart_div')); chart.draw(data, options);}</script><style>#chart_div { position: absolute; top: 0px; left: 0px; bottom: 0px; right: 0px;}</style></head><body> <div id='chart_div'></div></body></html>"
    }
    
    func buildMonthChartHTML() -> NSString {
        return "<html><head><script type='text/javascript' src='https://www.google.com/jsapi'></script><script type='text/javascript'>google.load('visualization', '1', {packages:['corechart']});google.setOnLoadCallback(drawChart);function drawChart() { var data = google.visualization.arrayToDataTable([ ['Week', 'Cigs'], ['Week 1', 6], ['Week 2', 5], ['Week 3', 6], ['Week 4', 8], ['Week 5', 5] ]); var options = { width: '100%', height: '100%', legend: { position: 'none' }, bar: { groupWidth: '70%' }, backgroundColor: '#333333', backgroundColor: { strokeWidth: 0, fill: '#333333' }, chartArea: { left: 20, top: 10, width:'95%', height:'80%'}, fontSize: 10, Style: { color: 'white' }, hAxis: { textStyle:{color: '#FFF'} } }; var chart = new google.visualization.ColumnChart(document.getElementById('chart_div')); chart.draw(data, options);}</script><style>#chart_div { position: absolute; top: 0px; left: 0px; bottom: 0px; right: 0px;}</style></head><body> <div id='chart_div'></div></body></html>"
    }
    
    func buildYearChartHTML() -> NSString {
        return "<html><head><script type='text/javascript' src='https://www.google.com/jsapi'></script><script type='text/javascript'>google.load('visualization', '1', {packages:['corechart']});google.setOnLoadCallback(drawChart);function drawChart() { var data = google.visualization.arrayToDataTable([ ['Month', 'Cigs'], ['JAN', 55], ['FEB', 60], ['MAR', 40], ['APR', 45], ['MAY', 66], ['JUN', 68], ['JUL', 48], ['AUG', 44], ['SEP', 38], ['OCT', 27], ['NOV', 30], ['DEC', 22] ]); var options = { width: '100%', height: '100%', legend: { position: 'none' }, bar: { groupWidth: '70%' }, backgroundColor: '#333333', backgroundColor: { strokeWidth: 0, fill: '#333333' }, chartArea: { left: 20, top: 10, width:'95%', height:'80%'}, fontSize: 8, Style: { color: 'white' }, hAxis: { textStyle:{color: '#FFF'} } }; var chart = new google.visualization.ColumnChart(document.getElementById('chart_div')); chart.draw(data, options);}</script><style>#chart_div { position: absolute; top: 0px; left: 0px; bottom: 0px; right: 0px;}</style></head><body> <div id='chart_div'></div></body></html>"
    }
}
