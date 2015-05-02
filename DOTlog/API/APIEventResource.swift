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

class APIEventResource : APIResource {

	// *******  DOT MAY HAVE TO UPDATE BASED ON DOTLOG INSTALLATION DIRECTORY STRUCTURE  ******* //
	private let eventURI = "/dotlog/api/index.cfm/api/events"
	// *******  DOT MAY HAVE TO UPDATE BASED ON DOTLOG INSTALLATION DIRECTORY STRUCTURE  ******* //

	private let httpMethod = "PUT"
	private let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext

	private var APIAddressString = String()

	init (baseURLString base: String){
		APIAddressString = base + eventURI
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

	func getBody() -> NSData? {
		let events = eventJSONBuilder()

		var options = NSJSONWritingOptions.PrettyPrinted
		return NSJSONSerialization.dataWithJSONObject(events, options: options, error: nil)!
	}

	func getResourceIdentifier () -> String {
		return eventURI
	}

	func refreshLocalResource(webData: NSMutableData) -> NSError? {
		var error: NSError?

		deleteOld()
		
		return error
	}

	func eventJSONBuilder() -> Dictionary<String,AnyObject> {
		var events : [Dictionary<String, AnyObject>] = []
		let fetchEvents = NSFetchRequest (entityName:"EventEntry")
		let eventEntries = managedObjectContext!.executeFetchRequest(fetchEvents, error:nil) as! [EventEntry]

		for entry in eventEntries {
			var eventDateFormatter = NSDateFormatter()
			eventDateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
			let tempDate = eventDateFormatter.stringFromDate(entry.event_time)

			let nextEvent : [String: AnyObject] = ["FAA_CODE":entry.faa_code,"CATEGORY_TITLE":entry.category_title, "IN_WEEKLY_REPORT": entry.in_weekly_report.boolValue, "EVENT_TEXT":entry.event_text, "EVENT_TIME":tempDate]

			events.append(nextEvent)
		}

		return ["EVENTS":events]
	}

	func deleteOld() {
		let fetch = NSFetchRequest (entityName:"EventEntry")
		let entries = managedObjectContext!.executeFetchRequest(fetch, error:nil) as! [EventEntry]
		for entry in entries {
			managedObjectContext?.deleteObject(entry)
		}
		
		var error: NSError?
		managedObjectContext?.save(&error)
	}
}