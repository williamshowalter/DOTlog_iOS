//
//  TabBarControllerViewController.swift
//  DOTlog
//
//  Created by William Showalter on 15/04/19.
//  Copyright (c) 2015 UAF CS Capstone 2015. All rights reserved.
//

import UIKit

class TabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

		for item in self.tabBar.items as! [UITabBarItem] {
			if let image = item.image {
				item.image = image.imageWithColor(UIColor.darkGrayColor()).imageWithRenderingMode(.AlwaysOriginal)
				item.selectedImage = image.imageWithColor(UIColor.whiteColor()).imageWithRenderingMode(.AlwaysOriginal)
			}
		}
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

	override func disablesAutomaticKeyboardDismissal() -> Bool {
		return false
	}
}

extension UIImage {
	func imageWithColor(tintColor: UIColor) -> UIImage {
		UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)

		let context = UIGraphicsGetCurrentContext() as CGContextRef
		CGContextTranslateCTM(context, 0, self.size.height)
		CGContextScaleCTM(context, 1.0, -1.0);
		CGContextSetBlendMode(context, kCGBlendModeNormal)

		let rect = CGRectMake(0, 0, self.size.width, self.size.height) as CGRect
		CGContextClipToMask(context, rect, self.CGImage)
		tintColor.setFill()
		CGContextFillRect(context, rect)

		let newImage = UIGraphicsGetImageFromCurrentImageContext() as UIImage
		UIGraphicsEndImageContext()

		return newImage
	}
}