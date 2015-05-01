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

class ViewAddEvent: UITableViewController, UITextFieldDelegate, UITextViewDelegate {

	let uninitializedString = "Must Run Sync"
	let notSyncedAlert = UIAlertController(title: "Must Run Sync", message: "Please sync for airport & category lists", preferredStyle: .Alert)
	let categoryNotSelectedAlert = UIAlertController(title: "No Category", message: "Please select a category", preferredStyle: .Alert)
	let noEventSummaryAlert = UIAlertController(title: "No Event Summary", message: "Please enter an event summary", preferredStyle: .Alert)
	let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext

	var airports : [String] = []

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

		resetPage()

	}

	func resetPage() {
		let airportFetch = NSFetchRequest (entityName:"AirportEntry")
		if let airportResults = managedObjectContext!.executeFetchRequest(airportFetch, error:nil) as? [AirportEntry]{
			airports = Array<String>() // Clear old array
			for airport in airportResults {
				airports.append(airport.faa_code)
			}
		}

		if airports.count == 0 {
			airports = [uninitializedString]
		}

		UIFieldAirport.text = ""

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
	}

	func textFieldDidBeginEditing(textField: UITextField) {
		textField.becomeFirstResponder()
	}

	@IBAction func editCategory(sender: UITextField) {
		performSegueWithIdentifier("SegueSelectCategory", sender: self)
	}

	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if segue.identifier == "SegueSelectCategory" {
			var destinationViewController = segue.destinationViewController as! ViewAddEventCategory

			if let currentCategory = UIFieldCategory.text {
				destinationViewController.currentCategory = currentCategory
			}
		}
	}

	override func canBecomeFirstResponder() -> Bool {
		return true
	}

	@IBAction func editAirport(sender: UITextField) {
		let fetchRegions = NSFetchRequest (entityName: "RegionEntry")
		let regions = managedObjectContext!.executeFetchRequest(fetchRegions, error: nil) as! [RegionEntry]
		if regions.count > 1 {
			performSegueWithIdentifier("SegueAddEventToRegions", sender: self)
		}
		else {
			let fetchDistricts = NSFetchRequest (entityName: "DistrictEntry")
			let districts = managedObjectContext!.executeFetchRequest(fetchDistricts, error: nil) as! [RegionEntry]
			if districts.count > 1 {
				performSegueWithIdentifier("SegueAddEventToDistricts", sender: self)
			}
			else {
				let fetchHubs = NSFetchRequest (entityName: "HubEntry")
				let hubs = managedObjectContext!.executeFetchRequest(fetchHubs, error: nil) as! [RegionEntry]
				if hubs.count > 1 {
					performSegueWithIdentifier("SegueAddEventToHubs", sender: self)
				}
				else {
					performSegueWithIdentifier("SegueAddEventToAirports", sender: self)
				}
			}
		}
	}

	// Returns to this view controller
	@IBAction func ButtonReturnToAddEvent(segue: UIStoryboardSegue) {
	}
}