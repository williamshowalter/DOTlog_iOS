//
//  AirportEntry.swift
//  DOTlog
//
//  Created by William Showalter on 15/04/30.
//  Copyright (c) 2015 UAF CS Capstone 2015. All rights reserved.
//

import Foundation
import CoreData

class AirportEntry: NSManagedObject {

    @NSManaged var faa_code: String
    @NSManaged var hub: HubEntry

}
