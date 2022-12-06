//
//  ContentOfferItemCollectionViewCell.swift
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

class CustomLinkButton: UIButton {
    var params: Link?
    override init(frame: CGRect) {
        self.params = nil
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        self.params = nil
        super.init(coder: aDecoder)
    }
}
protocol ContentOfferItemCellDelegate: class {
    func didSelectContentOfferLink(_ link: Link)
    func closeContentOffer()
}
class ContentOfferItemCollectionViewCell: CardCollectionViewCell {
    struct Layout {
        static var cardContentInset = UIEdgeInsets(top: 15, left: 20, bottom: 20, right: 20)
        static var cardHeaderBottomMargin: CGFloat = 20
        static var cardHeaderHeight: CGFloat = 63
        static var titleFont = Font.bold.of(size: 17)
        static var detailFont = Font.regular.of(size: 13)
        static var lineSpacing = Constants.defaultLineSpacing
        static var defaultStackSpacing: CGFloat = 2
        static var detailLabelBottomMargin: CGFloat = 25
        static var timeLabelBottomMargin: CGFloat = 5
        static var imageCornerRadius: CGFloat = 31
        static var imageHeight: CGFloat = 62
        static var titleFontHeight: CGFloat = 22
        static var primaryFont = Font.bold.of(size: 15)
        static var regularFont = Font.regular.of(size: 15)

    }
    weak var delegate: ContentOfferItemCellDelegate?

    var topHeaderView: UIView = {
        let view = UIView()
        return view
    }()
    
    var imageBaseView: UIView = {
        let view = UIView()
       // view.backgroundColor = .clear
        return view
    }()
    
    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.masksToBounds = true
        return iv
    }()
    let crossButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(Image.crossWhite.value, for: .normal)
        button.clipsToBounds = true
        button.showsTouchWhenHighlighted = true
        button.adjustsImageWhenHighlighted = true

        return button
    }()
    let cardHeaderContainer = UIView()
    
    let msrPillView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 3
        return view
    }()
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = Layout.titleFont
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    let detailLabel: UILabel = {
        let label = UILabel()
        label.font = Layout.detailFont
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    let stackView: UIStackView = {
        let stack = UIStackView(frame: CGRect.zero)
        stack.axis = .vertical
        stack.distribution = .fillProportionally
        stack.spacing = Layout.defaultStackSpacing
        return stack
    }()

    static func calculateHeightForWidth(item: Story?, width: CGFloat) -> CGFloat {
        guard let item = item?.item else {return 0.0}
        
        let cardWidth = width - CardLayout.cardInset.left - CardLayout.cardInset.right
        let contentWidth = cardWidth - Layout.cardContentInset.left - Layout.cardContentInset.right
        let imageHeight = Layout.imageHeight/2
        var titleLabelHeight: CGFloat = 0
        var titleLabelBottomMargin: CGFloat = 0
        if let title = item.textTitle, !title.isEmpty {
            titleLabelHeight = TextSize.calculateHeight(title, font: Layout.titleFont, width: contentWidth, lineSpacing: Layout.lineSpacing)
            titleLabelBottomMargin = 12
        }
        
        var detailLabelHeight: CGFloat = 0
        let detailLabelBottomMargin: CGFloat = 20
        if let itemDescription = item.textDescription, !itemDescription.isEmpty {
            detailLabelHeight = TextSize.calculateHeight(itemDescription, font: Layout.detailFont, width: contentWidth, lineSpacing: Layout.lineSpacing)
            
        }
        let linksHeight: CGFloat = CGFloat((item.links?.count ?? 0)*52)
        let height = 131+detailLabelHeight+linksHeight+titleLabelHeight+detailLabelBottomMargin
        return height
    }
    
    func linksViewHeight(links: [Link]) -> Int {
        return links.count*52
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
            //make.topMargin.equalTo(25)
            make.right.equalTo(0)
            make.height.equalTo(50)
            make.width.equalTo(50)
           // make.centerY.equalToSuperview()
        }
        cardView.addSubview(imageBaseView)
        imageBaseView.snp.makeConstraints { (make) in
            make.topMargin.equalTo(Layout.imageHeight/2)
            make.height.equalTo(Layout.imageHeight)
            make.width.equalTo(Layout.imageHeight)
            make.centerX.equalToSuperview()
        }
        
        imageBaseView.addSubview(imageView)
        imageView.backgroundColor = .white
        imageView.snp.makeConstraints { (make) in
            make.topMargin.equalTo(0)
            make.height.equalTo(Layout.imageHeight)
            make.width.equalTo(Layout.imageHeight)
            make.centerX.equalToSuperview()
        }
        cardView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(12)
            make.centerX.equalTo(imageBaseView)
            make.left.equalTo(topHeaderView).offset(17)
            make.right.equalTo(topHeaderView).offset(-17)
        }
        cardView.addSubview(detailLabel)
        detailLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.centerX.equalTo(topHeaderView)
            make.left.equalTo(topHeaderView).offset(34)
            make.right.equalTo(topHeaderView).offset(-34)
        }

        imageBaseView.backgroundColor = .white
        imageView.clipsToBounds = true
        imageView.layer.borderWidth = 3.0
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.layer.cornerRadius = Layout.imageCornerRadius
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
        //debugPrint("configureData>>>>>")
        guard let contentItem = item.item else {return}
        
        if let url = contentItem.icon {
            imageView.kf.setImage(with: URL(string: url))
        }
        titleLabel.text = contentItem.textTitle
        detailLabel.text = contentItem.textDescription
        hideLinkView()
        if let links = contentItem.links {
            if links.count > 0 {
                linkButtons(items: links)
                self.showLinkView(links: links)
            } else {
                self.hideLinkView()
            }
        }
    }
    func hideLinkView() {
        self.stackView.removeAllArrangedSubviews()
        self.stackView.snp.removeConstraints()
        self.stackView.removeFromSuperview()
        self.cardView.setNeedsUpdateConstraints()
    }
    func showLinkView(links: [Link]) {
        cardView.addSubview(stackView)
        stackView.snp.makeConstraints { make in
           // make.top.equalTo(detailLabel.snp.bottom).offset(Layout.cardContentInset.top)
            make.left.right.equalToSuperview()
            make.height.equalTo(self.linksViewHeight(links: links))
            make.bottom.equalToSuperview()
        }
       // self.stackView.backgroundColor = .yellow
       // self.cardView.backgroundColor = .red
        self.cardView.setNeedsUpdateConstraints()
    }
    func makeLinkButtonsWithText(info: Link) -> CustomLinkButton {
        let titleText = info.text
        let linkBtn = CustomLinkButton(type: UIButton.ButtonType.system)
        linkBtn.frame = CGRect(x: 0,
                               y: 1,
                               width: cardView.frame.size.width,
                               height: 50)
        linkBtn.backgroundColor = UIColor.white
        linkBtn.setTitle(titleText, for: .normal)
        linkBtn.addTarget(self, action: #selector(handleRegister(_:)), for:.touchUpInside)
        linkBtn.params = info
        guard let community = UserManager.shared.user?.selectedCommunity, let colors = community.colors else {
            linkBtn.setTitleColor(UIColor.black, for: .normal)
            return linkBtn
        }
        if info.descriptionStyle == TransactionListDisplay.primary.display {
            linkBtn.setTitleColor(colors.primary, for: .normal)
            linkBtn.titleLabel?.font = Layout.primaryFont
        } else if info.descriptionStyle == TransactionListDisplay.danger.display {
            let color = UIColor.init(displayP3Red: 215.0/255.0, green: 87.0/255.0, blue: 102.0/255.0, alpha: 1.0)
            linkBtn.setTitleColor(color, for: .normal)
            linkBtn.titleLabel?.font = Layout.regularFont

        } else {
            linkBtn.setTitleColor(UIColor.black, for: .normal)
            linkBtn.titleLabel?.font = Layout.regularFont
        }
        return linkBtn
    }
    func buttonView(info: Link) -> UIView {
        let tmpView = UIView(frame: .zero)
        let topSeperatorView = UIView(frame: CGRect(x: 0,
                                                    y: 0,
                                                    width: cardView.frame.size.width,
                                                    height: 1))
        topSeperatorView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.12)
        tmpView.addSubview(topSeperatorView)
        
        let button = makeLinkButtonsWithText(info: info)
        tmpView.addSubview(button)
        return tmpView
    }
    func linkButtons(items: [Link]){
        for i in 0...(items.count-1) {
            let button = buttonView(info: items[i])
            stackView.addArrangedSubview(button)
        }
    }
    @objc func handleRegister(_ sender: CustomLinkButton) {
        print(sender.params)
        guard let link = sender.params else {return}
        delegate?.didSelectContentOfferLink(link)
    }
    @objc func closeOffer() {
      delegate?.closeContentOffer()
    }
}
