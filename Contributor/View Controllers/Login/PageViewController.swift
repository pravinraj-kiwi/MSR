//
//  OnboardingViewController.swift
//  Contributor
//
//  Created by arvindh on 29/08/18.
//  Copyright © 2018 Measure. All rights reserved.
//

import SnapKit
import UIKit
import UserNotifications

class PageViewController: UIViewController {
  var viewControllers: [UIViewController] = []
  
  let pageScrollView: UIScrollView = {
    let scrollView = UIScrollView()
    scrollView.showsVerticalScrollIndicator = false
    scrollView.showsHorizontalScrollIndicator = false
    scrollView.isPagingEnabled = true
    scrollView.scrollsToTop = false
    scrollView.backgroundColor = Constants.backgroundColor
    return scrollView
  }()
  
  let containerView: UIView = {
    let view = UIView()
    view.clipsToBounds = true
    return view
  }()
  
  let pageControl: UIPageControl = UIPageControl(frame: CGRect.zero)
  
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .default
  }
  
  convenience init(viewControllers: [UIViewController]) {
    self.init(nibName: nil, bundle: nil)
    self.viewControllers = viewControllers
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupViews()
    layoutViewControllers()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    pageScrollView.setNeedsLayout()
    pageScrollView.layoutIfNeeded()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  override func setupViews() {
    let scrollViewContainer = UIView()
    view.addSubview(scrollViewContainer)
    scrollViewContainer.snp.makeConstraints { (make) in
      make.top.equalTo(view.safeAreaLayoutGuide)
      make.left.equalTo(view)
      make.right.equalTo(view)
    }
    
    scrollViewContainer.addSubview(pageScrollView)
    pageScrollView.snp.makeConstraints { (make: ConstraintMaker) in
      make.edges.equalTo(scrollViewContainer)
    }
    pageScrollView.delegate = self
    
    pageScrollView.addSubview(containerView)
    containerView.snp.makeConstraints { (make: ConstraintMaker) in
      make.edges.equalTo(pageScrollView)
      make.height.equalTo(scrollViewContainer)
    }
    
    view.addSubview(pageControl)
    pageControl.snp.makeConstraints { (make: ConstraintMaker) in
      make.top.equalTo(scrollViewContainer.snp.bottom)
      make.left.equalTo(view)
      make.right.equalTo(view)
      make.height.equalTo(20)
      make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-8)
    }
    pageControl.numberOfPages = viewControllers.count
    
    applyCommunityTheme()
  }
  
  func layoutViewControllers() {
    for (index, controller) in viewControllers.enumerated() {
      addChild(controller)
      containerView.addSubview(controller.view)
      
      let previousVC: UIViewController? = (index == 0) ? nil : viewControllers[index - 1]
      controller.view.snp.makeConstraints({ make in
        make.top.equalTo(containerView)
        make.bottom.equalTo(containerView)
        if let pvc = previousVC {
          make.left.equalTo(pvc.view.snp.right)
        } else {
          make.left.equalTo(containerView)
        }
        if index == viewControllers.count - 1 {
          make.right.equalTo(containerView)
        }
        make.width.equalTo(pageScrollView)
      })
      controller.didMove(toParent: self)
    }
  }
}

extension PageViewController: UIScrollViewDelegate {
  func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    let currentOffsetX = max(0, scrollView.contentOffset.x)
    let pageIndex = Int(currentOffsetX / scrollView.frame.size.width)
    pageControl.currentPage = pageIndex
  }
  
  func scrollTo(_ page: Int) {
    let newpage = CGFloat(page)
    let offsetPoint: CGPoint = CGPoint(x: pageScrollView.frame.size.width * newpage, y: 0)
    pageScrollView.setContentOffset(offsetPoint, animated: true)
  }
}

extension PageViewController: CommunityThemeConfigurable {
  @objc func applyCommunityTheme() {
    guard let community = UserManager.shared.currentCommunity, let colors = community.colors else {
      return
    }
    
    view.backgroundColor = colors.background
    containerView.backgroundColor = colors.background
    
    pageControl.backgroundColor = colors.background
    pageControl.currentPageIndicatorTintColor = colors.primary
    pageControl.pageIndicatorTintColor = colors.veryLightText
  }
}
