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

class NewEntry: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {

	let managedObjectContext = (UIApplication.sharedApplication().delegate as AppDelegate).managedObjectContext
	var categories : [Int : String] = [0:"Hazard", 1:"Airport Closure", 2:"Kittens on Runway"]
	var airports : [Int : String] = [0:"FBX", 1:"KZB", 2:"UZB", 3:"LNK"]

	@IBOutlet var pickerCategories: UIPickerView! = UIPickerView()
	@IBOutlet var pickerAirports: UIPickerView! = UIPickerView()

	@IBOutlet weak var textCategory: UITextField!
	@IBOutlet weak var textEvent: UITextView!
	@IBOutlet weak var textEventTime: UITextField!
	@IBOutlet weak var textEventDate: UITextField!
	@IBOutlet weak var textAirport: UITextField!

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

	@IBOutlet weak var categoryPicker: UIPickerView!
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

	override func viewDidLoad() {
		super.viewDidLoad()

		var todaysDate:NSDate = NSDate()
		var dateFormatter:NSDateFormatter = NSDateFormatter()
		dateFormatter.dateFormat = "hh:mm a"
		textEventTime.text = dateFormatter.stringFromDate(todaysDate)

		dateFormatter.dateFormat = "MMM dd yyyy"
		textEventDate.text = dateFormatter.stringFromDate(todaysDate)

		textCategory.text = categories[0]
		textAirport.text = airports[0]
		pickerCategories.delegate = self
		pickerAirports.delegate = self
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	// Get rid of the keyboard when touching outside
	override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
		self.view.endEditing(true);
	}
	// Get rid of keyboard when hitting return
	func textFieldShouldReturn(textField: UITextField!) -> Bool {
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

	func pickerView(pickerView: UIPickerView!, titleForRow row: Int, forComponent component: Int) -> String! {
		if (pickerView == pickerCategories){
			return categories[row]
		}
		else if (pickerView == pickerAirports){
			return airports[row];
		}
		return categories[row]
	}

	func pickerView(pickerView: UIPickerView!, didSelectRow row: Int, inComponent component: Int)
	{
		if (pickerView == pickerCategories){
			textCategory.text = categories[row]
		}
		else if (pickerView == pickerAirports){
			textAirport.text = airports[row];
		}
	}

	@IBAction func editCategories(sender: UITextField) {
		sender.inputView = pickerCategories
	}

	@IBAction func editAirport(sender: UITextField) {
		sender.inputView = pickerAirports;
	}

	@IBAction func saveLogEntry(sender: AnyObject) {
		let entityDescription =
		NSEntityDescription.entityForName("LogEntry",
			inManagedObjectContext: managedObjectContext!)

		let logEntry = LogEntry(entity: entityDescription!,
			insertIntoManagedObjectContext: managedObjectContext)

		let tempAirport = (airports as NSDictionary).allKeysForObject(textAirport.text)[0] as Int;
		let tempCategory = 0;
		let tempUser = 0;

		logEntry.entryDescription = textEvent.text
		logEntry.airportID = tempAirport
		logEntry.categoryID = tempCategory
		logEntry.userID = tempUser

		var error: NSError?

		managedObjectContext?.save(&error)

		if let err = error {
			labelStatus.text = err.localizedFailureReason;
		} else {
			labelStatus.text = "Log Entry Saved"
			self.textEvent.text = ""
			self.textCategory.text = categories[0]
			self.viewDidLoad()
		}

	}

}

extension NSDate {
	func dateFromString(date: String, format: String) -> NSDate {
		let formatter = NSDateFormatter()
		let locale = NSLocale(localeIdentifier: "en_US_POSIX")

		formatter.locale = locale
		formatter.dateFormat = format

		return formatter.dateFromString(date)!
	}
}