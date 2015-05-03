//
//  ViewSyncCredentials.swift
//  DOTlog
//
//  Created by William Showalter on 15/04/21.
//  Copyright (c) 2015 UAF CS Capstone 2015. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class ViewSyncCredentials: UITableViewController {

	let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
	var keychainObj = KeychainAccess()

	@IBOutlet weak var UIFieldUsername: UITextField!

	@IBOutlet weak var UIFieldPassword: UITextField!

	@IBOutlet weak var UISwitchRememberMe: UISwitch!

	override func viewWillAppear(animated: Bool){
		super.viewWillAppear(animated)
	}

	override func viewDidLoad() {
		super.viewDidLoad()

	}

	@IBAction func ButtonLogin(sender: AnyObject) {
		if UISwitchRememberMe.on {
			saveCreds()
		}
		performSegueWithIdentifier("SegueEnterCredsToEventList", sender: self)
	}

	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if segue.identifier == "SegueEnterCredsToEventList" {
			var destinationViewController = segue.destinationViewController as! ViewEventList

			destinationViewController.syncManagerObj.runSync(UIFieldUsername.text!, password: UIFieldPassword.text!, baseURL: destinationViewController.baseURL!, observer: destinationViewController)

		}
	}

	// COPIED FROM VIEWACCOUNTSETTINGS - REFACTOR
	func saveCreds () {
		println(keychainObj.setUsernamePassword(UIFieldUsername.text, pass: UIFieldPassword.text))
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
}