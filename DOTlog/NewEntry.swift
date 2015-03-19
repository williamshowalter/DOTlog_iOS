//
//  NewEntry.swift
//  DOTlog
//
//  Created by William Showalter on 15/03/18.
//  Copyright (c) 2015 UAF CS Capstone 2015. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class NewEntry: UIViewController, UITextFieldDelegate {

	let managedObjectContext = (UIApplication.sharedApplication().delegate as AppDelegate).managedObjectContext

	@IBOutlet weak var textCategory: UITextField!
	@IBOutlet weak var textEvent: UITextView!
	@IBOutlet weak var textEventTime: UITextField!
	@IBOutlet weak var textEventDate: UITextField!

	@IBAction func editEventTime(sender: UITextField) {

	}

	@IBAction func editEventDate(sender: UITextField) {
		
	}

	override func viewDidLoad() {
		super.viewDidLoad()
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	// Get rid of the keyboard
	override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
		self.view.endEditing(true);
	}
	
	func textFieldShouldReturn(textField: UITextField!) -> Bool {
		textField.resignFirstResponder();
		return true;
	}

	@IBAction func saveLogEntry(sender: AnyObject) {
		let entityDescription =
		NSEntityDescription.entityForName("LogEntry",
			inManagedObjectContext: managedObjectContext!)

		let logEntry = LogEntry(entity: entityDescription!,
			insertIntoManagedObjectContext: managedObjectContext)

		var error: NSError?

		managedObjectContext?.save(&error)

		if let err = error {
			// Error to label
		} else {
			// Clear fields
		}
	}

}