//
//  OnboardingViewController.swift
//  EasyDelete
//
//  Created by Marcos Vicente on 01/09/2023.
//

import UIKit
import SnapKit

final class OnboardingViewController: UIViewController {
    
    private var mainWindow: UIWindow?
    
    private lazy var containerView: UIView = UIView()
    
    private lazy var closeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.tintColor = .gray
        return button
    }()
    
    private lazy var nextButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.link, for: .normal)
        return button
    }()
    
    private lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.currentPageIndicatorTintColor = .link
        pageControl.isUserInteractionEnabled = false
        pageControl.pageIndicatorTintColor = .lightGray
        return pageControl
    }()
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.isPagingEnabled = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()
    
    private var currentPosition: Int = 0
    private var viewModels: [OnboardingViewModel] = [
        OnboardingViewModel(image: Image.onboardingStep1,
                            title: Strings.Onboarding.onboardingStep1Title,
                            message: Strings.Onboarding.onboardingStep1Message),
        OnboardingViewModel(image: Image.onboardingStep2,
                            title: Strings.Onboarding.onboardingStep2Title,
                            message: Strings.Onboarding.onboardingStep2Message),
        OnboardingViewModel(image: Image.onboardingStep3,
                            title: Strings.Onboarding.onboardingStep3Title,
                            message: [Strings.Onboarding.onboardingStep3MessagePart1,
                                      Strings.Onboarding.onboardingStep3MessagePart2,
                                      Strings.Onboarding.onboardingStep3MessagePart3].joined(separator: "\n")),
        OnboardingViewModel(image: Image.onboardingStep4,
                            title: Strings.Onboarding.onboardingStep4Title,
                            message: [Strings.Onboarding.onboardingStep4MessagePart1,
                                      Strings.Onboarding.onboardingStep4MessagePart2].joined(separator: "\n"))]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupComponents()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        configureScroll()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        view.addSubviews([closeButton, scrollView, pageControl, nextButton])
        scrollView.addSubview(containerView)
        
        closeButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(40.0)
            make.top.equalToSuperview().offset(80.0)
        }
        
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(closeButton.snp.bottom).offset(95.0)
            make.horizontalEdges.equalToSuperview()
            make.bottom.greaterThanOrEqualTo(pageControl.snp.top).offset(-30.0)
        }
        
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        pageControl.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(40.0)
            make.bottom.greaterThanOrEqualTo(nextButton.snp.top).offset(-82.0)
        }
        
        nextButton.snp.makeConstraints { make in
            make.horizontalEdges.bottom.equalToSuperview().inset(40.0)
        }
    }
    
    private func setupComponents() {
        scrollView.delegate = self
        closeButton.addTarget(self, action: #selector(didTapClose), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(didTapNext), for: .touchUpInside)
        
        pageControl.numberOfPages = viewModels.count
        nextButton.setTitle(setButtonTitle(page: currentPosition), for: .normal)
    }
    
    private func configureScroll() {
        for pos in 0..<viewModels.count {
            let pageView = OnboardingPageView(
                frame: CGRect(x: CGFloat(pos) * scrollView.frame.size.width,
                              y: 0,
                              width: scrollView.frame.size.width,
                              height: scrollView.frame.size.height))
            pageView.setup(image: viewModels[pos].illustration,
                           title: viewModels[pos].title,
                           message: viewModels[pos].message)

            containerView.addSubview(pageView)
        }
        scrollView.contentSize = CGSize(width: scrollView.frame.size.width * CGFloat(viewModels.count), height: containerView.frame.size.height)
    }
    
    @objc private func didTapNext(button: UIButton) {
        let eachScreenViewWidth: CGFloat = scrollView.contentSize.width / CGFloat(viewModels.count)
        let isAtOffset = scrollView.contentOffset.x.truncatingRemainder(dividingBy: eachScreenViewWidth) == 0
        
        if isAtOffset {
            currentPosition = Int(scrollView.contentOffset.x / (scrollView.contentSize.width / CGFloat(viewModels.count)))
            
            if currentPosition < 3 {
                scrollView.setContentOffset(CGPoint(x: eachScreenViewWidth * CGFloat(currentPosition + 1), y: 0), animated: true)
            } else {
                OnboardingCompletionAssistant.shared.setAsComplete()
                showMainFlow()
            }
        }
    }
    
    @objc private func didTapClose(button: UIButton) {
        OnboardingCompletionAssistant.shared.setAsComplete()
        showMainFlow()
    }
    
    private func showMainFlow() {
        if let currentWindowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            
            currentWindowScene.windows.first?.isHidden = true
            
            let viewModel = ContactsListViewModel()
            let contactsViewController = UINavigationController(rootViewController: ContactsListViewController(viewModel: viewModel))
            
            mainWindow = UIWindow(windowScene: currentWindowScene)
            mainWindow?.windowLevel = .normal
            mainWindow?.rootViewController = contactsViewController
            mainWindow?.makeKeyAndVisible()
        }
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

extension OnboardingViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let eachScreenViewWidth: CGFloat = scrollView.contentSize.width / CGFloat(viewModels.count)
        let isAtOffset = scrollView.contentOffset.x.truncatingRemainder(dividingBy: eachScreenViewWidth) == 0
        
        if isAtOffset {
            currentPosition = Int(scrollView.contentOffset.x / (scrollView.contentSize.width / CGFloat(viewModels.count)))
            pageControl.currentPage = currentPosition
            nextButton.setTitle(setButtonTitle(page: currentPosition), for: .normal)
        }
    }
}

final class OnboardingCompletionAssistant {
    
    static let shared = OnboardingCompletionAssistant()
    private init() {}
    
    var isFirstLaunch: Bool = {
        return !UserDefaults.standard.bool(forKey: Keys.isFirstLaunch)
    }()
    
    func setAsComplete() {
        UserDefaults.standard.set(true, forKey: Keys.isFirstLaunch)
    }
}
