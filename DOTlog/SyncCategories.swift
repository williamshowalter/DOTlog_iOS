//
//  SyncCategories.swift
//  DOTlog
//
//  Created by William Showalter on 15/04/08.
//  Copyright (c) 2015 UAF CS Capstone 2015. All rights reserved.
//


import UIKit
import CoreData
import Foundation

class SyncCategories : NSObject, NSURLConnectionDelegate, SyncType {

	private let categoryURI = "/dotlog/api/index.cfm/api/categories"
	private let httpMethod = "GET"
	private let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext

	private var APIAddressString = String()

	init (baseURLString base: String){
		APIAddressString = base + categoryURI
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
		return NSData() // No sending data for Categories
	}

	func syncJSON(webData : NSMutableData) {
		let data = JSON(data: webData)
		var newEvents : [String] = []
		for (index,entry) in data["CATEGORIES"]{
			if let eventText = entry["CATEGORY_TITLE"].string {
				newEvents.append(eventText)
			}
			else {
				//self.presentViewController(apiAlert, animated: true, completion:nil) // CATEGORY SPECIFIC LINE
			}
		}

		deleteOld()

		for event in newEvents {
			let entityDescription = NSEntityDescription.entityForName("CategoryEntry", inManagedObjectContext: managedObjectContext!)
			let newEvent = CategoryEntry(entity: entityDescription!, insertIntoManagedObjectContext: managedObjectContext)
			newEvent.category_title = event
			var error: NSError?

			managedObjectContext?.save(&error)
		}
	}

	private func deleteOld() {
		let fetch = NSFetchRequest (entityName:"CategoryEntry")
		let entries = managedObjectContext!.executeFetchRequest(fetch, error:nil) as! [CategoryEntry]
		for entry in entries {
			managedObjectContext?.deleteObject(entry)
		}
	}
}