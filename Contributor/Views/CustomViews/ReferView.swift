//
//  ReferFriendView.swift
//  Contributor
//
//  Created by KiwiTech on 10/26/20.
//  Copyright © 2020 Measure. All rights reserved.
//

import Foundation

protocol ReferFriendViewDelegate: class {
  func didTapToCloseFriendView()
  func didTapToOpenReferView()
}

class ReferView: UIView, NibLoadableView {

@IBOutlet weak var referView: UIView!
@IBOutlet weak var referImageView: UIImageView!
@IBOutlet weak var referCloseButton: UIButton!
@IBOutlet weak var referHeading: UILabel!
@IBOutlet weak var referSubHeading: UILabel!

weak var referFriendDelegate: ReferFriendViewDelegate?
private var contentView: UIView!

override func awakeFromNib() {
    super.awakeFromNib()
}

override init(frame: CGRect) {
    super.init(frame: frame)
    xibSetup()
}

required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    xibSetup()
}

func xibSetup() {
    contentView = loadViewFromNib()
    contentView.frame = bounds
    contentView.autoresizingMask = [UIView.AutoresizingMask.flexibleWidth,
                                    UIView.AutoresizingMask.flexibleHeight]
    addSubview(contentView)
    referView.snackBarShadow(color: .black, cornerRadius: 0, bgColor: UIColor.clear.cgColor)
    applyCommunityTheme()
    referHeading.text = GiftCardViewText.referFriendHeadingText.localized()
    referSubHeading.text = GiftCardViewText.referFriendSubHeadingText.localized()
}

func loadViewFromNib() -> UIView! {
    let bundle = Bundle(for: type(of: self))
    let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
    if let view = nib.instantiate(withOwner: self, options: nil).first as? UIView {
        return view
    }
    return UIView()
}

 @IBAction func clickedToCloseReferView(_ sender: Any) {
    referFriendDelegate?.didTapToCloseFriendView()
 }
    
 @IBAction func clickedToOpenReferView(_ sender: Any) {
    referFriendDelegate?.didTapToOpenReferView()
  }
}

extension ReferView: CommunityThemeConfigurable {
@objc func applyCommunityTheme() {
    guard let community = UserManager.shared.user?.selectedCommunity, let colors = community.colors else {
       return
     }
    referView.backgroundColor = colors.primary
    
  }
    

}
