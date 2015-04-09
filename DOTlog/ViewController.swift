
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

	var baseURL : String = "http://dotlog.uafcsc.com"

	var airports : SyncAirports = SyncAirports(baseURLString: "/")
	var categories : SyncCategories = SyncCategories(baseURLString: "/")
	var events : SyncEvents = SyncEvents(baseURLString: "/")

	override func viewDidLoad() {
		super.viewDidLoad()

		airports = SyncAirports(baseURLString: baseURL)
		categories = SyncCategories(baseURLString: baseURL)
		events = SyncEvents(baseURLString: baseURL)

		airports.requestData()
		categories.requestData()
		events.sendData()
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	@IBOutlet weak var webView: UIWebView!

}

