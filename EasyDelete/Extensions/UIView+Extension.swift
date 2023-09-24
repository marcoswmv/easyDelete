//
//  UIView+Extension.swift
//  EasyDelete
//
//  Created by Marcos Vicente on 04.08.2021.
//

import UIKit

extension UIView {
    func addSubviews(_ views: [UIView]) {
        views.forEach { addSubview($0) }
    }
    
    func addSubview(_ view: UIView, aboveAll: Bool) {
        if aboveAll {
            (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows
                .first(where: { $0.isKeyWindow })?
                .addSubview(view)
        } else {
            addSubview(view)
        }
    }
}
