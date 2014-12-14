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
    @IBOutlet weak var cigarettesPerLabel: UILabel!
    
    // Cloud data
    var historyData : cloudData!

    // Count for today
    var todaysCount : Int!
    
    // UIWebView for bar chart
    @IBOutlet weak var barChart: UIWebView!
    
    // Strings for chart HTML
    var dayChartHTML: String!
    var weekChartHTML: String!
    var monthChartHTML: String!
    var yearChartHTML: String!
    
    //labels for average
    @IBOutlet weak var averageData: UILabel!
    
    //var for averages
    var hourlyAverage : float_t = 0
    
    override func viewWillAppear(animated: Bool) {
        // Grab total records (Cloud records + Incremented Records)
        historyData.grab_todays_records()
        
        // Update today's total count and max goal
        todaysCount = historyData.dailyRecords.count + historyData.sessionRecords.count

        // Create the HTML string for each chart
        dayChartHTML = buildDayChartHTML()
        weekChartHTML = buildWeekChartHTML()
        monthChartHTML = buildMonthChartHTML()
        yearChartHTML = buildYearChartHTML()
        
        // Build the chart according to selected time period
        buildChart(segmentControl.selectedSegmentIndex)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set the delegate of this ViewController class
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        historyData = appDelegate.getCloudData()
        
        // Configuration for the UIWebView
        webViewConfiguration()
    }
    
    @IBAction func indexChanged(sender: UISegmentedControl) {
        // Add the selected time period's chart to the UIWebView
        buildChart(segmentControl.selectedSegmentIndex)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // Draw chart from string
    func drawChart(chartHTML: String) {
        // Load HTML string into UIWebView to show chart
        barChart.loadHTMLString(chartHTML, baseURL: nil)
    }
    
    func webViewConfiguration() {
        // UIWebView configuration
        barChart.scrollView.scrollEnabled = false
        barChart.scrollView.bounces = false
        barChart.opaque = false
    }
   
    func buildChart(selectedIndex:Int?) {
        
        // Switch case to determine what to do based
        switch selectedIndex! {
            
        // Day information
        case 0:
            total.text = "Today's Total"
            barGraph.text = "Hourly"
            average.text = "Hourly Average"
            
            hourlyAverage = getHourlyAverage()
            averageData.text = String(format: "%.2f", hourlyAverage)
            cigarettesPerLabel.text = "cigarettes per hour"
            lastSmokeTimer.text = "Time Since Last Smoke"
            mostSmokedDay.text = " "
            
            dataLabel.text = "\(todaysCount)"
            MaxLabel.text = "\(historyData.maxGoal)"
            //days count * 5
            timeSpentSmokingLabel.text = "\(todaysCount * 5)"
            
            drawChart(dayChartHTML)
            
        // Week information
        case 1:
            total.text = "This Week"
            barGraph.text = "Daily"
            average.text = "Daily Average"
            lastSmokeTimer.text = "Average Time Between Cigarettes"
            mostSmokedDay.text = " "
            cigarettesPerLabel.text = "cigarettes per day"
            var weeklyMax: Int! = historyData.maxGoal * 7
            MaxLabel.text = "\(weeklyMax)"
            dataLabel.text = "\(todaysCount)"
            //weeks count * 5
            timeSpentSmokingLabel.text = "\(todaysCount * 10)"
            
            drawChart(weekChartHTML)
            
        // Month information
        case 2:
            total.text = "This Month"
            barGraph.text = "Weekly"
            average.text = "Weekly Average"
            lastSmokeTimer.text = "Average Time Between Cigarettes"
            cigarettesPerLabel.text = "cigarettes per week"
            mostSmokedDay.text = " "
            
            dataLabel.text = "\(todaysCount)"
            var monthlyMax: Int! = historyData.maxGoal * 30
            MaxLabel.text = "\(monthlyMax)"
            
            //months count * 5
            timeSpentSmokingLabel.text = "\(todaysCount * 20)"
            
            drawChart(monthChartHTML)
            
        // Year information
        case 3:
            total.text = "This Year"
            barGraph.text = "Monthly"
            average.text = "Monthly Average"
            lastSmokeTimer.text = "Average Time Between Cigarettes"
            cigarettesPerLabel.text = "cigarettes per month"
            mostSmokedDay.text = " "
            
            dataLabel.text = "\(todaysCount)"
            
            //years count * 5
            timeSpentSmokingLabel.text = "\(todaysCount * 30)"
            var yearlyMax: Int! = historyData.maxGoal * 365
            MaxLabel.text = "\(yearlyMax)"
            
            drawChart(yearChartHTML)
            
        // Default to Day information
        default:
            total.text = "Today's Total"
            barGraph.text = "Hourly"
            average.text = "Hourly Average"
            cigarettesPerLabel.text = "cigarettes per hour"
            lastSmokeTimer.text = "Time Since Last Smoke"
            mostSmokedDay.text = " "
            
            dataLabel.text = "\(todaysCount)"
            MaxLabel.text = "\(historyData.maxGoal)"
            timeSpentSmokingLabel.text = "\(todaysCount * 5)"
            
            drawChart(dayChartHTML)
            
            break
        }
    }
    
    func getHourlyAverage() -> float_t {
    
        var today = float_t(todaysCount)
        
        return (today / 24)
    
    }
    
    func buildDayChartHTML() -> NSString {
        
        // This array stories the count of cigs for each time interval ([0] = 12am - 4am, [1] = 4am - 8am, etc.)
        var dataArray: [Int] = [0, 0, 0, 0, 0, 0]
        var arr: [Int] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
        
        // Formatter to get 24-hour time from record
        var hourFormatter: NSDateFormatter = NSDateFormatter()
        hourFormatter.dateFormat = "HH"
        
        // Formatter to get year from records
        var formatter: NSDateFormatter = NSDateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        
        // Get the year from today's date
        var today: NSDate = NSDate()
        var date: String = formatter.stringFromDate(today)
        
        var count: Int = 0
        
        // Add data stored in cloud
        for record in historyData.allRecords {
            
            // Get hour/year from record's timestamp (24-hour)
            var HourString: String = hourFormatter.stringFromDate(record.date_NS)
            var DateString: String = formatter.stringFromDate(record.date_NS)
            
            // Convert hour from string to int
            var hour: Int = HourString.toInt()!

            // Check if today
            if(DateString == date) {
                count++
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
                println("There were \(count) All Records.")
            }
        }
        
        // Add data from current session
        for record in historyData.sessionRecords {
            
            // Get hour/year from record's timestamp (24-hour)
            var HourString: String = hourFormatter.stringFromDate(record.date_NS)
            var DateString: String = formatter.stringFromDate(record.date_NS)
            
            // Convert hour from string to int
            var hour: Int = HourString.toInt()!
            
            // Check if today
            if(DateString == date) {
                count++
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
            }
        }
        println("There were \(count) Session Records.")
        
        // Build HTML string with dataArray info inserted into graph
        var stringHTML: String = "<html><head><script type='text/javascript' src='https://www.google.com/jsapi'></script><script type='text/javascript'>google.load('visualization', '1', {packages:['corechart']});google.setOnLoadCallback(drawChart);function drawChart() { var data = google.visualization.arrayToDataTable([ ['Hour', 'Cigs', { role: 'style' } ], ['12am - 4am', \(dataArray[0]), 'color: white; opacity: 0.75'], ['4am - 8am', \(dataArray[1]), 'color: white; opacity: 0.75'], ['8am - 12pm', \(dataArray[2]), 'color: white; opacity: 0.75'], ['12pm - 4pm', \(dataArray[3]), 'color: white; opacity: 0.75'], ['4pm - 8pm', \(dataArray[4]), 'color: white; opacity: 0.75'], ['8pm - 12am', \(dataArray[5]), 'color: white; opacity: 0.75'] ]); var options = { width: '100%', height: '100%', legend: { position: 'none' }, bar: { groupWidth: '70%' }, backgroundColor: '#333333', backgroundColor: { strokeWidth: 0, fill: '#333333' }, chartArea: { left: 20, top: 10, width:'95%', height:'85%'}, fontSize: 8, Style: { color: 'white' }, hAxis: { textStyle:{color: '#FFF'} }, vAxis: { textStyle:{color: '#FFF'} } }; var chart = new google.visualization.ColumnChart(document.getElementById('chart_div')); chart.draw(data, options);}</script><style> #chart_div { position: absolute; top: 0px; left: 0px; bottom: 0px; right: 0px; color: white; }</style></head><body> <div id='chart_div'></div></body></html>"
        
        // Return HTML string
        return stringHTML
    }
    
    func buildWeekChartHTML() -> NSString {
        
        // This array stories the count of cigs for each day ([0] = Sunday, [1] = Monday, etc.)
        var dataArray: [Int] = [0, 0, 0, 0, 0, 0, 0]
        
        // Formatter to get date from record
        var formatter: NSDateFormatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        // Formatter to get year from records/current year from today's date
        var yearFormatter: NSDateFormatter = NSDateFormatter()
        yearFormatter.dateFormat = "yyyy"
        var today: NSDate = NSDate()
        var CurrentYearString: String = yearFormatter.stringFromDate(today)
        var todayDate: String = formatter.stringFromDate(today)
        var todayDayNum: Int! = getDayOfWeek(todayDate)
        
        var max = historyData.maxGoal
        
        // Add data stored in cloud
        for record in historyData.allRecords {

            // Get date/year string from record's timestamp
            var DateString: String = formatter.stringFromDate(record.date_NS)
            var YearString: String = yearFormatter.stringFromDate(record.date_NS)
            
            // Convert hour from string to int
            var day: Int! = getDayOfWeek(DateString)
            
            for (var i = 0; i < todayDayNum; i++) {
                let calendar = NSCalendar.currentCalendar()
                let components = NSDateComponents()
                components.day = -i
                
                let dateToInclude = calendar.dateByAddingComponents(components, toDate: today, options: nil)
                var dateToGraph: String = formatter.stringFromDate(dateToInclude!)
                
                if( YearString == CurrentYearString && dateToGraph == DateString ) {

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
                }
            }
            
        }
        
        // Add data from current session
        for record in historyData.sessionRecords {
            
            // Get date string from record's timestamp
            var DateString: String = formatter.stringFromDate(record.date_NS)
            
            // Convert hour from string to int
            var day: Int! = getDayOfWeek(DateString)
            
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
        }

        // Build HTML string with dataArray info inserted into graph
        var stringHTML: String = "<html><head><script type='text/javascript' src='https://www.google.com/jsapi'></script><script type='text/javascript'>google.load('visualization', '1', {packages:['corechart']});google.setOnLoadCallback(drawChart);function drawChart() { var data = google.visualization.arrayToDataTable([ ['Day', 'Cigs', { role: 'style' }, 'Maximum' ], ['SUN', \(dataArray[0]), 'color: white; opacity: 0.75', \(max)], ['MON', \(dataArray[1]), 'color: white; opacity: 0.75', \(max)], ['TUE', \(dataArray[2]), 'color: white; opacity: 0.75', \(max)], ['WED', \(dataArray[3]), 'color: white; opacity: 0.75', \(max)], ['THU', \(dataArray[4]), 'color: white; opacity: 0.75', \(max)], ['FRI', \(dataArray[5]), 'color: white; opacity: 0.75', \(max)], ['SAT', \(dataArray[6]), 'color: white; opacity: 0.75', \(max)] ]); var options = { seriesType: 'bars', series: {1: {type: 'line'}}, width: '100%', height: '100%', legend: { position: 'none' }, bar: { groupWidth: '70%' }, backgroundColor: '#333333', backgroundColor: { strokeWidth: 0, fill: '#333333' }, chartArea: { left: 20, top: 10, width:'95%', height:'85%'}, fontSize: 8, Style: { color: 'white' }, hAxis: { textStyle:{color: '#FFF'} }, vAxis: { textStyle:{color: '#FFF'} } }; var chart = new google.visualization.ComboChart(document.getElementById('chart_div')); chart.draw(data, options);}</script><style>#chart_div { position: absolute; top: 0px; left: 0px; bottom: 0px; right: 0px;}</style></head><body> <div id='chart_div'></div></body></html>"
        
        // Return HTML string
        return stringHTML
    }
    
    func buildMonthChartHTML() -> NSString {
        // This array stories the count of cigs for each month ([0] = Week 1 (1st-7th), [1] = Week 2 (8th-15th), etc.)
        var dataArray: [Int] = [0, 0, 0, 0, 0]
        
        // Formatter to get day from record
        var dayFormatter: NSDateFormatter = NSDateFormatter()
        dayFormatter.dateFormat = "dd"
        // Formatter to get month from records
        var monthFormatter: NSDateFormatter = NSDateFormatter()
        monthFormatter.dateFormat = "MM"
        // Formatter to get year from records
        var yearFormatter: NSDateFormatter = NSDateFormatter()
        yearFormatter.dateFormat = "yyyy"
        
        // Get the year from today's date
        var today: NSDate = NSDate()
        var CurrentYearString: String = yearFormatter.stringFromDate(today)
        var CurrentMonthString: String = monthFormatter.stringFromDate(today)
        
        // Get string for last day of the current month
        var lastDayOfMonth: String = getLastDayOfMonth()
        
        // Get goal number
        var max: Int = historyData.maxGoal * 7
        
        // Add data stored in cloud
        for record in historyData.allRecords {
            
            // Get month and year strings from record's timestamp
            var DayString: String = dayFormatter.stringFromDate(record.date_NS)
            var MonthString: String = monthFormatter.stringFromDate(record.date_NS)
            var YearString: String = yearFormatter.stringFromDate(record.date_NS)
            // Convert month string to int
            var day: Int = DayString.toInt()!
            
            // Check if record occurred in the current year
            if( YearString == CurrentYearString && MonthString == CurrentMonthString ) {
                
                // Increment index based upon day of the month
                switch day {
                case 1...7:
                    dataArray[0]++
                case 8...14:
                    dataArray[1]++
                case 15...21:
                    dataArray[2]++
                case 22...28:
                    dataArray[3]++
                default:
                    dataArray[4]++
                    break
                }
            }
        }
        
        // Add data from current session
        for record in historyData.sessionRecords {
            
            // Get month and year strings from record's timestamp
            var DayString: String = dayFormatter.stringFromDate(record.date_NS)
            var MonthString: String = monthFormatter.stringFromDate(record.date_NS)
            var YearString: String = yearFormatter.stringFromDate(record.date_NS)
            // Convert month string to int
            var day: Int = DayString.toInt()!
            
            // Check if record occurred in the current year
            if( YearString == CurrentYearString && MonthString == CurrentMonthString ) {
                
                // Increment index based upon day of the month
                switch day {
                case 1...7:
                    dataArray[0]++
                case 8...14:
                    dataArray[1]++
                case 15...21:
                    dataArray[2]++
                case 22...28:
                    dataArray[3]++
                default:
                    dataArray[4]++
                    break
                }
            }
        }
        
        // Build HTML string with dataArray info inserted into graph
        var stringHTML: String = "<html><head><script type='text/javascript' src='https://www.google.com/jsapi'></script><script type='text/javascript'>google.load('visualization', '1', {packages:['corechart']});google.setOnLoadCallback(drawChart);function drawChart() { var data = google.visualization.arrayToDataTable([ ['Week', 'Cigs', { role: 'style' }, 'Maximum' ], ['1st - 7th', \(dataArray[0]), 'color: white; opacity: 0.75', \(max)], ['8th - 14th', \(dataArray[1]), 'color: white; opacity: 0.75', \(max)], ['15th - 21st', \(dataArray[2]), 'color: white; opacity: 0.75', \(max)], ['22nd - 28th', \(dataArray[3]), 'color: white; opacity: 0.75', \(max)], ['29th - \(lastDayOfMonth)', \(dataArray[4]), 'color: white; opacity: 0.75', \(max)] ]); var options = { seriesType: 'bars', series: {1: {type: 'line'}}, width: '100%', height: '100%', legend: { position: 'none' }, bar: { groupWidth: '70%' }, backgroundColor: '#333333', backgroundColor: { strokeWidth: 0, fill: '#333333' }, chartArea: { left: 20, top: 10, width:'95%', height:'85%'}, fontSize: 8, Style: { color: 'white' }, hAxis: { textStyle:{color: '#FFF'} }, vAxis: { textStyle:{color: '#FFF'} } }; var chart = new google.visualization.ComboChart(document.getElementById('chart_div')); chart.draw(data, options);}</script><style>#chart_div { position: absolute; top: 0px; left: 0px; bottom: 0px; right: 0px;}</style></head><body> <div id='chart_div'></div></body></html>"
        
        // Return HTML string
        return stringHTML
    }
    
    func buildYearChartHTML() -> NSString {
        
        // This array stories the count of cigs for each month ([0] = January, [1] = February, etc.)
        var dataArray: [Int] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
        
        // Formatter to get month from record
        var monthFormatter: NSDateFormatter = NSDateFormatter()
        monthFormatter.dateFormat = "MM"
        // Formatter to get year from records
        var yearFormatter: NSDateFormatter = NSDateFormatter()
        yearFormatter.dateFormat = "yyyy"
        
        // Get the year from today's date
        var today: NSDate = NSDate()
        var CurrentYearString: String = yearFormatter.stringFromDate(today)
        
        var max = historyData.maxGoal * 30
        
        // Add data stored in cloud
        for record in historyData.allRecords {
            
            // Get month and year strings from record's timestamp
            var MonthString: String = monthFormatter.stringFromDate(record.date_NS)
            var YearString: String = yearFormatter.stringFromDate(record.date_NS)
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
        }
        
        // Add data from current session
        for record in historyData.sessionRecords {
            
            // Get month and year strings from record's timestamp
            var MonthString: String = monthFormatter.stringFromDate(record.date_NS)
            var YearString: String = yearFormatter.stringFromDate(record.date_NS)
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
        }
        
        // Build HTML string with dataArray info inserted into graph
        var stringHTML: String = "<html><head><script type='text/javascript' src='https://www.google.com/jsapi'></script><script type='text/javascript'>google.load('visualization', '1', {packages:['corechart']});google.setOnLoadCallback(drawChart);function drawChart() { var data = google.visualization.arrayToDataTable([ ['Month', 'Cigs', { role: 'style' }, 'Maximum' ], ['JAN', \(dataArray[0]), 'color: white; opacity: 0.75', \(max)], ['FEB', \(dataArray[1]), 'color: white; opacity: 0.75', \(max)], ['MAR', \(dataArray[2]), 'color: white; opacity: 0.75', \(max)], ['APR', \(dataArray[3]), 'color: white; opacity: 0.75', \(max)], ['MAY', \(dataArray[4]), 'color: white; opacity: 0.75', \(max)],"
        stringHTML += "['JUN', \(dataArray[5]), 'color: white; opacity: 0.75', \(max)], ['JUL', \(dataArray[6]), 'color: white; opacity: 0.75', \(max)], ['AUG', \(dataArray[7]), 'color: white; opacity: 0.75', \(max)], ['SEP', \(dataArray[8]), 'color: white; opacity: 0.75', \(max)], ['OCT', \(dataArray[9]), 'color: white; opacity: 0.75', \(max)], ['NOV', \(dataArray[10]), 'color: white; opacity: 0.75', \(max)], ['DEC', \(dataArray[11]), 'color: white; opacity: 0.75', \(max)] ]); var options = { seriesType: 'bars', series: {1: {type: 'line'}}, width: '100%', height: '100%', legend: { position: 'none' }, bar: { groupWidth: '70%' }, backgroundColor: '#333333', backgroundColor: { strokeWidth: 0, fill: '#333333' }, chartArea: { left: 20, top: 10, width:'95%', height:'85%'}, fontSize: 8, Style: { color: 'white' }, hAxis: { textStyle:{color: '#FFF'} }, vAxis: { textStyle:{color: '#FFF'} } }; var chart = new google.visualization.ComboChart(document.getElementById('chart_div')); chart.draw(data, options);}</script><style>#chart_div { position: absolute; top: 0px; left: 0px; bottom: 0px; right: 0px;}</style></head><body> <div id='chart_div'></div></body></html>"
        
        // Return HTML string
        return stringHTML
    }

    func getLastDayOfMonth() -> NSString {
        
        // Formatter to get month from record
        var monthFormatter: NSDateFormatter = NSDateFormatter()
        monthFormatter.dateFormat = "MM"
        // Formatter to get year from records
        var yearFormatter: NSDateFormatter = NSDateFormatter()
        yearFormatter.dateFormat = "yyyy"
        
        var today: NSDate = NSDate()
        var thisYear: String = yearFormatter.stringFromDate(today)
        var thisMonth: String = monthFormatter.stringFromDate(today)
        var month: Int = thisMonth.toInt()!
        var year: Int = thisYear.toInt()!
        println("Current Year: \(year)")
        println("Current Month: \(month)")
        var lastDayOfMonth: String = String()
        
        switch month {
        case 2:
            // Caculate if leap year for February
            if (year % 400 == 0) {
                lastDayOfMonth = "29th"
            } else if (year % 100 == 0) {
                lastDayOfMonth = "28th"
            } else if (year % 4 == 0) {
                lastDayOfMonth = "29th"
            } else {
                lastDayOfMonth = "28th"
            }
        case 1, 3, 5, 7, 8, 10, 12:
            lastDayOfMonth = "31st"
        case 4, 6, 9, 11:
            lastDayOfMonth = "30th"
        // ? for
        default:
            lastDayOfMonth = "?"
            break
        }
        return lastDayOfMonth
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
