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

class SyncCategories : NSObject, NSURLConnectionDelegate {

	var finishedLoading : Bool = false

	private var webData = NSMutableData ()
	private var URLString = String()
	private var URLObj = NSURL()
	private var apiURI = "/dotlog/api/index.cfm/api/categories"   // CATEGORY SPECIFIC LINE

	private var keychainObj = KeychainAccess()

	private let managedObjectContext = (UIApplication.sharedApplication().delegate as AppDelegate).managedObjectContext

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

	func connection(connection: NSURLConnection, didReceiveData data: NSData){
		webData.appendData(data)
	}

	func connection(connection: NSURLConnection, didReceiveResponse response: NSURLResponse){
		webData = NSMutableData ()
	}

	func connectionDidFinishLoading(connection : NSURLConnection){
		finishedLoading = true
		syncJSON()
	}

	func connection(connection: NSURLConnection, didFailWithError error: NSError){
		println("Connection Error in Sync")
	}

	func connectionShouldUseCredentialStorage(connection: NSURLConnection) -> Bool {
		return false
	}

	func requestData() {
		finishedLoading = false
		let request = NSMutableURLRequest (URL: URLObj)
		request.HTTPMethod = "GET"
		let initRequest = NSURLConnection(request: request, delegate:self, startImmediately:true)!
	}

	private func syncJSON() {
		let data = JSON(data: webData)
		var newEntries : [String] = []
		for (index,entry) in data["CATEGORIES"]{   // CATEGORY SPECIFIC LINE
			newEntries.append(entry["CATEGORY_TITLE"].string!)  // CATEGORY SPECIFIC LINE
		}

		deleteOld()

		for entry in newEntries {
			let entityDescription = NSEntityDescription.entityForName("CategoryEntry", inManagedObjectContext: managedObjectContext!)   // CATEGORY SPECIFIC LINE
			let newEntry = CategoryEntry(entity: entityDescription!, insertIntoManagedObjectContext: managedObjectContext)  // CATEGORY SPECIFIC LINE
			newEntry.category_title = entry   // CATEGORY SPECIFIC LINE
			var error: NSError?

			managedObjectContext?.save(&error)
		}
	}

	private func deleteOld() {
		let fetch = NSFetchRequest (entityName:"CategoryEntry")  // CATEGORY SPECIFIC LINE
		let entries = managedObjectContext!.executeFetchRequest(fetch, error:nil) as [CategoryEntry]  // CATEGORY SPECIFIC LINE
		for entry in entries {
			managedObjectContext?.deleteObject(entry)
		}
	}
}