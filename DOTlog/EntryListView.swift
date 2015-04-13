//
//  EntryList.swift
//  DOTlog
//
//  Created by William Showalter on 15/03/18.
//  Copyright (c) 2015 UAF CS Capstone 2015. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class EntryListView: UIViewController, UITableViewDelegate, UITableViewDataSource {

	@IBOutlet weak var entryTableView: UITableView!

	let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext

	var logEntries = [EventEntry]()

	override func viewDidLoad() {
		super.viewDidLoad()
		entryTableView.dataSource = self
		entryTableView.delegate = self
	}

	override func viewWillAppear(animated: Bool){
		super.viewWillAppear(animated)
		fetchLogs()
		self.entryTableView.reloadData()
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	// Functions for UITableViewDataSources
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return logEntries.count;
	}

	func fetchLogs(){
		let logsFetch = NSFetchRequest (entityName:"EventEntry")
		logEntries = managedObjectContext!.executeFetchRequest(logsFetch, error:nil) as! [EventEntry]
	}

	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		var newCell : UITableViewCell? = tableView.dequeueReusableCellWithIdentifier("EventEntry") as? UITableViewCell

		if newCell == nil {
			newCell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "EventEntry")
		}

		let logEntry = logEntries[indexPath.row]
		newCell!.detailTextLabel!.text = logEntry.faa_code + " - " + logEntry.category_title + " - " + logEntry.event_description
		return newCell!
	}

	func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
		if editingStyle == UITableViewCellEditingStyle.Delete {

			let entryToDelete = logEntries[indexPath.row]
			managedObjectContext?.deleteObject(entryToDelete)

			logEntries.removeAtIndex(indexPath.row)
			tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
		}
	}

}