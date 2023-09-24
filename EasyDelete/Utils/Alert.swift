//
//  Alert.swift
//  EasyDelete
//
//  Created by Marcos Vicente on 06.08.2021.
//

import UIKit

struct Alert {
    private static func showBasicAlert(on viewController: UIViewController,
                                       style: UIAlertController.Style,
                                       title: String?,
                                       message: String?,
                                       actions: [UIAlertAction] = [UIAlertAction(title: Strings.Title.okButtonTitle,
                                                                                 style: .cancel,
                                                                                 handler: nil)],
                                       completion: (() -> Void)? = nil) {
        
        let alert =  UIAlertController(title: title, message: message, preferredStyle: style)
        
        for action in actions { alert.addAction(action) }
        DispatchQueue.main.async { viewController.present(alert, animated: true, completion: completion) }
    }
    
    static func showErrorAlert(on viewController: UIViewController, message: String) {
        showBasicAlert(on: viewController,
                       style: .alert,
                       title: Strings.Title.errorAlertTitle,
                       message: message)
    }
    
    static func showNoContactSelectedAlert(on viewController: UIViewController) {
        showBasicAlert(on: viewController,
                       style: .alert,
                       title: Strings.Title.selectButtonTitle, message: nil)
    }
    
    static func showNoContactsAlert(on viewController: UIViewController) {
        showBasicAlert(on: viewController,
                       style: .alert,
                       title: Strings.Title.noContactsAlertTitle, message: nil)
    }
    
    static func showActionSheetToAskForConfirmationToDelete(on viewController: UIViewController, numberOfContacts: Int = 1, _ completionHandler: @escaping ((Bool) -> Void)) {
        
        let cancel = UIAlertAction(title: Strings.Title.cancelButtonTitle, style: .cancel, handler: nil)
        let confirm = UIAlertAction(title: Strings.Title.confirmButtonTitle, style: .destructive, handler: { _ in
            completionHandler(true)
        })
        
        let message = numberOfContacts > 1 ? Strings.Text.actionSheetPluralText : Strings.Text.actionSheetText
        
        showBasicAlert(on: viewController,
                       style: .actionSheet,
                       title: Strings.Title.deleteActionSheetTitle,
                       message: message,
                       actions: [cancel, confirm])
    }
    
    static func showSettingsAlert(title: String, message: String, on viewController: UIViewController) {
        if let settings = URL(string: UIApplication.openSettingsURLString),
            UIApplication.shared.canOpenURL(settings) {
            
            let openSettingsAction = UIAlertAction(title: Strings.Title.openSettingsButtonTitle,
                                                   style: .default) { _ in
                UIApplication.shared.open(settings)
            }
            let cancel = UIAlertAction(title: Strings.Title.cancelButtonTitle, style: .cancel, handler: nil)
            
            showBasicAlert(on: viewController,
                           style: .alert,
                           title: title,
                           message: message,
                           actions: [openSettingsAction, cancel])
        }
    }
}
