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

let SUMMARYCHARLIMIT : Int = 4000

class ViewNewEntry: UIViewController, UITextFieldDelegate, UITextViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource {


	let uninitializedString = "Must Run Sync"
	let notSyncedAlert = UIAlertController(title: "Must Run Sync", message: "Please sync for airport & category lists", preferredStyle: .Alert)
	let categoryNotSelectedAlert = UIAlertController(title: "No Category", message: "Please select a category", preferredStyle: .Alert)
	let noEventSummaryAlert = UIAlertController(title: "No Event Summary", message: "Please enter an event summary", preferredStyle: .Alert)
	let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext

	var categories : [String] = []
	var airports : [String] = []

	@IBOutlet weak var scrollView: UIScrollView!
	
	@IBOutlet var pickerCategories: UIPickerView! = UIPickerView()
	@IBOutlet var pickerAirports: UIPickerView! = UIPickerView()
	var pickerDate  : UIDatePicker! = UIDatePicker()
	var pickerTime  : UIDatePicker! = UIDatePicker()

	@IBOutlet weak var UIFieldCategory: UITextField!
	@IBOutlet weak var UIFieldSummary: UITextView!
	@IBOutlet weak var UIFieldTime: UITextField!
	@IBOutlet weak var UIFieldDate: UITextField!
	@IBOutlet weak var UIFieldAirport: UITextField!

	@IBOutlet weak var UISwitchInWeeklyReport: UISwitch!

	@IBOutlet weak var submissionStatus: UILabel!
	

	@IBAction func editEventDate(sender: UITextField) {
		pickerDate.datePickerMode = UIDatePickerMode.Date
		sender.inputView = pickerDate
		pickerDate.addTarget(self, action: Selector("setEventDate:"), forControlEvents: UIControlEvents.ValueChanged)
	}

	@IBAction func editEventTime(sender: UITextField) {
		pickerTime.datePickerMode = UIDatePickerMode.Time
		sender.inputView = pickerTime
		pickerTime.addTarget(self, action: Selector("setEventTime:"), forControlEvents: UIControlEvents.ValueChanged)
	}


	func setEventDate(sender: UIDatePicker) {
		var monthDayYearFormatter = NSDateFormatter()
		monthDayYearFormatter.dateFormat = "MMM dd yyyy"
		UIFieldDate.text = monthDayYearFormatter.stringFromDate(sender.date)
	}

	func setEventTime(sender: UIDatePicker) {
		var timeFormatter = NSDateFormatter()
		timeFormatter.dateFormat = "hh:mm a"
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

		UISwitchInWeeklyReport.transform = CGAffineTransformMakeScale (0.75,0.75)

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

		pickerDate.date = NSDate()
		pickerTime.date = NSDate()

		setEventDate(pickerDate)
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
			var tempDate:String = UIFieldDate.text + " " + UIFieldTime.text

			event.event_time = dateFormatter.dateFromString (tempDate)!

			var error: NSError?
			
			managedObjectContext?.save(&error)

			if let err = error {
				submissionStatus.text = err.localizedFailureReason;
			} else {
				submissionStatus.text = "Event Saved"
				resetPage()
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
	@IBAction func hideKeyboardInScrollView(sender: AnyObject) {
		self.view.endEditing(true);
	}

	func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int{
		return 1
	}

	// Resize scrollview when keyboard/pickers are out
	func textFieldDidBeginEditing(textField: UITextField) {
		self.scrollView.setContentOffset(CGPointMake(0, textField.frame.origin.y), animated: true)
		self.viewDidLayoutSubviews()
	}
	func textFieldDidEndEditing(textField: UITextField) {
		self.scrollView.setContentOffset(CGPointMake(0,0), animated: true)
		self.viewDidLayoutSubviews()
	}
	func textViewDidBeginEditing(textView: UITextView) {
		self.scrollView.setContentOffset(CGPointMake(0, textView.frame.origin.y), animated: true)
		self.viewDidLayoutSubviews()
	}
	func textViewDidEndEditing(textView: UITextView) {
		self.scrollView.setContentOffset(CGPointMake(0,0), animated: true)
		self.viewDidLayoutSubviews()
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