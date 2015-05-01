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
	var activeSyncCounter : Int = 0

	func runSync(username: String, password: String, baseURL: String, observer : ErrorObserver) {
		airportResource = APIAirportResource(baseURLString: baseURL)
		categoryResource = APICategoryResource(baseURLString: baseURL)
		eventResource = APIEventResource(baseURLString: baseURL)

		var visitorObj = NetworkVisitor()
		visitorObj.setCreds(username, pass: password)
		visitorObj.registerObserver(observer)
		activeSyncCounter++
		airportResource.accept(visitorObj)

		visitorObj = NetworkVisitor()
		visitorObj.setCreds(username, pass: password)
		visitorObj.registerObserver(observer)
		activeSyncCounter++
		categoryResource.accept(visitorObj)

		visitorObj = NetworkVisitor()
		visitorObj.setCreds(username, pass: password)
		visitorObj.registerObserver(observer)
		activeSyncCounter++
		eventResource.accept(visitorObj)
	}

	func getActiveSyncCount() -> Int {
		return activeSyncCounter
	}

	func reduceActiveSyncCount() {
		if activeSyncCounter != 0 {
			--activeSyncCounter
		}
	}

}