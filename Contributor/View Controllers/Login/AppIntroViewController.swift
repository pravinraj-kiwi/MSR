//
//  AppIntroViewController.swift
//  Contributor
//
//  Created by arvindh on 26/01/19.
//  Copyright © 2019 Measure. All rights reserved.
//

import os
import UIKit
import UserNotifications
import SwiftyUserDefaults
import Kingfisher
import SDWebImagePDFCoder

class AppIntroViewController: UIViewController {
    struct Layout {
        static let defaultLogoWidth: CGFloat = 150
        static let communityLogoWidth: CGFloat = 260
        static let actionButtonBottomMargin: CGFloat = 60
        static let actionButtonWidth: CGFloat = 180
        static let actionButtonHeight: CGFloat = 44
        static let poweredByTopMargin: CGFloat = 15
        static var poweredByFont = Font.regular.of(size: 15)
    }
    
    let container: UIView = {
        let view = UIView()
        view.backgroundColor = Color.introScreenButton.value
        return view
    }()
    
    let spacerView = UIView()
    
    let defaultLogoImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.image = Image.logoGray.value
        return iv
    }()
    
    let communityLogoImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        return iv
    }()
    
    let poweredByLabel: UILabel = {
        let label = UILabel()
        label.font = Layout.poweredByFont
        label.numberOfLines = 1
        label.textAlignment = .center
        label.text = AppIntroText.waterMark
        return label
    }()
    
    let loadingActivityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(frame: CGRect.zero)
        indicator.color = .white
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    let actionButton: ActivityIndicatorButton = {
        let button = ActivityIndicatorButton(frame: CGRect.zero)
        button.layer.borderColor = Color.whiteText.value.cgColor
        button.layer.borderWidth = 2
        button.setDarkeningBackgroundColor(color: Constants.primaryColor)
        button.buttonTitleColor = Color.whiteText.value
        button.spinnerColor = Color.text.value
        button.setTitle(AppIntroText.getStarted.localized(), for: .normal)
        return button
    }()
    
    var loadDefaultTask: DispatchWorkItem?
    var haveStartedLoading = false
    var items = [OnboardingMessage]()
    let myGroup = DispatchGroup()
    static var defaultItems: [OnboardingMessage] {
        return [
            OnboardingMessage(
                image: Image.onboarding1.rawValue,
                title: Onboarding.onboardingTitle1.localized(),
                text: Onboarding.onboardingText1.localized(),
                showActionButton: false,
                showPillButton: false,
                layout: Text.basic.localized()
            ),
            OnboardingMessage(
                image: Image.onboarding2.rawValue,
                title: Onboarding.onboardingTitle2.localized(),
                text: Onboarding.onboardingText2.localized(),
                showActionButton: false,
                showPillButton: false,
                layout: Text.basic.localized()
            ),
            OnboardingMessage(
                image: Image.onboarding3.rawValue,
                title: Onboarding.onboardingTitle3.localized(),
                text: Onboarding.onboardingText3.localized(),
                showActionButton: false,
                showPillButton: false,
                layout: Text.basic.localized()
            ),
            OnboardingMessage(
                image: Image.onboarding4.rawValue,
                title: Onboarding.onboardingTitle4.localized(),
                text: Onboarding.onboardingText4.localized(),
                pillButtonText: Text.new,
                showActionButton: true,
                showPillButton: true,
                layout: Text.basic.localized()
            )
        ]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        addListeners()
        
        if Defaults[.community] == nil {
            Defaults[.community] = UserManager.shared.loadDefaultCommunity()
        } else {
            getCommunity { (_, _) in }
        }
        loadDefaultTask = DispatchWorkItem {
            if !self.haveStartedLoading {
                self.showDefaultIntro()
            }
        }
        runLoadDefaultTaskAfterDelay()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        AnalyticsManager.shared.logOnce(event: .appIntro)
        FirebaseAnalyticsManager.shared.logFirebaseAnalytics(.introScreen)
    }
    
    func getCommunity(completion: @escaping (Community?, Error?) -> Void) {
        UserManager.shared.loadCommunityFromDeepLink { (community, error) in
            if let error = error {
                completion(nil, error)
            }
            completion(community, nil)
        }
    }
    
    func addListeners() {
        NotificationCenter.default.addObserver(self, selector: #selector(onDeepLinkCommunityFound),
                                               name: .deepLinkCommunityFound, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onDeepLinkCommunityNotFound),
                                               name: .deepLinkCommunityNotFound, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onDeepLinkCommunityLoaded),
                                               name: .deepLinkCommunityLoaded, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onboardTemplateFound),
                                               name: .onboardTemplateFound, object: nil)
    }
    
    override func setupViews() {
        view.addSubview(container)
        container.snp.makeConstraints { (make) in
            make.edges.equalTo(view)
        }
        
        container.addSubview(defaultLogoImageView)
        defaultLogoImageView.snp.makeConstraints { (make) in
            make.width.equalTo(Layout.defaultLogoWidth)
            make.center.equalTo(container)
        }
        
        container.addSubview(spacerView)
        spacerView.snp.makeConstraints { (make) in
            make.top.equalTo(defaultLogoImageView.snp.bottom)
            make.bottom.equalTo(view.safeAreaLayoutGuide)
            make.width.equalToSuperview()
        }
        
        spacerView.addSubview(loadingActivityIndicator)
        loadingActivityIndicator.snp.makeConstraints { (make) in
            make.centerX.centerY.equalToSuperview()
        }
        loadingActivityIndicator.startAnimating()
    }
    
    func showActionButton() {
        print("Items count\(items.count)")
        spacerView.addSubview(actionButton)
        actionButton.snp.makeConstraints { (make) in
            make.width.equalTo(Layout.actionButtonWidth)
            make.height.equalTo(Layout.actionButtonHeight)
            make.centerX.centerY.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-50)
        }
        actionButton.addTarget(self, action: #selector(self.exitToOnboarding), for: .touchUpInside)
    }
    
    func runLoadDefaultTaskAfterDelay() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: loadDefaultTask!)
    }
    
    @objc func onDeepLinkCommunityNotFound() {
        if let task = loadDefaultTask, !task.isCancelled {
            task.cancel()
        }
        if !haveStartedLoading {
            showDefaultIntro()
        }
    }
    
    @objc func onboardTemplateFound() {
        self.loadingActivityIndicator.startAnimating()
        configureOnBoardTemplate { (onboardingData, _) in
            if let onboardingArray = onboardingData {
                self.prepareOnBoardingItems(items: onboardingArray) { (result) in
                    self.loadingActivityIndicator.stopAnimating()
                    UIView.transition(with: self.view, duration: 1.0, options: .transitionCrossDissolve, animations: {
                        self.defaultLogoImageView.image = Image.logo.value
                        self.container.backgroundColor = Color.introScreenButton.value
                        self.communityLogoImageView.image = Image.logo.value
                    }, completion: nil)
                    if result {
                        self.items = onboardingArray
                        DispatchQueue.main.async {
                            self.stopLoaderAndShowStartedButton()
                        }
                        self.showActionButton()
                    } else {
                        self.items = AppIntroViewController.defaultItems
                        self.showActionButton()
                        self.stopLoaderAndShowStartedButton()

                    }
                }
            }
        }
    }
    
    @objc func onDeepLinkCommunityFound() {
        if let task = loadDefaultTask, !task.isCancelled {
            task.cancel()
        }
        runLoadDefaultTaskAfterDelay()
    }
    
    @objc func onDeepLinkCommunityLoaded() {
        if let task = loadDefaultTask, !task.isCancelled {
            task.cancel()
        }
        showCommunityIntro()
    }
    
    func showDefaultIntro() {
        haveStartedLoading = true
        configureOnBoardTemplate { (onboardingData, _) in
            if let onboardingArray = onboardingData {
                self.prepareOnBoardingItems(items: onboardingArray) { (result) in
                    if result {
                        self.items = onboardingArray
                        DispatchQueue.main.async {
                            self.stopLoaderAndShowStartedButton()
                        }
                        self.showActionButton()
                    } else {
                        self.items = AppIntroViewController.defaultItems
                        self.showActionButton()
                        self.stopLoaderAndShowStartedButton()
                    }
                }
            }
        }
    }
    func stopLoaderAndShowStartedButton() {
        self.loadingActivityIndicator.stopAnimating()
        UIView.transition(with: self.view,
                          duration: 1.0,
                          options: .transitionCrossDissolve,
                          animations: {
            self.defaultLogoImageView.image = Image.logo.value
            self.container.backgroundColor = Color.introScreenButton.value
            self.communityLogoImageView.image = Image.logo.value
        },
                          completion: nil)
    }
    func prepareOnBoardingItems(items: [OnboardingMessage],
                                completion: @escaping(Bool)-> Void) {
        var isAllUrlValid = true
        for tmpObj in items {
            myGroup.enter()
        self.validateOnBoardingImages(url: tmpObj.imageUrl) { (result) in
                if result {
                    debugPrint("Successful image url")
                    self.myGroup.leave()
                } else {
                    debugPrint("error in url")
                    isAllUrlValid = false
                    completion(isAllUrlValid)
                }
            }
        }
        myGroup.notify(queue: .main) {
            print("Finished all requests.", isAllUrlValid)
            completion(isAllUrlValid)
        }
    }
    func saveImage(image: UIImage, fileName: String) -> Bool {
        guard let data = image.jpegData(compressionQuality: 1) ?? image.pngData() else {
            return false
        }
        guard let directory = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) as NSURL else {
            return false
        }
        do {
            try data.write(to: directory.appendingPathComponent("\(fileName).png")!)
            return true
        } catch {
            print(error.localizedDescription)
            return false
        }
    }
    func validateOnBoardingImages(url: String?,
                                  completion: @escaping(Bool)-> Void) {
        if let imgUrl = url, url != "" {
            if let url = URL(string: imgUrl) {
                debugPrint("Image Url is ", url)
                if let image = self.drawPDFfromURL(url: url) {
                    let fileNameWithoutExtension = imgUrl.fileName()

                   let isSuccess = self.saveImage(image: image, fileName: fileNameWithoutExtension)
                    if isSuccess {
                        completion(true)
                    } else {
                        completion(false)
                    }
                } else {
                    completion(false)
                }
            }
        }
    }
    func drawPDFfromURL(url: URL) -> UIImage? {
        guard let document = CGPDFDocument(url as CFURL) else { return nil }
        guard let page = document.page(at: 1) else { return nil }

        let pageRect = page.getBoxRect(.mediaBox)
        let renderer = UIGraphicsImageRenderer(size: pageRect.size)
        let img = renderer.image { ctx in
            UIColor.white.set()
            ctx.fill(pageRect)

            ctx.cgContext.translateBy(x: 0.0, y: pageRect.size.height)
            ctx.cgContext.scaleBy(x: 1.0, y: -1.0)

            ctx.cgContext.drawPDFPage(page)
        }

        return img
    }
    func runCommunityRevealAnimation() {
        guard let community = UserManager.shared.currentCommunity, let colors = community.colors else {
            return
        }
        
        UIView.transition(with: view, duration: 1.0, options: .transitionCrossDissolve, animations: {
            self.defaultLogoImageView.alpha = 0
            self.communityLogoImageView.alpha = 1
            self.spacerView.addSubview(self.poweredByLabel)
            self.poweredByLabel.snp.makeConstraints { (make) in
                make.top.equalTo(self.communityLogoImageView.snp.bottom).offset(Layout.poweredByTopMargin)
                make.centerX.equalToSuperview()
            }
            self.container.backgroundColor = colors.introScreenBackground
            self.showActionButton()
            self.view.setNeedsUpdateConstraints()
            
        }, completion: nil)
    }
    
    func showCommunityIntro() {
        haveStartedLoading = true
        loadingActivityIndicator.stopAnimating()
        
        guard let community = UserManager.shared.currentCommunity,
              let images = community.images, let colors = community.colors else {
            return
        }
        actionButton.setDarkeningBackgroundColor(color: colors.introScreenButton)
        actionButton.buttonTitleColor = colors.introScreenButtonText
        actionButton.spinnerColor = colors.introScreenText
        poweredByLabel.textColor = colors.introScreenText
        communityLogoImageView.alpha = 0
        container.addSubview(self.communityLogoImageView)
        
        if images.logoIntroScreen.starts(with: "http") {
            communityLogoImageView.kf.setImage(with: URL(string: images.logoIntroScreen), completionHandler:  {
                result in
                switch result {
                case .success(let value):
                    self.communityLogoImageView.snp.makeConstraints { (make) in
                        make.width.equalTo(Layout.communityLogoWidth)
                        make.height.equalTo(Layout.communityLogoWidth / value.image.size.width * value.image.size.height)
                        make.center.equalTo(self.container)
                    }
                    self.runCommunityRevealAnimation()
                default:
                    break
                }
            })
        } else {
            if let communityLogo = images.logoIntroScreen {
                communityLogoImageView.image = UIImage(named: communityLogo)
            }
            runCommunityRevealAnimation()
        }
    }
    
    @objc func exitToOnboarding() {
        if Defaults[.onboardingDone] {
            Router.shared.route(
                to: Route.signUpOrLogin,
                from: self,
                presentationType: .push())
        } else {
            actionButton.state = .loading
            if items.isEmpty {
                Router.shared.route(
                    to: Route.onboarding(templateData: AppIntroViewController.defaultItems),
                    from: self,
                    presentationType: .push())
            } else {
                Router.shared.route(
                    to: Route.onboarding(templateData: items),
                    from: self,
                    presentationType: .push())
            }
            AnalyticsManager.shared.logOnce(event: .onboarding1)
            FirebaseAnalyticsManager.shared.logFirebaseAnalytics(.onboardingScreen)
        }
    }
}
extension String {

    func fileName() -> String {
        return URL(fileURLWithPath: self).deletingPathExtension().lastPathComponent
    }

    func fileExtension() -> String {
        return URL(fileURLWithPath: self).pathExtension
    }
}
