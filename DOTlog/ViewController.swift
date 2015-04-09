
//
//  ViewController.swift
//  DOTlog
//
//  Created by William Showalter on 15/02/28.
//  Copyright (c) 2015 UAF CS Capstone 2015. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {

	let managedObjectContext =
		(UIApplication.sharedApplication().delegate
				as AppDelegate).managedObjectContext

	// Revolving webdata variable that is used by all connections
	var webData = NSMutableData()
	var activeURL : NSURL = NSURL()
	var getURLs = [NSURL (string: "http://dotlog.uafcsc.com/dotlog/api/index.cfm/api/airports")!, NSURL (string: "http://dotlog.uafcsc.com/dotlog/api/index.cfm/api/categories")!]
	var postURL = NSURL (string: "http://dotlog.uafcsc.com/dotlog/api/index.cfm/api/events")!

	var user = "temp"
	var password = "temp"

	var keychainObj = KeychainAccess()

	override func viewDidLoad() {
		super.viewDidLoad()
		activeURL = getURLs[0]
		currentGetRequest()
		eventJSONBuilder()
	}

	func currentGetRequest() {
		let request = NSMutableURLRequest (URL: activeURL)
		request.HTTPMethod = "GET"
		let initRequest = NSURLConnection(request: request, delegate:self, startImmediately:true)
	}

	func eventPostRequest() {
		let request = NSMutableURLRequest (URL: postURL)
		request.HTTPMethod = "PUT"

		let initRequest = NSURLConnection(request: request, delegate:self, startImmediately:true)
	}

	func eventJSONBuilder() -> Dictionary<String,Any> {
		var events : [Dictionary<String, Any>] = []
		let fetchEvents = NSFetchRequest (entityName:"LogEntry")
		let eventEntries = managedObjectContext!.executeFetchRequest(fetchEvents, error:nil) as [LogEntry]

		for entry in eventEntries {
			//let temp : JSON = JSON.nullJSON
			var dateFormatter = NSDateFormatter()
			dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
			let tempDate = dateFormatter.stringFromDate(entry.event_time)

			let temp : [String: Any] = ["airport_code":entry.faa_code,"category_title":entry.category_title, "in_weekly_report":entry.in_weekly_report.boolValue,"event_text":entry.event_description,	"event_time":tempDate]

			events.append(temp)
		}

		return ["events":events]
	}

	func airportSyncJSON() {
		let airportData = JSON(data: webData)
		var newAirports : [String] = []
		for (index,airport) in airportData["AIPRORTS"]{
			newAirports.append(airport["FAA_CODE"].string!)
		}

		deleteAirports()

		for title in newAirports {
			let airportEntityDescription = NSEntityDescription.entityForName("AirportEntry",
				inManagedObjectContext: managedObjectContext!)
			let newAirport = AirportEntry(entity: airportEntityDescription!,
				insertIntoManagedObjectContext: managedObjectContext)
			newAirport.faa_code = title
			var error: NSError?

			managedObjectContext?.save(&error)
		}
	}

	func deleteAirports() {
		let fetchAirports = NSFetchRequest (entityName:"AirportEntry")
		let airportentries = managedObjectContext!.executeFetchRequest(fetchAirports, error:nil) as [AirportEntry]

		for entry in airportentries {
			managedObjectContext?.deleteObject(entry)
		}
	}

	func categorySyncJSON() {
		let categoryData = JSON(data: webData)
		var newCategories : [String] = []
		for (index,category) in categoryData["CATEGORIES"]{
			newCategories.append(category["CATEGORY_TITLE"].string!)
		}

		deleteCategories()

		for title in newCategories {
			let categoryEntityDescription = NSEntityDescription.entityForName("categoryEntry",
				inManagedObjectContext: managedObjectContext!)
			let newCategory = CategoryEntry(entity: categoryEntityDescription!,
				insertIntoManagedObjectContext: managedObjectContext)
			newCategory.category_title = title
			var error: NSError?

			managedObjectContext?.save(&error)
		}
	}

	func deleteCategories() {
		let fetchCategories = NSFetchRequest (entityName:"CategoryEntry")
		let categoryEntries = managedObjectContext!.executeFetchRequest(fetchCategories, error:nil) as [CategoryEntry]

		for entry in categoryEntries {
			managedObjectContext?.deleteObject(entry)
		}
	}

	func connection(connection: NSURLConnection, willSendRequestForAuthenticationChallenge challenge: NSURLAuthenticationChallenge){
		if (challenge.previousFailureCount != 0){
			// Previous failures
			challenge.sender.cancelAuthenticationChallenge(challenge)
		}
		else {
			let credential = NSURLCredential (user: user,
											password: password,
						persistence: NSURLCredentialPersistence.ForSession)
			challenge.sender.useCredential(credential, forAuthenticationChallenge: challenge)
		}

	}

	func connection(connection: NSURLConnection, didReceiveData data: NSData){
		webData.appendData(data)
	}

	func connection(connection: NSURLConnection, didReceiveResponse response: NSURLResponse){
		webData = NSMutableData ()
	}

	func connectionDidFinishLoading(connection : NSURLConnection){
		webView.loadData(webData, MIMEType: "text/html", textEncodingName: "UTF-8", baseURL:activeURL)
		if (activeURL == getURLs[0]){
			airportSyncJSON()
			activeURL = getURLs[1]
			currentGetRequest()
		}
		else if (activeURL == getURLs[1]){
			//categorySyncJSON()
		}
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	@IBOutlet weak var webView: UIWebView!

}

