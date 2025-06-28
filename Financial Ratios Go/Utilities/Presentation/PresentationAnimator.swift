//
//  SlideInTransition.swift
//  Financial Ratios Go
//
//  Created by Banghua Zhao on 10/5/19.
//  Copyright © 2019 Banghua Zhao. All rights reserved.
//

import UIKit

class PresentationAnimator: NSObject {
    var isPresenting = false

    init(isPresenting: Bool) {
        self.isPresenting = isPresenting
    }
}

extension PresentationAnimator: UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let key: UITransitionContextViewControllerKey = isPresenting ? .to : .from
        guard let controller = transitionContext.viewController(forKey: key)
        else { return }

        if isPresenting {
            transitionContext.containerView.addSubview(controller.view)
        }

        let presentedFrame = transitionContext.finalFrame(for: controller)
        var dismissedFrame = presentedFrame

        dismissedFrame.origin.x = -presentedFrame.width

        let initialFrame = isPresenting ? dismissedFrame : presentedFrame
        let finalFrame = isPresenting ? presentedFrame : dismissedFrame

        let animationDuration = transitionDuration(using: transitionContext)
        controller.view.frame = initialFrame
        UIView.animate(
            withDuration: animationDuration,
            animations: {
                controller.view.frame = finalFrame
            }, completion: { finished in
                if !self.isPresenting {
                    controller.view.removeFromSuperview()
                }
                transitionContext.completeTransition(finished)
        })
    }
}
