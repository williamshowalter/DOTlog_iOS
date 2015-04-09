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

class SyncCategories {

	var webData = NSMutableData ()
	var URLString = String()
	var URLObj = NSURL()
	var finishedLoading : Bool = false
	var apiURI = "/dotlog/api/index.cfm/api/categories"

	let managedObjectContext =
	(UIApplication.sharedApplication().delegate
		as AppDelegate).managedObjectContext

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
			let credential = NSURLCredential (user: "user",
				password: "password",
				persistence: NSURLCredentialPersistence.ForSession)
			challenge.sender.useCredential(credential, forAuthenticationChallenge: challenge)
		}

	}

	func connection(connection: NSURLConnection, didReceiveData data: NSData){
		webData.appendData(data)
	}

	func connection(connection: NSURLConnection, didReceiveResponse response: NSURLResponse){
		webData = NSMutableData ()
	}

	func connectionDidFinishLoading(connection : NSURLConnection){
		finishedLoading = true
	}

	func requestData() {
		let request = NSMutableURLRequest (URL: URLObj)
		request.HTTPMethod = "GET"
		let initRequest = NSURLConnection(request: request, delegate:self, startImmediately:true)
	}

	func syncJSON() {
		let categoryData = JSON(data: webData)
		var newCategories : [String] = []
		for (index,category) in categoryData["CATEGORIES"]{
			newCategories.append(category["CATEGORY_TITLE"].string!)
		}

		deleteOld()

		for title in newCategories {
			let categoryEntityDescription = NSEntityDescription.entityForName("categoryEntry",
				inManagedObjectContext: managedObjectContext!)
			let newCategory = CategoryEntry(entity: categoryEntityDescription!,
				insertIntoManagedObjectContext: managedObjectContext)
			newCategory.category_title = title
			var error: NSError?

			managedObjectContext?.save(&error)
		}
	}

	func deleteOld() {
		let fetchCategories = NSFetchRequest (entityName:"CategoryEntry")
		let categoryEntries = managedObjectContext!.executeFetchRequest(fetchCategories, error:nil) as [CategoryEntry]

		for entry in categoryEntries {
			managedObjectContext?.deleteObject(entry)
		}
	}
}