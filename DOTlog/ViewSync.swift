
//
//  ViewController.swift
//  DOTlog
//
//  Created by William Showalter on 15/02/28.
//  Copyright (c) 2015 UAF CS Capstone 2015. All rights reserved.
//

import UIKit
import CoreData

class ViewSync: UIViewController, UITextFieldDelegate {

	let APIAlert = UIAlertController(title: "Contact IT", message: "Error: DOTlog API Unexpected Data from Webserver. Error must be resolved with IT before sync.", preferredStyle: .Alert)
	let managedObjectContext =
	(UIApplication.sharedApplication().delegate
		as! AppDelegate).managedObjectContext
	let defaultBaseURL : String = "http://dotlog.uafcsc.com"

	@IBOutlet weak var UIFieldBaseURL: UITextField!
	@IBOutlet weak var UIFieldUsername: UITextField!
	@IBOutlet weak var UIFieldPassword: UITextField!

	var keychainObj = KeychainAccess()

	var airportResource = APIAirportResource(baseURLString: "/")
	var categoryResource = APICategoryResource(baseURLString: "/")
	var eventResource = APIEventResource(baseURLString: "/")

	override func viewDidLoad() {
		super.viewDidLoad()

		UIFieldBaseURL.text = defaultBaseURL
		if let username = keychainObj.getUsername(){
			UIFieldUsername.text = username;
		}
		else {
			UIFieldUsername.text = "";
		}

		UIFieldPassword.secureTextEntry = true;
		if let password = keychainObj.getPassword(){
			UIFieldPassword.text = password;
		}
		else {
			UIFieldPassword.text = "";
		}
	}

	func syncResources() {
		airportResource = APIAirportResource(baseURLString: UIFieldBaseURL.text)
		categoryResource = APICategoryResource(baseURLString: UIFieldBaseURL.text)
		eventResource = APIEventResource(baseURLString: UIFieldBaseURL.text)

		var visitorObj = NetworkVisitor()

		airportResource.accept(visitorObj)
		visitorObj = NetworkVisitor()
		categoryResource.accept(visitorObj)
		visitorObj = NetworkVisitor()
		eventResource.accept(visitorObj)
	}

	@IBAction func syncButton(sender: AnyObject) {
		keychainObj.setUsernamePassword(UIFieldUsername.text, pass: UIFieldPassword.text)
		syncResources()
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
	func textFieldShouldReturn(textField: UITextField) -> Bool {
		textField.resignFirstResponder();
		return true;
	}

	@IBOutlet weak var webView: UIWebView!

}

