//
//  GiftCardsViewController.swift
//  Contributor
//
//  Created by arvindh on 16/01/19.
//  Copyright © 2019 Measure. All rights reserved.
//

import UIKit
import IGListKit
import SnapKit
import Moya
import EmailValidator

class GiftCardsViewController: UIViewController, SpinnerDisplayable, StaticViewDisplayable {
    struct Layout {
        static let buttonHeight: CGFloat = 36
        static let buttonWidth: CGFloat = 80
        static let descriptionLabelBottomMargin: CGFloat = 16
        static let noteLabelBottomMargin: CGFloat = 20
        static let sideMargin: CGFloat = 12
        static let payPalTopMargin: CGFloat = 0
        static let payPalBottomMargin: CGFloat = 10
        static let payPalWidthMargin: CGFloat = 156
        static let payPalHeightMargin: CGFloat = 99
        
    }
    
    lazy var adapter: ListAdapter = {
        let updater = ListAdapterUpdater()
        let listAdapter = ListAdapter(updater: updater, viewController: self)
        listAdapter.collectionView = collectionView
        listAdapter.dataSource = self
        return listAdapter
    }()
    
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        cv.backgroundColor = Constants.backgroundColor
        cv.alwaysBounceVertical = true
        return cv
    }()
    
    let headerView: UIView = {
        let view = UIView()
        view.backgroundColor = Constants.backgroundColor
        view.hugContent(in: NSLayoutConstraint.Axis.vertical)
        return view
    }()
    
    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
        
    }()
    var checkMarkView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    let tableView: UITableView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UITableView(frame: .zero)
        cv.backgroundColor = Constants.backgroundColor
        cv.alwaysBounceVertical = true
        return cv
    }()
    var spinnerViewController: SpinnerViewController = SpinnerViewController()
    var staticMessageViewController: FullScreenMessageViewController?
    var fetchError: Error?
    var giftCardsHolder: GiftCardHolder?
    var redemptionOptions: [GiftCardRedemptionOption] = []
    var buttonStackView: UIStackView?
    var paymentType: PaymentType = .giftCard
    var payPalDatasource = PayPalDataSource()
    var tableHeaderView = PayPalFormHeader.loadNib()
    var paypalFormData = [FormSection]()
    var selectedRedemtionOption: GiftCardRedemptionOption?
    override func viewDidLoad() {
        super.viewDidLoad()
        setTitle(GiftCardViewText.redeemBalance.localized())
        hideBackButtonTitle()
        setupViews()
        setupNavbar()
        setUpHeaderView()
        fetchGiftCards()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        FirebaseAnalyticsManager.shared.logFirebaseAnalytics(.redeemGiftScreen)
    }
    func setUpHeaderView() {
        view.backgroundColor = Constants.backgroundColor
        setUpDataSource()
    }
    func setUpDataSource() {
        tableView.register(cellType: PayPalInputCell.self)
        tableView.register(cellType: SectionViewCell.self)
        tableView.register(cellType: PlaceholderFormCell.self)
        tableView.register(cellType: FooterCell.self)
        tableView.register(cellType: FormAcceptanceCell.self)
        tableView.setTableHeaderView(headerView: tableHeaderView)
        tableHeaderView.headerDelegate = self
        tableView.updateHeaderViewFrame()
        payPalDatasource.tableView = tableView
        payPalDatasource.formData = updateAccountData()
        payPalDatasource.delegate = self
        tableView.dataSource = payPalDatasource
        tableView.delegate = payPalDatasource
        tableView.rowHeight = 64
        tableView.estimatedRowHeight = 64
        payPalDatasource.payPalAmountSelected(false)
        tableView.separatorStyle = .none
    }
    func updateAccountData() -> [FormSection] {
        let emailField = FormModel()
        emailField.textFieldType = .email
        emailField.placeholderValue = PlaceholderTextValue.paypalEmail.localized()
        emailField.section = 0
        emailField.placeholderKey = PlaceholderText.paypalEmail.localized()
        emailField.textFieldType1 = .confirmEmail
        emailField.placeholderValue1 = PlaceholderTextValue.paypalEmail.localized()
        emailField.placeholderKey1 = PlaceholderText.confirmPayPalEmail.localized()
        emailField.section = 0
        paypalFormData = [FormSection.init(formType: .singleCell,
                                           formSection: 0,
                                           formValue: [emailField])]
        return paypalFormData
    }
    override func setupViews() {
        view.backgroundColor = Constants.backgroundColor
        imageView.image = Image.paypal.value
        view.addSubview(imageView)
        if paymentType == .paypal {
            imageView.snp.makeConstraints { (make) in
                make.top.equalTo(view).offset(10)
                make.centerX.equalTo(view)
                make.width.equalTo(Layout.payPalWidthMargin)
            }
        } else {
            imageView.isHidden = true
        }
        view.addSubview(headerView)
        headerView.snp.makeConstraints { (make) in
            make.top.equalTo(imageView.snp_bottom)
            make.left.equalTo(view)
            make.right.equalTo(view)
        }
        if paymentType == .paypal {
            view.addSubview(tableView)
            tableView.snp.makeConstraints { (make) in
                make.top.equalTo(headerView.snp.bottom)
                make.left.equalTo(view)
                make.right.equalTo(view)
                make.bottom.equalTo(view)
            }
        } else {
            view.addSubview(collectionView)
            collectionView.snp.makeConstraints { (make) in
                make.top.equalTo(headerView.snp.bottom)
                make.left.equalTo(view)
                make.right.equalTo(view)
                make.bottom.equalTo(view)
            }
        }
    }
    
    func setupNavbar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.done, target: self, action: #selector(self.dismissSelf))
        navigationItem.leftBarButtonItem?.setTitleTextAttributes(Font.regular.asTextAttributes(size: 17), for: .normal)
    }
    
    func setupHeader() {
        headerView.removeAllSubviews()
        if paymentType == .paypal {
            self.collectionView.isHidden = true
        }
        let balanceLabel: UILabel = {
            let label = UILabel()
            label.font = Font.semiBold.of(size: 16)
            label.numberOfLines = 0
            label.backgroundColor = Constants.backgroundColor
            label.textAlignment = .center
            
            if let wallet = UserManager.shared.wallet {
                label.text = "\(GiftCardViewText.currentBalance.localized()) \(wallet.balanceFiatString) (\(wallet.balanceMSRString))"
            }
            
            label.hugContent(in: NSLayoutConstraint.Axis.vertical)
            return label
        }()
        
        let descriptionLabel: UILabel = {
            let label = UILabel()
            label.font = Font.regular.of(size: 16)
            label.numberOfLines = 0
            label.backgroundColor = Constants.backgroundColor
            label.textAlignment = .center
            label.text = GiftCardViewText.redeemAmount.localized()
            label.hugContent(in: NSLayoutConstraint.Axis.vertical)
            return label
        }()
        
        headerView.addSubview(balanceLabel)
        balanceLabel.snp.makeConstraints { (make) in
            make.top.equalTo(headerView).offset(20)
            make.left.equalTo(headerView).offset(Layout.sideMargin)
            make.right.equalTo(headerView).offset(-Layout.sideMargin)
        }
        
        headerView.addSubview(descriptionLabel)
        descriptionLabel.snp.makeConstraints { (make) in
            make.top.equalTo(balanceLabel.snp.bottom).offset(10)
            make.left.equalTo(headerView).offset(Layout.sideMargin)
            make.right.equalTo(headerView).offset(-Layout.sideMargin)
        }
        
        let buttonStackView: UIStackView = {
            let stackView = UIStackView()
            stackView.axis = .horizontal
            stackView.alignment = .fill
            stackView.distribution = .fillProportionally
            stackView.hugContent(in: NSLayoutConstraint.Axis.horizontal)
            return stackView
        }()
        
        add(redeemOptions: redemptionOptions, in: buttonStackView)
        self.buttonStackView = buttonStackView
        
        headerView.addSubview(buttonStackView)
        buttonStackView.snp.makeConstraints { (make) in
            make.height.equalTo(Layout.buttonHeight)
            make.centerX.equalTo(headerView)
            make.top.equalTo(descriptionLabel.snp.bottom).offset(Layout.descriptionLabelBottomMargin)
        }
        
        let noteLabel: UILabel = {
            let label = UILabel()
            label.font = Font.regular.of(size: 16)
            label.backgroundColor = Constants.backgroundColor
            label.textAlignment = .center
            label.numberOfLines = 0
            label.hugContent(in: NSLayoutConstraint.Axis.vertical)
            
            let walletBalance: Decimal = UserManager.shared.wallet?.balanceFiat ?? 0
            let lowestRedemptionAmount: Decimal = redemptionOptions.first?.decimalValue ?? 0
            
            var prefix: String = ""
            if walletBalance < lowestRedemptionAmount {
                let currencySymbol = UserManager.shared.user?.currency?.symbol ?? "$"
                prefix = "\(GiftCardViewText.minBalance.localized()) \(currencySymbol)\(lowestRedemptionAmount) \(GiftCardViewText.requireRedeem.localized())"
            }
            if paymentType == .giftCard {
                label.text = "\(prefix)\(GiftCardViewText.clickedAmount.localized())"

            } else {
                label.text = prefix
            }
            return label
        }()
        
        headerView.addSubview(noteLabel)
        noteLabel.snp.makeConstraints { (make) in
            make.top.equalTo(buttonStackView.snp.bottom).offset(Layout.descriptionLabelBottomMargin)
            make.left.equalTo(view).offset(Layout.sideMargin)
            make.right.equalTo(view).offset(-Layout.sideMargin)
            make.bottom.equalTo(headerView).offset(-Layout.noteLabelBottomMargin)
        }
        
        let border: UIView = {
            let view = UIView()
            view.backgroundColor = Color.border.value
            return view
        }()
        
        headerView.addSubview(border)
        border.snp.makeConstraints { (make) in
            make.height.equalTo(2)
            make.left.equalTo(headerView).offset(Layout.sideMargin)
            make.right.equalTo(headerView).offset(-Layout.sideMargin)
            make.bottom.equalTo(headerView)
        }
        
        applyCommunityTheme()
    }
    
    fileprivate func add(redeemOptions options: [GiftCardRedemptionOption], in stackView: UIStackView) {
        let createButton = {
            (option: GiftCardRedemptionOption) -> UIButton in
            let button = UIButton(type: UIButton.ButtonType.custom)
            button.setTitle(option.formattedFiatValue, for: UIControl.State.normal)
            button.titleLabel?.font = Font.semiBold.of(size: 14)
            
            let alpha = option.enabled ? 1 : Constants.buttonDisabledAlpha
            button.alpha = alpha
            button.layer.cornerRadius = 4
            button.isEnabled = option.enabled
            
            button.snp.makeConstraints({ (make) in
                make.width.equalTo(Layout.buttonWidth)
            })
            button.setContentHuggingPriority(UILayoutPriority.required, for: NSLayoutConstraint.Axis.horizontal)
            button.addTarget(self, action: #selector(self.didTapButton(sender:)), for: UIControl.Event.touchUpInside)
            return button
        }
        
        stackView.removeAllArrangedSubviews()
        
        for (index, option) in options.enumerated() {
            let tmpView = UIStackView()
            let button = createButton(option)
            button.tag = index
            tmpView.addArrangedSubview(button)
            stackView.addArrangedSubview(button)
            stackView.setCustomSpacing(14, after: button)
        }
        if options.contains(where: { name in name.enabled == true }) {
            debugPrint("One option is enable atleast")
        } else {
            debugPrint("No Option enable for user, so hide input fields")
            payPalDatasource.hideAllRows = true
            tableView.reloadData()
        }
    }
    
    func fetchGiftCards() {
        guard let _ = UserManager.shared.user else {
            return
        }
        
        showSpinner()
        
        let group = DispatchGroup()
        if paymentType == .giftCard {
            group.enter()
            NetworkManager.shared.getGiftCards() {
                [weak self] (giftCards, error) in
                
                guard let this = self else {return}
                
                if error != nil {
                    this.fetchError = error
                }
                else {
                    this.giftCardsHolder = GiftCardHolder(items: giftCards)
                }
                
                group.leave()
            }
        }
        group.enter()
        NetworkManager.shared.getRedemptionAmounts(type: paymentType.getPaymentTypeServerValue()){
            [weak self] (options, error) in
            guard let this = self else {return}
            
            if error != nil {
                this.fetchError = error
            }
            else {
                this.redemptionOptions = options
            }
            
            group.leave()
        }
        
        group.notify(queue: DispatchQueue.main) {
            if let _ = self.fetchError {
                let message = MessageHolder(message: Message.genericFetchError)
                self.show(staticMessage: message)
            }
            else {
                self.setupHeader()
                self.adapter.performUpdates(animated: false, completion: nil)
                self.hideSpinner()
            }
        }
    }
    func removeShadowsFromOtherButtons() {
        _ = buttonStackView?.subviews.compactMap {
            $0.layer.borderWidth = 0.0
            $0.layer.shadowColor = UIColor.clear.cgColor
            $0.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
            $0.layer.masksToBounds = false
            $0.layer.shadowOpacity = 0.0
            $0.layer.cornerRadius = 0
            $0.layer.borderColor = UIColor.clear.cgColor
            $0.layer.cornerRadius = 4
        }
    }
    fileprivate func showTickMarkIcon(_ sender: UIButton) {
        checkMarkView = UIImageView(frame: CGRect(x: sender.frame.width - 14,
                                                  y: 1,
                                                  width: 15,
                                                  height: 15))
        checkMarkView.image = Image.tick.value
        sender.addSubview(checkMarkView)
        self.view.bringSubviewToFront(checkMarkView)
    }
    
    fileprivate func addShadowOnSelectedButton(_ sender: UIButton) {
        sender.layer.shadowColor = UIColor.gray.cgColor
        sender.layer.shadowOffset = CGSize(width: 0.0, height: 5.0)
        sender.layer.masksToBounds = false
        sender.layer.shadowOpacity = 0.5
        sender.layer.cornerRadius = 4
        sender.layer.borderColor = UIColor.white.cgColor
        sender.layer.borderWidth = 2.0
        sender.alpha = 1
    }
    @objc func didTapButton(sender: UIButton) {
        let index = sender.tag
        let option = redemptionOptions[index]
        
        if paymentType == .paypal {
            removeShadowsFromOtherButtons()
            checkMarkView.removeFromSuperview()
            addShadowOnSelectedButton(sender)
            showTickMarkIcon(sender)
            self.selectedRedemtionOption = option
            payPalDatasource.payPalAmountSelected(true)
        } else {
            let alerter = Alerter(viewController: self)
            let messageHolder = MessageHolder(
                message: Message.redeemGiftCardAlert,
                customValues: ["AMOUNT": option.formattedFiatValue, "MSR": option.formattedMSRValue]
            )
            alerter.alert(
                messageHolder: messageHolder,
                confirmButtonTitle: Text.yes.localized(),
                cancelButtonTitle: Text.cancel.localized(),
                onConfirm: {
                    Router.shared.route(
                        to: Route.redeemGiftCard(redemptionType: .giftCard,
                                                 option: option,
                                                 delegate: self),
                        from: self,
                        presentationType: PresentationType.push()
                    )
                },
                onCancel: nil
            )
        }
        
    }
}

extension GiftCardsViewController: ListAdapterDataSource {
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        var objects: [ListDiffable] = []
        if let giftCardsHolder = giftCardsHolder {
            objects.append(giftCardsHolder)
        }
        
        return objects
    }
    
    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        let sectionController = GiftCardsSectionController()
        return sectionController
    }
    
    func emptyView(for listAdapter: ListAdapter) -> UIView? {
        return nil
    }
}

extension GiftCardsViewController: MessageViewControllerDelegate {
    func didTapActionButton() {
        fetchError = nil
        hideStaticMessage()
        fetchGiftCards()
    }
}
extension GiftCardsViewController: CommunityThemeConfigurable {
    @objc func applyCommunityTheme() {
        guard let community = UserManager.shared.currentCommunity, let colors = community.colors else {
            return
        }
        
        guard let buttonStackView = buttonStackView else {
            return
        }
        
        for view in buttonStackView.subviews {
            if let button = view as? UIButton {
                button.setTitleColor(colors.whiteText, for: .normal)
                button.setDarkeningBackgroundColor(color: colors.primary)
            }
        }
    }
}
extension GiftCardsViewController: PayPalFormHeaderDelegate {
    func clickToWebSiteDetails() {
        Helper.clickToOpenUrl(Constants.payPalWebSiteURL,
                              controller: self,
                              shouldPresent: false)
    }
}
extension GiftCardsViewController: PayPalDataSourceDelegate {
    func hasEmailMatched() -> Bool {
        let email = paypalFormData.flatMap({$0.sectionValue.map({$0.fieldValue})})[0]
        let confirmEmail = paypalFormData.flatMap({$0.sectionValue.map({$0.fieldValue1})})[0]
        if (!EmailValidator.validate(email: email)) {
            _ =  paypalFormData.compactMap({$0.sectionValue.map({$0.shouldShowError = true})})
            tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
            return false
        }
        if (!EmailValidator.validate(email: confirmEmail)) {
            _ =  paypalFormData.compactMap({$0.sectionValue.map({$0.shouldShowError1 = true})})
            tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
            return false
        }
        if !email.isEmpty && !confirmEmail.isEmpty {
            if  email != confirmEmail {
                _ =  paypalFormData.compactMap({$0.sectionValue.map({$0.emailsNotMatched = true})})
                tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
                return false
            } else {
                _ =  paypalFormData.compactMap({$0.sectionValue.map({$0.emailsNotMatched = false})})
                tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
                return true
            }
        }
        return false
    }
    func clickToPeformAction(_ updatedFormData: [FormSection]) {
        self.view.endEditing(true)
        if updatedFormData.map({$0.isTermsConditionAccepted })[0] == false {
            NotificationCenter.default.post(name: NSNotification.Name.errorUpdateButton, object: nil)
            return
        }
        if !hasEmailMatched() {
            NotificationCenter.default.post(name: NSNotification.Name.errorUpdateButton, object: nil)
            return
        }
        if self.selectedRedemtionOption == nil {
            payPalDatasource.payPalAmountSelected(false)
            return
        }
        let section = updatedFormData.flatMap({$0.sectionValue.filter({$0.section == 0})})
        let email = section.map({$0.fieldValue})[0]
        guard let option = self.selectedRedemtionOption else {return}
        Router.shared.route(
            to: Route.redeemGiftCard(redemptionType: .paypal,
                                     paypalEmail: email,
                                     option: option,
                                     delegate: self),
            from: self,
            presentationType: PresentationType.push()
        )
    }
    
    func clickToOpenTerms() {
        Helper.clickToOpenUrl(Constants.payPalTermsURL,
                              controller: self,
                              shouldPresent: false)
    }
}
extension GiftCardsViewController: RedeemCompletionDelegate {
    func redeemptionComplete() {
        self.dismiss(animated: false, completion: nil)
    }
}
