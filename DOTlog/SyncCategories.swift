//
//  SyncCategories.swift
//  DOTlog
//
//  Created by William Showalter on 15/04/08.
//  Copyright (c) 2015 UAF CS Capstone 2015. All rights reserved.
//

import Foundation

class SyncCategories {

	var webData = NSMutableData ()
	var activeURL = NSURL()
	var finishedLoading : Bool = false
	// Write constructor for things

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

}