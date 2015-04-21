//
//  ErrorObserver.swift
//  DOTlog
//
//  Created by William Showalter on 15/04/14.
//  Copyright (c) 2015 UAF CS Capstone 2015. All rights reserved.
//

import Foundation

// This is an abstract base class for observers in the observer design pattern
// viewcontrollers can inherit from this class in order to be notified of errors
// http://en.wikipedia.org/wiki/Observer_pattern

protocol ErrorObserver {
	func notify (error : NSError)
	func notifyFinishSuccess ()
}