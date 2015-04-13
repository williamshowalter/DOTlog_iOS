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

class ViewEntryList: UIViewController, UITableViewDelegate, UITableViewDataSource {

	@IBOutlet weak var entryTableView: UITableView!

	let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext

	var eventEntries = [EventEntry]()

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

	func fetchLogs(){
		let logsFetch = NSFetchRequest (entityName:"EventEntry")
		eventEntries = managedObjectContext!.executeFetchRequest(logsFetch, error:nil) as! [EventEntry]
	}

	// Functions for UITableViewDataSources
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return eventEntries.count;
	}

	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		var newCell : UITableViewCell? = tableView.dequeueReusableCellWithIdentifier("EventEntry") as? UITableViewCell

		if newCell == nil {
			newCell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "EventEntry")
		}

		let eventEntry = eventEntries[indexPath.row]
		newCell!.detailTextLabel!.text = eventEntry.faa_code + " - " + eventEntry.category_title + " - " + eventEntry.event_text
		return newCell!
	}

	func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
		if editingStyle == UITableViewCellEditingStyle.Delete {

			let entryToDelete = eventEntries[indexPath.row]
			managedObjectContext?.deleteObject(entryToDelete)

			eventEntries.removeAtIndex(indexPath.row)
			tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
		}
	}

}