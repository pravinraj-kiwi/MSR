//
//  MyDataViewController.swift
//  Contributor
//
//  Created by arvindh on 05/09/18.
//  Copyright © 2018 Measure. All rights reserved.
//

import os
import UIKit
import IGListKit
import SwiftyUserDefaults
import Instructions

class MyDataViewController: UIViewController, SpinnerDisplayable, StaticViewDisplayable {
  var spinnerViewController: SpinnerViewController = SpinnerViewController()
  var staticMessageViewController: FullScreenMessageViewController?
  
  lazy var adapter: ListAdapter = {
    let updater = ListAdapterUpdater()
    let listAdapter = ListAdapter(updater: updater, viewController: self)
    listAdapter.collectionView = collectionView
    listAdapter.dataSource = self
    listAdapter.collectionViewDelegate = self
    return listAdapter
  }()
  
  let collectionView: UICollectionView = {
    let layout = UICollectionViewFlowLayout()
    layout.estimatedItemSize = CGSize(width: 10, height: 10)
    let cv = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
    cv.backgroundColor = Constants.backgroundColor
    cv.alwaysBounceVertical = true
    return cv
  }()
  
    let topHeaderItem = TopHeaderItem(text: TabName.myData.localized(), showDate: false)
    let dataSourcesHeaderItem = GenericHeaderItem(text: MyDataText.connectApps.localized())
    let connectedAppHeaderItem = GenericHeaderItem(text: MyDataText.conectedData.localized())
  let helpMessage = MessageHolder(message: Message.myProfileData)

  var fetchCategoriesError: Error?
  var gotFetchError: Bool {
    return fetchCategoriesError != nil
  }

  var linkedinAdData: ConnectedAppData?
  var connectedData = [ConnectedAppData]()
  var surveyCategories: [SurveyCategory] = []
  var profileAttributes: [ProfileAttributeModel]? = []
  var category: Category?
  var dataSources: DataSourceHolder!
  var coachMarksController = CoachMarksController()
  var scrolledFrame: CGRect?
  var coachMark: CoachMark?
    
  override func viewDidLoad() {
    super.viewDidLoad()
    setTitle(TabName.myData.localized())
    hideBackButtonTitle()
    setupDataSources()
    setupViews()
    addObserver()
    if Defaults[.hadSeenMyDataTutorial] == true {
      fetchMyData(showLoader: true)
    }
  }
   
  func addObserver() {
    NotificationCenter.default.addObserver(self, selector: #selector(updateConnectingAppUI(_:)),
                                           name: NSNotification.Name.connectingAppSuccess, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(updateCategory),
                                           name: NSNotification.Name.updateCategory, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(updateRedDotOnTabBar),
                                           name: NSNotification.Name.hadSeenToolTip, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(updateMyAttributeSection),
                                              name: NSNotification.Name.updateAttributeSection, object: nil)
  }
    
  func startInstructions() {
    coachMarksController.overlay.isUserInteractionEnabled = false
    self.coachMarksController.overlay.backgroundColor = Utilities.getRgbColor(48.0, 48.0, 48.0, 0.5)
    self.coachMarksController.dataSource = self
  } 
    
  @objc func updateConnectingAppUI(_ notification: Notification) {
    fetchMyData(showLoader: true)
    NotificationCenter.default.post(name: NSNotification.Name.partnerAlreadyConnected, object: nil, userInfo: nil)
  }
    
  @objc func updateCategory() {
    if ConnectivityUtils.isConnectedToNetwork() == false {
        Helper.showNoNetworkAlert(controller: self)
        return
    }
    fetchCategories { (isSucces) in
        if isSucces {
            NotificationCenter.default.post(name: .updateCollectionViewUI, object: nil, userInfo: nil)
        }
    }
  }
 
  @objc func updateMyAttributeSection() {
    getProfileAttributes { (attributes, success) in
        if success {
            NotificationCenter.default.post(name: .updateAttributeCell, object: attributes, userInfo: nil)
        }
     }
  }
    
  @objc func updateRedDotOnTabBar() {
    self.currentTabBar?.setBadgeText(nil, atIndex: 1)
  }
    
  override func viewWillDisappear(_ animated: Bool) {
      super.viewWillDisappear(animated)
      coachMarksController.stop(immediately: true)
  }
    
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    os_log("MyData->viewDidAppear", log: OSLog.views, type: .debug)
     if Defaults[.hadSeenMyDataTutorial] == false
            && self.currentTabBar?.selectedIndex == 1 {
        fetchMyData(showLoader: true)
    }
    FirebaseAnalyticsManager.shared.logFirebaseAnalytics(.myDataScreen)
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  func setupDataSources() {
    dataSources = DataSourceHolder(items: [
      DataSource.spotify,
      DataSource.amazon,
      DataSource.location,
      DataSource.health
    ])
  }
  
  override func setupViews() {
    view.backgroundColor = Constants.backgroundColor
    view.addSubview(collectionView)
    collectionView.snp.makeConstraints { (make) in
      make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
      make.left.equalTo(view)
      make.right.equalTo(view)
      make.bottom.equalTo(view)
    }
  }
    
    func fetchMyData(showLoader: Bool) {
    showSpinner()

    let group = DispatchGroup()

    group.enter()
    fetchCategories { (_) in
        group.leave()
    }

    group.enter()
    fetchLinkAdStatus {
      group.leave()
    }
    
    group.enter()
     getProfileAttributes { (_, _) in
      group.leave()
    }
        
   group.notify(queue: DispatchQueue.main) {
     [weak self] in
     guard let this = self else {
       return
     }
     this.hideSpinner()
     this.adapter.performUpdates(animated: false) { (_) in
        if Defaults[.hadSeenMyDataTutorial] == false && this.currentTabBar?.selectedIndex == 1 {
            if ConnectivityUtils.isConnectedToNetwork() == false {
                Helper.showNoNetworkAlert(controller: this)
                return
            }
            this.startInstructions()
            this.coachMarksController.start(in: .currentWindow(of: this))
        }
     }
   }
 }
    
func getProfileAttributes(completion: (([ProfileAttributeModel]?, Bool) -> Void)? = nil) {
    NetworkManager.shared.getProfileAttribute { [weak self] (attributes, error) in
      guard let this = self else {return}
        if error != nil {
          completion?(nil, false)
      } else {
         this.profileAttributes = attributes
         NotificationCenter.default.post(name: .updateAttributeCell, object: attributes, userInfo: nil)
         completion?(attributes, true)
      }
   }
}
    
 func fetchCategories(completion: ((Bool) -> Void)? = nil) {
    NetworkManager.shared.getSurveyCategories { [weak self] (categories, error) in
       guard let this = self else {return}
       if let error = error {
         this.fetchCategoriesError = error
         completion?(false)
       } else {
         this.category = categories
         this.surveyCategories = categories?.surveyCategory ?? []
         this.fetchCategoriesError = nil
         completion?(true)
       }
    }
  }

  func fetchLinkAdStatus(completion: (() -> Void)? = nil) {
    NetworkManager.shared.checkIfAppConnected { [weak self] (connectedAppData, error) in
        guard let this = self else {return}
        if error == nil {
            if let data = connectedAppData {
                this.connectedData = data
                let filterData = data.filter({$0.displayAd == true})
                if filterData.isEmpty == false {
                  this.linkedinAdData = filterData[0] as ConnectedAppData
                  NotificationCenter.default.post(name: NSNotification.Name.connectingAppStatusChanged,
                                                  object: this.linkedinAdData, userInfo: nil)
                } else {
                    this.linkedinAdData = nil
                    NotificationCenter.default.post(name: NSNotification.Name.connectingAppStatusChanged,
                                                    object: nil, userInfo: nil)
                }
            }
        }
        completion?()
    }
  }

  deinit {
     NotificationCenter.default.removeObserver(self)
  }
}

// MARK: ListAdapterDataSource

extension MyDataViewController: ListAdapterDataSource {
  func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
    var objects: [ListDiffable] = []
    
    // main header
    objects.append(topHeaderItem)

    if gotFetchError {
      objects.append(MessageHolder(message: Message.genericFetchError))
    } else {
      // static message
      let dataHeaderViewController = MyDataHeaderSectionController()
      objects.append(dataHeaderViewController)

     objects.append(helpMessage)
        
      let categoriesViewController = DataSurveyCategoriesViewController()
      categoriesViewController.dataSource = self
      objects.append(categoriesViewController)
      
        if UserManager.shared.user?.hasFilledBasicDemos == true
            && profileAttributes?.isEmpty == false {
        let attributeProfileController = ProfileAttributeSection()
        objects.append(attributeProfileController)
      }
        
      let connectedAppViewController = ConnectedAppsSectionController()
      objects.append(connectedAppViewController)
    }
    return objects
  }
  
  func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
    switch object {
    case is TopHeaderItem:
      let controller = TopHeaderSectionController()
      controller.delegate = self
      return controller
    case is MyDataHeaderSectionController:
        let dataHeaderViewController = MyDataHeaderSectionController()
        dataHeaderViewController.categoryData = category
        return dataHeaderViewController
    case let message as MessageHolder:
      switch message.messageType {
      case .error:
        let controller = ErrorMessageSectionController()
        controller.delegate = self
        return controller
      default:
        let linkedinController = LinkedinSectionController()
        linkedinController.delegate = self
        return linkedinController
      }
    case is ProfileAttributeSection:
        let profileAttributeController = ProfileAttributeSection()
        if let attributes = profileAttributes {
          profileAttributeController.delegate = self
          profileAttributeController.profileAttributes = attributes
        }
        return profileAttributeController
    case is ConnectedAppsSectionController:
        let connectedAppsController = ConnectedAppsSectionController()
        connectedAppsController.data = connectedData
        connectedAppsController.connectedAppsDelegate = self
        return connectedAppsController
    case is UIViewController:
      return ContainerSectionController()
    default:
      fatalError()
    }
}
  
func emptyView(for listAdapter: ListAdapter) -> UIView? {
  return nil
 }
}

// MARK: DataSurveyCategoriesDataSource

extension MyDataViewController: DataSurveyCategoriesDataSource {
  func categories() -> Category? {
    if let category = self.category {
        return category
    }
    return nil
  }
    
func getFilterCategory() -> [SurveyCategory]? {
    return getOrderedListOnBasisOfCompletion(self.surveyCategories)
}
    
func getOrderedListOnBasisOfCompletion(_ surveyCategory: [SurveyCategory]?) -> [SurveyCategory] {
    var filteredCategory = [SurveyCategory]()
    if let notCompletedCategory = surveyCategory?.filter({$0.isCompleted == false}) {
       filteredCategory = notCompletedCategory
    }
    if let completedCategories = surveyCategory?.filter({$0.isCompleted == true}),
        let notCompletedCategory = surveyCategory?.filter({$0.isCompleted == false}) {
        filteredCategory = getFilterredCategory(surveyCategory, notCompletedCategory, completedCategories)
    }
    return filteredCategory
}

func getFilterredCategory(_ surveyCategory: [SurveyCategory]?, _ notCompletedCategory: [SurveyCategory],
                          _ completedCategories: [SurveyCategory]) -> [SurveyCategory] {
    var filterCategory = [SurveyCategory]()
    if completedCategories.count == 1
        && completedCategories.filter({$0.ref == Constants.basic}).isEmpty == false {
         if let basic = surveyCategory?.filter({$0.ref == Constants.basic}) {
            let sortedFilteredCategory = completedCategories.filter({$0.ref != Constants.basic}).sorted(by: { $0.order < $1.order })
             filterCategory =  basic + notCompletedCategory + sortedFilteredCategory
         }
     } else {
         let sortFilteredCategory = completedCategories.sorted(by: { $0.order < $1.order })
         filterCategory = notCompletedCategory + sortFilteredCategory
     }
     return filterCategory
}
    
func moveToSurvey(surveyManager: SurveyManager) {
    if ConnectivityUtils.isConnectedToNetwork() == false {
        Helper.showNoNetworkAlert(controller: self)
        return
    }
    Router.shared.route(
        to: Route.surveyStart(surveyManager: surveyManager, screenType: .myData),
        from: self,
        presentationType: PresentationType.modal(presentationStyle: .pageSheet,
                                                 transitionStyle: .coverVertical)
       )
    }
}

// MARK: LinkedinValidationData
extension MyDataViewController: ConnectedAppsDataSourceDelegate {
  func clickToOpenProfileValidations(dataType: ConnectedDataType) {
    clickToOpenDataTypePage(dataType)
  }
    
  func clickToOpenPatnersScreen(dataType: ConnectedDataType) {
    clickToOpenDataTypePage(dataType)
  }
    
 func clickToOpenDataTypePage(_ data: ConnectedDataType) {
    Router.shared.route(
        to: Route.dataType(dataType: data, connectAppData: connectedData),
        from: self,
        presentationType: .modal(presentationStyle: .fullScreen,
        transitionStyle: .coverVertical))
  }
}

extension MyDataViewController: LinkedinDataSourceDelegate {

func getLinkedinData() -> ConnectedAppData? {
    return linkedinAdData
}

func clickToOpenConnectionDetail(appType: ConnectedApp) {
    updatesAdStatus(appType: appType) { (isSuccess) in
         if isSuccess {
            Router.shared.route(
                to: Route.connect(appType: appType),
            from: self,
            presentationType: .modal(presentationStyle: .pageSheet,
                                     transitionStyle: .coverVertical))
            self.updateAdDataUI(true)
        }
    }
}

func updateAdDataUI(_ isYesClicked: Bool) {
  if ConnectivityUtils.isConnectedToNetwork() == false {
     Helper.showNoNetworkAlert(controller: self)
     return
  }
  NetworkManager.shared.checkIfAppConnected {
    [weak self] (connectedAppData, error) in
    guard let this = self else {return}
    if error == nil {
        if let data = connectedAppData {
            this.connectedData = data
            let filterData = data.filter({$0.displayAd == true})
            if filterData.isEmpty == false {
                this.linkedinAdData = filterData[0] as ConnectedAppData
            } else {
                this.linkedinAdData = nil
                NotificationCenter.default.post(name: NSNotification.Name.connectingAppStatusChanged,
                                                object: nil, userInfo: nil)
            }
            this.adapter.performUpdates(animated: false, completion: nil)
            this.scrollToBottom(animated: false)
        }
    }
  }
}

func clickToCloseAdView(appType: ConnectedApp) {
    updatesAdStatus(appType: appType) { [weak self] (isSuccess) in
        guard let this = self else { return }
        if isSuccess {
            this.updateAdDataUI(false)
       }
   }
}

func scrollToBottom(animated: Bool = true) {
    let bottomOffset = CGPoint(
        x: 0,
        y: self.collectionView.contentSize.height)
    self.collectionView.setContentOffset(bottomOffset, animated: animated)
}

func updatesAdStatus(appType: ConnectedApp, completion: @escaping (Bool) -> Void) {
   if ConnectivityUtils.isConnectedToNetwork() == false {
        Helper.showNoNetworkAlert(controller: self)
        return
   }
    NetworkManager.shared.updateLinkedinStatus(adType: appType.rawValue) { (error) in
      if error == nil {
         completion(true)
      }
      completion(false)
    }
}
}

extension MyDataViewController: ProfileAttributeSectionDelegate {
    func moveToAttributeList() {
        if ConnectivityUtils.isConnectedToNetwork() == false {
            Helper.showNoNetworkAlert(controller: self)
            return
        }
        Router.shared.route(
          to: Route.profileAttributeList,
          from: self,
          presentationType: .modal(presentationStyle: .pageSheet, transitionStyle: .coverVertical)
        )
    }
}

// MARK: TopHeaderViewCellDelegate
extension MyDataViewController: TopHeaderSectionControllerDelegate {
  func didTapSettingsButton() {
    if ConnectivityUtils.isConnectedToNetwork() == false {
        Helper.showNoNetworkAlert(controller: self)
        return
    }
    Router.shared.route(
      to: Route.settings,
      from: self,
      presentationType: .modal(presentationStyle: .fullScreen, transitionStyle: .coverVertical)
    )
  }
}

// MARK: UICollectionViewDelegate
extension MyDataViewController: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView,
                      willDisplaySupplementaryView view: UICollectionReusableView,
                      forElementKind elementKind: String, at indexPath: IndexPath) {
    view.layer.zPosition = 0.0 // Fix for view appearing on top of scrollbar
  }
}

// MARK: ErrorMessageSectionControllerDelegate
extension MyDataViewController: ErrorMessageSectionControllerDelegate {
  func didTapActionButton() {
    fetchMyData(showLoader: true)
  }
}

// MARK: Tabbable
extension MyDataViewController: Tabbable {
  var tabName: String {
    return TabName.myData.localized()
  }
  
  var tabImage: Image {
    return Image.myDataIcon
  }
  
  var tabHighlightedImage: Image {
    return Image.myDataIcon
  }
}
