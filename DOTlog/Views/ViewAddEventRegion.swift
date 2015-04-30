//
//  ViewAddEventRegion.swift
//  DOTlog
//
//  Created by William Showalter on 15/04/30.
//  Copyright (c) 2015 UAF CS Capstone 2015. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class ViewAddEventRegion: UITableViewController {

	let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext

	var regions : [String] = []
	var currentRegion : String? = nil

	override func viewWillAppear(animated: Bool){
		super.viewWillAppear(animated)
		resetPage()
	}

	override func viewDidLoad() {
		super.viewDidLoad()

	}

	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return regions.count
	}

	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		var cell : UITableViewCell?

		if regions[indexPath.row] == currentRegion {
			cell = tableView.dequeueReusableCellWithIdentifier("selectedRegionCell") as! UITableViewCell?
		}
		else {
			cell = tableView.dequeueReusableCellWithIdentifier("regionCell") as! UITableViewCell?
		}

		cell?.textLabel?.text = regions[indexPath.row]

		return cell!
	}

	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		let cell = self.tableView.cellForRowAtIndexPath(indexPath)
		currentRegion = cell?.textLabel?.text
		performSegueWithIdentifier("SegueRegionToDistrict", sender: self)

	}

	func resetPage() {
		let categoryFetch = NSFetchRequest (entityName:"RegionEntry")
		if let categoryResults = managedObjectContext!.executeFetchRequest(categoryFetch, error:nil) as? [CategoryEntry]{
			regions = Array<String>() // Clear old array
			for category in categoryResults {
				regions.append(category.category_title)
			}
		}
	}


	@IBAction func SaveCategory(sender: AnyObject) {

	}

	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		var destinationViewController = segue.destinationViewController as! ViewAddEvent

		if segue.identifier == "SegueRegionToDistrict" {
			// setup region for district selection
		}
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
}