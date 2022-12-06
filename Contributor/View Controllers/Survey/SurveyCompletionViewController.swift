//
//  SurveyFinishViewController.swift
//  Contributor
//
//  Created by arvindh on 14/11/18.
//  Copyright © 2018 Measure. All rights reserved.
//

import os
import UIKit
import SwiftyUserDefaults
import Cosmos
import IGListKit

protocol SurveyCompletionDelegate: class {
    func didCompleteSurvey(_ surveyManager: SurveyManager?)
}

enum SurveyStatus: String {
    case completed, cancelled, inProgress, disqualified, overQuota, inReview, closed
    
    var stringValue: String {
        return self.rawValue
    }
}

class SurveyCompletionViewController: UIViewController {
    struct Layout {
        static let containerInset: CGFloat = 0
        static let subContainerInset: CGFloat = 20
        static let topMargin: CGFloat = 0
        static let contentMaxWidth: CGFloat = 300
        static let introLabelBottomMargin: CGFloat = 18
        static let msrCompensationLabelBottomMargin: CGFloat = 4
        static let fiatCompensationLabelBottomMargin: CGFloat = 22
        static var borderHeight: CGFloat = 1
        static let imageSize: CGFloat = 70
        static let imageTopMargin: CGFloat = 40
        static let imageBottomMargin: CGFloat = 30
        static let actionButtonTopMargin: CGFloat = 43
        static let actionButtonWidth: CGFloat = 190
        static let actionButtonHeight: CGFloat = 44
        static let numberOfRatingStars: Int = 5
    }
    
    let positiveRatingItems = [PositiveRatingText.understand, PositiveRatingText.simple, PositiveRatingText.fairPayment, PositiveRatingText.efficient, PositiveRatingText.content, PositiveRatingText.fun, PositiveRatingText.fastLoading, PositiveRatingText.design]
    
    let negativeRatingItems = [NegativeRatingText.tooLong, NegativeRatingText.tooSmall, NegativeRatingText.slowLoading, NegativeRatingText.boring, NegativeRatingText.complicated, NegativeRatingText.mobileFriendly, NegativeRatingText.questions, NegativeRatingText.errors]
    
    var ratingItems: [String] = []
    var selectedRatingItems = Set<String>([])
    
    enum RatingView {
        case none, positive, negative
    }
    var currentRatingView: RatingView = .none
    
    weak var delegate: SurveyCompletionDelegate?
    var surveyType: SurveyType
    var surveyStatus: SurveyStatus
    var externalSurvey: ExternalSurveyCompletion?
    var surveyManager: SurveyManager?
    var showRatings: Bool = false
    let videoUrl: String?
    var hasSkipContentValidation = false
    var twitterDetail: [String: Any]?

    let container: UIView = {
        let view = UIView()
        view.backgroundColor = Constants.backgroundColor
        return view
    }()
    
    let stackView: UIStackView = {
        let stack = UIStackView(frame: CGRect.zero)
        stack.axis = .vertical
        stack.alignment = .center
        stack.distribution = .fill
        stack.spacing = CGFloat(20)
        return stack
    }()
    
    let completionImage: UIImageView = {
        let bannerImageView = UIImageView()
        bannerImageView.contentMode = .scaleToFill
        bannerImageView.clipsToBounds = true
        return bannerImageView
    }()
    
    let completionImageLabel: UILabel = {
        let label = UILabel()
        label.font = Font.bold.of(size: 32)
        label.backgroundColor = .clear
        label.numberOfLines = 0
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    let introLabel: UILabel = {
        let label = UILabel()
        label.font = Font.regular.of(size: 18)
        label.backgroundColor = Constants.backgroundColor
        label.numberOfLines = 0
        label.textColor = Color.text.value
        label.textAlignment = .center
        return label
    }()
    
    let msrCompensationLabel: UILabel = {
        let label = UILabel()
        label.font = Font.bold.of(size: 30)
        label.backgroundColor = Constants.backgroundColor
        label.textColor = Color.text.value
        label.textAlignment = .center
        return label
    }()
    
    let fiatCompensationLabel: UILabel = {
        let label = UILabel()
        label.font = Font.regular.of(size: 20)
        label.textColor = Color.lightText.value
        label.textAlignment = .center
        return label
    }()
    
    let border1: UIView = {
        let view = UIView()
        view.backgroundColor = Color.lightBorder.value
        return view
    }()
    
    let overallRatingLabel: UILabel = {
        let label = UILabel()
        label.font = Font.regular.of(size: 18)
        label.textColor = Color.text.value
        label.textAlignment = .center
        label.text = CompletedSurveyText.ratingLabelText.localized()
        return label
    }()
    
    let cosmosView: CosmosView = {
        let cv = CosmosView()
        cv.settings.emptyImage = Image.starEmpty.value
        cv.settings.filledImage = Image.starFull.value
        cv.settings.starSize = 40
        cv.settings.starMargin = 7
        cv.settings.totalStars = Layout.numberOfRatingStars
        cv.rating = 0
        return cv
    }()
    
    let border2: UIView = {
        let view = UIView()
        view.backgroundColor = Color.lightBorder.value
        return view
    }()
    
    let ratingItemsLabel: UILabel = {
        let label = UILabel()
        label.font = Font.regular.of(size: 18)
        label.textColor = Color.text.value
        label.textAlignment = .center
        label.text = CompletedSurveyText.ratingItemLabelText.localized()
        return label
    }()
    
    let collectionView: UICollectionView = {
        let layout = CenterAlignedCollectionViewFlowLayout()
        layout.estimatedItemSize = CGSize(width: 100, height: 40)
        
        let cv = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        cv.register(RatingItemCollectionViewCell.self, forCellWithReuseIdentifier: CellIdentifier.ratingItem.rawValue)
        cv.backgroundColor = Constants.backgroundColor
        return cv
    }()
    
    let border3: UIView = {
        let view = UIView()
        view.backgroundColor = Color.lightBorder.value
        return view
    }()
    
    let actionButton: UIButton = {
        let button = UIButton(type: UIButton.ButtonType.custom)
        button.titleLabel?.font = Font.regular.of(size: 18)
        button.setTitle(CompletedSurveyText.surveyCompleteButonText.localized(), for: UIControl.State.normal)
        button.layer.cornerRadius = Constants.buttonCornerRadius
        return button
    }()
    
    init(surveyType: SurveyType, surveyStatus: SurveyStatus, surveyManager: SurveyManager? = nil, videoUrl: String?) {
        self.surveyType = surveyType
        self.surveyStatus = surveyStatus
        self.surveyManager = surveyManager
        self.videoUrl = videoUrl
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UserManager.shared.currentlyTakingInternalSurvey = false
        UserManager.shared.currentlyTakingExternalSurvey = false
        
        switch surveyType {
        case .externalOffer, .categoryOffer:
            showRatings = true
        default:
            showRatings = false
        }
        
        updateContent()
        setupNavbar()
        setupViews()
        hideBackButtonTitle()
        
        cosmosView.didFinishTouchingCosmos = { rating in
            let isPositiveRating = rating > 3
            switch self.currentRatingView {
            case .none:
                if isPositiveRating {
                    self.ratingItems = self.positiveRatingItems
                    self.currentRatingView = .positive
                }
                else {
                    self.ratingItems = self.negativeRatingItems
                    self.currentRatingView = .negative
                }
                self.collectionView.reloadData()
            case .positive:
                if !isPositiveRating {
                    self.resetRatingItemSelection()
                    self.ratingItems = self.negativeRatingItems
                    self.collectionView.reloadData()
                    self.currentRatingView = .negative
                }
            case .negative:
                if isPositiveRating {
                    self.resetRatingItemSelection()
                    self.ratingItems = self.positiveRatingItems
                    self.collectionView.reloadData()
                    self.currentRatingView = .positive
                }
            }
            
            self.border2.isHidden = false
            self.ratingItemsLabel.isHidden = false
            self.collectionView.isHidden = false
        }
        trackData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        UserManager.shared.currentlyTakingInternalSurvey = false
        UserManager.shared.currentlyTakingExternalSurvey = false
        
        // force a rotation if there was an exit from the survey and it was in landscape
        UIDevice.current.setValue(UIDeviceOrientation.portrait.rawValue, forKey: Constants.orientation)
    }
    
    override func setupViews() {
        view.backgroundColor = Constants.backgroundColor
        view.addSubview(completionImage)
        view.addSubview(stackView)
        
        completionImage.snp.makeConstraints { (make) in
            make.top.equalTo(view).offset(Layout.topMargin)
            make.left.equalTo(view).offset(Layout.containerInset)
            make.right.equalTo(view).offset(-Layout.containerInset)
        }
        
        stackView.snp.makeConstraints { (make) in
            make.top.equalTo(completionImage.snp.bottom).offset(25)
            make.left.equalTo(view).offset(20)
            make.right.equalTo(view).offset(-20)
            make.bottom.equalTo(view).offset(-30)
        }
        
        border1.snp.makeConstraints { (make) in
            make.height.equalTo(Layout.borderHeight)
            make.width.equalTo(Layout.contentMaxWidth)
        }
        
        border2.snp.makeConstraints { (make) in
            make.height.equalTo(Layout.borderHeight)
            make.width.equalTo(Layout.contentMaxWidth)
        }
        
        collectionView.snp.makeConstraints { (make) in
            make.width.equalTo(Layout.contentMaxWidth)
            make.height.equalTo(190)
        }
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        border3.snp.makeConstraints { (make) in
            make.height.equalTo(Layout.borderHeight)
            make.width.equalTo(Layout.contentMaxWidth)
        }
        
        actionButton.snp.makeConstraints { (make) in
            make.width.equalTo(Layout.actionButtonWidth)
            make.height.equalTo(Layout.actionButtonHeight)
        }
        
        completionImage.addSubview(completionImageLabel)
        
        completionImageLabel.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(16)
            make.height.equalTo(38)
            make.centerY.equalToSuperview()
        }
        
        stackView.addArrangedSubview(introLabel)
        stackView.setCustomSpacing(10, after: introLabel)
        stackView.addArrangedSubview(msrCompensationLabel)
        stackView.setCustomSpacing(2, after: msrCompensationLabel)
        stackView.addArrangedSubview(fiatCompensationLabel)
        
        if showRatings {
            border2.isHidden = true
            ratingItemsLabel.isHidden = true
            collectionView.isHidden = true
            
            stackView.addArrangedSubview(border1)
            stackView.addArrangedSubview(overallRatingLabel)
            stackView.addArrangedSubview(cosmosView)
            stackView.setCustomSpacing(25, after: cosmosView)
            stackView.addArrangedSubview(border2)
            stackView.addArrangedSubview(ratingItemsLabel)
            stackView.addArrangedSubview(collectionView)
            
            overallRatingLabel.snp.makeConstraints { (make) in
                make.left.equalTo(stackView).offset(Layout.subContainerInset)
                make.right.equalTo(stackView).offset(-Layout.subContainerInset)
            }
            
            ratingItemsLabel.snp.makeConstraints { (make) in
                make.left.equalTo(stackView).offset(Layout.subContainerInset)
                make.right.equalTo(stackView).offset(-Layout.subContainerInset)
            }
        }
        
        stackView.addArrangedSubview(border3)
        stackView.setCustomSpacing(28, after: border3)
        stackView.addArrangedSubview(actionButton)
        
        actionButton.addTarget(self, action: #selector(self.finish), for: UIControl.Event.touchUpInside)
        
        applyCommunityTheme()
    }
    
    func setupNavbar() {
        if let _ = self.presentingViewController {
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.done, target: self, action: #selector(self.finish))
            navigationItem.leftBarButtonItem?.setTitleTextAttributes(Font.regular.asTextAttributes(size: 17), for: .normal)
        }
    }
    
    func resetRatingItemSelection() {
        selectedRatingItems.removeAll()
        for cell in collectionView.visibleCells {
            if let cell = cell as? RatingItemCollectionViewCell {
                cell.setUnselected()
            }
        }
    }
    
    func updateInReviewUI(_ offerItem: OfferItem) {
        if offerItem.estimatedEarnings > 0 {
            if let externalMessage = externalSurvey, let msg = externalMessage.eventMsg {
                introLabel.text = msg
            } else {
                introLabel.text = CompletedSurveyText.inreviewIntroTitle.localized()
            }
            if externalSurvey?.eventShowPayment == true {
                msrCompensationLabel.text = offerItem.estimatedEarnings.formattedMSRString
                fiatCompensationLabel.text = offerItem.estimatedEarningsFiat.formattedFiatString
            } else {
                msrCompensationLabel.text = ""
                fiatCompensationLabel.text = ""
            }
        } else {
            if let externalMessage = externalSurvey, let msg = externalMessage.eventMsg {
                introLabel.text = msg
            } else {
                introLabel.text = CompletedSurveyText.inreviewCompletedIntroTitle.localized()
            }
        }
    }
    
    func updateJobCompeteUI(_ offerItem: OfferItem) {
        if offerItem.estimatedEarnings > 0 {
            if let externalMessage = externalSurvey, let msg = externalMessage.eventMsg {
                introLabel.text = msg
            } else {
                introLabel.text = CompletedSurveyText.introTitle.localized()
            }
            if externalSurvey?.eventShowPayment == true {
                msrCompensationLabel.text = offerItem.estimatedEarnings.formattedMSRString
                fiatCompensationLabel.text = offerItem.estimatedEarningsFiat.formattedFiatString
            } else {
                msrCompensationLabel.text = ""
                fiatCompensationLabel.text = ""
            }
        } else {
            if let externalMessage = externalSurvey, let msg = externalMessage.eventMsg {
                introLabel.text = msg
            } else {
                introLabel.text = CompletedSurveyText.completedIntroTitle.localized()
            }
        }
    }
    
    func updateWelcomeOfferUI() {
        setTitle(CompletedSurveyText.profileAddedHeaderText.localized())
        introLabel.text = CompletedSurveyText.welcomeInfoLabelText.localized()
    }
    
    func disqualifiedSurveyUI(_ offerItem: OfferItem) {
        if offerItem.disqualifyEarnings > 0 {
            if let externalMessage = externalSurvey, let msg = externalMessage.eventMsg {
                introLabel.text = msg
            } else {
                introLabel.text = CompletedSurveyText.disqualifyInfoLabelText.localized()
            }
            if externalSurvey?.eventShowPayment == true {
                msrCompensationLabel.text = offerItem.disqualifyEarnings.formattedMSRString
                fiatCompensationLabel.text = offerItem.disqualifyEarningsFiat.formattedFiatString
            } else {
                msrCompensationLabel.text = ""
                fiatCompensationLabel.text = ""
            }
        } else {
            if let externalMessage = externalSurvey, let msg = externalMessage.eventMsg {
                introLabel.text = msg
            } else {
                introLabel.text = CompletedSurveyText.disqualifyLabelText.localized()
            }
        }
    }
    func closedSurveyUI() {
        introLabel.text = "Sorry, this survey has been closed"
        border1.isHidden = true
        overallRatingLabel.isHidden = true
        cosmosView.isHidden = true
        border2.isHidden = true
        ratingItemsLabel.isHidden = true
        collectionView.isHidden = true
    }
    
    func overQuotaSurveyUI(_ offerItem: OfferItem) {
        if offerItem.disqualifyEarnings > 0 {
            if let externalMessage = externalSurvey, let msg = externalMessage.eventMsg {
                introLabel.text = msg
            } else {
                introLabel.text = CompletedSurveyText.overQuotaInfoLabelText.localized()
            }
            if externalSurvey?.eventShowPayment == true {
                msrCompensationLabel.text = offerItem.disqualifyEarnings.formattedMSRString
                fiatCompensationLabel.text = offerItem.disqualifyEarningsFiat.formattedFiatString
            } else {
                msrCompensationLabel.text = ""
                fiatCompensationLabel.text = ""
            }
        } else {
            if let externalMessage = externalSurvey, let msg = externalMessage.eventMsg {
                introLabel.text = msg
            } else {
                introLabel.text = CompletedSurveyText.overQuotaLabelText.localized()
            }
        }
    }
    
    func updateCompletionScreenImage(str: String, color: UIColor) {
        completionImageLabel.text = str
        completionImageLabel.textColor = color
    }
    
    func updateContent() {
        switch surveyStatus {
        
        case .inReview:
            setTitle(CompletedSurveyText.inReviewHeaderText.localized())
            completionImage.image = Image.inReviewJob.value
            updateCompletionScreenImage(str: SurveyStatusText.inReview.localized(),
                                        color: Utilities.getRgbColor(47.0, 47.0, 87.0))
            switch surveyType {
            case .categoryOffer(_, _): break
            case .externalOffer(let offerItem): updateInReviewUI(offerItem)
            case .welcome, .category: break
            case .embeddedOffer(_, _): break
            }
            let inReviewStatus = JobCompletionStaus.inReview
            FirebaseAnalyticsManager.shared.logFirebaseAnalytics(.jobStatusScreen(status: inReviewStatus))
            
        case .completed:
            setTitle(CompletedSurveyText.jobCompletedHeaderText.localized())
            let completedStatus = JobCompletionStaus.completed
            FirebaseAnalyticsManager.shared.logFirebaseAnalytics(.jobStatusScreen(status: completedStatus))
            
            switch surveyType {
            case .categoryOffer(let offerItem, _):
                updateJobCompeteUI(offerItem)
                updateCompletionScreenImage(str: SurveyStatusText.jobComplete.localized(),
                                            color: Utilities.getRgbColor(47.0, 47.0, 87.0))
                completionImage.image = Image.completedJob.value
                
            case .externalOffer(let offerItem):
                completionImage.image = Image.completedJob.value
                updateCompletionScreenImage(str: SurveyStatusText.jobComplete.localized(),
                                            color: Utilities.getRgbColor(47.0, 47.0, 87.0))
                updateJobCompeteUI(offerItem)
                
            case .welcome, .category:
                updateWelcomeOfferUI()
                
            case .embeddedOffer(_, _):
                completionImage.image = Image.completedJob.value
                updateCompletionScreenImage(str: SurveyStatusText.jobComplete.localized(),
                                            color: Utilities.getRgbColor(47.0, 47.0, 87.0))
                updateWelcomeOfferUI()
            }
            
        case .disqualified:
            let disqualifiedStatus = JobCompletionStaus.disqualified
            FirebaseAnalyticsManager.shared.logFirebaseAnalytics(.jobStatusScreen(status: disqualifiedStatus))
            setTitle(CompletedSurveyText.disqualifiedHeaderText.localized())
            switch surveyType {
            case .categoryOffer(let offerItem, _):
                disqualifiedSurveyUI(offerItem)
                updateCompletionScreenImage(str: SurveyStatusText.disqualified.localized(),
                                            color: .white)
                completionImage.image = Image.disqualifiedJob.value
                
            case .externalOffer(let offerItem):
                updateCompletionScreenImage(str: SurveyStatusText.disqualified.localized(),
                                            color: .white)
                completionImage.image = Image.disqualifiedJob.value
                disqualifiedSurveyUI(offerItem)
                
            default: break
            }
            
        case .overQuota:
            let fullquotaStatus = JobCompletionStaus.fullquota
            FirebaseAnalyticsManager.shared.logFirebaseAnalytics(.jobStatusScreen(status: fullquotaStatus))
            setTitle(CompletedSurveyText.overQuotaHeaderText.localized())
            switch surveyType {
            case .categoryOffer(let offerItem, _):
                overQuotaSurveyUI(offerItem)
                updateCompletionScreenImage(str: SurveyStatusText.overQuota.localized(),
                                            color: .white)
                completionImage.image = Image.disqualifiedJob.value
                
            case .externalOffer(let offerItem):
                updateCompletionScreenImage(str: SurveyStatusText.overQuota.localized(),
                                            color: .white)
                completionImage.image = Image.disqualifiedJob.value
                overQuotaSurveyUI(offerItem)
                
            default: break
            }
            
        case .cancelled:
            switch surveyType {
            case .externalOffer(_):
                setTitle(CompletedSurveyText.surveyCancelHeaderText.localized())
                introLabel.text = CompletedSurveyText.surveyCancelInfoText.localized()
            default: break
            }
        case .closed:
            let closedStatus = JobCompletionStaus.terminate
             FirebaseAnalyticsManager.shared.logFirebaseAnalytics(.jobStatusScreen(status: closedStatus))
            setTitle(CompletedSurveyText.closedHeaderText.localized())
            switch surveyType {
            case .categoryOffer(_, _):
                
                closedSurveyUI()
                updateCompletionScreenImage(str: SurveyStatusText.closedTxt.localized(),
                                            color: .white)
                completionImage.image = Image.disqualifiedJob.value
                
            case .externalOffer(_):
                updateCompletionScreenImage(str: SurveyStatusText.closedTxt.localized(),
                                            color: .white)
                completionImage.image = Image.disqualifiedJob.value
                closedSurveyUI()
                
            default: break
            }
            
        default: break
        }
    }
    
    @objc func dismissAndGoBack() {
        switch surveyType {
        case .categoryOffer(let offerItem, _), .externalOffer(let offerItem), .embeddedOffer(let offerItem, _):
            if let sampleRequestID = offerItem.sampleRequestID {
                let rating = Int(cosmosView.rating)
                if rating > 0 {
                    NetworkManager.shared.rateSurvey(sampleRequestID: sampleRequestID, rating: rating, ratingItems: Array(selectedRatingItems)) {
                        error in
                        
                        if let _ = error {
                            os_log("Error posting survey rating.", log: OSLog.surveys, type: .error)
                        }
                    }
                    
                    AnalyticsManager.shared.log(
                        event: .rateSurvey,
                        params: [
                            "af_rating_value": rating,
                            "af_content_type": surveyType.stringValue,
                            "af_content_id": offerItem.offerIDForAnalytics,
                            "af_max_rating_value": Layout.numberOfRatingStars
                        ]
                    )
                }
            }
            
            let recentlyClosedInfo: [String: Int] = ["offerID": offerItem.offerID]
            NotificationCenter.default.post(name: NSNotification.Name.offerCompleted, object: nil, userInfo: recentlyClosedInfo)
            
        default:
            break
        }
        
        msr_dismiss {
            [weak self] in
            self?.delegate?.didCompleteSurvey(self?.surveyManager)
        }
    }
    
    @objc func finish() {
        dismissAndGoBack()
    }
    
    func trackData() {
        switch surveyType {
        
        case .category(_):
            AnalyticsManager.shared.log(
                event: .selfProfileJobCompleted,
                params: [
                    "ref": surveyType.categoryRef
                ]
            )
            
        case .categoryOffer(let offerItem, _):
            AnalyticsManager.shared.log(
                event: .makeWorkProfileJobCompleted,
                params: [
                    "survey_id": offerItem.offerIDForAnalytics
                ]
            )
            if ConnectivityUtils.isConnectedToNetwork() == false {
                Helper.showNoNetworkAlert(controller: self)
                return
            }
            
        case .embeddedOffer(let offerItem, _):
            AnalyticsManager.shared.log(
                event: .selfProfileMaintenanceJobCompleted,
                params: [
                    "survey_id": offerItem.offerIDForAnalytics
                ]
            )
        case .externalOffer(let offerItem):
            AnalyticsManager.shared.log(
                event: .paidSurveyJobCompleted,
                params: [
                    "survey_id": offerItem.offerIDForAnalytics
                ]
            )
        default:
            break
        }
    }
}
extension SurveyCompletionViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        view.layer.zPosition = 0.0 // Fix for view appearing on top of scrollbar
    }
}

extension SurveyCompletionViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ratingItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifier.ratingItem.rawValue, for: indexPath) as? RatingItemCollectionViewCell else {
            fatalError()
        }
        
        let item = ratingItems[indexPath.item]
        cell.configure(with: item)
        
        if selectedRatingItems.contains(item) {
            cell.setSelected()
        }
        else {
            cell.setUnselected()
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedItem = ratingItems[indexPath.item]
        
        if let cell = collectionView.cellForItem(at: indexPath) as? RatingItemCollectionViewCell {
            
            if selectedRatingItems.contains(selectedItem) {
                selectedRatingItems.remove(selectedItem)
                cell.setUnselected()
            }
            else {
                selectedRatingItems.insert(selectedItem)
                cell.setSelected()
            }
        }
    }
}

extension SurveyCompletionViewController: CommunityThemeConfigurable {
    @objc func applyCommunityTheme() {
        guard let community = UserManager.shared.currentCommunity, let colors = community.colors else {
            return
        }
        
        actionButton.setDarkeningBackgroundColor(color: colors.primary)
        actionButton.setTitleColor(colors.background, for: .normal)
    }
}
