//
//  LogEntry.swift
//  DOTlog
//
//  Created by William Showalter on 15/02/28.
//  Copyright (c) 2015 UAF CS Capstone 2015. All rights reserved.
//

import Foundation
import CoreData

class LogEntry: NSManagedObject {

    @NSManaged var userID: NSNumber
    @NSManaged var airportID: NSNumber
    @NSManaged var entryDescription: String
    @NSManaged var categoryID: NSNumber
    @NSManaged var timeStamp: NSDate
    @NSManaged var timeEvent: NSDate

}
