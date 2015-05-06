//
//  SyncType.swift
//  DOTlog
//
//  Created by William Showalter on 15/04/12.
//  Copyright (c) 2015 UAF CS Capstone 2015. All rights reserved.
//

import Foundation

// *******  REPLACE WITH OFFICIAL DOT DOMAIN TO BE USED FOR DOTLOG  ******* //
let defaultBaseURL : String = "http://dotlog.uafcsc.com"

// This is an abstract base class for clients in the visitor design pattern
// used in the NetworkVisitor class
// http://en.wikipedia.org/wiki/Visitor_pattern

protocol APIResource {
	func accept (visitor : NetworkVisitor)
	func getAPIAddressString() -> String
	func refreshLocalResource(webData : NSMutableData) -> NSError?
	func getMethod () -> String
	func getBody() -> NSData?
	func getResourceIdentifier () -> String
}