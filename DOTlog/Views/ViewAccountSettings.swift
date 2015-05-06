//
//  ViewAccountSettings.swift
//  DOTlog
//
//  Created by William Showalter on 15/05/02.
//  Copyright (c) 2015 UAF CS Capstone 2015. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class ViewAccountSettings: UIViewController {

	override func viewDidLoad() {
		super.viewDidLoad()
	}

	@IBAction func ButtonSave(sender: AnyObject) {
		let tableViewController = self.childViewControllers.last as? ViewAccountSettingsTableView
		tableViewController?.SaveAccountSettings()
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
}