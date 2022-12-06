// Copyright (c) 2015-present Frédéric Maquin <fred@ephread.com> and contributors.
// Licensed under the terms of the MIT License.

import UIKit
import Instructions
import SwiftyUserDefaults

// Custom coach mark body (with the secret-like arrow)
internal class CustomCoachMarkBodyView: UIView, CoachMarkBodyView {
// MARK: - Internal properties
var nextControl: UIControl? { return self.nextButton }
var highlighted: Bool = false
var nextButton: UIButton = {
    let nextButton = UIButton()
    nextButton.accessibilityIdentifier = AccessibilityIdentifiers.next
    nextButton.addTarget(self, action: #selector(handleRegister(_:)), for: .touchUpInside)
    return nextButton
}()
var headerLabel = UILabel()
var descLabel = UILabel()
var pageControl = UIPageControl()
var stackView = UIStackView()
var labelStackView = UIStackView()
weak var highlightArrowDelegate: CoachMarkBodyHighlightArrowDelegate?

// MARK: - Initialization
override init (frame: CGRect) {
    super.init(frame: frame)
    self.setupInnerViewHierarchy()
}

convenience init() {
    self.init(frame: .zero)
}

required init?(coder aDecoder: NSCoder) {
    fatalError("This class does not support NSCoding.")
}

func updateStackView() {
 self.stackView.alignment = .fill
 self.stackView.distribution = .equalSpacing
 self.stackView.axis = .horizontal
 self.stackView.addBackground(color: .clear)
 self.labelStackView.alignment = .fill
 self.labelStackView.distribution = .fill
 self.labelStackView.spacing = 7
 self.labelStackView.axis = .vertical
 self.labelStackView.addBackground(color: .clear)
}

func updateLabel() {
 self.headerLabel.backgroundColor = UIColor.clear
 self.headerLabel.textColor = UIColor.darkGray
 self.headerLabel.font = Font.bold.of(size: 16)
 self.headerLabel.textAlignment = .left
 self.headerLabel.numberOfLines = 0
 self.headerLabel.lineBreakMode = .byWordWrapping
 self.descLabel.backgroundColor = UIColor.clear
 self.descLabel.textColor = UIColor.darkGray
 self.descLabel.font = Font.regular.of(size: 15)
 self.descLabel.textAlignment = .left
 self.descLabel.numberOfLines = 0
 self.descLabel.lineBreakMode = .byWordWrapping
}

func updateControlProperty() {
 self.nextButton.translatesAutoresizingMaskIntoConstraints = false
 self.descLabel.translatesAutoresizingMaskIntoConstraints = false
 self.headerLabel.translatesAutoresizingMaskIntoConstraints = false
 self.pageControl.translatesAutoresizingMaskIntoConstraints = false
 self.stackView.translatesAutoresizingMaskIntoConstraints = false
 self.labelStackView.translatesAutoresizingMaskIntoConstraints = false
 self.nextButton.isUserInteractionEnabled = true
 self.descLabel.isUserInteractionEnabled = false
 self.headerLabel.isUserInteractionEnabled = false
 self.pageControl.isUserInteractionEnabled = false
 self.nextButton.titleLabel?.font = Font.regular.of(size: 16)
 self.nextButton.contentHorizontalAlignment = .right
}
    
func updateStackConstraint() {
  NSLayoutConstraint.activate(
    NSLayoutConstraint.constraints(
        withVisualFormat: "V:|-(14)-[labelStackView]-(13)-[stackView(20)]-|",
        options: NSLayoutConstraint.FormatOptions(rawValue: 0),
        metrics: nil,
        views: ["labelStackView": labelStackView, "stackView": stackView]
    )
)
    
 NSLayoutConstraint.activate(
    NSLayoutConstraint.constraints(
        withVisualFormat: "H:|-(13)-[stackView]-(13)-|",
        options: NSLayoutConstraint.FormatOptions(rawValue: 0),
        metrics: nil,
        views: ["stackView": stackView]
    )
 )

 NSLayoutConstraint.activate(
       NSLayoutConstraint.constraints(
           withVisualFormat: "H:|-(13)-[labelStackView]-(13)-|",
           options: NSLayoutConstraint.FormatOptions(rawValue: 0),
           metrics: nil,
           views: ["labelStackView": labelStackView]
       )
  )
}
    
func headerLabelConstraints() {
  NSLayoutConstraint.activate(
    NSLayoutConstraint.constraints(
        withVisualFormat: "H:[headerLabel]",
        options: NSLayoutConstraint.FormatOptions(rawValue: 0),
        metrics: nil,
        views: ["headerLabel": headerLabel]
       )
  )

  NSLayoutConstraint.activate(
    NSLayoutConstraint.constraints(
        withVisualFormat: "H:[descLabel]",
        options: NSLayoutConstraint.FormatOptions(rawValue: 0),
        metrics: nil,
        views: ["descLabel": descLabel]
    )
  )
}
    
func nextButtonConstraints() {
    let selectedLanguage = AppLanguageManager.shared.getLanguage()
    if (selectedLanguage == "pt-BR") || (selectedLanguage == "pt") {
        NSLayoutConstraint.activate(
         NSLayoutConstraint.constraints(
            withVisualFormat: "H:[nextButton(==75)]",
            options: NSLayoutConstraint.FormatOptions(rawValue: 0),
            metrics: nil,
            views: ["nextButton": nextButton]
         )
       )
    } else {
        NSLayoutConstraint.activate(
         NSLayoutConstraint.constraints(
            withVisualFormat: "H:[nextButton(==45)]",
            options: NSLayoutConstraint.FormatOptions(rawValue: 0),
            metrics: nil,
            views: ["nextButton": nextButton]
         )
       )
    }


 var visualFormat = "H:[pageControl]"
 if #available(iOS 14.0, *) {
   visualFormat = "H:|-(-40)-[pageControl]"
 }

 NSLayoutConstraint.activate(
   NSLayoutConstraint.constraints(
      withVisualFormat: visualFormat,
      options: NSLayoutConstraint.FormatOptions(rawValue: 0),
      metrics: nil,
      views: ["pageControl": pageControl]
   )
  )
}
    
func addControlToView() {
 self.addSubview(headerLabel)
 self.addSubview(descLabel)
 self.addSubview(stackView)
 self.addSubview(labelStackView)
 stackView.addArrangedSubview(pageControl)
 stackView.addArrangedSubview(nextButton)
 labelStackView.addArrangedSubview(headerLabel)
 labelStackView.addArrangedSubview(descLabel)
}

private func setupInnerViewHierarchy() {
 self.translatesAutoresizingMaskIntoConstraints = false
 self.backgroundColor = UIColor.white
 self.clipsToBounds = true
 self.headerShadow(color: .black)
 updateStackView()
 self.pageControl.numberOfPages = 4
 updateLabel()
 updateControlProperty()
 addControlToView()
 updateStackConstraint()
 headerLabelConstraints()
 nextButtonConstraints()
 applyCommunityTheme()
}
    
@objc func handleRegister(_ sender: UIButton) {
    if sender.currentTitle == ToolTip.finishActionButtonText {
        Defaults[.hadSeenMyDataTutorial] = true
        NotificationCenter.default.post(name: NSNotification.Name.hadSeenToolTip, object: nil)
     }
  }
}

extension CustomCoachMarkBodyView: CommunityThemeConfigurable {
  @objc func applyCommunityTheme() {
   guard let community = UserManager.shared.user?.selectedCommunity, let colors = community.colors else {
      return
    }
    self.pageControl.currentPageIndicatorTintColor = colors.primary
    self.nextButton.setTitleColor(colors.primary, for: .normal)
    self.pageControl.pageIndicatorTintColor = colors.primary.withAlphaComponent(0.26)
  }
}

extension UIView {
func headerShadow(color: UIColor) {
    layer.masksToBounds = false
    layer.cornerRadius = 7.0
    layer.backgroundColor = UIColor.white.cgColor
    layer.borderColor = UIColor.clear.cgColor
    layer.shadowColor = color.cgColor
    layer.shadowOffset = CGSize(width: 0, height: 2)
    layer.shadowOpacity = 0.5
    layer.shadowRadius = 4
  }
}
