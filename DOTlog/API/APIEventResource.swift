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
	private var APIAddressString : String
	private let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext

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
		let events = eventJSONSerializer()

		return NSJSONSerialization.dataWithJSONObject(events, options: nil, error: nil)!
	}

	func getResourceIdentifier () -> String {
		return eventURI
	}

	func refreshLocalResource(webData: NSMutableData) -> NSError? {
		var error: NSError?

		deleteOld()
		return error
	}

	func eventJSONSerializer() -> Dictionary<String,AnyObject> {
		var serializedEvents : [Dictionary<String, AnyObject>] = []
		let fetchEvents = NSFetchRequest (entityName:"EventEntry")
		let events = managedObjectContext!.executeFetchRequest(fetchEvents, error:nil) as! [EventEntry]

		for event in events {
			var eventDateFormatter = NSDateFormatter()
			eventDateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
			let tempDate = eventDateFormatter.stringFromDate(event.event_time)

			let nextEvent : [String: AnyObject] = ["FAA_CODE":event.faa_code,"CATEGORY_TITLE":event.category_title, "IN_WEEKLY_REPORT": event.in_weekly_report.boolValue, "EVENT_TEXT":event.event_text, "EVENT_TIME":tempDate]

			serializedEvents.append(nextEvent)
		}
		return ["EVENTS":serializedEvents]
	}

	func deleteOld() {
		let fetch = NSFetchRequest (entityName:"EventEntry")
		let events = managedObjectContext!.executeFetchRequest(fetch, error:nil) as! [EventEntry]

		for event in events {
			managedObjectContext?.deleteObject(event)
		}
		managedObjectContext?.save(nil)
	}
}