//
//  WebContentViewController.swift
//  Contributor
//
//  Created by johnm on 08/11/18.
//  Copyright © 2018 Measure. All rights reserved.
//

import UIKit
import WebKit
import SnapKit

protocol WebContentDelegate: class {
    func didFinishNavigation(navigationAction: WKNavigationAction)
}

extension WebContentDelegate {
    func didFinishNavigation(navigationAction: WKNavigationAction) {}
}

class WebContentViewController: UIViewController {
  var webView: WKWebView!
  var startURL: URL?
  var startHTMLString: String?
  var startBaseURL: URL?
  var shouldHideBackButton: Bool = true
  weak var webContentDelegate: WebContentDelegate?
  var isFromSetting: Bool = false
  var isFromSupport: Bool = false
  var isFromSurveyStartPage: Bool = false
    var isFromFeedScreen: Bool = false

    
  let activityIndicator: UIActivityIndicatorView = {
    let activityIndicator = UIActivityIndicatorView(style: .large)
    activityIndicator.tintColor = .gray
    activityIndicator.hidesWhenStopped = true
    return activityIndicator
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .white
    setupWebview()
    setupViews()
    setupNavbar()

    if let url = startURL {
        var request = URLRequest(url: url)
        request.setValue(AppLanguageManager.shared.getLanguage() ?? "en", forHTTPHeaderField: "Accept-Language")
      webView.load(request)
    } else if let string = startHTMLString {
      webView.loadHTMLString(string, baseURL: startBaseURL)
    }
    addSurveyObserver()
  }

  func addSurveyObserver() {
    NotificationCenter.default.addObserver(self, selector: #selector(dismissSurvey),
                                           name: NSNotification.Name.dismissSurveyPage, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(refreshWebView),
                                           name: NSNotification.Name.refreshWebview, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(self.onApplicationEnterForeground),
                                           name: UIApplication.willEnterForegroundNotification, object: nil)
  }
    
 override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    NotificationCenter.default.addObserver(self, selector: #selector(moveToNext),
                                           name: NSNotification.Name.initialSurveyStart, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(moveToBack),
                                           name: NSNotification.Name.moveBackwardSurveyPage, object: nil)
    self.currentTabBar?.setBar(hidden: true, animated: false)
  }
    
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    NotificationCenter.default.removeObserver(self, name: NSNotification.Name.moveBackwardSurveyPage, object: nil)
    NotificationCenter.default.removeObserver(self, name: NSNotification.Name.initialSurveyStart, object: nil)
  }
    
  override func setupViews() {
    view.addSubview(webView)
    webView.snp.makeConstraints { (make) in
      make.edges.equalTo(view)
    }
  }
  
  func setupWebview() {
    let config = WKWebViewConfiguration()
    webView = WKWebView(frame: CGRect.zero, configuration: config)
    webView.backgroundColor = .white
    webView.contentMode = .scaleAspectFit
    webView.tintColor = Constants.primaryColor
    webView.navigationDelegate = self
  }
    
    func setupNavbar() {
        if !isFromSetting {
            if shouldHideBackButton {
                hideBackButtonTitle()
            } else {
                navigationItem.leftBarButtonItem = backBarButtonItem()
            }
        }
        if isFromSupport || isFromSurveyStartPage {
            // prevent downward swiping to dismiss
            if #available(iOS 13.0, *) {
                isModalInPresentation = true
            }
        }
        if isFromFeedScreen {
            let backbutton = UIButton(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
            backbutton.backgroundColor = .clear
            backbutton.imageView?.image?.withTintColor(.red)
            backbutton.setImage(UIImage.init(named: "back-arrow")!, for: .normal)
            backbutton.setTitle(" Feed", for: .normal)
            backbutton.setTitleColor(UIColor.black, for: .normal)
            backbutton.titleLabel?.font = Font.bold.of(size: 19)
            backbutton.addTarget(self, action: #selector(self.dismissSelf), for: .touchUpInside)
            navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backbutton)
            navigationItem.leftBarButtonItem?.tintColor = .red
        }
        webView.contentMode = .scaleAspectFill
        webView.addSubview(activityIndicator)
        activityIndicator.updateIndicatorView(self, hidden: false)
        activityIndicator.snp.makeConstraints { (make) in
            make.width.equalTo(20)
            make.height.equalTo(20)
            make.centerX.equalTo(self.webView)
            make.centerY.equalTo(self.webView)
        }
    }
    @objc func close() {
      dismissSelf()
    }
  func goToUrl(urlString: String) {
    goToUrl(url: URL(string: urlString)!)
  }
  
  func goToUrl(url: URL) {
    guard let webView = webView else {
      print("Webview controller isn't loaded so can't go to URL")
      return
    }
    debugPrint("The Url is >>>,", url)
    var request = URLRequest(url: url)
    request.setValue(AppLanguageManager.shared.getLanguage() ?? "en", forHTTPHeaderField: "Accept-Language")
    webView.load(request)
  }
  
  func showHTMLString(_ string: String, baseURL: URL?) {
    guard let webView = webView else {
      print("Webview controller isn't loaded so can't load string")
      return
    }
    webView.loadHTMLString(string, baseURL: baseURL)
  }
  
  static func createAppPageHTMLString(_ string: String) -> String {
    let top = """
      <!doctype html>
      <html lang="en">
      <head>
          <meta charset="utf-8">
          <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
          <script src="https://use.typekit.net/rll0ypr.js"></script>
          <script>try {
              Typekit.load({async: true});
          } catch (e) {
          }</script>
          <link rel="stylesheet" href="/static/web/dist/style.css">
          <script src="/static/web/dist/bundle.js"></script>
      </head>
      <body class="no-nav">
    """
    
    let bottom = """
      </body>
      </html>
    """
    
    return top + string + bottom
  }

@objc func onApplicationEnterForeground() {
  if startURL == Constants.statusDownBaseURL {
    Helper.checkAppAvailabilityStatus(self) { [weak self] (isSuccess, measureAppStatus) in
        if isSuccess == false { return }
         guard let this = self else { return }
         if measureAppStatus == .available {
            this.dismissSelf()
            NotificationCenter.default.post(name: NSNotification.Name.refreshController,
                                            object: nil, userInfo: nil)
         }
      }
    }
}
    
override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
  setUIDocumentMenuViewControllerSoureViewsIfNeeded(viewControllerToPresent)
  super.present(viewControllerToPresent, animated: flag, completion: completion)
}

func setUIDocumentMenuViewControllerSoureViewsIfNeeded(_ viewControllerToPresent: UIViewController) {
  if #available(iOS 13, *), viewControllerToPresent is UIDocumentMenuViewController {
    viewControllerToPresent.popoverPresentationController?.sourceView = webView
    let webViewFrame = CGRect(x: webView.center.x, y: webView.center.y, width: 1, height: 1)
    viewControllerToPresent.popoverPresentationController?.sourceRect = webViewFrame
    let arrowDirection = UIPopoverArrowDirection(rawValue: 0)
    viewControllerToPresent.popoverPresentationController?.permittedArrowDirections = arrowDirection
   }
 }
}

extension WebContentViewController: WKNavigationDelegate {
    
  func webView(_ webView: WKWebView,
               decidePolicyFor navigationAction: WKNavigationAction,
               decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
     webContentDelegate?.didFinishNavigation(navigationAction: navigationAction)
     decisionHandler(WKNavigationActionPolicy.allow)
  }
    
  func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
    if let clickedUrl = webView.url?.absoluteString,
           clickedUrl == Constants.finishRecordingButtonUrl {
        activityIndicator.updateIndicatorView(self, hidden: true)
    } else {
        if ConnectivityUtils.isConnectedToNetwork() == false {
            activityIndicator.updateIndicatorView(self, hidden: true)
        } else {
            activityIndicator.updateIndicatorView(self, hidden: false)
        }
    }
  }
  
  func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
    if shouldHideBackButton {
        if webView.canGoBack {
            self.navigationItem.leftBarButtonItems?[0].isEnabled = true
        } else {
            self.navigationItem.leftBarButtonItems?[0].isEnabled = false
        }
    }
    activityIndicator.updateIndicatorView(self, hidden: true)
    logFirebaseAnalytics()
  }
  
  func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
    activityIndicator.updateIndicatorView(self, hidden: true)
  }
}

extension WebContentViewController {
  
func logFirebaseAnalytics() {
  if startURL == Constants.termsURL {
    FirebaseAnalyticsManager.shared.logFirebaseAnalytics(.termsConditionScreen)
  }
  if startURL == Constants.privacyURL {
    FirebaseAnalyticsManager.shared.logFirebaseAnalytics(.privacyPolicyScreen)
  }
  if startURL == Constants.faqURL {
    FirebaseAnalyticsManager.shared.logFirebaseAnalytics(.faqScreen)
  }
  if startURL == Constants.statusDownBaseURL {
    FirebaseAnalyticsManager.shared.logFirebaseAnalytics(.maintScreen)
  }
}
    
@objc func moveToNext() {}

@objc func moveToBack() {
 if webView.canGoBack {
  webView.goBack()
 }
}

@objc func refreshWebView() {
  activityIndicator.updateIndicatorView(self, hidden: true)
}

@objc func dismissSurvey() {
  Router.shared.route(
    to: Route.jobExitView(offerType: .externalOffer),
    from: self,
    presentationType: .modal(presentationStyle: .pageSheet, transitionStyle: .coverVertical))
   }
}
