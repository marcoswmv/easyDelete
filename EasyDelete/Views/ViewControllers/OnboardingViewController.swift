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
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.isPagingEnabled = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()
    
    var viewModels: [OnboardingViewModel] = [
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
                            title: Strings.Onboarding.onboardingStep4MessagePart1,
                            message: [Strings.Onboarding.onboardingStep4MessagePart1,
                                      Strings.Onboarding.onboardingStep4MessagePart2].joined(separator: "\n"))]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        configureScroll()
    }
    
    private func setupUI() {
        view.addSubview(containerView)
        containerView.addSubview(scrollView)
        
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func configureScroll() {
        scrollView.frame = containerView.bounds
        
        for pos in 0..<viewModels.count {
            let pageView = OnboardingPageView(frame: CGRect(x: CGFloat(pos) * containerView.frame.size.width,
                                                            y: 0,
                                                            width: containerView.frame.size.width,
                                                            height: containerView.frame.size.height))
            pageView.isUserInteractionEnabled = true
            pageView.setup(total: viewModels.count,
                           position: pos,
                           image: viewModels[pos].illustration,
                           title: viewModels[pos].title,
                           message: viewModels[pos].message) { buttonTag in
                if buttonTag < 4 {
                    self.scrollView.setContentOffset(
                        CGPoint(x: self.containerView.frame.size.width * CGFloat(buttonTag),
                                y: 0), animated: true)
                } else {
                    OnboardingCompletionAssistant.shared.setAsComplete()
                    self.showMainFlow()
                }
            } handleClose: { _ in
                OnboardingCompletionAssistant.shared.setAsComplete()
                self.showMainFlow()
            }

            scrollView.addSubview(pageView)
        }
        scrollView.contentSize = CGSize(width: containerView.frame.size.width * CGFloat(viewModels.count), height: 0)
    }
    
    @objc private func didTapButton(button: UIButton) {
        if button.tag < 4 {
            scrollView.setContentOffset(CGPoint(x: containerView.frame.size.width * CGFloat(button.tag), y: 0), animated: true)
        } else {
            OnboardingCompletionAssistant.shared.setAsComplete()
            showMainFlow()
        }
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
