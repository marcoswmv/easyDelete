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
    
    func setConstraints(to superview: UIView, leading: CGFloat = 0, top: CGFloat = 0, trailing: CGFloat = 0, bottom: CGFloat = 0) {
        NSLayoutConstraint.activate([
            leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: leading),
            topAnchor.constraint(equalTo: superview.topAnchor, constant: top),
            trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: trailing),
            bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: bottom)
        ])
    }
    
    func setCenterConstraint(to superview: UIView) {
        NSLayoutConstraint.activate([
            centerXAnchor.constraint(equalTo: superview.centerXAnchor),
            centerYAnchor.constraint(equalTo: superview.centerYAnchor),
        ])
    }
    
    func setSizeConstraint(width: CGFloat, height: CGFloat) {
        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: width),
            heightAnchor.constraint(equalToConstant: height)
        ])
    }
}
