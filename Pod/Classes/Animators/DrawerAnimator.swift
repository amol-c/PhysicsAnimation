//
//  DrawerAnimator.swift
//  Pods
//
//  Created by Amol Chaudhari on 10/18/15.
//
//

import Foundation

let TranslationFactor: CGFloat = 0.3
let InitialDimViewAlpha: CGFloat = 0.5

class DrawerAnimator: NSObject, UIDynamicAnimatorDelegate {
    private var fromViewController: UIViewController!
    private var toViewController: UIViewController!
    private var containerView: UIView!
    private var animator: UIDynamicAnimator!
    private var transitionContext: UIViewControllerContextTransitioning!
    private var pushBehavior: UIPushBehavior!
    private var attachmentBehavior: UIAttachmentBehavior!
    private var dimmingView: UIView!

    // MARK: Lifecycle
    deinit {
        self.dimmingView?.removeFromSuperview()
    }

    // MARK: Internal
    func startGestureWith(var gestureRecognizerLocation: CGPoint, percent: CGFloat) {
        let toViewControllerXTranslation = -CGRectGetWidth(transitionContext.containerView()?.bounds ?? CGRectZero) * TranslationFactor
        self.toViewController.view.transform = CGAffineTransformMakeTranslation(toViewControllerXTranslation + gestureRecognizerLocation.x * TranslationFactor, 0)

        gestureRecognizerLocation.y = CGRectGetMidY(self.fromViewController.view.bounds)
        self.attachmentBehavior.anchorPoint = gestureRecognizerLocation

        let transform = self.applyLinearTransform(percent, originalStart: 0, originalEnd: 1, newStart: 0, newEnd: InitialDimViewAlpha)
        self.dimmingView.alpha = InitialDimViewAlpha - transform

        self.transitionContext.updateInteractiveTransition(percent)
    }

    func endGestureRecognizer(gestureRecognizer: UIPanGestureRecognizer) {
        self.animator.removeBehavior(self.attachmentBehavior)
        let velocity = gestureRecognizer.velocityInView(self.fromViewController.view)
        let velocityThreshold: CGFloat = 1000
        let belowMidScreenBounds = gestureRecognizer.translationInView(self.containerView).x < self.fromViewController.view.bounds.size.width/2
        // When the transition is failed as the user didnt swipe all the way to the left
        if(velocity.x < velocityThreshold && belowMidScreenBounds) {
            let toView = self.toViewController.view.snapshotViewAfterScreenUpdates(false)

            let toViewControllerXTranslation = -CGRectGetWidth(self.toViewController.view?.bounds ?? CGRectZero) * TranslationFactor

            UIView.animateWithDuration(self.transitionDuration(transitionContext), animations: { () -> Void in
                self.toViewController.view.transform = CGAffineTransformMakeTranslation(toViewControllerXTranslation, 0)
                }, completion: { completed in
                    self.containerView.insertSubview(toView, belowSubview: self.fromViewController.view)
                    self.toViewController.view.transform = CGAffineTransformIdentity
                    self.transitionContext.cancelInteractiveTransition()
                    self.transitionContext.completeTransition(false)
            })

            self.addDynamicBehaviorWith(gestureRecognizer)

            return
        }
        // Called when transition is successful
        self.animator.removeAllBehaviors()
        self.completeTransition()
    }

    // MARK: Private
    private func addDynamicBehaviorWith(gestureRecognizer: UIPanGestureRecognizer) {
        self.pushBehavior.active = true
        let constantPush: CGFloat = -500
        self.pushBehavior.pushDirection = CGVectorMake(constantPush, 0)

        let gravityDirectionX: CGFloat = -1
        let gravityBehavior = UIGravityBehavior(items: [self.fromViewController.view])
        gravityBehavior.magnitude = 1
        gravityBehavior.gravityDirection = CGVectorMake(gravityDirectionX, 0)
        self.animator.addBehavior(gravityBehavior)

        let collisionBehavior = UICollisionBehavior(items: [self.fromViewController.view])
        collisionBehavior.setTranslatesReferenceBoundsIntoBoundaryWithInsets(UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -250))
        self.animator.addBehavior(collisionBehavior)
        self.animator.addBehavior(self.pushBehavior)

        let itemBehavior = UIDynamicItemBehavior(items: [self.fromViewController.view])
        itemBehavior.elasticity = 0.5
        self.animator.addBehavior(itemBehavior)
    }

    private func completeTransition() {
        let previousClipsToBounds = fromViewController.view.clipsToBounds

        UIView.animateWithDuration(self.transitionDuration(transitionContext), animations: { () -> Void in
            self.toViewController.view.transform = CGAffineTransformIdentity
            self.fromViewController.view.transform = CGAffineTransformMakeTranslation(self.toViewController.view.bounds.size.width, 0)
            self.dimmingView.alpha = 0
            }, completion: { finished in
                self.dimmingView.removeFromSuperview()
                self.fromViewController.view.transform = CGAffineTransformIdentity
                self.fromViewController.view.clipsToBounds = previousClipsToBounds
                self.transitionContext.finishInteractiveTransition()
                self.transitionContext.completeTransition(true)
        })
    }

    private func applyLinearTransform(currentValue: CGFloat, originalStart: CGFloat, originalEnd: CGFloat, newStart: CGFloat, newEnd: CGFloat) -> CGFloat {
        let transformedValue = (currentValue - originalStart)/(originalEnd - originalStart) * ((newEnd - newEnd) + newEnd)

        return transformedValue
    }
}

extension DrawerAnimator: UIViewControllerAnimatedTransitioning {
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        if transitionContext!.isInteractive() {
            return 0.25
        }
        return 0.5
    }

    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        self.initializeWith(transitionContext)
        let toViewControllerXTranslation = -CGRectGetWidth(transitionContext.containerView()?.bounds ?? CGRectZero) * TranslationFactor
        toViewController.view.transform = CGAffineTransformMakeTranslation(toViewControllerXTranslation, 0)
        fromViewController.view.clipsToBounds = false

        self.completeTransition()
    }
}

extension DrawerAnimator: UIViewControllerInteractiveTransitioning {
    func startInteractiveTransition(transitionContext: UIViewControllerContextTransitioning) {
        self.initializeWith(transitionContext)
        self.initializeDynamics()
    }
    
    private func initializeDynamics() {
        self.animator = UIDynamicAnimator(referenceView: self.containerView)
        self.pushBehavior = UIPushBehavior(items: [self.fromViewController.view], mode: .Continuous)
        self.pushBehavior.magnitude = 0
        self.pushBehavior.angle = 0
        self.pushBehavior.active = false

        self.animator.addBehavior(self.pushBehavior)

        self.attachmentBehavior = UIAttachmentBehavior(item: self.fromViewController.view, attachedToAnchor: CGPointMake(0, CGRectGetMidY(self.fromViewController.view.bounds)))
        self.animator.addBehavior(self.attachmentBehavior)

        self.animator.delegate = self
    }

    private func initializeWith(transitionContext: UIViewControllerContextTransitioning) {
        self.animator?.removeAllBehaviors()
        self.transitionContext = transitionContext
        self.containerView = transitionContext.containerView()

        self.fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)
        self.toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)

        self.fromViewController.view.frame = transitionContext.finalFrameForViewController(self.toViewController)
        self.containerView.insertSubview(self.toViewController.view, belowSubview: self.fromViewController.view)
        self.fromViewController.view.addLeftSideShadowWithFading()

        self.dimmingView?.removeFromSuperview()
        self.dimmingView = UIView(frame: self.toViewController.view.bounds)
        dimmingView.backgroundColor = UIColor(white: 0, alpha: InitialDimViewAlpha)
        self.toViewController.view.addSubview(dimmingView)
    }
}
