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

class APICategoryResource : APIResource {

	// *******  DOT MAY HAVE TO UPDATE BASED ON DOTLOG INSTALLATION DIRECTORY STRUCTURE  ******* //
	private let categoryURI = "/dotlog/api/index.cfm/api/categories"
	// *******  DOT MAY HAVE TO UPDATE BASED ON DOTLOG INSTALLATION DIRECTORY STRUCTURE  ******* //

	private let httpMethod = "GET"
	private var APIAddressString = String()
	private let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext


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

	func getBody() -> NSData? {
		return nil
	}

	func getResourceIdentifier () -> String {
		return categoryURI
	}

	func refreshLocalResource(webData: NSMutableData)  -> NSError? {
		var error: NSError?
		let errorinfo = ["NSLocalizedDescriptionKey":"Bad data received for from category resource \(getAPIAddressString())"]

		let data = JSON(data: webData)["CATEGORIES"]

		if data.error == nil {
			var receivedCategories : [String] = []
			for (index,category) in data{
				if let categoryText = category["CATEGORY_TITLE"].string {
					receivedCategories.append(categoryText)
				}
				else {
					error = NSError (domain: "API Category", code: 21, userInfo: errorinfo)
					return error
				}
			}

			if receivedCategories.count != 0 {
				deleteOld()
			}

			for category in receivedCategories {
				let categoryDescription = NSEntityDescription.entityForName("CategoryEntry", inManagedObjectContext: managedObjectContext!)
				let receivedCategoryEntry = CategoryEntry(entity: categoryDescription!, insertIntoManagedObjectContext: managedObjectContext)
				receivedCategoryEntry.category_title = category

				managedObjectContext?.save(&error)
			}
		}
		else {
			error = NSError (domain: "API Category", code: 20, userInfo: errorinfo)
		}

		return error
	}

	private func deleteOld() {
		let fetch = NSFetchRequest (entityName:"CategoryEntry")
		let categories = managedObjectContext!.executeFetchRequest(fetch, error:nil) as! [CategoryEntry]
		for category in categories {
			managedObjectContext?.deleteObject(category)
		}
	}
}