//
//  OnboardingPageView.swift
//  EasyDelete
//
//  Created by Marcos Vicente on 08/09/2023.
//

import UIKit
import SnapKit

class OnboardingPageView: UIView {
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 27, weight: .semibold)
        label.textAlignment = .center
        return label
    }()
    
    private lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17)
        label.textAlignment = .center
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.textColor = .gray
        return label
    }()
    
    private var isSmallScreen: Bool {
        UIScreen.main.bounds.size.height < 670.0
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup(image: UIImage?,
               title: String,
               message: String) {
        imageView.image = image
        titleLabel.text = title
        messageLabel.text = message
        
        let imageHeight: CGFloat = image?.size.height ?? 0.0
        
        addSubviews([imageView, titleLabel, messageLabel])
        
        imageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(imageHeight == 271 || isSmallScreen ? 0.0 : 31.0)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(titleLabel.snp.top).offset(isSmallScreen ? -30.0 : -40.0)
            make.height.equalTo(isSmallScreen ? 120.0 : imageHeight)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(40.0)
            make.bottom.equalTo(messageLabel.snp.top).offset(isSmallScreen ? -15.0 : -30.0)
            make.height.equalTo(32.0)
        }
        
        messageLabel.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(40.0)
            make.bottom.equalToSuperview().priority(.low)
        }
    }
}
