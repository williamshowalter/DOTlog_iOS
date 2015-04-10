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

class SyncEvents : NSObject, NSURLConnectionDelegate {

	private var webData = NSMutableData ()
	private var URLString = String()
	private var URLObj = NSURL()
	private var apiURI = "/dotlog/api/index.cfm/api/events"   // EVENT SPECIFIC LINE

	private var keychainObj = KeychainAccess()

	private let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext

	init (baseURLString base: String){
		URLString = base + apiURI
		URLObj = NSURL(string: URLString)!
	}

	func connection(connection: NSURLConnection, willSendRequestForAuthenticationChallenge challenge: NSURLAuthenticationChallenge){
		if (challenge.previousFailureCount != 0){
			// Previous failures
			challenge.sender.cancelAuthenticationChallenge(challenge)
		}
		else {
			let credential = NSURLCredential (user: keychainObj.getUsername(),
				password: keychainObj.getPassword(),
				persistence: NSURLCredentialPersistence.ForSession)
			challenge.sender.useCredential(credential, forAuthenticationChallenge: challenge)
		}
	}

	func sendData() {
		let events = eventJSONBuilder()

		var options = NSJSONWritingOptions.PrettyPrinted
		var jsonData : NSData = NSJSONSerialization.dataWithJSONObject(events, options: options, error: nil)!

		//jsonData = NSString(data: data, encoding: NSUTF8StringEncoding)!   example string conversion for verifying

		let requestObj = NSMutableURLRequest (URL: URLObj)
		requestObj.HTTPMethod = "PUT"
		requestObj.HTTPBody = jsonData
		requestObj.addValue("application/json", forHTTPHeaderField: "Content-Type")
		requestObj.addValue("application/json", forHTTPHeaderField: "Accept")

		if let initRequest = NSURLConnection(request: requestObj, delegate:self, startImmediately:true) {
			deleteOld()
		}
	}

	func eventJSONBuilder() -> Dictionary<String,AnyObject> {
		var events : [Dictionary<String, AnyObject>] = []
		let fetchEvents = NSFetchRequest (entityName:"LogEntry")
		let eventEntries = managedObjectContext!.executeFetchRequest(fetchEvents, error:nil) as! [LogEntry]

		for entry in eventEntries {
			var dateFormatter = NSDateFormatter()
			dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
			let tempDate = dateFormatter.stringFromDate(entry.event_time)

			let temp : [String: AnyObject] = ["airport_code":entry.faa_code,"category_title":entry.category_title, "in_weekly_report":entry.in_weekly_report.boolValue,"event_text":entry.event_description,	"event_time":tempDate]

			events.append(temp)
		}
		return ["events":events]
	}

	private func deleteOld() {
		let fetch = NSFetchRequest (entityName:"LogEntry")   // LOG SPECIFIC LINE
		let entries = managedObjectContext!.executeFetchRequest(fetch, error:nil) as! [LogEntry]  // LOG SPECIFIC LINE
		for entry in entries {
			managedObjectContext?.deleteObject(entry)
		}
	}
}