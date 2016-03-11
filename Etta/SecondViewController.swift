//
//  SecondViewController.swift
//  Depth
//
//  Created by Ben on 11/03/2016.
//  Copyright © 2016 Ben. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController {

	override func viewDidLoad() {
		super.viewDidLoad()
	}
	
	@IBAction func goBack() {
		navigationController?.popToRootViewControllerAnimated(true)
	}

}
