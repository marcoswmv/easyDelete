//
//  OnboardingPageView.swift
//  EasyDelete
//
//  Created by Marcos Vicente on 08/09/2023.
//

import UIKit

class OnboardingPageView: UIView {
    
    private lazy var closeButton: UIButton = UIButton()
    private lazy var imageView: UIImageView = UIImageView()
    private lazy var titleLabel: UILabel = UILabel()
    private lazy var messageLabel: UILabel = UILabel()
    private lazy var nextButton: UIButton = UIButton()
    private lazy var pageControl: UIPageControl = UIPageControl()
    
    private var handleClose: ((Int) -> Void)? = nil
    private var handleStep: ((Int) -> Void)? = nil

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup(total: Int,
               position: Int,
               image: UIImage?,
               title: String,
               message: String,
               handleStep: ((Int) -> Void)?,
               handleClose: ((Int) -> Void)?) {
        
        let imageWidth: CGFloat = image?.size.width ?? 0.0
        let imageHeight: CGFloat = image?.size.height ?? 0.0
        
        var xPos: CGFloat = frame.size.width - ((frame.size.width - imageWidth) / 2) - imageWidth
        var yPos: CGFloat = frame.size.height - frame.size.height * (frame.size.height > 700 ? 0.80 : 0.90)
        let width: CGFloat = frame.size.width - (40.0 * 2)
        
        if imageHeight < 271 {
            yPos += 31
        }
        imageView.frame = CGRect(x: xPos,
                                 y: yPos,
                                 width: width - (7.0 * 2),
                                 height: 271.0)
        imageView.image = image
        imageView.sizeToFit()
        
        xPos = frame.size.width - width - 40.0
        yPos += imageView.frame.size.height + 40
        titleLabel.frame = CGRect(x: xPos,
                                  y: yPos,
                                  width: width,
                                  height: 32.0)
        titleLabel.font = UIFont.systemFont(ofSize: 27, weight: .semibold)
        titleLabel.textAlignment = .center
        titleLabel.text = title
        
        yPos += titleLabel.frame.size.height + 30
        messageLabel.frame = CGRect(x: xPos,
                                    y: yPos,
                                    width: width,
                                    height: 60)
        messageLabel.font = UIFont.systemFont(ofSize: 17)
        messageLabel.textAlignment = .center
        messageLabel.lineBreakMode = .byWordWrapping
        messageLabel.numberOfLines = 0
        messageLabel.textColor = .gray
        messageLabel.text = message
        messageLabel.sizeToFit()
        
        let percentage: CGFloat = frame.size.height > 700 ? 0.20 : 0.15
        yPos = frame.size.height - (frame.size.height * percentage)
        pageControl.frame = CGRect(x: xPos,
                                   y: yPos,
                                   width: width,
                                   height: 10.0)
        pageControl.numberOfPages = total
        pageControl.currentPage = position
        pageControl.currentPageIndicatorTintColor = .link
        pageControl.pageIndicatorTintColor = .lightGray
        pageControl.isUserInteractionEnabled = false
        
        yPos = frame.size.height - (frame.size.height * 0.10)
        nextButton.frame = CGRect(x: xPos,
                                  y: yPos,
                                  width: width,
                                  height: 30.0)
        nextButton.setTitle(setButtonTitle(page: position), for: .normal)
        nextButton.setTitleColor(.link, for: .normal)
        nextButton.tag = position + 1
        nextButton.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
        self.handleStep = handleStep
        
        closeButton.frame = CGRect(x: 40.0, y: 80.0, width: 15.0, height: 15.0)
        closeButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        closeButton.tintColor = .gray
        closeButton.tag = position + 1
        closeButton.addTarget(self, action: #selector(didTapClose), for: .touchUpInside)
        self.handleClose = handleClose
        
        addSubviews([closeButton, imageView, titleLabel, messageLabel, pageControl, nextButton])
    }
    
    @objc private func didTapButton(button: UIButton) {
        handleStep?(button.tag)
    }
    
    @objc private func didTapClose(button: UIButton) {
        handleClose?(button.tag)
    }
    
    private func setButtonTitle(page: Int) -> String {
        switch page {
        case 0:
            return Strings.Onboarding.onboardingStepStartButtonTitle
        case 1...2:
            return Strings.Onboarding.onboardingStepButtonTitle
        case 3:
            return Strings.Onboarding.onboardingStepEndButtonTitle
        default:
            return Strings.undefined
        }
    }
}
