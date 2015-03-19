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

class NewEntry: UIViewController, UITextFieldDelegate {

	let managedObjectContext = (UIApplication.sharedApplication().delegate as AppDelegate).managedObjectContext

	@IBOutlet weak var textCategory: UITextField!
	@IBOutlet weak var textEvent: UITextView!
	@IBOutlet weak var textEventTime: UITextField!
	@IBOutlet weak var textEventDate: UITextField!

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

	override func viewDidLoad() {
		super.viewDidLoad()
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	// Get rid of the keyboard
	override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
		self.view.endEditing(true);
	}
	
	func textFieldShouldReturn(textField: UITextField!) -> Bool {
		textField.resignFirstResponder();
		return true;
	}

	@IBAction func saveLogEntry(sender: AnyObject) {
		let entityDescription =
		NSEntityDescription.entityForName("LogEntry",
			inManagedObjectContext: managedObjectContext!)

		let logEntry = LogEntry(entity: entityDescription!,
			insertIntoManagedObjectContext: managedObjectContext)

		var error: NSError?

		managedObjectContext?.save(&error)

		if let err = error {
			// Error to label
		} else {
			// Clear fields
		}
	}

	func getDateFromString() -> String {
		var todaysDate = NSDate().dateFromString("2015-02-04 23:29:28", format:  "yyyy-MM-dd HH:mm:ss")

		var dateFormatter = NSDateFormatter()
		dateFormatter.dateFormat = "dd-MM-yyyy"
		var DateInFormat = dateFormatter.stringFromDate(todaysDate)

		return DateInFormat
	}

	func getTimeFromString() -> String {
		var todaysDate = NSDate().dateFromString("2015-02-04 23:29:28", format:  "yyyy-MM-dd HH:mm:ss")

		var dateFormatter = NSDateFormatter()
		dateFormatter.dateFormat = "dd-MM-yyyy"
		var DateInFormat = dateFormatter.stringFromDate(todaysDate)

		return DateInFormat
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