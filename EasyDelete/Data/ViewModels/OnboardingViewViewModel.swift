//
//  OnboardingViewViewModel.swift
//  EasyDelete
//
//  Created by Marcos Vicente on 01/09/2023.
//

import UIKit

struct OnboardingViewModel {
    
    let illustration: UIImage?
    let title: String
    let message: String
    
    init(image: String, title: String, message: String) {
        self.illustration = UIImage(named: image)
        self.title = title
        self.message = message
    }
}
