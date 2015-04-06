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

	override func viewDidLoad() {
		super.viewDidLoad()

		// PROOF OF CONCEPT - not final
		let username = "USERNAME"
		let password = "PASS"

		let url = NSURL (string: "http://" + username + ":" + password + "@dotlog.uafcsc.com/dotlog/pages/")
		let requestObj = NSMutableURLRequest (URL: url!)
		webView.loadRequest(requestObj)
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	@IBOutlet weak var webView: UIWebView!

}

