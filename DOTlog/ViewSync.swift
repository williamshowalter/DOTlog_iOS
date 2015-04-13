
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


	let apiAlert = UIAlertController(title: "Contact IT", message: "Error: DOTlog API Unexpected Data from Webserver. Error must be resolved with IT before sync.", preferredStyle: .Alert)


	@IBOutlet weak var textBaseURL: UITextField!
	@IBOutlet weak var textUsername: UITextField!
	@IBOutlet weak var textPassword: UITextField!

	let managedObjectContext =
		(UIApplication.sharedApplication().delegate
				as! AppDelegate).managedObjectContext

	var baseURL : String = "http://dotlog.uafcsc.com"

	var airportResource = APIAirportResource(baseURLString: "/")
	var categoryResource = APICategoryResource(baseURLString: "/")
	var eventResource = APIEventResource(baseURLString: "/")

	var keychainObj = KeychainAccess()

	override func viewDidLoad() {
		super.viewDidLoad()

		textBaseURL.text = baseURL
		if let username = keychainObj.getUsername(){
			textUsername.text = username;
		}
		else {
			textUsername.text = "";
		}

		textPassword.secureTextEntry = true;
		if let password = keychainObj.getPassword(){
			textPassword.text = password;
		}
		else {
			textPassword.text = "";
		}
	}

	func sync() {
		airportResource = APIAirportResource(baseURLString: baseURL)
		categoryResource = APICategoryResource(baseURLString: baseURL)
		eventResource = APIEventResource(baseURLString: textBaseURL.text)

		var visitorObj = NetworkVisitor()

		airportResource.accept(visitorObj)
		visitorObj = NetworkVisitor()
		categoryResource.accept(visitorObj)
		visitorObj = NetworkVisitor()
		eventResource.accept(visitorObj)
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
	func textFieldShouldReturn(textField: UITextField) -> Bool {
		textField.resignFirstResponder();
		return true;
	}

	@IBOutlet weak var webView: UIWebView!

}

