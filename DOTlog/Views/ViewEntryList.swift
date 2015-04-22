//
//  EntryList.swift
//  DOTlog
//
//  Created by William Showalter on 15/03/18.
//  Copyright (c) 2015 UAF CS Capstone 2015. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class ViewEventList: UIViewController, UITableViewDelegate, UITableViewDataSource, ErrorObserver {

	// This class is an ErrorObserver from the Observer design pattern
	// This allows the class to have subjects to keep references to the observer
	// and notify this viewcontroller with errors through the notify(NSError) function.
	// http://en.wikipedia.org/wiki/Observer_pattern

	@IBOutlet weak var entryTableView: UITableView!

	let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
	let notSyncedAlert = UIAlertController(title: "Run Initial Sync Before Adding Events", message: nil, preferredStyle: .Alert)
	let noCredentialAlert = UIAlertController(title: "Set Credentials in Account Settings", message: nil, preferredStyle: .Alert)
	let syncManagerObj = SyncManager()

	var errorReceivedSinceLastSync = false
	var eventEntries = [EventEntry]()
	var keychainObj = KeychainAccess()

	var username : String?
	var password : String?
	var baseURL : String?

	override func viewDidLoad() {
		super.viewDidLoad()
		entryTableView.dataSource = self
		entryTableView.delegate = self

		self.notSyncedAlert.addAction(UIAlertAction(title: "Dismiss",
			style: UIAlertActionStyle.Default,
			handler: {(alert: UIAlertAction!) in}))
		self.noCredentialAlert.addAction(UIAlertAction(title: "Dismiss",
			style: UIAlertActionStyle.Default,
			handler: {(alert: UIAlertAction!) in}))
	}

	override func viewWillAppear(animated: Bool){
		super.viewWillAppear(animated)
		fetchLogs()
		self.entryTableView.reloadData()
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	func fetchLogs(){
		let logsFetch = NSFetchRequest (entityName:"EventEntry")
		eventEntries = managedObjectContext!.executeFetchRequest(logsFetch, error:nil) as! [EventEntry]
	}

	// Functions for UITableViewDataSources
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return eventEntries.count;
	}

	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		var newCell : UITableViewCell? = tableView.dequeueReusableCellWithIdentifier("EventEntry") as? UITableViewCell
		println(newCell)

		if newCell == nil {
			newCell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "EventEntry")
			println("New cell initialized")
		}

		let eventEntry = eventEntries[indexPath.row]
		println("FAA: \(eventEntry.faa_code)")
		println("Cat: \(eventEntry.category_title)")
		println("text: \(eventEntry.event_text)")
		newCell!.detailTextLabel!.text = eventEntry.faa_code + " - " + eventEntry.category_title + " - " + eventEntry.event_text
		return newCell!
	}

	func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
		if editingStyle == UITableViewCellEditingStyle.Delete {

			let entryToDelete = eventEntries[indexPath.row]
			managedObjectContext?.deleteObject(entryToDelete)

			eventEntries.removeAtIndex(indexPath.row)
			tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
		}
	}


	@IBAction func addEventButton(sender: AnyObject) {
		var airports = Array<String>()
		var categories = Array<String>()

		let airportFetch = NSFetchRequest (entityName:"AirportEntry")
		if let airportResults = managedObjectContext!.executeFetchRequest(airportFetch, error:nil) as? [AirportEntry]{
			for airport in airportResults {
				airports.append(airport.faa_code)
			}
		}

		let categoryFetch = NSFetchRequest (entityName:"CategoryEntry")
		if let categoryResults = managedObjectContext!.executeFetchRequest(categoryFetch, error:nil) as? [CategoryEntry]{
			for category in categoryResults {
				categories.append(category.category_title)
			}
		}

		if airports.count == 0 || categories.count == 0 {
			self.presentViewController(notSyncedAlert, animated: true, completion:nil)
		}
		else {
			performSegueWithIdentifier("AddEventSegue", sender: self)
		}
	}

	@IBAction func syncButton(sender: AnyObject) {
		errorReceivedSinceLastSync = false
		fetchURLUsernamePass()

		if username == "" || password == "" || baseURL == nil {
			performSegueWithIdentifier("SyncCredentials", sender: self)
		}
		else {
			syncManagerObj.runSync(username!, password: password!, baseURL: baseURL!, observer: self)
		}
	}

	func fetchURLUsernamePass() {
		let URLFetch = NSFetchRequest (entityName:"SyncURLEntry")
		if let URLs = managedObjectContext!.executeFetchRequest(URLFetch, error:nil) as? [SyncURLEntry] {
			if URLs.count != 0 {
				baseURL = URLs[0].urlString
			}
			else {
				baseURL = defaultBaseURL
			}
		}
		else {
			baseURL = defaultBaseURL
		}

		if let usernameFetch = keychainObj.getUsername(){
			username = usernameFetch;
		}
		else {
			username = "";
		}

		if let passwordFetch = keychainObj.getPassword(){
			password = passwordFetch;
		}
		else {
			password = "";
		}
	}

	func notify (error : NSError) {

		if !errorReceivedSinceLastSync {
			errorReceivedSinceLastSync = true

			let code = error.code

			var errorMessage = "Contact Regional Aviation Office."
			var errorDetailMessage = error.localizedDescription
			var errorTitle = "Error"
			var errorDetailTitle = "Error Code: \(code)"

			if let detailMessage : [NSObject : AnyObject] = error.userInfo {
				if let errorDetailMessageText = detailMessage["NSLocalizedDescriptionKey"] as? String {
					errorDetailMessage = "\(errorDetailMessageText)"
				}
			}

			if code == 401 {
				errorTitle = error.domain
				errorMessage = ""
			}

			if code == -1003 {
				errorTitle = "Bad URL" // Needs to match page wording
				errorMessage = "Please check Website URL"
			}

			let errorAlert = UIAlertController(title: errorTitle, message: errorMessage, preferredStyle: UIAlertControllerStyle.Alert)

			let errorAlertDetail = UIAlertController(title: errorDetailTitle, message: errorDetailMessage as String, preferredStyle: UIAlertControllerStyle.Alert)

			errorAlert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Cancel, handler:{ (ACTION :UIAlertAction!)in }))
			errorAlert.addAction(UIAlertAction(title: "Details", style: UIAlertActionStyle.Default, handler:{ (ACTION :UIAlertAction!)in self.presentViewController(errorAlertDetail, animated: true, completion: nil)}))
			errorAlertDetail.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Cancel, handler:{ (ACTION :UIAlertAction!)in }))

			self.presentViewController(errorAlert, animated: true, completion: nil)
		}
	}

	// Returns to this view controller
	@IBAction func ButtonCancelToEventList(segue: UIStoryboardSegue) {

	}

	func notifyFinishSuccess () {
		self.viewWillAppear(true)
	}
}