
//
//  ViewController.swift
//  DOTlog
//
//  Created by William Showalter on 15/02/28.
//  Copyright (c) 2015 UAF CS Capstone 2015. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {

	let managedObjectContext =
		(UIApplication.sharedApplication().delegate
				as AppDelegate).managedObjectContext

	var webData = NSMutableData()
	var baseurl = NSURL()

	override func viewDidLoad() {
		super.viewDidLoad()

		// PROOF OF CONCEPT - not final
		let username = "USERNAME"
		let password = "PASS"

		//let url = NSURL (string: "http://" + username + ":" + password + "@dotlog.uafcsc.com/dotlog/pages/")
		let baseurl = NSURL (string: "http://dotlog.uafcsc.com/dotlog/pages/")
		let requestObj = NSMutableURLRequest (URL: baseurl!)
		let initRequest = NSURLConnection(request: requestObj, delegate:self, startImmediately:true)
	}

	func connection(connection: NSURLConnection, willSendRequestForAuthenticationChallenge challenge: NSURLAuthenticationChallenge){
		if (challenge.previousFailureCount != 0){
			// Previous failures
			challenge.sender.cancelAuthenticationChallenge(challenge)
		}
		else {
			let credential = NSURLCredential (user: "Administrator",
											password: "dotSERVER1",
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
		webView.loadData(webData, MIMEType: "text/html", textEncodingName: "UTF-8", baseURL:baseurl)
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	@IBOutlet weak var webView: UIWebView!

}

