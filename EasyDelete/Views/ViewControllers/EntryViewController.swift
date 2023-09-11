//
//  EntryViewController.swift
//  EasyDelete
//
//  Created by Marcos Vicente on 01/09/2023.
//

import UIKit

class EntryViewController: UIViewController {
    
    private lazy var mainWindow: UIWindow = {
        let window = UIWindow()
        window.windowLevel = .normal + 1
        window.overrideUserInterfaceStyle = .light
        return window
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
    }
}
