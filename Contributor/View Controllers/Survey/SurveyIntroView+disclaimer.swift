//
//  SurveyIntroView+disclaimer.swift
//  Contributor
//
//  Created by KiwiTech on 10/28/20.
//  Copyright © 2020 Measure. All rights reserved.
//

import UIKit
import WebKit

extension SurveyIntroViewController {
    
func updateDisclaimerPageFromMyData() {
 bottomContainer.addSubview(bottomContentContainer)
 bottomContentContainer.snp.makeConstraints { (make) in
   make.top.equalTo(bottomContainer)
   make.bottom.equalTo(bottomContainer)
   make.left.equalTo(bottomContainer).offset(Layout.containerInset)
   make.right.equalTo(bottomContainer).offset(-Layout.containerInset)
 }
    
 bottomContentContainer.addSubview(jobTypeImageView)
 jobTypeImageView.snp.makeConstraints { (make) in
   make.top.equalTo(bottomContentContainer).offset(40)
   make.left.equalTo(bottomContentContainer)
   make.width.equalTo(Layout.jobTypeImageWidth)
   make.height.equalTo(Layout.jobTypeImageHeight)
 }

 bottomContentContainer.addSubview(jobTypeHeadingLabel)
 jobTypeHeadingLabel.snp.makeConstraints { (make) in
   make.top.equalTo(jobTypeImageView).offset(1)
   make.left.equalTo(jobTypeImageView.snp.right).offset(10)
   make.right.equalTo(bottomContentContainer)
 }

 bottomContentContainer.addSubview(jobTypeContentLabel)
 jobTypeContentLabel.snp.makeConstraints { (make) in
   make.top.equalTo(jobTypeImageView.snp.bottom).offset(15)
   make.left.equalTo(jobTypeImageView)
   make.right.equalTo(bottomContentContainer)
 }

 bottomContentContainer.addSubview(privacyImageView)
 privacyImageView.snp.makeConstraints { (make) in
   make.top.equalTo(jobTypeContentLabel.snp.bottom).offset(40)
   make.left.equalTo(bottomContentContainer)
   make.width.equalTo(Layout.privacyImageWidth)
   make.height.equalTo(Layout.privacyImageHeight)
 }

 bottomContentContainer.addSubview(privacyHeadingLabel)
 privacyHeadingLabel.snp.makeConstraints { (make) in
   make.top.equalTo(privacyImageView).offset(1)
   make.left.equalTo(privacyImageView.snp.right).offset(10)
   make.right.equalTo(bottomContentContainer)
 }

 bottomContentContainer.addSubview(privacyContentLabel)
 privacyContentLabel.snp.makeConstraints { (make) in
   make.top.equalTo(privacyImageView.snp.bottom).offset(15)
   make.left.equalTo(privacyImageView)
   make.right.equalTo(bottomContentContainer)
 }

 bottomContentContainer.addSubview(communityLinksStackView)
 communityLinksStackView.snp.makeConstraints { (make) in
   make.top.equalTo(privacyContentLabel.snp.bottom).offset(10)
   make.left.equalTo(container)
   make.right.equalTo(container)
   make.bottom.equalTo(bottomContentContainer).offset(-38).priority(999)
 }
 updateCommunityView()
}
    
func updateCommunityView() {
 communityLinksStackView.addArrangedSubview(communityPrivacyPolicyButton)
 communityLinksStackView.addArrangedSubview(communityTermsOfServiceButton)
 communityLinksStackView.addArrangedSubview(communityAccessibilityButton)
 communityLinksStackView.addArrangedSubview(communityContactButton)
 communityPrivacyPolicyButton.isHidden = true
 communityTermsOfServiceButton.isHidden = true
 communityAccessibilityButton.isHidden = true
 communityContactButton.isHidden = true
    
 communityPrivacyPolicyButton.addTarget(self, action: #selector(showCommunityPrivacyPolicy), for: .touchUpInside)
 communityTermsOfServiceButton.addTarget(self, action: #selector(showCommunityTermsOfService), for: .touchUpInside)
 communityAccessibilityButton.addTarget(self, action: #selector(showCommunityAccessibility), for: .touchUpInside)
 communityContactButton.addTarget(self, action: #selector(showCommunityContact), for: .touchUpInside)
}
    
func updateDisclaimerPageFromFeed() {
 bottomContainer.backgroundColor = .clear
 bottomContainer.addSubview(webStackView)
 webStackView.snp.makeConstraints { (make) in
    make.top.equalTo(bottomContainer)
    make.bottom.equalTo(bottomContainer)
    make.left.equalTo(bottomContainer)
    make.right.equalTo(bottomContainer)
 }
    
 webStackView.addArrangedSubview(disclaimerWebView)
 disclaimerWebView.navigationDelegate = self
 disclaimerWebView.scrollView.isScrollEnabled = true
 disclaimerWebView.contentMode = .scaleAspectFit
 disclaimerWebView.snp.makeConstraints { (make) in
    make.top.equalTo(webStackView)
    make.left.equalTo(webStackView)
    make.trailing.equalTo(webStackView)
    make.height.equalTo(400)
 }
    
 disclaimerWebView.addSubview(activityIndicator)
 activityIndicator.showIndicatorView(hidden: false)
 activityIndicator.snp.makeConstraints { (make) in
     make.width.equalTo(20)
     make.height.equalTo(20)
     make.centerX.equalTo(self.disclaimerWebView)
     make.centerY.equalTo(self.disclaimerWebView)
   }
  }
}

extension SurveyIntroViewController: WKNavigationDelegate {
    
  func webView(_ webView: WKWebView,
               decidePolicyFor navigationAction: WKNavigationAction,
               decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
    if let privacyUrl = navigationAction.request.url?.absoluteString {
        if Constants.privacyURL == URL(string: privacyUrl) {
            if ConnectivityUtils.isConnectedToNetwork() == false {
                activityIndicator.showIndicatorView(hidden: true)
                Helper.showNoNetworkAlert(controller: self)
                decisionHandler(WKNavigationActionPolicy.cancel)
                return
            }
            Helper.clickToOpenUrl(Constants.privacyURL, controller: self,
                                  title: Text.privacy.localized(), isFromSurveyStartPage: true)
            decisionHandler(WKNavigationActionPolicy.cancel)
            return
        }
    }
    if let termUrl = navigationAction.request.url?.absoluteString {
        if Constants.termsURL == URL(string: termUrl) {
            if ConnectivityUtils.isConnectedToNetwork() == false {
                activityIndicator.showIndicatorView(hidden: true)
                Helper.showNoNetworkAlert(controller: self)
                decisionHandler(WKNavigationActionPolicy.cancel)
                return
            }
            Helper.clickToOpenUrl(Constants.termsURL, controller: self,
                                  title: Text.termsCondition.localized(), isFromSurveyStartPage: true)
            decisionHandler(WKNavigationActionPolicy.cancel)
            return
        }
    }
    decisionHandler(WKNavigationActionPolicy.allow)
  }
    
  func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
    activityIndicator.showIndicatorView(hidden: false)
  }
  
  func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
    webView.backgroundColor = .clear
    webView.isOpaque = false
    activityIndicator.showIndicatorView(hidden: true)
  }
  
  func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
    activityIndicator.showIndicatorView(hidden: true)
    disclaimerWebView.loadHTMLString(StaticHtml().surveyStartPageHtml(),
                                     baseURL: Constants.baseContributorAPIURL)
  }
}
