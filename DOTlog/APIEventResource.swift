//
//  SyncEvents.swift
//  DOTlog
//
//  Created by William Showalter on 15/04/08.
//  Copyright (c) 2015 UAF CS Capstone 2015. All rights reserved.
//

import UIKit
import CoreData
import Foundation

class APIEventResource : NSObject, NSURLConnectionDelegate, APIResource {

	private let apiURI = "/dotlog/api/index.cfm/api/events"
	private let httpMethod = "PUT"
	private var APIAddressString = String()

	private let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext

	init (baseURLString base: String){
		APIAddressString = base + apiURI
	}

	func accept(visitor : NetworkVisitor){
		visitor.visit(self)
	}

	func getMethod() -> String{
		return httpMethod
	}

	func getAPIAddressString() -> String {
		return APIAddressString
	}

	func getBody() -> NSData {
		let events = eventJSONBuilder()

		var options = NSJSONWritingOptions.PrettyPrinted
		var jsonData : NSData = NSJSONSerialization.dataWithJSONObject(events, options: options, error: nil)!

		return jsonData
	}

	func syncJSON(webData: NSMutableData) {
		deleteOld()
	}

	func eventJSONBuilder() -> Dictionary<String,AnyObject> {
		var events : [Dictionary<String, AnyObject>] = []
		let fetchEvents = NSFetchRequest (entityName:"EventEntry")
		let eventEntries = managedObjectContext!.executeFetchRequest(fetchEvents, error:nil) as! [EventEntry]

		for entry in eventEntries {
			var dateFormatter = NSDateFormatter()
			dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
			let tempDate = dateFormatter.stringFromDate(entry.event_time)

			let temp : [String: AnyObject] = ["FAA_CODE":entry.faa_code,"CATEGORY_TITLE":entry.category_title, "IN_WEEKLY_REPORT":entry.in_weekly_report.boolValue,"EVENT_TEXT":entry.event_text,	"EVENT_TIME":tempDate]

			events.append(temp)
		}
		return ["events":events]
	}

	private func deleteOld() {
		let fetch = NSFetchRequest (entityName:"EventEntry")
		let entries = managedObjectContext!.executeFetchRequest(fetch, error:nil) as! [EventEntry]
		for entry in entries {
			managedObjectContext?.deleteObject(entry)
		}
	}
}