
//
//  ViewController.swift
//  DOTlog
//
//  Created by William Showalter on 15/02/28.
//  Copyright (c) 2015 UAF CS Capstone 2015. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITextFieldDelegate {

	@IBOutlet weak var textBaseURL: UITextField!
	@IBOutlet weak var textUsername: UITextField!
	@IBOutlet weak var textPassword: UITextField!

	let managedObjectContext =
		(UIApplication.sharedApplication().delegate
				as! AppDelegate).managedObjectContext

	var baseURL : String = "http://dotlog.uafcsc.com"

	var airports : SyncAirports = SyncAirports(baseURLString: "/")
	var categories : SyncCategories = SyncCategories(baseURLString: "/")
	var events : SyncEvents = SyncEvents(baseURLString: "/")

	var keychainObj = KeychainAccess()

	override func viewDidLoad() {
		super.viewDidLoad()

		textBaseURL.text = baseURL
		//textUsername.text = keychainObj.getUsername()
		textPassword.secureTextEntry = true;
		//textPassword.text = keychainObj.getPassword()
	}

	func sync() {
		airports = SyncAirports(baseURLString: baseURL)
		categories = SyncCategories(baseURLString: baseURL)
		events = SyncEvents(baseURLString: textBaseURL.text)

		airports.requestData()
		categories.requestData()
		events.sendData()
	}

	@IBAction func syncButton(sender: AnyObject) {
		keychainObj.setUsernamePassword(textUsername.text, pass: textPassword.text)
		baseURL = textBaseURL.text
		sync()
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	// Get rid of the keyboard when touching outside
	override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
		self.view.endEditing(true);
	}
	// Get rid of keyboard when hitting return
	func textFieldShouldReturn(textField: UITextField!) -> Bool {
		textField.resignFirstResponder();
		return true;
	}

	@IBOutlet weak var webView: UIWebView!

}

