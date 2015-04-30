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

class ViewAddEventHub: UITableViewController {

	let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext

	var hubs : [String] = []
	var currentHub : String? = nil

	override func viewWillAppear(animated: Bool){
		super.viewWillAppear(animated)
		resetPage()
	}

	override func viewDidLoad() {
		super.viewDidLoad()

	}

	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return hubs.count
	}

	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		var cell : UITableViewCell?

		if hubs[indexPath.row] == currentHub {
			cell = tableView.dequeueReusableCellWithIdentifier("selectedHubCell") as! UITableViewCell?
		}
		else {
			cell = tableView.dequeueReusableCellWithIdentifier("hubCell") as! UITableViewCell?
		}

		cell?.textLabel?.text = hubs[indexPath.row]

		return cell!
	}

	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		let cell = self.tableView.cellForRowAtIndexPath(indexPath)
		currentHub = cell?.textLabel?.text
		performSegueWithIdentifier("SegueHubToAirport", sender: self)

	}

	func resetPage() {
		let categoryFetch = NSFetchRequest (entityName:"HubEntry")
		if let categoryResults = managedObjectContext!.executeFetchRequest(categoryFetch, error:nil) as? [CategoryEntry]{
			hubs = Array<String>() // Clear old array
			for category in categoryResults {
				hubs.append(category.category_title)
			}
		}
	}


	@IBAction func SaveCategory(sender: AnyObject) {

	}

	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		var destinationViewController = segue.destinationViewController as! ViewAddEvent

		if segue.identifier == "SegueHubToAirport" {
			// setup hub for airport selection
		}
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
}