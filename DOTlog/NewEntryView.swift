//
//  NewEntry.swift
//  DOTlog
//
//  Created by William Showalter on 15/03/18.
//  Copyright (c) 2015 UAF CS Capstone 2015. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class NewEntryView: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {

	let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
	var categories : [String] = []
	var airports : [String] = []

	@IBOutlet var pickerCategories: UIPickerView! = UIPickerView()
	@IBOutlet var pickerAirports: UIPickerView! = UIPickerView()

	@IBOutlet weak var textCategory: UITextField!
	@IBOutlet weak var textEvent: UITextView!
	@IBOutlet weak var textEventTime: UITextField!
	@IBOutlet weak var textEventDate: UITextField!
	@IBOutlet weak var textAirport: UITextField!

	@IBOutlet weak var in_weekly_report: UISwitch!

	@IBOutlet weak var labelStatus: UILabel!
	
	
	@IBAction func editEventTime(sender: UITextField) {
		var datePickerView  : UIDatePicker = UIDatePicker()
		datePickerView.datePickerMode = UIDatePickerMode.Time
		sender.inputView = datePickerView
		datePickerView.addTarget(self, action: Selector("handleDatePickerTime:"), forControlEvents: UIControlEvents.ValueChanged)
	}

	@IBAction func editEventDate(sender: UITextField) {
		var datePickerView  : UIDatePicker = UIDatePicker()
		datePickerView.datePickerMode = UIDatePickerMode.Date
		sender.inputView = datePickerView
		datePickerView.addTarget(self, action: Selector("handleDatePickerDate:"), forControlEvents: UIControlEvents.ValueChanged)
	}


	func handleDatePickerDate(sender: UIDatePicker) {
		var dateFormatter = NSDateFormatter()
		dateFormatter.dateFormat = "MMM dd yyyy"
		textEventDate.text = dateFormatter.stringFromDate(sender.date)
	}

	func handleDatePickerTime(sender: UIDatePicker) {
		var dateFormatter = NSDateFormatter()
		dateFormatter.dateFormat = "hh:mm a"
		textEventTime.text = dateFormatter.stringFromDate(sender.date)
	}

	override func viewWillAppear(animated: Bool){
		super.viewWillAppear(animated)
		let airportFetch = NSFetchRequest (entityName:"AirportEntry")
		if let airportResults = managedObjectContext!.executeFetchRequest(airportFetch, error:nil) as? [AirportEntry]{
			airports = Array<String>() // Clear old array
			for airport in airportResults {
				airports.append(airport.faa_code)
			}
		}

		let categoryFetch = NSFetchRequest (entityName:"CategoryEntry")
		if let categoryResults = managedObjectContext!.executeFetchRequest(categoryFetch, error:nil) as? [CategoryEntry]{
			categories = Array<String>() // Clear old array
			for category in categoryResults {
				categories.append(category.category_title)
			}
		}

		// Initialize if no airports -- temporary until syncing is finished.
		if airports.count != 0
		{
			textAirport.text = airports[0]
		}
		// Initialize if no categories -- temporary until syncing is finished
		if categories.count != 0
		{
			textCategory.text = categories[0]
		}

		// Initialize if no airports -- temporary until syncing is finished.
		if airports.count == 0
		{
			airports = ["Please run initial sync"]
			textAirport.text = airports[0]
		}
		// Initialize if no categories -- temporary until syncing is finished
		if categories.count == 0
		{
			categories = ["Please run initial sync"]
			textCategory.text = categories[0]
		}
	}

	override func viewDidLoad() {
		super.viewDidLoad()




		var todaysDate:NSDate = NSDate()
		var dateFormatter:NSDateFormatter = NSDateFormatter()
		dateFormatter.dateFormat = "hh:mm a"
		textEventTime.text = dateFormatter.stringFromDate(todaysDate)

		dateFormatter.dateFormat = "MMM dd yyyy"
		textEventDate.text = dateFormatter.stringFromDate(todaysDate)

		pickerCategories.delegate = self
		pickerAirports.delegate = self

		in_weekly_report.on = false

		in_weekly_report.transform = CGAffineTransformMakeScale (0.75,0.75)

	}

	@IBAction func saveLogEntry(sender: AnyObject) {
		let entityDescription =
		NSEntityDescription.entityForName("LogEntry",
			inManagedObjectContext: managedObjectContext!)

		let logEntry = LogEntry(entity: entityDescription!,
			insertIntoManagedObjectContext: managedObjectContext)

		logEntry.faa_code = textAirport.text
		logEntry.category_title = textCategory.text
		logEntry.event_description = textEvent.text
		logEntry.in_weekly_report = in_weekly_report.on

		var dateFormatter:NSDateFormatter = NSDateFormatter()
		dateFormatter.dateFormat = "MMM dd yyyy hh:mm a"
		var tempDate:String = textEventDate.text + " " + textEventTime.text

		logEntry.event_time = dateFormatter.dateFromString (tempDate)!

		var error: NSError?

		managedObjectContext?.save(&error)

		if let err = error {
			labelStatus.text = err.localizedFailureReason;
		} else {
			labelStatus.text = "Log Entry Saved"
			self.textEvent.text = ""
			self.viewDidLoad()
		}
		
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	// Get rid of the keyboard when touching outside
	override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
		self.view.endEditing(true);
	}
	// Get rid of keyboard when hitting return
	func textFieldShouldReturn(textField: UITextField) -> Bool {
		textField.resignFirstResponder();
		return true;
	}

	// returns the number of 'columns' to display.
	func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int{
		return 1
	}

	// returns the # of rows in each component..
	func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
		if (pickerView == pickerCategories){
			return categories.count
		}
		else if (pickerView == pickerAirports){
			return airports.count
		}
		return categories.count
	}

	func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
		if (pickerView == pickerCategories && categories.count != 0){
			return categories[row]
		}
		else if (pickerView == pickerAirports && airports.count != 0){
			return airports[row];
		}
		return "Please run sync"
	}

	func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
	{
		if (pickerView == pickerCategories && categories.count != 0){
			textCategory.text = categories[row]
		}
		else if (pickerView == pickerAirports && airports.count != 0){
			textAirport.text = airports[row];
		}
	}

	@IBAction func editCategories(sender: UITextField) {
		sender.inputView = pickerCategories
	}

	@IBAction func editAirport(sender: UITextField) {
		sender.inputView = pickerAirports;
	}

}