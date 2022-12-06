//
//  DataTypeTableViewCell.swift
//  Contributor
//
//  Created by Kiwitech on 04/05/20.
//  Copyright © 2020 Measure. All rights reserved.
//

import UIKit
import SwiftyAttributes
import SwiftyUserDefaults

protocol DataTypeDelegate: class {
  func clickToOpenConnectionDetail(index: Int)
  func clickToOpenConnectedDetail(index: Int)
}

class DataTypeTableViewCell: UITableViewCell {

@IBOutlet weak var dataTypeImageView: UIImageView!
@IBOutlet weak var dataTypeLabel: UILabel!
@IBOutlet weak var dataTypeConnectButton: UIButton!
@IBOutlet weak var connectedView: UIStackView!
@IBOutlet weak var connectedSelectionButton: UIButton!
@IBOutlet weak var connetedArrowImageView: UIImageView!

weak var delegate: DataTypeDelegate?

override func awakeFromNib() {
super.awakeFromNib()
// Initialization code
}

override func setSelected(_ selected: Bool, animated: Bool) {
super.setSelected(selected, animated: animated)
// Configure the view for the selected state
}
    
func updateSurveyPartner(_ appData: ConnectedAppData) {
if appData.type == ConnectedApp.dynata.rawValue {
    dataTypeLabel.text = Constants.dynata
    if appData.setUpStatus == AppStatus.notConnected.rawValue {
        updateConnectedView(true, .dynata)
        connectedSelectionButton.isUserInteractionEnabled = false
    } else {
        updateConnectedView(false, .dynata)
        connectedSelectionButton.isUserInteractionEnabled = true
    }
}
if appData.type == ConnectedApp.pollfish.rawValue {
    dataTypeLabel.text = Constants.pollfish
    if appData.setUpStatus == AppStatus.notConnected.rawValue {
        updateConnectedView(true, .pollfish)
        connectedSelectionButton.isUserInteractionEnabled = false
    } else {
        updateConnectedView(false, .pollfish)
        connectedSelectionButton.isUserInteractionEnabled = true
    }
}

if appData.type == ConnectedApp.kantar.rawValue {
    dataTypeLabel.text = Constants.kantar
    if appData.setUpStatus == AppStatus.notConnected.rawValue {
        updateConnectedView(true, .kantar)
        connectedSelectionButton.isUserInteractionEnabled = false
    } else {
        updateConnectedView(false, .kantar)
        connectedSelectionButton.isUserInteractionEnabled = true
    }
  }
    
if appData.type == ConnectedApp.precision.rawValue {
    dataTypeLabel.text = Constants.precisionSample
    if appData.setUpStatus == AppStatus.notConnected.rawValue {
        updateConnectedView(true, .precision)
        connectedSelectionButton.isUserInteractionEnabled = false
    } else {
        updateConnectedView(false, .precision)
        connectedSelectionButton.isUserInteractionEnabled = true
    }
  }
}

func updateUI(appData: ConnectedAppData) {
if appData.type == ConnectedApp.linkedin.rawValue {
    connectedSelectionButton.isUserInteractionEnabled = false
    dataTypeLabel.text = Constants.linkedin
    if appData.setUpStatus == AppStatus.notConnected.rawValue {
        updateConnectedView(true, .linkedin)
    } else {
        updateConnectedView(false, .linkedin)
    }
}
if appData.type == ConnectedApp.facebook.rawValue {
    connectedSelectionButton.isUserInteractionEnabled = false
    dataTypeLabel.text = Constants.facebook
    if appData.setUpStatus == AppStatus.notConnected.rawValue {
        updateConnectedView(true, .facebook)
    } else {
        updateConnectedView(false, .facebook)
    }
}
updateSurveyPartner(appData)
if let type = appData.type {
    dataTypeImageView.image = UIImage(named: "\(type)")
}
  applyCommunityTheme()
}

func updateConnectedView(_ isConnected: Bool, _ appType: ConnectedApp) {
    connectedView.isHidden = isConnected
    if appType == .facebook || appType == .linkedin {
        connetedArrowImageView.isHidden = !isConnected
    }
    dataTypeConnectButton.isHidden = !isConnected
}

@IBAction func clickToConnectApp(_ sender: UIButton) {
    dataTypeConnectButton.bounceBriefly()
    delegate?.clickToOpenConnectionDetail(index: sender.tag)
}
@IBAction func clickToGoToDetail(_ sender: UIButton) {
    delegate?.clickToOpenConnectedDetail(index: sender.tag)
 }
}

extension DataTypeTableViewCell: CommunityThemeConfigurable {
@objc func applyCommunityTheme() {
    guard let community = UserManager.shared.user?.selectedCommunity, let colors = community.colors else {
        return
    }
    dataTypeConnectButton.setTitleColor(colors.primary, for: .normal)
    dataTypeConnectButton.setTitle(MyDataText.connectText.localized(), for: .normal)
   }
}

protocol AppDetailDelegate: class {
    func clickToReloadRow()
}

class AppSeeAllTableViewCell: UITableViewCell {

@IBOutlet weak var subLabel: EdgeInsetLabel!
@IBOutlet weak var seeAllButton: UIButton!
@IBOutlet weak var titleLabel: UILabel!
    
weak var appDetailDelegate: AppDetailDelegate?
var communityColor: UIColor = Constants.primaryColor
var connectsApp: ConnectedAppData?
    
 override func awakeFromNib() {
   super.awakeFromNib()
   // Initialization code
    backgroundColor = Color.cellBackgroundColor.value
    applyCommunityTheme()
}

func updateProfilItems(connectApp: ConnectedAppData?) {
  if let selectedAppData = connectApp {
    if let items = selectedAppData.details?.profileItems,
       let type = selectedAppData.type,
       let appType = ConnectedApp(rawValue: type) {
        var text = Constants.dynata
        if appType == .pollfish {
          text = Constants.pollfish
        }
        if appType == .kantar {
          text = Constants.kantar
        }
        if appType == .precision {
          text = Constants.precisionSample
        }
        
        titleLabel.text = "By connecting to".localized() +  "\(text)" + " you will share".localized() +  "\(items.count)" + " profile points including:".localized()

    }
    updateInitialTextLabel(connectApp)
    seeAllButton.setTitle(SeeAllCell.moreText.localized(), for: .normal)
    subLabel.lineBreakMode = .byTruncatingTail
    subLabel.numberOfLines = 2
    connectsApp = connectApp
  }
}
    
 func updateInitialTextLabel(_ connectApp: ConnectedAppData?) {
    if let selectedAppData = connectApp, selectedAppData.details?.profileItems?.isEmpty == false {
        if let items = selectedAppData.details?.profileItems?[0..<5].map({$0}) {
          let detail = items.compactMap({$0.label?.en}).joined(separator: ", ")
          let attributedDataText = detail.lineSpaced(1.2, with: Font.regular.of(size: 16))
          subLabel.attributedText = attributedDataText
        }
     }
 }

 func updateFinalTextLabel(_ connectApp: ConnectedAppData?) {
     if let selectedAppData = connectApp, selectedAppData.details?.profileItems?.isEmpty == false {
         if let items = selectedAppData.details?.profileItems?.map({$0}) {
            let detail = items.compactMap({$0.label?.en}).joined(separator: ", ")
           let attributedDataText = detail.lineSpaced(1.2, with: Font.regular.of(size: 16))
           subLabel.attributedText = attributedDataText
       }
    }
}

@IBAction func clickToSeeAll(_ sender: UIButton) {
    if Defaults[.seeAllClicked] == false {
        Defaults[.seeAllClicked] = true
    } else {
       Defaults[.seeAllClicked] = false
    }
    updateUI()
    appDetailDelegate?.clickToReloadRow()
  }
    
  func updateUI() {
    if Defaults[.seeAllClicked] == false {
        updateInitialTextLabel(connectsApp)
        seeAllButton.setTitle(SeeAllCell.moreText.localized(), for: .normal)
        subLabel.lineBreakMode = .byTruncatingTail
        subLabel.numberOfLines = Constants.collapseNumberOfLines
    } else {
        updateFinalTextLabel(connectsApp)
        seeAllButton.setTitle(SeeAllCell.lessText.localized(), for: .normal)
        subLabel.lineBreakMode = .byWordWrapping
        subLabel.numberOfLines = Constants.expandLabelNumberOfLines
     }
   }
}

extension AppSeeAllTableViewCell: CommunityThemeConfigurable {
@objc func applyCommunityTheme() {
    guard let community = UserManager.shared.user?.selectedCommunity, let colors = community.colors else {
        return
    }
    seeAllButton.setTitleColor(colors.primary, for: .normal)
    }
}

protocol AppSubDetailDelegate: class {
  func clickToReloadMoreRow()
  func clickToOpenTerms()
  func clickoOpenPrivacy()
}

class AppReadMoreTableViewCell: UITableViewCell {

@IBOutlet weak var readMoreLabel: UILabel!

weak var delegate: AppSubDetailDelegate?
var communityColor: UIColor = Constants.primaryColor
var appType: ConnectedApp? = .dynata

override func awakeFromNib() {
   super.awakeFromNib()
    // Initialization code
   backgroundColor = Color.cellBackgroundColor.value
   addTapGestureOnLabel()
}

func updateCollapseView(_ communityColor: UIColor) {
    readMoreLabel.lineBreakMode = .byTruncatingTail
    readMoreLabel.numberOfLines = Constants.collapseNumberOfLines
    switch appType {
    case .dynata:
        updateInitialUI(communityColor, ReadCell.initialReadText.localized())
    case .pollfish:
        updateInitialUI(communityColor, ReadCell.initialPollfishReadText.localized())
    case .kantar:
        updateInitialUI(communityColor, ReadCell.initialKantarReadText.localized())
    case .precision:
        readMoreLabel.numberOfLines = Constants.precisionCollapseNumberOfLines
        updateInitialUI(communityColor, ReadCell.initialPrecisionReadText.localized())
    default: break
    }
}

func updateExpandView(_ communityColor: UIColor) {
    readMoreLabel.lineBreakMode = .byWordWrapping
    readMoreLabel.numberOfLines = Constants.expandLabelNumberOfLines
    switch appType {
    case .dynata:
        updateFinalUI(communityColor, ReadCell.finalReadText.localized())
    case .pollfish:
        updateFinalUI(communityColor, ReadCell.finalPollfishReadText.localized())
    case .kantar:
        updateFinalUI(communityColor, ReadCell.finalKantarReadText.localized())
    case .precision:
        updateFinalUI(communityColor, ReadCell.finalPrecisionReadText.localized())
    default: break
    }
}

func updateInitialUI(_ communityColor: UIColor, _ prefixString: String) {
    let readMoreAttributedText = prefixString.lineSpaced(1.2, with: Font.regular.of(size: 16))
    let linkFontAttributes = [
        Attribute.textColor(communityColor),
        Attribute.underlineColor(communityColor)
    ]
    readMoreAttributedText.addAttributesToTerms(linkFontAttributes, to: [DataTypeCell.readMore.localized()])
    readMoreLabel.attributedText = readMoreAttributedText
}

func updateFinalUI(_ communityColor: UIColor, _ prefixString: String) {
    let readMoreAttributedText = prefixString.lineSpaced(1.2, with: Font.regular.of(size: 16))
    let linkFontAttributes = [
        Attribute.textColor(communityColor),
        Attribute.underlineColor(communityColor),
        Attribute.underlineStyle(.single)
    ]
    readMoreAttributedText.addAttributesToTerms(linkFontAttributes,
                                                to: [DataTypeCell.privacyLinkText.localized(),
                                                     DataTypeCell.termsLinkText.localized()])
    readMoreLabel.attributedText = readMoreAttributedText
}

func updateReadMoreData() {
    applyCommunityTheme()
}

func addTapGestureOnLabel() {
     let tap = UITapGestureRecognizer(target: self,
                                      action: #selector(readMoreClicked(tap:)))
     readMoreLabel.addGestureRecognizer(tap)
     readMoreLabel.isUserInteractionEnabled = true
}
   
@objc func readMoreClicked(tap: UITapGestureRecognizer) {
    if let _ = readMoreLabel.text?.range(of: DataTypeCell.readMore.localized())?.nsRange {
        if Defaults[.readMoreClicked] == false {
            Defaults[.readMoreClicked] = true
         } else {
            Defaults[.readMoreClicked] = false
        }
        updateReadMoreData()
        delegate?.clickToReloadMoreRow()
    }
    if let range = readMoreLabel.text?.range(of: DataTypeCell.privacyLinkText.localized())?.nsRange {
        if tap.didTapAttributedTextInLabel(label: readMoreLabel,
        inRange: range) {
            delegate?.clickoOpenPrivacy()
        }
    }
    if let range = readMoreLabel.text?.range(of: DataTypeCell.termsLinkText.localized())?.nsRange {
        if tap.didTapAttributedTextInLabel(label: readMoreLabel,
               inRange: range) {
            delegate?.clickToOpenTerms()
        }
      }
   }
}

extension AppReadMoreTableViewCell: CommunityThemeConfigurable {
@objc func applyCommunityTheme() {
    guard let community = UserManager.shared.user?.selectedCommunity,
          let colors = community.colors else {
        return
    }
    if Defaults[.readMoreClicked] == false {
        updateCollapseView(colors.primary)
    } else {
        updateExpandView(colors.primary)
    }
   }
}
