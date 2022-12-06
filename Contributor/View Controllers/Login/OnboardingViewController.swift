//
//  OnboardingViewController.swift
//  Contributor
//
//  Created by arvindh on 26/01/19.
//  Copyright © 2019 Measure. All rights reserved.
//

import UIKit
import SwiftyUserDefaults
import SDWebImagePDFCoder

struct OnboardingMessage: Codable {
    var imageUrl: String?
    var image: String?
    var title: String?
    var text: String?
    var pillButtonText: String?
    var showActionButton: Bool = false
    var showPillButton: Bool = false
    var layout: String?
    
    private enum CodingKeys: String, CodingKey {
        case imageUrl = "image_url"
        case image
        case title = "title"
        case text = "text"
        case showActionButton = "show_next_button"
        case showPillButton = "show_pill"
        case pillButtonText = "pill_text"
        case layout
    }
}

class OnboardingViewController: UIViewController {
  var item: OnboardingMessage
  var controllerIndex: Int
  var iPhone: Bool { UIDevice.current.userInterfaceIdiom == .phone }

  let imageView: UIImageView = {
    let iv = UIImageView()
    iv.contentMode = .scaleAspectFill
    iv.clipsToBounds = false
    return iv
  }()
   
  let pillStackView: UIStackView = {
    let stack = UIStackView(frame: CGRect.zero)
    stack.axis = .vertical
    stack.distribution = .fill
    stack.spacing = 30
    return stack
  }()
    
  let stackView: UIStackView = {
    let stack = UIStackView(frame: CGRect.zero)
    stack.axis = .vertical
    stack.distribution = .fill
    stack.spacing = 10
    return stack
  }()
  
  let titleLabel: UILabel = {
    let label = UILabel()
    label.font = Font.bold.of(size: 30)
    label.textAlignment = .center
    label.setContentHuggingPriority(UILayoutPriority.required,
                                    for: NSLayoutConstraint.Axis.vertical)
    return label
  }()
  
  let descriptionLabel: UILabel = {
    let label = UILabel()
    label.font = Font.regular.of(size: 18)
    label.textAlignment = .center
    label.numberOfLines = 0
    label.setContentHuggingPriority(UILayoutPriority.required,
                                    for: NSLayoutConstraint.Axis.vertical)
    return label
  }()
    
   let activityIndicator: UIActivityIndicatorView = {
    let indicator = UIActivityIndicatorView(frame: CGRect.zero)
    indicator.color = Color.text.value
    indicator.hidesWhenStopped = true
    return indicator
  }()
    
  let actionButton: UIButton = {
    let button = UIButton(frame: CGRect.zero)
    button.titleLabel?.font = Font.regular.of(size: 18)
    button.layer.cornerRadius = Constants.buttonCornerRadius
    button.layer.masksToBounds = true
    button.setTitle(Text.next.localized(), for: .normal)
    return button
  }()
   
  let pillView: UIView = {
     let view = UIView()
     return view
  }()
    
  let pillButton: UIButton = {
    let button = UIButton(frame: CGRect.zero)
    button.titleLabel?.font = Font.bold.of(size: 14)
    button.layer.cornerRadius = 10
    button.layer.masksToBounds = true
    button.setTitle(Text.new.localized(), for: .normal)
    return button
   }()
  
  init(item: OnboardingMessage, index: Int) {
    self.item = item
    self.controllerIndex = index
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupViews()
    updateValues()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  override func setupViews() {
    let imageViewContainer = UIView()
    view.addSubview(imageViewContainer)
    imageViewContainer.snp.makeConstraints { (make) in
      if iPhone && UIScreen.main.nativeBounds.size.height <= 1334 {
        make.top.equalTo(view.safeAreaLayoutGuide).offset(23)
      } else {
        make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
      }
      make.left.equalTo(view)
      make.right.equalTo(view)
      make.bottom.equalTo(view.snp.bottom).offset(-260)
    }

    imageViewContainer.addSubview(imageView)
    imageView.snp.makeConstraints { (make) in
      if iPhone && UIScreen.main.nativeBounds.size.height <= 1334 {
        make.top.equalTo(imageViewContainer.snp.top).offset(20)
      } else {
        make.top.equalTo(imageViewContainer.snp.top).offset(10)
      }
      make.width.equalTo(imageViewContainer.snp.width)
      make.bottom.equalTo(imageViewContainer.snp.bottom)
      make.height.equalTo(imageViewContainer.snp.width).priority(751)
      make.height.greaterThanOrEqualTo(imageViewContainer).priority(752)
    }
    
    view.addSubview(activityIndicator)
    activityIndicator.snp.makeConstraints { (make) in
      make.centerX.equalTo(imageView)
      make.centerY.equalTo(imageView)
    }
    
    view.addSubview(pillView)
    pillView.snp.makeConstraints { (make) in
      if iPhone && UIScreen.main.nativeBounds.size.height <= 1334 {
        make.top.equalTo(imageViewContainer.snp.bottom).offset(28)
      } else {
        make.top.equalTo(imageViewContainer.snp.bottom)
      }
      make.left.equalTo(imageViewContainer).offset(30)
      make.right.equalTo(imageViewContainer).offset(-30)
    }
    
    pillView.addSubview(pillButton)
    pillButton.snp.makeConstraints { (make) in
      make.centerX.equalTo(pillView)
      make.width.equalTo(63)
      make.height.equalTo(20)
    }

    view.addSubview(stackView)
    stackView.snp.makeConstraints { (make) in
      make.top.equalTo(pillView.snp.bottom).offset(30)
      make.left.equalTo(imageViewContainer).offset(30)
      make.right.equalTo(imageViewContainer).offset(-30)
    }
    
    stackView.addArrangedSubview(titleLabel)
    stackView.addArrangedSubview(descriptionLabel)
        
    view.addSubview(actionButton)
    actionButton.snp.makeConstraints { (make) in
      make.top.greaterThanOrEqualTo(stackView.snp.bottom).offset(20).priority(500)
      make.centerX.equalTo(stackView)
      make.width.equalTo(180)
      make.height.equalTo(44)
      if iPhone && UIScreen.main.nativeBounds.size.height <= 1334 {
        make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-20)
      } else {
        make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-30)
      }
    }
    actionButton.addTarget(self, action: #selector(self.getStarted(_:)), for: UIControl.Event.touchUpInside)
    
    applyCommunityTheme()
  }

    func updateValues() {
        titleLabel.text = item.title
        descriptionLabel.text = item.text
        if let imgUrl = item.imageUrl, imgUrl != "" {
            self.imageView.image = getSavedImage(named: imgUrl.fileName())
        } else {
            self.imageView.image = UIImage(named: "\(Constants.onboarding)\(self.controllerIndex)")
            self.revealAnimation()
        }
        actionButton.isHidden = !item.showActionButton
        pillView.isHidden = !item.showPillButton
        if let pillText = item.pillButtonText, pillText.isEmpty == false {
            pillButton.setTitle(pillText, for: .normal)
        }
    }
    func getSavedImage(named: String) -> UIImage? {
        if let dir = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) {
            return UIImage(contentsOfFile: URL(fileURLWithPath: dir.absoluteString).appendingPathComponent(named).path)
        }
        return nil
    }
    func revealAnimation() {
        UIView.transition(with: self.view, duration: 1.0, options: .transitionCrossDissolve, animations: {
            self.imageView.alpha = 1
            
        }, completion: nil)
    }
  @objc func getStarted(_ sender: UIButton) {
    Defaults[.onboardingDone] = true
    Router.shared.route(
        to: Route.signUpOrLogin,
      from: self
    )
  }
}

extension OnboardingViewController: CommunityThemeConfigurable {
  @objc func applyCommunityTheme() {
    guard let community = UserManager.shared.currentCommunity, let colors = community.colors else {
      return
    }
    titleLabel.textColor = colors.text
    descriptionLabel.textColor = colors.text
    actionButton.setDarkeningBackgroundColor(color: colors.primary)
    actionButton.setTitleColor(colors.whiteText, for: .normal)
    pillButton.setDarkeningBackgroundColor(color: colors.primary)
    pillButton.setTitleColor(colors.whiteText, for: .normal)
  }
}
