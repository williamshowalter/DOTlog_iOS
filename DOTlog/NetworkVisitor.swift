//
//  NetworkVisitor.swift
//  DOTlog
//
//  Created by William Showalter on 15/04/12.
//  Copyright (c) 2015 UAF CS Capstone 2015. All rights reserved.
//

import UIKit
import CoreData
import Foundation

class NetworkVisitor : NSObject, NSURLConnectionDelegate {

	// This class is an implementation of the visitor design pattern
	// This allows all the API requests to share a common network interface
	// http://en.wikipedia.org/wiki/Visitor_pattern

	private var webData = NSMutableData ()
	private var URLObj = NSURL()
	private var keychainObj = KeychainAccess()
	private var APIClient : APIResource?

	private let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext

	func visit (APIObj : APIResource){
		APIClient = APIObj
		URLObj = NSURL(string: APIClient!.getAPIAddressString())!
		self.resourceRequest()
	}

	func connection(connection: NSURLConnection, willSendRequestForAuthenticationChallenge challenge: NSURLAuthenticationChallenge){
		if (challenge.previousFailureCount != 0){
			// Previous failures
			challenge.sender.cancelAuthenticationChallenge(challenge)
		}
		else {
			let credential = NSURLCredential (user: keychainObj.getUsername()!,
				password: keychainObj.getPassword()!,
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
		APIClient!.refreshLocalResource(webData)
	}

	func connection(connection: NSURLConnection, didFailWithError error: NSError){
		println("Connection Error in Sync")
	}

	func connectionShouldUseCredentialStorage(connection: NSURLConnection) -> Bool {
		return false
	}

	func resourceRequest() {
		let request = NSMutableURLRequest (URL: URLObj)
		request.HTTPMethod = APIClient!.getMethod()
		request.HTTPBody = APIClient!.getBody()
		request.addValue("application/json", forHTTPHeaderField: "Content-Type")
		request.addValue("application/json", forHTTPHeaderField: "Accept")

		let initRequest = NSURLConnection(request: request, delegate:self, startImmediately:true)!
	}

}