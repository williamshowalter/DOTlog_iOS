//
//  SyncManager.swift
//  DOTlog
//
//  Created by William Showalter on 15/04/21.
//  Copyright (c) 2015 UAF CS Capstone 2015. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class SyncManager {

	let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext

	var airportResource = APIAirportResource(baseURLString: "/")
	var categoryResource = APICategoryResource(baseURLString: "/")
	var eventResource = APIEventResource(baseURLString: "/")
	var activeResourceSyncCount : Int = 0

	func runSync(username: String, password: String, baseURL: String, observer : ErrorObserver) {
		airportResource = APIAirportResource(baseURLString: baseURL)
		categoryResource = APICategoryResource(baseURLString: baseURL)
		eventResource = APIEventResource(baseURLString: baseURL)

		let baseOptions = SyncOptions(resource: nil, username: username, password: password, baseURL: baseURL, observer: observer)
		var airportOptions = baseOptions; airportOptions.resource = airportResource
		var categoryOptions = baseOptions; categoryOptions.resource = airportResource
		var eventOptions = baseOptions; eventOptions.resource = airportResource

		newResourceSync(airportOptions)
		newResourceSync(categoryOptions)
		newResourceSync(eventOptions)
	}

	func newResourceSync(options: SyncOptions) {
		var networkVisitorObj = NetworkVisitor()
		networkVisitorObj.setCreds(options.username, pass: options.password)
		networkVisitorObj.registerObserver(options.observer)
		activeResourceSyncCount++
		options.resource?.accept(networkVisitorObj)
	}

	func getActiveSyncCount() -> Int {
		return activeResourceSyncCount
	}

	func reduceActiveSyncCount() {
		if activeResourceSyncCount != 0 {
			--activeResourceSyncCount
		}
	}
}

struct SyncOptions {
	var resource : APIResource?
	var username: String
	var password: String
	var baseURL: String
	var observer: ErrorObserver
}