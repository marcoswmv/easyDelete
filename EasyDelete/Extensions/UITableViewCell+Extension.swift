//
//  UITableViewCell+Extension.swift
//  EasyDelete
//
//  Created by Marcos Vicente on 31/01/23.
//

import UIKit

extension UITableViewCell {
    static var identifier: String {
        return String(describing: self)
    }

    static var nib: UINib {
        return UINib(nibName: self.identifier, bundle: nil)
    }
}
