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

class ViewNewEntry: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {

	let uninitializedString = "Must Run Sync"
	let notSyncedAlert = UIAlertController(title: "Must Run Sync", message: "Please sync for airport & category lists", preferredStyle: .Alert)
	let noEventSummaryAlert = UIAlertController(title: "No Event Summary", message: "Please enter an event summary", preferredStyle: .Alert)
	let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext

	var categories : [String] = []
	var airports : [String] = []

	@IBOutlet var pickerCategories: UIPickerView! = UIPickerView()
	@IBOutlet var pickerAirports: UIPickerView! = UIPickerView()

	@IBOutlet weak var UIFieldCategory: UITextField!
	@IBOutlet weak var UIFieldEvent: UITextView!
	@IBOutlet weak var UIFieldTime: UITextField!
	@IBOutlet weak var UIFieldDate: UITextField!
	@IBOutlet weak var UIFieldAirport: UITextField!

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
		UIFieldDate.text = dateFormatter.stringFromDate(sender.date)
	}

	func handleDatePickerTime(sender: UIDatePicker) {
		var dateFormatter = NSDateFormatter()
		dateFormatter.dateFormat = "hh:mm a"
		UIFieldTime.text = dateFormatter.stringFromDate(sender.date)
	}

	override func viewWillAppear(animated: Bool){
		super.viewWillAppear(animated)
		resetPage()
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		self.notSyncedAlert.addAction(UIAlertAction(title: "Okay",
			style: UIAlertActionStyle.Default,
			handler: {(alert: UIAlertAction!) in}))
		self.noEventSummaryAlert.addAction(UIAlertAction(title: "Okay",
			style: UIAlertActionStyle.Default,
			handler: {(alert: UIAlertAction!) in}))

		pickerCategories.delegate = self
		pickerAirports.delegate = self

		in_weekly_report.transform = CGAffineTransformMakeScale (0.75,0.75)

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

		// Initialize if no airports -- temporary until syncing is finished.
		if airports.count != 0
		{
			UIFieldAirport.text = airports[0]
		}
		// Initialize if no categories -- temporary until syncing is finished
		if categories.count != 0
		{
			UIFieldCategory.text = categories[0]
		}

		// Initialize if no airports
		if airports.count == 0
		{
			airports = [uninitializedString]
			UIFieldAirport.text = airports[0]
		}
		// Initialize if no categories
		if categories.count == 0
		{
			categories = [uninitializedString]
			UIFieldCategory.text = categories[0]
		}

		var todaysDate:NSDate = NSDate()
		var dateFormatter:NSDateFormatter = NSDateFormatter()
		dateFormatter.dateFormat = "hh:mm a"
		UIFieldTime.text = dateFormatter.stringFromDate(todaysDate)

		dateFormatter.dateFormat = "MMM dd yyyy"
		UIFieldDate.text = dateFormatter.stringFromDate(todaysDate)

		in_weekly_report.on = false

		UIFieldEvent.text = ""
	}

	@IBAction func saveEventEntry(sender: AnyObject) {

		if UIFieldCategory.text == uninitializedString || UIFieldAirport.text == uninitializedString {
			self.presentViewController(notSyncedAlert, animated: true, completion:nil)
		}

		else if UIFieldEvent.text == "" {
			self.presentViewController(noEventSummaryAlert, animated:true, completion:nil)
		}

		else {
			let entityDescription =
			NSEntityDescription.entityForName("EventEntry",
				inManagedObjectContext: managedObjectContext!)

			let event = EventEntry(entity: entityDescription!,
				insertIntoManagedObjectContext: managedObjectContext)

			event.faa_code = UIFieldAirport.text
			event.category_title = UIFieldCategory.text
			event.event_text = UIFieldEvent.text
			event.in_weekly_report = in_weekly_report.on

			var dateFormatter:NSDateFormatter = NSDateFormatter()
			dateFormatter.dateFormat = "MMM dd yyyy hh:mm a"
			var tempDate:String = UIFieldDate.text + " " + UIFieldDate.text

			event.event_time = dateFormatter.dateFromString (tempDate)!

			var error: NSError?
			
			managedObjectContext?.save(&error)

			if let err = error {
				labelStatus.text = err.localizedFailureReason;
			} else {
				labelStatus.text = "Event Saved"
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

	@IBAction func editCategories(sender: UITextField) {
		sender.inputView = pickerCategories
	}

	@IBAction func editAirport(sender: UITextField) {
		sender.inputView = pickerAirports;
	}

}