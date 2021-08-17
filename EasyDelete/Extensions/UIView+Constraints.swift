//
//  UIView+CenterConstraint.swift
//  EasyDelete
//
//  Created by Marcos Vicente on 04.08.2021.
//

import UIKit

extension UIView {
    
    func enableAutoLayout() {
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    func setConstraints(to superview: UIView, leading: CGFloat? = nil, top: CGFloat? = nil, trailing: CGFloat? = nil, bottom: CGFloat? = nil) {
        setHorizontalConstraints(to: superview, leading: leading, trailing: trailing)
        setVerticalConstraints(to: superview, top: top, bottom: bottom)
    }
    
    func setCenterConstraint(to superview: UIView) {
        setHorizontalCenterConstraint(to: superview)
        setVerticalCenterConstraint(to: superview)
    }
    
    func setHorizontalCenterConstraint(to superview: UIView) {
        NSLayoutConstraint.activate([
            centerXAnchor.constraint(equalTo: superview.centerXAnchor)
        ])
    }
    
    func setVerticalCenterConstraint(to superview: UIView) {
        NSLayoutConstraint.activate([
            centerYAnchor.constraint(equalTo: superview.centerYAnchor)
        ])
    }
    
    func setHorizontalConstraints(to superview: UIView, leading: CGFloat? = nil, trailing: CGFloat? = nil) {
        setLeadingConstraint(to: superview, leading: leading)
        setTrailingConstraint(to: superview, trailing: trailing)
    }
    
    func setLeadingConstraint(to superview: UIView, leading: CGFloat? = nil) {
        var constraint = NSLayoutConstraint()
        
        if let leading = leading {
            constraint = leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: leading)
        } else {
            constraint = leadingAnchor.constraint(equalTo: superview.leadingAnchor)
        }
        NSLayoutConstraint.activate([constraint])
    }
    
    func setTrailingConstraint(to superview: UIView, trailing: CGFloat? = nil) {
        var constraint = NSLayoutConstraint()
        
        if let trailing = trailing {
            constraint = trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: trailing)
        } else {
            constraint = trailingAnchor.constraint(equalTo: superview.trailingAnchor)
        }
        NSLayoutConstraint.activate([constraint])
    }
    
    func setVerticalConstraints(to superview: UIView, top: CGFloat? = nil, bottom: CGFloat? = nil) {
        setTopConstraint(to: superview, top: top)
        setBottomConstraint(to: superview, bottom: bottom)
    }
    
    func setTopConstraint(to superview: UIView, top: CGFloat? = nil) {
        var constraint = NSLayoutConstraint()
        
        if let top = top {
            constraint = topAnchor.constraint(equalTo: superview.topAnchor, constant: top)
        } else {
            constraint = topAnchor.constraint(equalTo: superview.topAnchor)
        }
        NSLayoutConstraint.activate([constraint])
    }
    
    func setBottomConstraint(to superview: UIView, bottom: CGFloat? = nil) {
        var constraint = NSLayoutConstraint()
        
        if let bottom = bottom {
            constraint = bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: bottom)
        } else {
            constraint = bottomAnchor.constraint(equalTo: superview.bottomAnchor)
        }
        NSLayoutConstraint.activate([constraint])
    }
    
    func setSizeConstraint(width: CGFloat, height: CGFloat) {
        setWidthConstraint(width: width)
        setHeightConstraint(height: height)
    }
    
    func setWidthConstraint(width: CGFloat) {
        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: width)
        ])
    }
    
    func setHeightConstraint(height: CGFloat) {
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: height)
        ])
    }
    
    func setTopConstraint(to superview: UIView, bottom: CGFloat? = nil) {
        var constraint = NSLayoutConstraint()
        
        if let bottom = bottom {
            constraint = topAnchor.constraint(equalTo: superview.bottomAnchor, constant: bottom)
        } else {
            constraint = topAnchor.constraint(equalTo: superview.bottomAnchor)
        }
        NSLayoutConstraint.activate([constraint])
    }
}
