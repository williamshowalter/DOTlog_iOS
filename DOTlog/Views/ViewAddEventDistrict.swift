//
//  ViewAddEventHub.swift
//  DOTlog
//
//  Created by William Showalter on 15/04/30.
//  Copyright (c) 2015 UAF CS Capstone 2015. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class ViewAddEventDistrict: UITableViewController {

	let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext

	var districts : [String] = []
	var currentDistrict : String? = nil

	override func viewWillAppear(animated: Bool){
		super.viewWillAppear(animated)
		resetPage()
	}

	override func viewDidLoad() {
		super.viewDidLoad()

	}

	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return districts.count
	}

	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		var cell : UITableViewCell?

		if districts[indexPath.row] == currentDistrict {
			cell = tableView.dequeueReusableCellWithIdentifier("selectedDistrictCell") as! UITableViewCell?
		}
		else {
			cell = tableView.dequeueReusableCellWithIdentifier("districtCell") as! UITableViewCell?
		}

		cell?.textLabel?.text = districts[indexPath.row]

		return cell!
	}

	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		let cell = self.tableView.cellForRowAtIndexPath(indexPath)
		currentDistrict = cell?.textLabel?.text
		performSegueWithIdentifier("SegueDistrictToHub", sender: self)

	}

	func resetPage() {
		let categoryFetch = NSFetchRequest (entityName:"DistrictEntry")
		if let categoryResults = managedObjectContext!.executeFetchRequest(categoryFetch, error:nil) as? [CategoryEntry]{
			districts = Array<String>() // Clear old array
			for category in categoryResults {
				districts.append(category.category_title)
			}
		}
	}


	@IBAction func SaveCategory(sender: AnyObject) {

	}

	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		var destinationViewController = segue.destinationViewController as! ViewAddEvent

		if segue.identifier == "SegueDistrictToHub" {
			// setup district for district selection
		}
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
}