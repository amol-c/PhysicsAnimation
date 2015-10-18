//
//  UIView.swift
//  Pods
//
//  Created by Amol Chaudhari on 10/18/15.
//
//

import Foundation

extension UIView {
    func addLeftSideShadowWithFading() {
        let shadowWidth: CGFloat = 4.0
        let shadowVerticalPadding: CGFloat = -20.0
        let shadowHeight = CGRectGetHeight(self.frame) - 2 * shadowVerticalPadding

        let shadowRect: CGRect = CGRectMake(-shadowWidth, shadowVerticalPadding, shadowWidth, shadowHeight)
        let shadowPath = UIBezierPath(rect: shadowRect)
        self.layer.shadowPath = shadowPath.CGPath
        self.layer.shadowOpacity = 0.25

        // fade shadow during transition
        let toValue: CGFloat = 0
        let animation = CABasicAnimation(keyPath: "shadowOpacity")
        animation.fromValue = self.layer.shadowOpacity
        animation.toValue = toValue
        self.layer.addAnimation(animation, forKey: .None)
        self.layer.shadowOpacity = Float(toValue)
    }
}
