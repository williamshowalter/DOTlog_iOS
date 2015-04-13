//
//  SyncType.swift
//  DOTlog
//
//  Created by William Showalter on 15/04/12.
//  Copyright (c) 2015 UAF CS Capstone 2015. All rights reserved.
//

import Foundation

protocol APIResource {
	func accept (visitor : NetworkVisitor)
	func getAPIAddressString() -> String
	func syncJSON(webData : NSMutableData)
	func getMethod () -> String
	func getBody () -> NSData
}