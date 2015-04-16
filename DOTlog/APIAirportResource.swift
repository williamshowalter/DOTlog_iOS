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

class APIAirportResource : APIResource {

	private let airportURI = "/dotlog/api/index.cfm/api/airports"
	private let httpMethod = "GET"
	private let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext

	private var APIAddressString = String()

	init (baseURLString base: String){
		APIAddressString = base + airportURI
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

	func getResourceIdentifier () -> String {
		return airportURI
	}

	func refreshLocalResource(webData: NSMutableData) -> NSError? {
		var error: NSError?
		let errorinfo = ["NSLocalizedDescriptionKey":"Bad data received for from airport resource \(getAPIAddressString())"]

		let data = JSON(data: webData, error: &error)["AIRPORTS"]

		if data.error == nil {
			var newAirports : [String] = []

			for (index,entry) in data {
				if let eventText = entry["FAA_CODE"].string {
					newAirports.append(eventText)
				}
				else {
					error = NSError (domain: "API Airport", code: 10, userInfo: errorinfo)
					return error
				}
			}

			if newAirports.count != 0 {
				deleteOld()
			}

			for airport in newAirports {
				let entityDescription = NSEntityDescription.entityForName("AirportEntry", inManagedObjectContext: managedObjectContext!)
				let newAirportEntry = AirportEntry(entity: entityDescription!, insertIntoManagedObjectContext: managedObjectContext)
				newAirportEntry.faa_code = airport

				managedObjectContext?.save(&error)
			}
		}
		else {
			error = NSError (domain: "API Airport", code: 11, userInfo: errorinfo)
		}

		return error
	}

	private func deleteOld() {
		let fetch = NSFetchRequest (entityName:"AirportEntry")
		let entries = managedObjectContext!.executeFetchRequest(fetch, error:nil) as! [AirportEntry]
		for entry in entries {
			managedObjectContext?.deleteObject(entry)
		}
	}
}