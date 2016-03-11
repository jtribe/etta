//
//  CustomPresentation.swift
//  Depth
//
//  Created by Ben on 11/03/2016.
//  Copyright © 2016 Ben. All rights reserved.
//

import UIKit
import Foundation

class CustomPresentation: NSObject, UIViewControllerAnimatedTransitioning {
	
	private let scale = UIScreen.mainScreen().scale
	private let identity = CATransform3DIdentity
	
	private var distance: CGFloat {
		return ZPositions.Distance.rawValue
	}
	
	private var spatial: CGFloat {
		return ZPositions.Spatial.rawValue
	}
	
	var reverse: Bool = false
	
	func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
		return 2.0
	}
	
	func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
		let containerView = transitionContext.containerView()
		let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
		let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
		let toView = toViewController.view
		let fromView = fromViewController.view
		
		// 1
		toView.layer.transform = addDepthDownToAnimation()
		
		// 2
		toView.alpha = 0.0
		rasterize(withLayer: toView.layer)
		
		// 3
		containerView?.addSubview(toView)
		containerView?.addSubview(fromView)
		containerView?.sendSubviewToBack(reverse == true ? fromView : toView)
		
		// 4
		fromView.layer.zPosition = reverse ? -spatial : spatial
		toView.layer.zPosition = reverse ? spatial : -spatial
		
		// 5
		UIView.animateWithDuration(transitionDuration(transitionContext), delay: 0.0, options: .CurveEaseOut, animations: { [weak self] in
			guard let weakSelf = self else { return }
			
			// 5.a
			fromView.layer.transform = weakSelf.addDepthDownFromAnimation()
			
			// 5.b
			fromView.alpha = 0.0
			weakSelf.rasterize(withLayer: fromView.layer)
			
			// 5.c
			toView.layer.transform = CATransform3DIdentity
			toView.alpha = 1.0
			
			}, completion: { finished in
				// 5.d
				if transitionContext.transitionWasCancelled() {
					toView.removeFromSuperview()
					toView.layer.removeAllAnimations()
				} else {
					fromView.removeFromSuperview()
					fromView.layer.removeAllAnimations()
				}
				
				// 5.e
				transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
		})
	}
	
	// 6
	func rasterize(withLayer layer: CALayer) {
		layer.contentsScale = scale
		layer.shouldRasterize = true
		layer.rasterizationScale = scale
	}
	
	// 7
	func addDepthDownToAnimation() -> CATransform3D {
		let toViewZ: CGFloat = reverse ? distance : -distance
		
		var rotationAndPerspectiveTransform: CATransform3D = CATransform3DIdentity
		rotationAndPerspectiveTransform.m34 = 1.0 / -500.0
		rotationAndPerspectiveTransform = CATransform3DTranslate(rotationAndPerspectiveTransform, 0.0, 0.0, toViewZ)
		
		return rotationAndPerspectiveTransform
	}
	
	func addDepthDownFromAnimation() -> CATransform3D {
		let fromViewZ: CGFloat = reverse ? -distance : distance
		
		var rotationAndPerspectiveTransform: CATransform3D = CATransform3DIdentity
		rotationAndPerspectiveTransform.m34 = 1.0 / -500.0
		rotationAndPerspectiveTransform = CATransform3DTranslate(rotationAndPerspectiveTransform, 0.0, 0.0, fromViewZ)
		
		return rotationAndPerspectiveTransform
	}
	
}

// 8
enum ZPositions: CGFloat {
	case Spatial = 300
	case Distance = 150
}