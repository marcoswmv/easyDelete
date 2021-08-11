//
//  UIApplication+TopViewController.swift
//  EasyDelete
//
//  Created by Marcos Vicente on 10.08.2021.
//

import UIKit

extension UIApplication {
    class func topViewController(base: UIViewController? = UIApplication.shared.windows.first?.rootViewController) -> UIViewController? {

       if let nav = base as? UINavigationController {
           return topViewController(base: nav.visibleViewController)

       } else if let tab = base as? UITabBarController, let selected = tab.selectedViewController {
           return topViewController(base: selected)

       } else if let presented = base?.presentedViewController {
           return topViewController(base: presented)
       }
       return base
    }
}
