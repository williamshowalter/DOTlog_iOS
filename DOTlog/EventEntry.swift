//
//  DOTlog.swift
//  DOTlog
//
//  Created by William Showalter on 15/04/05.
//  Copyright (c) 2015 UAF CS Capstone 2015. All rights reserved.
//

import Foundation
import CoreData

class EventEntry: NSManagedObject {

    @NSManaged var faa_code: String
    @NSManaged var category_title: String
    @NSManaged var event_time: NSDate
    @NSManaged var event_description: String
    @NSManaged var in_weekly_report: NSNumber

}
