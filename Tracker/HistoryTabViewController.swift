//
//  HistoryTabViewController.swift
//  TrackerTeamA

import UIKit
import Foundation

class HistoryTabViewController: UIViewController {

    // segmented control var
    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    // labels in segment control
    @IBOutlet weak var total: UILabel!
    @IBOutlet weak var barGraph: UILabel!
    @IBOutlet weak var average: UILabel!
    @IBOutlet weak var lastSmokeTimer: UILabel!
    @IBOutlet weak var mostSmokedDay: UILabel!
    @IBOutlet weak var MaxLabel: UILabel!
    @IBOutlet weak var dataLabel: UILabel!
    @IBOutlet weak var timeSpentSmokingLabel: UILabel!
    var historyData : cloudData!
    var todaysCount : Int!
    
    
    override func viewWillAppear(animated: Bool) {
        // Grab total records (Cloud records + Incremented Records)
        todaysCount = historyData.dailyRecords.count + historyData.sessionRecords.count
        dataLabel.text = "\(todaysCount)"
        MaxLabel.text = "\(historyData.maxGoal)"
        // Get Day chart as default
        chartHTML = buildDayChartHTML()
        // getChart(chartPeriod)
        drawChart(chartHTML)
        // For user to return to Day view
        segmentControl.selectedSegmentIndex = 0
        timeSpentSmokingLabel.text = "\(todaysCount * 5)"
        // Grab all records (DONT DO THIS: THIS GRABS ALL THE DATA AGAIN EACH TIME)
        // historyData.grabAllRecords()
    }

    // UIWebView for bar chart
    @IBOutlet weak var barChart: UIWebView!
    // String for chart HTML
    var chartHTML: String!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        // Set the delegate of this ViewController class
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        historyData = appDelegate.getCloudData()
        
        webViewConfiguration()
        MaxLabel.text = "\(historyData.maxGoal)"

        barGraph.text = "Hourly"
        average.text = "Daily Average"
        lastSmokeTimer.text = "Time Since Last Smoke"
        mostSmokedDay.text = " "
        
        // Get Day chart as default
        chartHTML = buildDayChartHTML()
        
        // getChart(chartPeriod)
        drawChart(chartHTML)
        
        // Grab all records
        historyData.grabAllRecords()

    }
    
    @IBAction func indexChanged(sender: UISegmentedControl) {
        
        // switch labels and values for each segment (day, week, month, year)
        switch segmentControl.selectedSegmentIndex
        {
        case 0:
            total.text = "Today's Total"
            
            // grab total
            todaysCount = historyData.dailyRecords.count + historyData.sessionRecords.count
            
            dataLabel.text = "\(todaysCount)"
            MaxLabel.text = "\(historyData.maxGoal)"
            
            barGraph.text = "Hourly"
            average.text = "    Daily Average"
            lastSmokeTimer.text = "Time Since Last Smoke"
            
            mostSmokedDay.text = " "
            timeSpentSmokingLabel.text = "\(todaysCount * 5)"
            
            
            chartHTML = buildDayChartHTML()
            drawChart(chartHTML)
            
        case 1:
            total.text = "This Week"
            barGraph.text = "Daily"
            average.text = "Weekly Average"
            lastSmokeTimer.text = "Average Time Between Cigarettes"
            mostSmokedDay.text = " "
            
            var weeklyMax: Int! = historyData.maxGoal * 7
            MaxLabel.text = "\(weeklyMax)"
            timeSpentSmokingLabel.text = "\(todaysCount * 10)"
            chartHTML = buildWeekChartHTML()
            drawChart(chartHTML)
            
        case 2:
            total.text = "This Month"
            barGraph.text = "Weekly"
            average.text = "Monthly Average"
            lastSmokeTimer.text = "Average Time Between Cigarettes"
            mostSmokedDay.text = " "
            
            var monthlyMax: Int! = historyData.maxGoal * 30
            MaxLabel.text = "\(monthlyMax)"
            timeSpentSmokingLabel.text = "\(todaysCount * 20)"
            chartHTML = buildMonthChartHTML()
            drawChart(chartHTML)
            
        case 3:
            total.text = "This Year"
            barGraph.text = "Monthly"
            average.text = "Yearly Average"
            lastSmokeTimer.text = "Average Time Between Cigarettes"
            mostSmokedDay.text = " "
            timeSpentSmokingLabel.text = "\(todaysCount * 30)"
            var yearlyMax: Int! = historyData.maxGoal * 365
            MaxLabel.text = "\(yearlyMax)"
            
            chartHTML = buildYearChartHTML()
            drawChart(chartHTML)
            
        default:

            total.text = "Today's Total"
            
            // grab total
            todaysCount = historyData.dailyRecords.count
            
            dataLabel.text = "\(todaysCount)"
            MaxLabel.text = "\(historyData.maxGoal)"
            timeSpentSmokingLabel.text = "\(todaysCount * 5)"
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
        for entry in historyData.dailyRecords {
            
            // Formatter to get 24-hour time from record
            var formatter: NSDateFormatter = NSDateFormatter()
            formatter.dateFormat = "HH"
            
            // Get hour from record's timestamp (24-hour)
            var TimeString:String = formatter.stringFromDate(historyData.dailyRecords[i].date_NS)
            
            // Convert hour from string to int
            var hour: Int = TimeString.toInt()!
            
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
        for record in historyData.sessionRecords{
            
            // Formatter to get 24-hour time from record
            var formatter: NSDateFormatter = NSDateFormatter()
            formatter.dateFormat = "HH"
            
            // Get hour from record's timestamp (24-hour)
            var TimeString:String = formatter.stringFromDate(historyData.sessionRecords[i].date_NS)
            
            // Convert hour from string to int
            var hour: Int = TimeString.toInt()!

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
        
        // Build HTML string with dataArray info inserted into graph
        var stringHTML: String = "<html><head><script type='text/javascript' src='https://www.google.com/jsapi'></script><script type='text/javascript'>google.load('visualization', '1', {packages:['corechart']});google.setOnLoadCallback(drawChart);function drawChart() { var data = google.visualization.arrayToDataTable([ ['Hour', 'Cigs', { role: 'style' } ], ['12am - 4am', \(dataArray[0]), 'color: white; opacity: 0.75'], ['4am - 8am', \(dataArray[1]), 'color: white; opacity: 0.75'], ['8am - 12pm', \(dataArray[2]), 'color: white; opacity: 0.75'], ['12pm - 4pm', \(dataArray[3]), 'color: white; opacity: 0.75'], ['4pm - 8pm', \(dataArray[4]), 'color: white; opacity: 0.75'], ['8pm - 12am', \(dataArray[5]), 'color: white; opacity: 0.75'] ]); var options = { width: '100%', height: '100%', legend: { position: 'none' }, bar: { groupWidth: '70%' }, backgroundColor: '#333333', backgroundColor: { strokeWidth: 0, fill: '#333333' }, chartArea: { left: 20, top: 10, width:'95%', height:'80%'}, fontSize: 8, Style: { color: 'white' }, hAxis: { textStyle:{color: '#FFF'} } }; var chart = new google.visualization.ColumnChart(document.getElementById('chart_div')); chart.draw(data, options);}</script><style> #chart_div { position: absolute; top: 0px; left: 0px; bottom: 0px; right: 0px; color: white; }</style></head><body> <div id='chart_div'></div></body></html>"
        
        // Return HTML string
        return stringHTML
    }
    
    func buildWeekChartHTML() -> NSString {
        
        // This array stories the count of cigs for each day ([0] = Sunday, [1] = Monday, etc.)
        var dataArray: [Int] = [0, 0, 0, 0, 0, 0, 0]
        var i = 0
        
        // Formatter to get date from record
        var formatter: NSDateFormatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        // Add data stored in cloud
        for record in historyData.allRecords {
            
            // Get date string from record's timestamp
            var DateString: String = formatter.stringFromDate(historyData.allRecords[i].date_NS)
            
            // Convert hour from string to int
            var day: Int!
            
            // Get int of day of record
            day = getDayOfWeek(DateString)
            
            // Increment index based upon day of week
            switch day {
            // Sunday
            case 1:
                dataArray[0]++
            // Monday
            case 2:
                dataArray[1]++
            // Tuesday
            case 3:
                dataArray[2]++
            // Wednesday
            case 4:
                dataArray[3]++
            // Thursday
            case 5:
                dataArray[4]++
            // Friday
            case 6:
                dataArray[5]++
            // Saturday
            case 7:
                dataArray[6]++
            default:
                break
            }
            i++
        }
        
        i = 0
        // Add data from current session
        for record in historyData.sessionRecords {
            
            // Get date string from record's timestamp
            var DateString: String = formatter.stringFromDate(historyData.sessionRecords[i].date_NS)
            
            // Convert hour from string to int
            var day: Int!
            
            // Get int of day of record
            day = getDayOfWeek(DateString)
            
            // Increment index based upon day of week
            switch day {
            // Sunday
            case 1:
                dataArray[0]++
            // Monday
            case 2:
                dataArray[1]++
            // Tuesday
            case 3:
                dataArray[2]++
            // Wednesday
            case 4:
                dataArray[3]++
            // Thursday
            case 5:
                dataArray[4]++
            // Friday
            case 6:
                dataArray[5]++
            // Saturday
            case 7:
                dataArray[6]++
            default:
                break
            }
            i++
        }

        // Build HTML string with dataArray info inserted into graph
        var stringHTML: String = "<html><head><script type='text/javascript' src='https://www.google.com/jsapi'></script><script type='text/javascript'>google.load('visualization', '1', {packages:['corechart']});google.setOnLoadCallback(drawChart);function drawChart() { var data = google.visualization.arrayToDataTable([ ['Day', 'Cigs', { role: 'style' } ], ['SUN', \(dataArray[0]), 'color: white; opacity: 0.75'], ['MON', \(dataArray[1]), 'color: white; opacity: 0.75'], ['TUE', \(dataArray[2]), 'color: white; opacity: 0.75'], ['WED', \(dataArray[3]), 'color: white; opacity: 0.75'], ['THU', \(dataArray[4]), 'color: white; opacity: 0.75'], ['FRI', \(dataArray[5]), 'color: white; opacity: 0.75'], ['SAT', \(dataArray[6]), 'color: white; opacity: 0.75'] ]); var options = { width: '100%', height: '100%', legend: { position: 'none' }, bar: { groupWidth: '70%' }, backgroundColor: '#333333', backgroundColor: { strokeWidth: 0, fill: '#333333' }, chartArea: { left: 20, top: 10, width:'95%', height:'80%'}, fontSize: 10, Style: { color: 'white' }, hAxis: { textStyle:{color: '#FFF'} } }; var chart = new google.visualization.ColumnChart(document.getElementById('chart_div')); chart.draw(data, options);}</script><style>#chart_div { position: absolute; top: 0px; left: 0px; bottom: 0px; right: 0px;}</style></head><body> <div id='chart_div'></div></body></html>"
        
        // Return HTML string
        return stringHTML
    }
    
    func buildMonthChartHTML() -> NSString {
        return "<html><head><script type='text/javascript' src='https://www.google.com/jsapi'></script><script type='text/javascript'>google.load('visualization', '1', {packages:['corechart']});google.setOnLoadCallback(drawChart);function drawChart() { var data = google.visualization.arrayToDataTable([ ['Week', 'Cigs', { role: 'style' } ], ['Week 1', 6, 'color: white; opacity: 0.75'], ['Week 2', 5, 'color: white; opacity: 0.75'], ['Week 3', 6, 'color: white; opacity: 0.75'], ['Week 4', 8, 'color: white; opacity: 0.75'], ['Week 5', 5, 'color: white; opacity: 0.75'] ]); var options = { width: '100%', height: '100%', legend: { position: 'none' }, bar: { groupWidth: '70%' }, backgroundColor: '#333333', backgroundColor: { strokeWidth: 0, fill: '#333333' }, chartArea: { left: 20, top: 10, width:'95%', height:'80%'}, fontSize: 10, Style: { color: 'white' }, hAxis: { textStyle:{color: '#FFF'} } }; var chart = new google.visualization.ColumnChart(document.getElementById('chart_div')); chart.draw(data, options);}</script><style>#chart_div { position: absolute; top: 0px; left: 0px; bottom: 0px; right: 0px;}</style></head><body> <div id='chart_div'></div></body></html>"
    }
    
    func buildYearChartHTML() -> NSString {
        
        // This array stories the count of cigs for each month ([0] = January, [1] = February, etc.)
        var dataArray: [Int] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
        var i = 0
        
        // Formatter to get month from record
        var monthFormatter: NSDateFormatter = NSDateFormatter()
        monthFormatter.dateFormat = "MM"
        // Formatter to get year from records
        var yearFormatter: NSDateFormatter = NSDateFormatter()
        yearFormatter.dateFormat = "yyyy"
        
        // Get the year from today's date
        var today: NSDate = NSDate()
        var CurrentYearString: String = yearFormatter.stringFromDate(today)
        
        // Add data stored in cloud
        for record in historyData.allRecords {
            
            // Get month and year strings from record's timestamp
            var MonthString: String = monthFormatter.stringFromDate(historyData.allRecords[i].date_NS)
            var YearString: String = yearFormatter.stringFromDate(historyData.allRecords[i].date_NS)
            // Convert month string to int
            var month: Int = MonthString.toInt()!
            
            // Check if record occurred in the current year
            if( YearString == CurrentYearString ) {
                
                // Increment index based upon month of the year
                switch month {
                case 1:
                    dataArray[0]++
                case 2:
                    dataArray[1]++
                case 3:
                    dataArray[2]++
                case 4:
                    dataArray[3]++
                case 5:
                    dataArray[4]++
                case 6:
                    dataArray[5]++
                case 7:
                    dataArray[6]++
                case 8:
                    dataArray[7]++
                case 9:
                    dataArray[8]++
                case 10:
                    dataArray[9]++
                case 11:
                    dataArray[10]++
                case 12:
                    dataArray[11]++
                default:
                    break
                }
            }
            i++
        }
        
        i = 0
        // Add data from current session
        for record in historyData.sessionRecords {
            
            // Get month and year strings from record's timestamp
            var MonthString: String = monthFormatter.stringFromDate(historyData.sessionRecords[i].date_NS)
            var YearString: String = yearFormatter.stringFromDate(historyData.sessionRecords[i].date_NS)
            // Convert month string to int
            var month: Int = MonthString.toInt()!
            
            // Check if record occurred in the current year
            if( YearString == CurrentYearString ) {
            
                // Increment index based upon month of the year
                switch month {
                case 1:
                    dataArray[0]++
                case 2:
                    dataArray[1]++
                case 3:
                    dataArray[2]++
                case 4:
                    dataArray[3]++
                case 5:
                    dataArray[4]++
                case 6:
                    dataArray[5]++
                case 7:
                    dataArray[6]++
                case 8:
                    dataArray[7]++
                case 9:
                    dataArray[8]++
                case 10:
                    dataArray[9]++
                case 11:
                    dataArray[10]++
                case 12:
                    dataArray[11]++
                default:
                    break
                }
            }
            i++
        }
        
        // Build HTML string with dataArray info inserted into graph
        var stringHTML: String = "<html><head><script type='text/javascript' src='https://www.google.com/jsapi'></script><script type='text/javascript'>google.load('visualization', '1', {packages:['corechart']});google.setOnLoadCallback(drawChart);function drawChart() { var data = google.visualization.arrayToDataTable([ ['Month', 'Cigs', { role: 'style' } ], ['JAN', \(dataArray[0]), 'color: white; opacity: 0.75'], ['FEB', \(dataArray[1]), 'color: white; opacity: 0.75'], ['MAR', \(dataArray[2]), 'color: white; opacity: 0.75'], ['APR', \(dataArray[3]), 'color: white; opacity: 0.75'], ['MAY', \(dataArray[4]), 'color: white; opacity: 0.75'], ['JUN', \(dataArray[5]), 'color: white; opacity: 0.75'], ['JUL', \(dataArray[6]), 'color: white; opacity: 0.75'], ['AUG', \(dataArray[7]), 'color: white; opacity: 0.75'], ['SEP', \(dataArray[8]), 'color: white; opacity: 0.75'], ['OCT', \(dataArray[9]), 'color: white; opacity: 0.75'], ['NOV', \(dataArray[10]), 'color: white; opacity: 0.75'], ['DEC', \(dataArray[11]), 'color: white; opacity: 0.75'] ]); var options = { width: '100%', height: '100%', legend: { position: 'none' }, bar: { groupWidth: '70%' }, backgroundColor: '#333333', backgroundColor: { strokeWidth: 0, fill: '#333333' }, chartArea: { left: 20, top: 10, width:'95%', height:'80%'}, fontSize: 8, Style: { color: 'white' }, hAxis: { textStyle:{color: '#FFF'} } }; var chart = new google.visualization.ColumnChart(document.getElementById('chart_div')); chart.draw(data, options);}</script><style>#chart_div { position: absolute; top: 0px; left: 0px; bottom: 0px; right: 0px;}</style></head><body> <div id='chart_div'></div></body></html>"
        
        // Return HTML string
        return stringHTML
    }
    
    func getDayOfWeek(today:String)->Int? {

        let formatter: NSDateFormatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        if let todayDate = formatter.dateFromString(today) {
            let myCalendar = NSCalendar(calendarIdentifier: NSGregorianCalendar)!
            let myComponents = myCalendar.components(.WeekdayCalendarUnit, fromDate: todayDate)
            let weekDay = myComponents.weekday
            return weekDay
        } else {
            return nil
        }
    }
}
