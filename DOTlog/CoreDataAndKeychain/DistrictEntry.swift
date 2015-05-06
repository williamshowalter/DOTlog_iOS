//
//  DistrictEntry.swift
//  DOTlog
//
//  Created by William Showalter on 15/04/30.
//  Copyright (c) 2015 UAF CS Capstone 2015. All rights reserved.
//

import Foundation
import CoreData

class DistrictEntry: NSManagedObject {

    @NSManaged var district_name: String
    @NSManaged var hub: NSOrderedSet
    @NSManaged var region: RegionEntry

}
