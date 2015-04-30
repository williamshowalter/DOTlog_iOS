//
//  RegionEntry.swift
//  DOTlog
//
//  Created by William Showalter on 15/04/30.
//  Copyright (c) 2015 UAF CS Capstone 2015. All rights reserved.
//

import Foundation
import CoreData

class RegionEntry: NSManagedObject {

    @NSManaged var region_name: String
    @NSManaged var district: NSOrderedSet

}
