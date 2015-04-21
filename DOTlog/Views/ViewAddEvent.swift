//
//  ViewAddEvent.swift
//  DOTlog
//
//  Created by William Showalter on 15/03/18.
//  Copyright (c) 2015 UAF CS Capstone 2015. All rights reserved.
//

import Foundation
import UIKit
import CoreData

let SUMMARYCHARLIMIT : Int = 4000

class ViewAddEvent: UITableViewController, UITextFieldDelegate, UITextViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource {

	let uninitializedString = "Must Run Sync"
	let notSyncedAlert = UIAlertController(title: "Must Run Sync", message: "Please sync for airport & category lists", preferredStyle: .Alert)
	let categoryNotSelectedAlert = UIAlertController(title: "No Category", message: "Please select a category", preferredStyle: .Alert)
	let noEventSummaryAlert = UIAlertController(title: "No Event Summary", message: "Please enter an event summary", preferredStyle: .Alert)
	let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext

	var categories : [String] = []
	var airports : [String] = []

	@IBOutlet var pickerCategories: UIPickerView! = UIPickerView()
	@IBOutlet var pickerAirports: UIPickerView! = UIPickerView()
	var pickerTime  : UIDatePicker! = UIDatePicker()

	@IBOutlet weak var UIFieldCategory: UITextField!
	@IBOutlet weak var UIFieldSummary: UITextView!
	@IBOutlet weak var UIFieldTime: UITextField!
	@IBOutlet weak var UIFieldAirport: UITextField!

	@IBOutlet weak var UISwitchInWeeklyReport: UISwitch!

	@IBAction func editEventTime(sender: UITextField) {
		pickerTime.datePickerMode = UIDatePickerMode.DateAndTime
		sender.inputView = pickerTime
		pickerTime.addTarget(self, action: Selector("setEventTime:"), forControlEvents: UIControlEvents.ValueChanged)
	}

	func setEventTime(sender: UIDatePicker) {
		var timeFormatter = NSDateFormatter()
		timeFormatter.dateFormat = "MMM dd yyyy hh:mm a"
		UIFieldTime.text = timeFormatter.stringFromDate(sender.date)
	}

	override func viewWillAppear(animated: Bool){
		super.viewWillAppear(animated)
		resetPage()
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		self.notSyncedAlert.addAction(UIAlertAction(title: "Dismiss",
			style: UIAlertActionStyle.Default,
			handler: {(alert: UIAlertAction!) in}))
		self.noEventSummaryAlert.addAction(UIAlertAction(title: "Dismiss",
			style: UIAlertActionStyle.Default,
			handler: {(alert: UIAlertAction!) in}))
		self.categoryNotSelectedAlert.addAction(UIAlertAction(title: "Dismiss",
			style: UIAlertActionStyle.Default,
			handler: {(alert: UIAlertAction!) in}))

		pickerCategories.delegate = self
		pickerAirports.delegate = self
	}

	func resetPage() {
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

		if airports.count == 0 {
			airports = [uninitializedString]
		}

		if categories.count == 0 {
			categories = [uninitializedString]
		}

		UIFieldAirport.text = airports[0]
		UIFieldCategory.text = ""

		pickerTime.date = NSDate()

		setEventTime(pickerTime)

		UISwitchInWeeklyReport.on = false

		UIFieldSummary.text = ""
	}

	@IBAction func saveEvent(sender: AnyObject) {

		if UIFieldCategory.text == uninitializedString || UIFieldAirport.text == uninitializedString {
			self.presentViewController(notSyncedAlert, animated: true, completion:nil)
		}

		else if UIFieldCategory.text == "" {
			self.presentViewController(categoryNotSelectedAlert, animated: true, completion:nil)
		}

		else if UIFieldSummary.text == "" {
			self.presentViewController(noEventSummaryAlert, animated:true, completion:nil)
		}

		else if count(UIFieldSummary.text) > SUMMARYCHARLIMIT {
			let summaryLengthAlert = UIAlertController(title: "Character Limit Exceeded", message: "Maximum Characters: \(String(SUMMARYCHARLIMIT))\nCurrent Characters: \(String(count(UIFieldSummary.text)))", preferredStyle: .Alert)

			summaryLengthAlert.addAction(UIAlertAction(title: "Dismiss",
				style: UIAlertActionStyle.Default,
				handler: {(alert: UIAlertAction!) in}))

			self.presentViewController(summaryLengthAlert, animated:true, completion:nil)
		}

		else {
			let entityDescription =
			NSEntityDescription.entityForName("EventEntry",
				inManagedObjectContext: managedObjectContext!)

			let event = EventEntry(entity: entityDescription!,
				insertIntoManagedObjectContext: managedObjectContext)

			event.faa_code = UIFieldAirport.text
			event.category_title = UIFieldCategory.text
			event.event_text = UIFieldSummary.text
			event.in_weekly_report = UISwitchInWeeklyReport.on

			var dateFormatter:NSDateFormatter = NSDateFormatter()
			dateFormatter.dateFormat = "MMM dd yyyy hh:mm a"
			var tempDate:String = UIFieldTime.text

			event.event_time = dateFormatter.dateFromString (tempDate)!

			var error: NSError?

			managedObjectContext?.save(&error)

			if let err = error {
				//submissionStatus.text = err.localizedFailureReason;
			} else {
				//submissionStatus.text = "Event Saved"
				var vc = self.storyboard?.instantiateViewControllerWithIdentifier("TabBarViewController") as! TabBarViewController
				self.presentViewController(vc, animated: true, completion: nil)
			}
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
	@IBAction func hideKeyboardOnClick(sender: AnyObject) {
		self.view.endEditing(true);

		self.UIFieldAirport.resignFirstResponder()
		self.UIFieldCategory.resignFirstResponder()
		self.UIFieldSummary.resignFirstResponder()
		self.UIFieldTime.resignFirstResponder()
		println("hideKeyboard")
	}

	func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int{
		return 1
	}

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
		return uninitializedString
	}

	func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
	{
		if (pickerView == pickerCategories && categories.count != 0){
			UIFieldCategory.text = categories[row]
		}
		else if (pickerView == pickerAirports && airports.count != 0){
			UIFieldAirport.text = airports[row];
		}
	}

	@IBAction func editCategory(sender: UITextField) {
		pickerCategories.reloadAllComponents()
		sender.inputView = pickerCategories
	}

	@IBAction func editAirport(sender: UITextField) {
		pickerAirports.reloadAllComponents()
		sender.inputView = pickerAirports;
	}
	
}