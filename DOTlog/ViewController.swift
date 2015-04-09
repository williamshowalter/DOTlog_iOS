
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

	var postURL = NSURL (string: "http://dotlog.uafcsc.com/dotlog/api/index.cfm/api/events")!
	var baseURL : String = "http://dotlog.uafcsc.com"
	var keychainObj = KeychainAccess()

	var airports : SyncAirports = SyncAirports(baseURLString: "/")

	override func viewDidLoad() {
		super.viewDidLoad()

		airports = SyncAirports(baseURLString: baseURL)
		airports.requestData()
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


	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	@IBOutlet weak var webView: UIWebView!

}

