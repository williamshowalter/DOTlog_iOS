
//
//  ViewController.swift
//  DOTlog
//
//  Created by William Showalter on 15/02/28.
//  Copyright (c) 2015 UAF CS Capstone 2015. All rights reserved.
//

import UIKit
import CoreData

let defaultBaseURL : String = "http://dotlog.uafcsc.com"

class ViewSync: UIViewController, UITextFieldDelegate, ErrorObserver {

	// This class is an ErrorObserver from the Observer design pattern
	// This allows the class to have subjects to keep references to the observer
	// and notify this viewcontroller with errors through the notify(NSError) function.
	// http://en.wikipedia.org/wiki/Observer_pattern

	let managedObjectContext =
	(UIApplication.sharedApplication().delegate
		as! AppDelegate).managedObjectContext

	@IBOutlet weak var UIFieldBaseURL: UITextField!
	@IBOutlet weak var UIFieldUsername: UITextField!
	@IBOutlet weak var UIFieldPassword: UITextField!

	@IBOutlet weak var UISyncIndicator: UIActivityIndicatorView!

	@IBOutlet weak var UISwitchRememberMe: UISwitch!

	var keychainObj = KeychainAccess()

	var airportResource = APIAirportResource(baseURLString: "/")
	var categoryResource = APICategoryResource(baseURLString: "/")
	var eventResource = APIEventResource(baseURLString: "/")
	var errorReceivedSinceLastSync = false

	override func viewDidLoad() {
		super.viewDidLoad()

		UISwitchRememberMe.on = false
		UISyncIndicator.stopAnimating()
		UISyncIndicator.hidesWhenStopped = true

		UIFieldBaseURL.text = defaultBaseURL
		// Populates URL, then replaces with remembered if present
		let URLFetch = NSFetchRequest (entityName:"SyncURLEntry")
		if let URLs = managedObjectContext!.executeFetchRequest(URLFetch, error:nil) as? [SyncURLEntry] {
			if URLs.count != 0 {
				UIFieldBaseURL.text = URLs[0].urlString
			}
		}

		if let username = keychainObj.getUsername(){
			UIFieldUsername.text = username;
			if username != "" {
				UISwitchRememberMe.on = true
			}
		}
		else {
			UIFieldUsername.text = "";
		}

		UIFieldPassword.secureTextEntry = true;
		if let password = keychainObj.getPassword(){
			UIFieldPassword.text = password;
			if password != "" {
				UISwitchRememberMe.on = true
			}
		}
		else {
			UIFieldPassword.text = "";
		}

	}

	func saveURL () {
		deleteOldURL()

		// Create new
		let entityDescription =
		NSEntityDescription.entityForName("SyncURLEntry",
			inManagedObjectContext: managedObjectContext!)

		let url = SyncURLEntry(entity: entityDescription!,
			insertIntoManagedObjectContext: managedObjectContext)

		url.urlString = UIFieldBaseURL.text

		var error: NSError?

		managedObjectContext?.save(&error)

		if let err = error {
			// eh
		} else {
			// eh
		}

	}

	func deleteOldURL () {
		// Delete old
		let fetch = NSFetchRequest (entityName:"SyncURLEntry")
		let entries = managedObjectContext!.executeFetchRequest(fetch, error:nil) as! [SyncURLEntry]
		for entry in entries {
			managedObjectContext?.deleteObject(entry)
		}
	}

	func syncResources() {
		errorReceivedSinceLastSync = false
		UISyncIndicator.startAnimating()

		airportResource = APIAirportResource(baseURLString: UIFieldBaseURL.text)
		categoryResource = APICategoryResource(baseURLString: UIFieldBaseURL.text)
		eventResource = APIEventResource(baseURLString: UIFieldBaseURL.text)

		var visitorObj = NetworkVisitor()
		visitorObj.setCreds(UIFieldUsername.text, pass: UIFieldPassword.text)
		visitorObj.registerObserver(self)
		airportResource.accept(visitorObj)

		visitorObj = NetworkVisitor()
		visitorObj.setCreds(UIFieldUsername.text, pass: UIFieldPassword.text)
		visitorObj.registerObserver(self)
		categoryResource.accept(visitorObj)

		visitorObj = NetworkVisitor()
		visitorObj.setCreds(UIFieldUsername.text, pass: UIFieldPassword.text)
		visitorObj.registerObserver(self)
		eventResource.accept(visitorObj)
	}

	func notify (error : NSError) {

		if !errorReceivedSinceLastSync {
			UISyncIndicator.stopAnimating()
			errorReceivedSinceLastSync = true

			let code = error.code

			var errorMessage = "Contact Regional Aviation Office."
			var errorDetailMessage = error.localizedDescription
			var errorTitle = "Error"
			var errorDetailTitle = "Error Code: \(code)"

			if let detailMessage : [NSObject : AnyObject] = error.userInfo {
				if let errorDetailMessageText = detailMessage["NSLocalizedDescriptionKey"] as? String {
					errorDetailMessage = "\(errorDetailMessageText)"
				}
			}

			if code == 401 {
				errorTitle = error.domain
				errorMessage = ""
			}

			if code == -1003 {
				errorTitle = "Bad URL" // Needs to match page wording
				errorMessage = "Please check Website URL"
			}

			let errorAlert = UIAlertController(title: errorTitle, message: errorMessage, preferredStyle: UIAlertControllerStyle.Alert)

			let errorAlertDetail = UIAlertController(title: errorDetailTitle, message: errorDetailMessage as String, preferredStyle: UIAlertControllerStyle.Alert)

			errorAlert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Cancel, handler:{ (ACTION :UIAlertAction!)in }))
			errorAlert.addAction(UIAlertAction(title: "Details", style: UIAlertActionStyle.Default, handler:{ (ACTION :UIAlertAction!)in self.presentViewController(errorAlertDetail, animated: true, completion: nil)}))
			errorAlertDetail.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Cancel, handler:{ (ACTION :UIAlertAction!)in }))

			self.presentViewController(errorAlert, animated: true, completion: nil)
		}

		UISyncIndicator.stopAnimating()
	}

	@IBAction func saveCredsButton(sender: AnyObject) {
		if UISwitchRememberMe.on {
			saveCreds()
			saveURL()
		}
		else {
			forgetCreds()
		}
	}

	func saveCreds () {
		keychainObj.setUsernamePassword(UIFieldUsername.text, pass: UIFieldPassword.text)
	}

	func forgetCreds () {
		UIFieldUsername.text = nil
		UIFieldPassword.text = nil
		saveCreds()
	}

	func notifyFinishSuccess() {
		self.UISyncIndicator.stopAnimating()
	}

	@IBAction func syncButton(sender: AnyObject) {
		saveURL ()
		if UISwitchRememberMe.on {
			saveCreds ()
		}
		syncResources ()
	}

	@IBAction func touchUIButtonForgetMe(sender: AnyObject) {
		forgetCreds()
		UISwitchRememberMe.on = false
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

}

