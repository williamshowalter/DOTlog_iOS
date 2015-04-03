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

	@IBOutlet weak var eventTime: UITextField!
	@IBOutlet weak var logTime: UITextField!
	@IBOutlet weak var entryDescription: UITextField!
	@IBOutlet weak var userID: UITextField!
	@IBOutlet weak var airportID: UITextField!
	@IBOutlet weak var categoryID: UITextField!

	@IBOutlet weak var status: UILabel!

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}


}

