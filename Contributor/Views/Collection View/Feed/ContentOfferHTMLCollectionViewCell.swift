//
//  ContentOfferHTMLCollectionViewCell.swift
//  Contributor
//
//  Created by Shashi Kumar on 26/05/21.
//  Copyright © 2021 Measure. All rights reserved.
//

import Foundation
import UIKit
import CoreMotion
import Kingfisher
import SwiftyAttributes
import WebKit
protocol ContentOfferHTMLCellDelegate: class {
    func closeOffer()
    func navigateWebLinks(url: URL?)
}
class ContentOfferHTMLCollectionViewCell: CardCollectionViewCell {
    struct Layout {
        static var cardContentInset = UIEdgeInsets(top: 15, left: 20, bottom: 20, right: 20)
        static var cardHeaderBottomMargin: CGFloat = 20
        static var cardHeaderHeight: CGFloat = 63
        static var lineSpacing = Constants.defaultLineSpacing
        static var imageCornerRadius: CGFloat = 31
        static var imageHeight: CGFloat = 62
    }
    weak var delegate: ContentOfferHTMLCellDelegate?
    var topHeaderView: UIView = {
        let view = UIView()
        return view
    }()
    let crossButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(Image.crossWhite.value, for: .normal)
        button.clipsToBounds = true
        button.showsTouchWhenHighlighted = true
        button.adjustsImageWhenHighlighted = true
        button.backgroundColor = .clear
        return button
    }()
    var imageBaseView: UIView = {
        let view = UIView()
        //view.backgroundColor = .clear
        return view
    }()
    
    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.masksToBounds = true
        return iv
    }()
    let activityIndicator: UIActivityIndicatorView = {
      let activityIndicator = UIActivityIndicatorView(style: .large)
      activityIndicator.tintColor = .gray
      activityIndicator.hidesWhenStopped = true
      return activityIndicator
    }()
    let cardHeaderContainer = UIView()
    
    let contentWebView: WKWebView = {
        var webView = WKWebView()
        let config = WKWebViewConfiguration()
        webView = WKWebView(frame: CGRect.zero, configuration: config)
        webView.contentMode = .scaleAspectFit
        return webView
    }()
    var webViewHeight: CGFloat = 0

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    static func calculateHeightForWidth(item: Story?, width: CGFloat) -> CGFloat {
        guard let item = item?.item else {return 0.0}
        
        let cardWidth = width - CardLayout.cardInset.left - CardLayout.cardInset.right
        let contentWidth = cardWidth - Layout.cardContentInset.left - Layout.cardContentInset.right
        var webLayoutHeight: CGFloat = 0

       // let _ = item.layoutType {
          switch item.layoutType {
          case .webImage4x2:
            webLayoutHeight = calculateImageHeight(width: cardWidth, widthRatio: 4, heightRatio: 2)
          case .webImage4x3:
            webLayoutHeight = calculateImageHeight(width: cardWidth, widthRatio: 4, heightRatio: 3)
          case .webImage4x4:
            webLayoutHeight = calculateImageHeight(width: cardWidth, widthRatio: 4, heightRatio: 4)
          default:
            webLayoutHeight = 250
            break
          }
       // }
        
        let height: CGFloat = CardLayout.cardInset.top
            + Layout.cardHeaderHeight
            + Layout.cardHeaderBottomMargin
            + Layout.cardContentInset.bottom
            + CardLayout.cardInset.bottom
            + webLayoutHeight
       
        return height
    }
    static func calculateImageHeight(width: CGFloat, widthRatio: CGFloat, heightRatio: CGFloat) -> CGFloat {
        
      return width * heightRatio / widthRatio
    }
    func setupViews() {
        cardView.addSubview(topHeaderView)
        topHeaderView.snp.makeConstraints { make in
            make.top.equalTo(0)
            make.left.equalTo(0)
            make.right.equalTo(0)
            make.height.equalTo(Layout.cardHeaderHeight)
            make.width.equalToSuperview()
        }
        cardView.addSubview(crossButton)
        crossButton.snp.makeConstraints { (make) in
           // make.topMargin.equalTo(25)
            make.right.equalTo(0)
            make.height.equalTo(50)
            make.width.equalTo(50)
           // make.centerY.equalToSuperview()
        }
        cardView.addSubview(imageBaseView)
        imageBaseView.snp.makeConstraints { (make) in
            make.topMargin.equalTo(25)
            make.height.equalTo(Layout.imageHeight)
            make.width.equalTo(Layout.imageHeight)
            make.centerX.equalToSuperview()
        }
        
        imageBaseView.addSubview(imageView)
        imageView.snp.makeConstraints { (make) in
            make.topMargin.equalTo(0)
            make.height.equalTo(Layout.imageHeight)
            make.width.equalTo(Layout.imageHeight)
            make.centerX.equalToSuperview()
        }
        imageBaseView.backgroundColor = UIColor.white
        imageView.backgroundColor = .white
        imageView.clipsToBounds = true
        imageView.layer.borderWidth = 3.0
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.layer.cornerRadius = Layout.imageCornerRadius
        imageBaseView.addShadowToCircularView(size: CGSize(width: 1.0, height: 5.5))
        cardView.addSubview(contentWebView)
         contentWebView.navigationDelegate = self
        contentWebView.backgroundColor = .clear
        contentWebView.scrollView.isScrollEnabled = true
        contentWebView.contentMode = .scaleAspectFit
        contentWebView.snp.makeConstraints { (make) in
            make.top.equalTo(imageView.snp.bottom).offset(Layout.cardContentInset.top)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.bottom.equalToSuperview().offset(-20)
           // make.height.equalTo(webViewHeight)
        }
        contentWebView.addSubview(activityIndicator)
        activityIndicator.showIndicatorView(hidden: false)
        activityIndicator.snp.makeConstraints { (make) in
            make.width.equalTo(20)
            make.height.equalTo(20)
            make.centerX.equalTo(self.contentWebView)
            make.centerY.equalTo(self.contentWebView)
          }
        crossButton.addTarget(self,
                              action: #selector(self.closeOffer),
                              for: UIControl.Event.touchUpInside)

        contentView.setNeedsUpdateConstraints()
        debugPrint("setUpViews>>>>>",topHeaderView.bounds)
    }
    func styleUI() {
       // debugPrint("styleUI>>>>>")
        DispatchQueue.main.async {
            self.imageBaseView.layer.cornerRadius = self.imageBaseView.frame.width/2.0
            self.imageBaseView.addShadowToCircularView(size: CGSize(width: 1.0, height: 2.5))
            guard let community = UserManager.shared.currentCommunity, let colors = community.colors else {
                return
            }
            let startColor = colors.primary.withAlphaComponent(0.6)
            self.topHeaderView.layer.sublayers?.remove(at: 0)
            self.topHeaderView.applyGradient(colors: [startColor.cgColor, colors.primary.cgColor],
                                             locations: [0.0, 1.0],
                                             direction: .leftToRight)
        }
        
        imageView.image = Image.dummyProfile.value
    }
    func configure(with item: Story) {
       // debugPrint("configureData>>>>>")
        contentWebView.scrollView.isScrollEnabled = false
        guard let contentItem = item.item else {return}
        
        if let url = contentItem.icon {
            imageView.kf.setImage(with: URL(string: url))
        }
        if let htmlUrl = contentItem.htmlURL, let url = URL(string: htmlUrl) {
            var request = URLRequest(url: url)
            request.setValue(AppLanguageManager.shared.getLanguage() ?? "en", forHTTPHeaderField: "Accept-Language")
            contentWebView.load(request)
           // contentWebView.load(URLRequest(url: url))
        } else {
             contentWebView.loadHTMLString(contentItem.html ?? "", baseURL: nil)
        }
    }
    @objc func closeOffer() {
        delegate?.closeOffer()
    }
}
extension ContentOfferHTMLCollectionViewCell: WKNavigationDelegate {
    
  func webView(_ webView: WKWebView,
               decidePolicyFor navigationAction: WKNavigationAction,
               decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
    if let privacyUrl = navigationAction.request.url?.absoluteString {
        if URL(string: "http://google.com/") == URL(string: privacyUrl) {
            if ConnectivityUtils.isConnectedToNetwork() == false {
                activityIndicator.showIndicatorView(hidden: true)
                //Helper.showNoNetworkAlert(controller: self)
                decisionHandler(WKNavigationActionPolicy.cancel)
                return
            }
            self.delegate?.navigateWebLinks(url: URL(string: privacyUrl))
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
    contentWebView.loadHTMLString(StaticHtml().surveyStartPageHtml(),
                                     baseURL: Constants.baseContributorAPIURL)
  }
}
