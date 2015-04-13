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

	private var webData = NSMutableData ()
	private var URLObj = NSURL()
	private var keychainObj = KeychainAccess()
	private var _APIObj : APIResource?

	private let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext

	let apiAlert = UIAlertController(title: "Contact IT", message: "Error: DOTlog API Unexpected Data from Webserver. Error must be resolved with IT before sync.", preferredStyle: .Alert)

	func visit (APIObj : APIResource){
		_APIObj = APIObj
		URLObj = NSURL(string: _APIObj!.getAPIAddressString())!
		self.requestData()
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
		_APIObj!.syncJSON(webData)
	}

	func connection(connection: NSURLConnection, didFailWithError error: NSError){
		println("Connection Error in Sync")
	}

	func connectionShouldUseCredentialStorage(connection: NSURLConnection) -> Bool {
		return false
	}

	func requestData() {
		let request = NSMutableURLRequest (URL: URLObj)
		request.HTTPMethod = _APIObj!.getMethod()
		request.HTTPBody = _APIObj!.getBody()
		request.addValue("application/json", forHTTPHeaderField: "Content-Type")
		request.addValue("application/json", forHTTPHeaderField: "Accept")

		let initRequest = NSURLConnection(request: request, delegate:self, startImmediately:true)!
	}

}