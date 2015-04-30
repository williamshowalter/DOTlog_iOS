//
//  HubEntry.swift
//  DOTlog
//
//  Created by William Showalter on 15/04/30.
//  Copyright (c) 2015 UAF CS Capstone 2015. All rights reserved.
//

import Foundation
import CoreData

class HubEntry: NSManagedObject {

    @NSManaged var hub_name: String
    @NSManaged var airport: NSOrderedSet
    @NSManaged var district: DistrictEntry

}
