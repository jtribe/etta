//
//  CustomInteraction.swift
//  Depth
//
//  Created by Ben on 11/03/2016.
//  Copyright © 2016 Ben. All rights reserved.
//

import UIKit

class CustomInteraction: UIPercentDrivenInteractiveTransition {
	
	var navigationController: UINavigationController?
	var shouldCompleteTransition = false
	var transitionInProgress = false
	
	override init() {
		super.init()
		
		completionSpeed = 1 - percentComplete
	}
	
	func attachToViewController(viewController: UIViewController) {
		navigationController = viewController.navigationController
		setupGestureRecognizer(viewController.view)
	}
	
	private func setupGestureRecognizer(view: UIView) {
		view.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: "handlePanGesture:"))
	}
	
	func handlePanGesture(gestureRecognizer: UIPanGestureRecognizer) {
		guard let gestureSuperview = gestureRecognizer.view?.superview else { return }
		
		let viewTranslation = gestureRecognizer.translationInView(gestureSuperview)
		let location = gestureRecognizer.locationInView(gestureSuperview)
		
		switch gestureRecognizer.state {
		case .Began:
			if location.x > PercentageValues.Threshold.rawValue {
				cancelInteractiveTransition()
				return
			}
			transitionInProgress = true
			navigationController?.popViewControllerAnimated(true)
			
		case .Changed:
			let const = CGFloat(fminf(fmaxf(Float(viewTranslation.x / 200.0), 0.0), 1.0))
			shouldCompleteTransition = const > PercentageValues.Half.rawValue
			updateInteractiveTransition(const)
		case .Cancelled, .Ended:
			transitionInProgress = false
			if !shouldCompleteTransition || gestureRecognizer.state == .Cancelled {
				cancelInteractiveTransition()
			} else {
				finishInteractiveTransition()
			}
		default:
			print("Swift switch must be exhaustive, thus the default")
		}
	}
}

enum PercentageValues: CGFloat {
	case Threshold = 50.0
	case Half = 0.50
}