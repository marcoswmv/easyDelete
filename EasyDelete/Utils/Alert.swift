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
                                       actions: [UIAlertAction] = [UIAlertAction(title: Consts.Alert.okButton,
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
                       title: Consts.Alert.errorTitle,
                       message: message)
    }
    
    static func showNoContactSelectedAlert(on viewController: UIViewController) {
        showBasicAlert(on: viewController,
                       style: .alert,
                       title: Consts.Alert.selectContactsTitle, message: nil)
    }
    
    static func showNoContactsAlert(on viewController: UIViewController) {
        showBasicAlert(on: viewController,
                       style: .alert,
                       title: Consts.Alert.nContactsTitle, message: nil)
    }
    
    static func showActionSheetToAskForConfirmationToDelete(on viewController: UIViewController, _ completionHandler: @escaping ((Bool) -> Void)) {
        
        let cancel = UIAlertAction(title: Consts.Alert.cancelButton, style: .cancel, handler: nil)
        let confirm = UIAlertAction(title: Consts.Alert.confirmButton, style: .destructive, handler: { _ in
            completionHandler(true)
        })
        
        showBasicAlert(on: viewController,
                       style: .actionSheet,
                       title: Consts.Alert.confirmationRequestTitle,
                       message: Consts.Alert.confirmationRequestMessage,
                       actions: [cancel, confirm])
    }
}
