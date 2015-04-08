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

class EntryList: UIViewController, UITableViewDelegate, UITableViewDataSource {

	@IBOutlet weak var entryTableView: UITableView!

	let managedObjectContext = (UIApplication.sharedApplication().delegate as AppDelegate).managedObjectContext

	var logEntries = [LogEntry]()

	override func viewDidLoad() {
		super.viewDidLoad()
		entryTableView.dataSource = self
		entryTableView.delegate = self
	}

	override func viewWillAppear(animated: Bool){
		super.viewWillAppear(animated)
		fetchLogs()
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
		let logsFetch = NSFetchRequest (entityName:"LogEntry")
		logEntries = managedObjectContext!.executeFetchRequest(logsFetch, error:nil) as [LogEntry]
	}

	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		var cell: UITableViewCell? = self.entryTableView.dequeueReusableCellWithIdentifier("LogEntry") as? UITableViewCell
		if cell == nil
		{
			cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "LogEntry")
		}
		let logEntry = logEntries[indexPath.row]
		cell!.detailTextLabel!.text = logEntry.faa_code + " - " + logEntry.category_title + " - " + logEntry.event_description
		return cell!

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