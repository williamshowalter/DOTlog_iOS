//
//  ViewAddEventAirport.swift
//  DOTlog
//
//  Created by William Showalter on 15/04/30.
//  Copyright (c) 2015 UAF CS Capstone 2015. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class ViewAddEventAirport: UITableViewController {

	let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext

	var airports : [String] = []
	var currentAirport : String? = nil

	override func viewWillAppear(animated: Bool){
		super.viewWillAppear(animated)
		resetPage()
	}

	override func viewDidLoad() {
		super.viewDidLoad()

	}

	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return airports.count
	}

	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		var cell : UITableViewCell?

		if airports[indexPath.row] == currentAirport {
			cell = tableView.dequeueReusableCellWithIdentifier("selectedAirportCell") as! UITableViewCell?
		}
		else {
			cell = tableView.dequeueReusableCellWithIdentifier("airportCell") as! UITableViewCell?
		}

		cell?.textLabel?.text = airports[indexPath.row]

		return cell!
	}

	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		let cell = self.tableView.cellForRowAtIndexPath(indexPath)
		currentAirport = cell?.textLabel?.text
		//performSegueWithIdentifier("SegueAirportToDistrict", sender: self)

	}

	func resetPage() {
		let categoryFetch = NSFetchRequest (entityName:"AirportEntry")
		if let categoryResults = managedObjectContext!.executeFetchRequest(categoryFetch, error:nil) as? [CategoryEntry]{
			airports = Array<String>() // Clear old array
			for category in categoryResults {
				airports.append(category.category_title)
			}
		}
	}


	@IBAction func SaveCategory(sender: AnyObject) {

	}

	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		var destinationViewController = segue.destinationViewController as! ViewAddEvent

		// different
		if segue.identifier == "SegueAirportToDistrict" {
			// setup airport for district selection
		}
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
}