//
//  OnboardingViewController.swift
//  {{ cookiecutter.project_name | replace(' ', '') }}
//
//  Created by {{ cookiecutter.lead_dev }} on 29/06/2017.
//  Copyright © 2017 {{ cookiecutter.company_name }}. All rights reserved.
//

import UIKit
import Anchorage
import Swiftilities

protocol OnboardingViewControllerProtocol: BaseViewControllerProtocol {

}

// MARK: OnboardingPageViewController
class OnboardingViewController: BaseViewController, OnboardingViewControllerProtocol {

    fileprivate let viewControllers: [UIViewController]

    fileprivate let skipButton: UIButton = {
        let button = UIButton()
        button.setTitle("SKIP", for: .normal) //TODO: localization
        button.setTitleColor(ColorSchemes.darkGray, for: .normal)
        button.setTitleColor(ColorSchemes.darkGray.highlighted, for: .highlighted)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        return button
    }()
    fileprivate let pageController = UIPageViewController(
        transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    fileprivate let firstHairline = HairlineView(axis: .horizontal)
    fileprivate let joinButton: UIButton = {
        let button = UIButton()
        button.setTitle("JOIN", for: .normal) //TODO: localization
        button.setTitleColor(ColorSchemes.green, for: .normal)
        button.setTitleColor(ColorSchemes.green.highlighted, for: .highlighted)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        return button
    }()
    fileprivate let secondHairline = HairlineView(axis: .horizontal)
    fileprivate let signInButton: UIButton = {
        let button = UIButton()
        button.setTitle("SIGN IN", for: .normal) //TODO: localization
        button.setTitleColor(ColorSchemes.darkGray, for: .normal)
        button.setTitleColor(ColorSchemes.darkGray.highlighted, for: .highlighted)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        return button
    }()

    init(viewModels: [OnboardingSamplePageViewModel]) {
        self.viewControllers = viewModels.map {
            OnboardingSamplePageViewController(viewModel: $0)
        }
        super.init(nibName: nil, bundle: nil)
    }

    //this is necessary because we are declaring a custom constructor for the class
    @available(*, unavailable) required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        configureLayout()
    }
}

// MARK: Private
private extension OnboardingViewController {

    func configureView() {
        view.backgroundColor = .white
        view.addSubview(skipButton)
        skipButton.addTarget(self, action: #selector(skipTapped), for: .touchUpInside)

        pageController.setViewControllers(
            [viewControllers[0]], direction: .forward, animated: false, completion: nil)
        pageController.dataSource = self
        addChildViewController(pageController)
        view.addSubview(pageController.view)
        pageController.didMove(toParentViewController: self)

        let pageControlAppearance = UIPageControl.appearance(whenContainedInInstancesOf: [OnboardingViewController.self])
        pageControlAppearance.pageIndicatorTintColor = ColorSchemes.lightGray
        pageControlAppearance.currentPageIndicatorTintColor = ColorSchemes.darkGray

        view.addSubview(firstHairline)
        joinButton.addTarget(self, action: #selector(joinTapped), for: .touchUpInside)
        view.addSubview(joinButton)
        view.addSubview(secondHairline)
        signInButton.addTarget(self, action: #selector(signInTapped), for: .touchUpInside)
        view.addSubview(signInButton)
    }

    struct Layout {
        static let skipButtonTrailingInset = CGFloat(20)
        static let skipButtonTopInset = CGFloat(22)
        static let pageViewTopSpace = CGFloat(20)
        static let joinVerticalSpace = CGFloat(8)
        static let signInVerticalSpace = CGFloat(18)
    }

    func configureLayout() {
        skipButton.topAnchor == view.topAnchor + Layout.skipButtonTopInset
        skipButton.trailingAnchor == view.trailingAnchor - Layout.skipButtonTrailingInset

        pageController.view.topAnchor == skipButton.bottomAnchor + Layout.pageViewTopSpace
        pageController.view.horizontalAnchors == view.horizontalAnchors

        firstHairline.topAnchor == pageController.view.bottomAnchor
        firstHairline.horizontalAnchors == view.horizontalAnchors

        joinButton.horizontalAnchors == view.horizontalAnchors
        joinButton.topAnchor == firstHairline.bottomAnchor + Layout.joinVerticalSpace
        joinButton.bottomAnchor == secondHairline.topAnchor - Layout.joinVerticalSpace

        secondHairline.horizontalAnchors == view.horizontalAnchors

        signInButton.horizontalAnchors == view.horizontalAnchors
        signInButton.topAnchor == secondHairline.bottomAnchor + Layout.signInVerticalSpace
        signInButton.bottomAnchor == view.bottomAnchor - Layout.signInVerticalSpace
    }

}

// MARK: Actions Handling
private extension OnboardingViewController {

    @objc func skipTapped() {
        //delegate?.skipTapped(for: self)
        (self.presenter as? OnboardingPresenterProtocol)?.userFinishedWelcome(action: OnboardingQuitActions.skip)
    }

    @objc func joinTapped() {
         (self.presenter as? OnboardingPresenterProtocol)?.userFinishedWelcome(action: OnboardingQuitActions.register)
    }

    @objc func signInTapped() {
         (self.presenter as? OnboardingPresenterProtocol)?.userFinishedWelcome(action: OnboardingQuitActions.sign_in)
    }
}

// MARK: UIPageViewControllerDataSource
extension OnboardingViewController: UIPageViewControllerDataSource {

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let index = viewControllers.index(of: viewController), index > 0 else {
            return nil
        }
        return viewControllers[index - 1]
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let index = viewControllers.index(of: viewController),
            index < viewControllers.count - 1 else {
                return nil
        }
        return viewControllers[index + 1]
    }

    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return viewControllers.count
    }

    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        guard let current = pageViewController.viewControllers?.first else {
            return 0
        }
        return viewControllers.index(of: current) ?? 0
    }
}
