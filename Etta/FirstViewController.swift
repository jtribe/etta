//
//  ViewController.swift
//  Depth
//
//  Created by Ben on 11/03/2016.
//  Copyright © 2016 Ben. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController, UINavigationControllerDelegate {

	let presenting = CustomPresentation()
	let interaction = CustomInteraction()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		navigationController?.delegate = self
	}
	
	@IBAction func goToSecondScreen() {
		navigationController?.pushViewController(
			UIStoryboard(name: "Main", bundle: nil)
			.instantiateViewControllerWithIdentifier("SecondViewController"), animated: true)
	}
	
	func navigationController(navigationController: UINavigationController, animationControllerForOperation operation: UINavigationControllerOperation, fromViewController fromVC: UIViewController, toViewController toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		
		if operation == .Push {
			interaction.attachToViewController(toVC)
		}
		
		presenting.reverse = operation == .Pop
		return presenting
	}
	
	func navigationController(navigationController: UINavigationController, interactionControllerForAnimationController animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
		return interaction.transitionInProgress ? interaction : nil
	}

}

