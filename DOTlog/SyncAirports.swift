//
//  SyncAirports.swift
//  DOTlog
//
//  Created by William Showalter on 15/04/08.
//  Copyright (c) 2015 UAF CS Capstone 2015. All rights reserved.
//

import UIKit
import CoreData
import Foundation

class SyncAirports : NSObject, NSURLConnectionDelegate, SyncType {

	private let apiURI = "/dotlog/api/index.cfm/api/airports"
	private let httpMethod = "GET"
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
		return NSData() // No sending data for Airports
	}

	func syncJSON(webData : NSMutableData) {
		let data = JSON(data: webData)
		var newEntries : [String] = []
		for (index,entry) in data["AIRPORTS"]{
			newEntries.append(entry["FAA_CODE"].string!)
		}

		if newEntries.count != 0{
			deleteOld()
		}

		for entry in newEntries {
			let entityDescription = NSEntityDescription.entityForName("AirportEntry", inManagedObjectContext: managedObjectContext!)
			let newEntry = AirportEntry(entity: entityDescription!, insertIntoManagedObjectContext: managedObjectContext)
			newEntry.faa_code = entry
			var error: NSError?

			managedObjectContext?.save(&error)
		}
	}

	private func deleteOld() {
		let fetch = NSFetchRequest (entityName:"AirportEntry")
		let entries = managedObjectContext!.executeFetchRequest(fetch, error:nil) as! [AirportEntry]
		for entry in entries {
			managedObjectContext?.deleteObject(entry)
		}
	}
}