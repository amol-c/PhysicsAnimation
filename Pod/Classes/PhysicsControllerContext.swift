//
//  PhysicsControllerContext.swift
//  Pods
//
//  Created by Amol Chaudhari on 10/17/15.
//
//

import Foundation

private enum UserInteracting {
    case InProgress, Stopped
}

public class PhysicsControllerContext: NSObject {
    @IBOutlet weak var navigationController: UINavigationController!
    private var animator: DrawerAnimator!
    private var userInteracting: UserInteracting = .Stopped

    override public func awakeFromNib() {
        super.awakeFromNib()
        self.navigationController.delegate = self
        self.initialize()
    }

    public init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        super.init()
        self.navigationController.delegate = self
        self.initialize()
    }

    // MARK: Selector
    func pan(gestureRecognizer: UIPanGestureRecognizer) {
        let view = self.navigationController.view
        let location = gestureRecognizer.locationInView(view)

        if(gestureRecognizer.state == .Began) {
            self.animator = DrawerAnimator()
            if(location.x < CGRectGetMidX(view.bounds)/3 && self.navigationController.viewControllers.count > 1) {
                self.userInteracting = .InProgress
                self.navigationController.popViewControllerAnimated(true)
            }

            return
        }

        if self.userInteracting != .InProgress {
            return
        }

        if(gestureRecognizer.state == .Changed) {
            let translation = gestureRecognizer.translationInView(view)
            let percent = fabs(translation.x / CGRectGetWidth(view.bounds))
            self.animator.startGestureWith(location, percent: percent)

            return
        }

        if(gestureRecognizer.state == .Ended) {
            self.userInteracting = .Stopped
            self.animator.endGestureRecognizer(gestureRecognizer)

            return
        }

        if gestureRecognizer.state == .Cancelled {
            self.userInteracting = .Stopped
            self.animator.endGestureRecognizer(gestureRecognizer)

            return
        }
    }

    // MARK: Private
    private func initialize() {
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: "pan:")
        panGestureRecognizer.delegate = self
        panGestureRecognizer.maximumNumberOfTouches = 1
        self.navigationController.view.addGestureRecognizer(panGestureRecognizer)
        self.animator = DrawerAnimator()
    }
}

extension PhysicsControllerContext: UINavigationControllerDelegate {
    public func navigationController(navigationController: UINavigationController, interactionControllerForAnimationController animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        if self.userInteracting == .InProgress {
            return self.animator
        }
        return .None
    }


    public func navigationController(navigationController: UINavigationController, animationControllerForOperation operation: UINavigationControllerOperation, fromViewController fromVC: UIViewController, toViewController toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if operation == .Pop {
            return self.animator
        }
        return .None
    }
}

extension PhysicsControllerContext: UIGestureRecognizerDelegate {
    public func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        if self.navigationController.viewControllers.count > 1 {
            return true
        }
        return false
    }
}


