//
//  UIViewController+Extension.swift
//  EasyDelete
//
//  Created by Marcos Vicente on 17/09/2023.
//

import UIKit
import SnapKit

extension UIViewController {
    func showToast(message: String, action: ContactStoreSuccessfulAction) {
        let viewWidthWithMargin = view.frame.size.width - 80
        let viewCenter = view.frame.size.width - ((view.frame.size.width - viewWidthWithMargin) / 2)
        
        let icon = UIImageView()
        let iconConfig = UIImage.SymbolConfiguration(font: .boldSystemFont(ofSize: 16.0))
        icon.contentMode = .scaleAspectFit
        icon.tintColor = .white
        icon.image = UIImage(systemName: action == .delete ? "trash" : "arrow.uturn.backward", withConfiguration: iconConfig)
        
        let toastLabel = UILabel()
        toastLabel.textColor = .white
        toastLabel.font = .boldSystemFont(ofSize: 16.0)
        toastLabel.textAlignment = .center
        toastLabel.text = message
        toastLabel.sizeToFit()
        
        let toastView = UIView(frame: CGRect(x: viewCenter - viewWidthWithMargin, 
                                             y: view.frame.size.height, 
                                             width: viewWidthWithMargin, 
                                             height: 60))
        toastView.backgroundColor = .systemGreen
        toastView.alpha = 1.0
        toastView.layer.cornerRadius = 22
        toastView.clipsToBounds = true
        
        let stackView = UIStackView(arrangedSubviews: [icon, toastLabel])
        stackView.spacing = 10.0
        
        toastView.addSubview(stackView)
        
        stackView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        view.addSubview(toastView, aboveAll: true)
        
        UIView.animate(withDuration: 1.0, delay: 0.0, options: .curveEaseOut, animations: {
            toastView.frame = CGRect(x: viewCenter - viewWidthWithMargin, 
                                      y: self.view.frame.size.height - 90, 
                                      width: viewWidthWithMargin, 
                                      height: 60)
        }, completion: { isDone in
            if isDone {
                UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseOut, animations: {
                    toastView.alpha = 0.0
                    toastView.frame = CGRect(x: viewCenter - viewWidthWithMargin, 
                                              y: self.view.frame.size.height, 
                                              width: viewWidthWithMargin, 
                                              height: 60)
                }, completion: {  isDone in
                    if isDone {
                        toastView.removeFromSuperview()
                    }
                })
            }
        })
    }
}
