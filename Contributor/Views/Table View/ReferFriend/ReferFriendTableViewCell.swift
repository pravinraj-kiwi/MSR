//
//  ReferFriendTableViewCell.swift
//  Contributor
//
//  Created by KiwiTech on 10/26/20.
//  Copyright © 2020 Measure. All rights reserved.
//

import UIKit
import SwiftyAttributes

protocol ReferFriendDelegate: class {
  func clickToShareCode(_ code: String)
  func showCopiedAlert()
  func didTapGesture(_ label: UILabel, gesture: UITapGestureRecognizer)
}

class ReferFriendTableViewCell: UITableViewCell {
    
 @IBOutlet weak var referCellView: UIView!
 @IBOutlet weak var referCellImageView: UIButton!
 @IBOutlet weak var referCellShareButton: UIButton!
 @IBOutlet weak var referCellCode: CopyLabel!
 @IBOutlet weak var referCellTerms: UILabel!
@IBOutlet weak var referFriendLbl1: UILabel!
@IBOutlet weak var referFriendLbl2: UILabel!
@IBOutlet weak var yourCodeLbl: UILabel!
@IBOutlet weak var referInfo: UILabel!
 
 weak var referDelegate: ReferFriendDelegate?

 override func awakeFromNib() {
   super.awakeFromNib()
    // Initialization code
    referCellCode.delegate = self
    addTapGestureOnLabel()
    applyCommunityTheme()
 }

 func updateCellUI(_ inviteCode: String) {
    referCellCode.text = inviteCode
 }
    
 @IBAction func clickToShareCode(_ sender: Any) {
    if let code = referCellCode.text {
      referDelegate?.clickToShareCode(code)
    }
 }
    
 func addTapGestureOnLabel() {
    let tap = UITapGestureRecognizer(target: self,
                                       action: #selector(tapLabel(tap:)))
    referCellTerms.addGestureRecognizer(tap)
    referCellTerms.isUserInteractionEnabled = true
 }
        
 @objc func tapLabel(tap: UITapGestureRecognizer) {
    referDelegate?.didTapGesture(referCellTerms, gesture: tap)
 }
}

extension ReferFriendTableViewCell: CopyLabelDelegate {
  func showCopiedAlert() {
    referDelegate?.showCopiedAlert()
  }
}

extension ReferFriendTableViewCell: CommunityThemeConfigurable {
@objc func applyCommunityTheme() {
    guard let community = UserManager.shared.user?.selectedCommunity, let colors = community.colors else {
       return
     }
    referCellShareButton.backgroundColor = colors.primary
    referCellCode.textColor = colors.primary
    referCellImageView.tintColor = colors.primary
    referCellView.backgroundColor = colors.primary
    let termsAttributedText = ReferFriendViewText.terms.localized().lineSpaced(1.2, with: Font.regular.of(size: 14))
    let linkFontAttributes = [
           Attribute.textColor(colors.primary),
           Attribute.underlineColor(colors.primary),
           Attribute.underlineStyle(.single)
       ]
    termsAttributedText.addAttributesToTerms(linkFontAttributes, to: [ReferFriendViewText.linkText.localized()])
    referCellTerms.attributedText = termsAttributedText
    referFriendLbl1.text = Text.referFriend.localized()
    referFriendLbl2.text = Text.referFriendDesc.localized()
    yourCodeLbl.text = Text.yourCode.localized()
    referInfo.text = Text.referInfo.localized()
    referCellShareButton.setTitle(Text.share.localized(), for: .normal)
  }
}
