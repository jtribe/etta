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
	
	private var rotation: CGFloat {
		return ZPositions.Rotation.rawValue
	}
	
	private func degreesToRadians(degrees: CGFloat) -> CGFloat {
		return ((CGFloat(M_PI) * degrees) / 180.0)
	}
	
	var reverse: Bool = false
	
	func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
		return 1.0
	}
	
	func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
		let containerView = transitionContext.containerView()
		let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
		let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
		let toView = toViewController.view
		let fromView = fromViewController.view
		
		// 1
		setAnchorPoint(CGPoint(x: 0.5, y: 0.0), view: toView)
		setAnchorPoint(CGPoint(x: 0.5, y: 0.0), view: fromView)
		
		// 1.a
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
		let toViewRotationDirection: CGFloat = reverse ? -rotation : rotation
		let toViewZ: CGFloat = reverse ? -distance : distance
		
		var rotationAndPerspectiveTransform: CATransform3D = CATransform3DIdentity
		rotationAndPerspectiveTransform.m34 = 1.0 / 1000.0
		rotationAndPerspectiveTransform = CATransform3DRotate(rotationAndPerspectiveTransform, degreesToRadians(toViewRotationDirection), 1, 0, 0);
		rotationAndPerspectiveTransform = CATransform3DTranslate(rotationAndPerspectiveTransform, 0.0, 0.0, toViewZ)
		
		return rotationAndPerspectiveTransform
	}
	
	func addDepthDownFromAnimation() -> CATransform3D {
		let fromViewRotationDirection: CGFloat = reverse ? rotation : -rotation
		let fromViewZ: CGFloat = reverse ? distance : -distance
		
		var rotationAndPerspectiveTransform: CATransform3D = CATransform3DIdentity
		rotationAndPerspectiveTransform.m34 = 1.0 / 1000.0
		rotationAndPerspectiveTransform = CATransform3DRotate(rotationAndPerspectiveTransform, degreesToRadians(fromViewRotationDirection), 1, 0, 0);
		rotationAndPerspectiveTransform = CATransform3DTranslate(rotationAndPerspectiveTransform, 0.0, 0.0, fromViewZ)
		
		return rotationAndPerspectiveTransform
	}
	
	func setAnchorPoint(anchorPoint: CGPoint, view: UIView) {
		var newPoint: CGPoint = CGPointMake(view.bounds.size.width * anchorPoint.x, view.bounds.size.height * anchorPoint.y)
		var oldPoint: CGPoint = CGPointMake(view.bounds.size.width * view.layer.anchorPoint.x, view.bounds.size.height * view.layer.anchorPoint.y)
		
		newPoint = CGPointApplyAffineTransform(newPoint, view.transform)
		oldPoint = CGPointApplyAffineTransform(oldPoint, view.transform)
		
		var position: CGPoint = view.layer.position
		
		position.x -= oldPoint.x
		position.x += newPoint.x
		
		position.y -= oldPoint.y
		position.y += newPoint.y
		
		view.translatesAutoresizingMaskIntoConstraints = true
		view.layer.anchorPoint = anchorPoint
		view.layer.position = position
	}
	
}

// 8
enum ZPositions: CGFloat {
	case Spatial = 300
	case Distance = 30
	case Rotation = 20
}