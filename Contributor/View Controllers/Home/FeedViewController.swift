//
//  FeedViewController.swift
//  Contributor
//
//  Created by arvindh on 05/09/18.
//  Copyright © 2018 Measure. All rights reserved.
//

import os
import UIKit
import IGListKit
import SafariServices
import WebKit
import SwiftyUserDefaults
import Toast_Swift
import AAViewAnimator
import URLNavigator


// MARK: Main view controller
class FeedViewController: UIViewController, SpinnerDisplayable {
  var spinnerViewController: SpinnerViewController = SpinnerViewController()
  fileprivate var markItemBackgroundTaskRunner: BackgroundTaskRunner!

  lazy var adapter: ListAdapter = {
    let updater = ListAdapterUpdater()
    let listAdapter = ListAdapter(updater: updater, viewController: self)
    listAdapter.collectionView = collectionView
    listAdapter.dataSource = self
    listAdapter.collectionViewDelegate = self
    listAdapter.scrollViewDelegate = self
    return listAdapter
  }()
  
  let collectionView: UICollectionView = {
    let layout = UICollectionViewFlowLayout()
    layout.estimatedItemSize = CGSize.zero
    let cv = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
    cv.backgroundColor = Constants.backgroundColor
    cv.alwaysBounceVertical = true
    return cv
  }()
  
  var offerItems: [FeedItem] = []
   // var storyItems: [FeedItem] = []
    var storyItems = [Story]()
   // let storiesItem = StoryListItem(stories: [])

  var selectedStoryItem: Story?
  var selectedStoryIndex = -1
  var contentItems: [ContentItem] = []
  var stats: UserStats?
  var pauseFeedRefresh: Bool = false
  var refreshControl: UIRefreshControl!
  var viewAppeared: Bool = false
  var offerNotificationInfo: [String: Any]?
  var recentlyDeclinedOfferID: Int?
  var recentlyCompletedOfferID: Int?
  var onboardingFinished: Bool = true
  var apiCallIsInProgress = false
  let generator = UIImpactFeedbackGenerator(style: .light)

    let topFeedHeaderItem = TopHeaderItem(text: FeedViewText.job.localized(), showDate: true)
  let newsHeaderItem = GenericHeaderItem(text: FeedViewText.news, useLargeFont: true)
  let onboardingItem = OnboardingItem()
  var emptyOffersItem = EmptyOffersItem(stats: nil)
  let seperatorItem = SeperatorItem()

  let genericFetchErrorMessageHolder = MessageHolder(message: Message.genericFetchError)
  let fraudErrorMessageHolder = MessageHolder(message: Message.fraudError)
  
  var fetchOfferItemsError: Error?
  var fetchContentItemsError: Error?
  var fetchUserStatsError: Error?
  var exitOfferId: Int?
  var isMaintenanceScreenDisplayed = false
  let customView = CustomSnackView()
  let referView = ReferView()
  var feedVisitCount: Int? = Defaults[.appLaunchCount]

  var gotFetchError: Bool {
    return fetchOfferItemsError != nil || fetchContentItemsError != nil
        || fetchUserStatsError != nil || ConnectivityUtils.isConnectedToNetwork() == false
  }
  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    super.init(nibName: nil, bundle: nil)
      showSpinner()
      NotificationCenter.default.addObserver(self, selector: #selector(updateStatusAsAppBecomeActive), name: NSNotification.Name.appGotActive, object: nil)
    
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  @objc func updateStatusAsAppBecomeActive(_ notification: Notification) {
    addListeners()
    fetchFeed()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    //Get Data Inbox Package and merge into profile
    DataInboxSupportManager.shared.updateDataInboxSupportIfNeeded()
    hideBackButtonTitle()
    setupViews()
    if let _ = Defaults[.loggedInUserAccessToken] {
       addListeners()
    if !Defaults[.feedDidLoadRunBefore] {
        Defaults[.feedDidLoadRunBefore] = true
        fetchFeed()
        adapter.collectionView?.scrollToItem(at: IndexPath(item: 0, section: 0), at: .top, animated: true)
      }
    }
    if UserDefaults.standard.value(forKey: Constants.profileNewValues) == nil {
       let updatedValues = UserManager.shared.profileStore?.compareAndUpdateOldValues()
       UserDefaults.standard.set(updatedValues, forKey: Constants.profileNewValues)
    }
  }
    
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    showReferViewAfterCross()
  }

  override func viewDidAppear(_ animated: Bool) {
    guard let user = UserManager.shared.user, let _ = Defaults[.loggedInUserAccessToken] else {
      return
    }
    super.viewDidAppear(animated)
    if viewAppeared {
      if pauseFeedRefresh {
        pauseFeedRefresh = false
      }
            
      if user.isAcceptingOffers && Defaults[.feedDidLoadRunBefore] {
        fetchFeed(refresh: true)
      } else {
        adapter.performUpdates(animated: true, completion: nil)
      }
    } else {
      adapter.performUpdates(animated: true, completion: nil)
    }
    viewAppeared = true
    NotificationCenter.default.post(name: NSNotification.Name.feedDidAppear, object: nil, userInfo: nil)
    FirebaseAnalyticsManager.shared.logFirebaseAnalytics(.feedScreen)
  }
    
  func showReferViewAfterCross() {
    if UserManager.shared.isLoggedIn && Defaults[.closeReferFriendView] {
        feedVisitCount!+=1
        Defaults[.appLaunchCount] = feedVisitCount
        debugPrint("Save Count: \(String(describing: Defaults[.appLaunchCount]))")
       if Defaults[.appLaunchCount] == 10 {
         addReferView()
         Defaults[.closeReferFriendView] = false
      }
    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
    
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    self.apiCallIsInProgress = false
    Defaults[.notifAppeared] = false
    Defaults[.feedDidLoadRunBefore] = false
  }
  override func setupViews() {
    view.addSubview(collectionView)
    collectionView.snp.makeConstraints { (make) in
      make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
      make.left.equalTo(view)
      make.right.equalTo(view)
      make.bottom.equalTo(view)
    }
    
    refreshControl = UIRefreshControl()
    refreshControl.addTarget(self, action: #selector(self.onManualFeedRefresh), for: UIControl.Event.valueChanged)
    collectionView.addSubview(refreshControl)
}
    
// feed-related notifications
func addFeedAndOfferListners() {
    NotificationCenter.default.addObserver(self, selector: #selector(self.onUpdatedFeedOnServer),
                                           name: NSNotification.Name.updatedFeedOnServer, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(self.onFeedChanged(_:)),
                                           name: NSNotification.Name.feedChanged, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(self.onFeedLikelyToChangeSoon),
                                           name: NSNotification.Name.feedLikelyToChangeSoon, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(self.onExistRefreshFeed),
                                           name: NSNotification.Name.surveyFinishedRefreshFeed, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(self.onUpdatedFeedOnServer(_:)),
                                           name: NSNotification.Name.onboardingFinished, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(self.moveToStartJobPage(_:)),
                                           name: NSNotification.Name.deeplinkFeedOffer, object: nil)
}

// stats notifications
func addWalletListner() {
   NotificationCenter.default.addObserver(self, selector: #selector(self.onBalanceChanged),
                                          name: NSNotification.Name.balanceChanged, object: nil)
}

// app active/inactive notifications to manage timers
func addOnboardingAndApplicationListner() {
    NotificationCenter.default.addObserver(self, selector: #selector(self.onApplicationEnterForeground),
                                           name: UIApplication.willEnterForegroundNotification, object: nil)
}
  
func addListeners() {
  addFeedAndOfferListners()
  addWalletListner()
  addOnboardingAndApplicationListner()
  NotificationCenter.default.addObserver(self, selector: #selector(self.reloadPage),
                                         name: NSNotification.Name.refreshController, object: nil)
  NotificationCenter.default.addObserver(self, selector: #selector(self.reloadPage),
                                           name: NSNotification.Name.partnerAlreadyConnected, object: nil)
  NetworkManager.shared.reloadCurrentUser { _ in }
}

@objc func reloadPage() {
   pauseFeedRefresh = false
   callFeedApi() {}
}
    
func checkPreviousAPICallTimeLapsed() -> Bool {
   let curentDate = Date()
   if let prevoiusCallDate = Defaults[.previousFeedFetchDate] {
        let diffComponents = Calendar.current.dateComponents([.second],
                                                             from: prevoiusCallDate,
                                                             to: curentDate)
        if let seconds = diffComponents.second {
         if seconds < 2 {
           return true
        }
      }
   }
  return false
}
    
@objc func fetchFeed(refresh: Bool = false, _ completion: (() -> Void)? = nil) {
   if !self.apiCallIsInProgress {
    if checkPreviousAPICallTimeLapsed() {
        self.refreshControl.endRefreshing()
        self.apiCallIsInProgress = false
        return
     }
     if ConnectivityUtils.isConnectedToNetwork() == false {
        self.hideSpinner()
        Helper.showNoNetworkAlert(controller: self)
        self.refreshControl.endRefreshing()
        self.apiCallIsInProgress = false
       return
     }
     self.apiCallIsInProgress = true
     checkIfMeasureAppAvailable { [weak self] (isAvailable) in
        guard let this = self else { return }
        this.apiCallIsInProgress = false
        if isAvailable {
            this.callFeedApi(refresh: refresh) {
                completion?()
            }
        } else {
            this.apiCallIsInProgress = false
        }
      }
   } else {
     self.hideSpinner()
     self.refreshControl.endRefreshing()
     self.apiCallIsInProgress = false
  }
}

func callFeedApi(refresh: Bool = false, _ completion: (() -> Void)? = nil) {
    guard UserManager.shared.isLoggedIn, let _ = Defaults[.loggedInUserAccessToken] else {
       return
     }
     if pauseFeedRefresh {
       self.refreshControl.endRefreshing()
       self.apiCallIsInProgress = false
        self.pauseFeedRefresh = false
       return
     }
     if !refresh {
       showSpinner()
     }
    callAPIByQueue {
        completion?()
    }
}
    
func callAPIByQueue(_ completion: (() -> Void)? = nil) {
    os_log("Fetching feed", log: OSLog.feed, type: .info)
    let serialQueue = DispatchQueue(label: "feed.serial.queue")
    serialQueue.async {
        self.fetchOfferItems {
        //    self.fetchContentItems {
                self.fetchUserStats {
                    DispatchQueue.main.async {
                        [weak self] in
                        guard let this = self else {
                            return
                        }
                        if UserManager.shared.user?.isAcceptingOffers == false && !this.onboardingFinished {
                        } else {
                            ProfileMaintenanceManager.shared.patchProfileIfNeeded()
                        }
                        this.updateUIOnCompletion()
                        completion?()
                    }
                }
           // }
        }
    }
}
    
func updateUIOnCompletion() {
  self.hideSpinner()
  if !Defaults[.notifAppeared]
        || ((adapter.collectionView?.contentOffset.y)! <= CGFloat(0) && Defaults[.notifAppeared]) {
    self.adapter.performUpdates(animated: false)
    self.updateOtherUI()
  }
 self.apiCallIsInProgress = false
 if !Defaults[.closeReferFriendView] && !self.referView.isDescendant(of: self.view) {
    if let tabBar = currentTabBar {
      let bottomY = view.frame.size.height - tabBar.tabBarHeight - 28
      referView.frame = CGRect(x: 0, y: bottomY + 78, width: view.frame.size.width, height: 78)
    }
    addReferView()
 }
}
    
func updateOtherUI() {
  self.refreshControl.endRefreshing()
  self.updateOfferOnCompletion()
  Defaults[.previousFeedFetchDate] = Date()
  Defaults[.feedDidLoadRunBefore] = false
}

func updateOfferOnCompletion() {
    if !self.gotFetchError {
     let goToTarget = self.offerNotificationInfo?["goToTarget"] as? Bool ?? false
      if goToTarget {
        if let offerID = self.offerNotificationInfo?["offerID"] as? String {
          DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5, execute: {
            self.showOffer(offerID)
            self.offerNotificationInfo = nil
          })
        }
      }
    }
    NotificationCenter.default.post(name: NSNotification.Name.feedChanged, object: nil, userInfo: nil)
}
    
func fetchOfferItems(completion: (() -> Void)? = nil) {
  NetworkManager.shared.getOfferItems {
   [weak self] (offerItems, error) in
   guard let this = self else {
     return
   }
  
   if let error = error {
     os_log("Error getting offer items: %{public}@", log: OSLog.feed, type: .error, error.localizedDescription)
     this.fetchOfferItemsError = error
     completion?()
   } else {
    if let arr = offerItems?.feedItem {
        this.offerItems =  arr.filter({$0.item.sampleRequestType != SampleRequestType.dataJob})
    }
    // this.offerItems = offerItems?.feedItem ?? []
     this.storyItems = offerItems?.stories ?? []
    
    this.openStoryByDefault()
    this.fetchOfferItemsError = nil
     completion?()
   }
 }
}
    func openStoryByDefault() {
        guard let storyIndex = self.storyItems.firstIndex(where: {$0.item.openedByDefault == true && $0.item.opened == false}) else {return}
        self.selectedStoryIndex = storyIndex
        self.selectedStoryItem = self.storyItems[storyIndex]
        for (index, itemInfo) in self.storyItems.enumerated() {
            if index == storyIndex {itemInfo.item?.isSelected = true} else {itemInfo.item?.isSelected = false}
            if index == self.selectedStoryIndex {itemInfo.item?.storySeened = true}
        }
        markStoryAsOpened(self.storyItems[storyIndex].item)

    }
func fetchContentItems(completion: (() -> Void)? = nil) {
  NetworkManager.shared.getContentItems {
   [weak self] (contentItems, error) in
   guard let this = self else {
     return
   }
   
   if let error = error {
     os_log("Error getting content items: %{public}@", log: OSLog.feed, type: .error, error.localizedDescription)
     this.fetchContentItemsError = error
    completion?()

   } else {
     this.contentItems = contentItems
     this.fetchContentItemsError = nil
    completion?()
   }
  }
}

func fetchUserStats(completion: (() -> Void)? = nil) {
 NetworkManager.shared.getUserStats {
  [weak self] (stats, error) in
  guard let this = self else {
    return
  }
  
  if let error = error {
    os_log("Error getting user stats: %{public}@", log: OSLog.feed, type: .error, error.localizedDescription)
    this.fetchUserStatsError = error
    completion?()
  } else {
    this.emptyOffersItem.stats = stats
    this.fetchUserStatsError = nil
    completion?()
  }
  }
}

@objc func onExistRefreshFeed(_ notification: Notification) {
  guard let offerID = notification.userInfo?["offerID"] as? Int else {
   return
 }

    offerItems.removeAll(where: {$0.item.offerID == offerID})

 DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
  [weak self] in
  guard let this = self else {
    return
  }
  this.adapter.performUpdates(animated: true, completion: nil)
  }
}

@objc func onManualFeedRefresh() {
  fetchFeed(refresh: true)
  NotificationCenter.default.post(name: NSNotification.Name.manualFeedRefresh,
                                  object: nil, userInfo: nil)
  NotificationCenter.default.post(name: NSNotification.Name.shouldCheckForPendingQualifications,
                                  object: nil, userInfo: ["source": "app-pull"])
}

@objc func onUpdatedFeedOnServer(_ notification: Notification) {
  if notification.name == NSNotification.Name.onboardingFinished {
     onboardingFinished = true
     pauseFeedRefresh = false
  }
    if notification.name == NSNotification.Name.updatedFeedOnServer {
       pauseFeedRefresh = false
    }
 fetchFeed(refresh: true) { [weak self] in
  guard let this = self else { return }
  if notification.name == NSNotification.Name.updatedFeedOnServer {
    if this.onboardingFinished && !this.customView.isDescendant(of: this.view) {
     if let info = notification.userInfo, let isPresented = info["notificationPresented"] as? Bool {
        if isPresented == true, let offset = this.adapter.collectionView?.contentOffset.y, offset > CGFloat(0) {
            let bottomY = this.view.frame.size.height - this.currentTabBar!.tabBarHeight - 40
            this.customView.frame = CGRect(x: (UIScreen.main.bounds.width - 151) / 2,
                                           y: bottomY, width: 151, height: 43)
            this.customView.aa_animate(animation: .fromBottom)
            this.customView.snackBarDelegate = self
            this.view.addSubview(this.customView)
             }
          }
        }
     }
  }
}
    
@objc func moveToStartJobPage(_ notification: Notification) {
  if let info = notification.userInfo, let nofiId = info["offerID"] as? String,
    let nofiOfferId = Int(nofiId) {
    NetworkManager.shared.getNotifOfferItem(offerId: nofiOfferId) { [weak self] (offer, _) in
        guard let this = self else { return }
        if let item = offer {
            this.didSelectOfferItem(item)
        }
     }
  }
}

@objc func onFeedChanged(_ notification: Notification) {
 if gotFetchError {
   adapter.performUpdates(animated: false, completion: nil)
 } else {
   let useSmallDelay = notification.userInfo?["useSmallDelay"] as? Bool ?? false
   var delay = 0.0
   if useSmallDelay {
    delay = 0.5
   }
    offerItems = offerItems.filter { !UserManager.shared.recentlyClosedOffers.keys.contains($0.item.offerID) }
  DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
    [weak self] in
    guard let this = self else {
      return
    }
    this.adapter.performUpdates(animated: false, completion: nil)
  }
 }
}

@objc func onFeedLikelyToChangeSoon() {
  DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) { self.fetchFeed(refresh: true) }
}
    
func checkIfMeasureAppAvailable(completion: @escaping (Bool) -> Void) {
   Helper.checkAppAvailabilityStatus(self) { [weak self] (isSuccess, measureAppStatus) in
       if isSuccess == false { return }
        guard let this = self else { return }
        if measureAppStatus == .available {
           if this.isMaintenanceScreenDisplayed == true {
                this.isMaintenanceScreenDisplayed = false
            }
           completion(true)
        } else if measureAppStatus == .unavailable && this.isMaintenanceScreenDisplayed == false {
           Helper.clickToOpenUrl(Constants.statusDownBaseURL,
                     controller: this,
                     presentationStyle: .fullScreen)
          this.isMaintenanceScreenDisplayed = true
          completion(false)
       }
    }
}

@objc func onApplicationEnterForeground() {
  if currentTabBar?.selectedIndex != 0 {
    return
  }
  debugPrint("Enter foreground")
  checkIfMeasureAppAvailable { [weak self] (isAvailable) in
   guard let this = self else { return }
   if isAvailable {
     this.callFeedApi(refresh: true)
    }
  }
  showReferViewAfterCross()
}

@objc func onBalanceChanged() {
  pauseFeedRefresh = false
 fetchFeed(refresh: true)
}

func showOffer(_ offerID: String) {
  guard let offerItem = offerItems.first(where: { (item) -> Bool in
    return String(item.item.offerID) == offerID
 })
 else {
   return
 }
    didSelectOfferItem(offerItem.item)
 }
}

// MARK: ListAdapterDataSource
extension FeedViewController: ListAdapterDataSource {
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        var objects: [ListDiffable] = []
        
        guard let user = UserManager.shared.user else {
            return objects
        }
        
        // main header
        objects.append(topFeedHeaderItem)
        
        if gotFetchError {
            objects.append(genericFetchErrorMessageHolder)
        } else if user.isFraudSuspect {
            objects.append(fraudErrorMessageHolder)
            FirebaseAnalyticsManager.shared.logFirebaseAnalytics(.fraudScreen)
        } else {
            if !user.isAcceptingOffers || !onboardingFinished {
                // for onboarding
                objects.append(onboardingItem)
                AnalyticsManager.shared.logOnce(event: .welcomeCardDisplayed)
                FirebaseAnalyticsManager.shared.logFirebaseAnalytics(.welcomeScreen)
            } else {
                // Stories handling
                objects.removeAll{$0 is StoryListItem}
                objects.removeAll{$0 is SeperatorItem}
                if !storyItems.isEmpty {
                    let storiesItem = StoryListItem(stories: storyItems)
                    objects.append(storiesItem)
                }
                if selectedStoryItem != nil {
                    if selectedStoryItem?.itemType == "content-action-only" {
                        objects.removeAll{$0 is StoryWithContentItem}
                    } else {
                        let obj = StoryWithContentItem(item: selectedStoryItem!)
                        objects.append(obj)
                         objects.append(seperatorItem)
                    }
                    
                } else {
                    objects.removeAll{$0 is StoryWithContentItem}
                }
                // add offer items
                if offerItems.isEmpty {
                    objects.append(emptyOffersItem)
                    
                    if user.inviteCode != nil && user.remainingInvitations > 0 {
                        /* let referFriendViewController = ReferFriendViewController()
                         objects.append(referFriendViewController)*/
                    }
                } else {
                    for item in offerItems {
                        objects.append(item)
                    }
                }
                
                // only add content header and items if there are any there
                if !contentItems.isEmpty {
                    objects.append(newsHeaderItem)
                    for item in contentItems {
                        objects.append(item)
                    }
                }
            }
        }
        
        return objects
    }
    
    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        switch object {
        case is TopHeaderItem:
            let controller = TopHeaderSectionController()
            controller.delegate = self
            return controller
        case is GenericHeaderItem:
            let controller = GenericHeaderSectionController()
            return controller
        case is StoryWithContentItem:
            let controller = StoryOfferItemSectionController()
            controller.delegate = self
            return controller
        case is StoryListItem:
            let controller = RoundedStoriesSectionController()
            controller.selectedIndex = self.selectedStoryIndex
            controller.selectedStory = self.selectedStoryItem
            if self.offerItems.count > 0 {
                controller.hideTopBorder = false
            } else {
                controller.hideTopBorder = true
            }
            controller.delegate = self
            return controller
        case is SeperatorItem:
            let controller = SeperatorViewItemSectionController()
            if self.offerItems.count > 0 {
                controller.hideTopBorder = false
            } else {
                controller.hideTopBorder = true
            }
            return controller
        case is FeedItem:
            let controller = OfferItemSectionController()
            controller.delegate = self
            return controller
        case is EmptyOffersItem:
            let controller = EmptyOffersSectionController()
            
            controller.resizingDelegate = self
            return controller
        /* case is ReferFriendViewController:
         let controller = ReferFriendSectionController()
         return controller*/
        case is ContentItem:
            let controller = ContentItemSectionController()
            controller.delegate = self
            return controller
        case is MessageHolder:
            let controller = ErrorMessageSectionController()
            controller.delegate = self
            return controller
        case is OnboardingItem:
            let controller = OnboardingItemSectionController()
            controller.onboardingItemDelegate = self
            controller.resizingDelegate = self
            return controller
        default:
            fatalError()
        }
    }
    
    func emptyView(for listAdapter: ListAdapter) -> UIView? {
        return nil
    }
}

// MARK: TopHeaderSectionControllerDelegate

extension FeedViewController: TopHeaderSectionControllerDelegate {
 func didTapSettingsButton() {
 // pause feed refreshing until control is returned from Settings
 
 pauseFeedRefresh = true
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

// MARK: ContainerSectionControllerDelegate

extension FeedViewController: ListSectionNeedsResizingDelegate {
func needsResizing() {
  collectionView.collectionViewLayout.invalidateLayout()
  }
}

// MARK: OnboardingSectionControllerDelegate

extension FeedViewController: OnboardingItemSectionControllerDelegate {
func didTapStartPhoneNumberSurveyButton() {
  pauseFeedRefresh = true

  // bzzzz
  generator.impactOccurred()

  Router.shared.route(
        to: .phoneNumberValidation,
        from: self,
        presentationType: .modal(presentationStyle: .pageSheet, transitionStyle: .coverVertical)
    )
}

func didTapStartBasicProfileSurveyButton() {
// pause feed refreshing until control is returned from the job modal
 pauseFeedRefresh = true

    // bzzzz
generator.impactOccurred()

let surveyManager = SurveyManager(surveyType: .welcome)
    Router.shared.route(
      to: Route.surveyStart(surveyManager: surveyManager, screenType: .myFeed),
      from: self,
      presentationType: .modal(presentationStyle: .pageSheet, transitionStyle: .coverVertical)
    )
}

func didTapStartLocationValidationButton() {
 NetworkManager.shared.validateLocation() {
  error in
  
   if let _ = error {
    os_log("validateLocation failed", log: OSLog.feed, type: .error)
   }
  }
}

func didTapContactSupportButton() {
    Router.shared.route(to: .support(), from: self,
                      presentationType: .modal(presentationStyle: .pageSheet,
                                               transitionStyle: .coverVertical))
    }
}

// MARK: OffersSectionControllerDelegate

extension FeedViewController: OfferItemSectionControllerDelegate {
 func didSelectOfferItem(_ offerItem: OfferItem) {

  // mark the item as opened if not already
  if !offerItem.opened {
   offerItem.opened = true
  
  markItemBackgroundTaskRunner = BackgroundTaskRunner(application: UIApplication.shared)
  markItemBackgroundTaskRunner.startTask {
    NetworkManager.shared.markOfferItemsAsOpened(items: [offerItem]) {
      [weak self] error in
      
      if let _ = error {
        os_log("markOfferItemsAsOpened failed", log: OSLog.feed, type: .error)
      }
      
      self?.markItemBackgroundTaskRunner.endTask()
    }
  }
}

if [.offered, .started].contains(offerItem.responseStatus) {
  // bzzzz
  generator.impactOccurred()

  // pause feed refreshing until control is returned from the job modal
  pauseFeedRefresh = true
  
  switch offerItem.offerType {
  case .external:
    let surveyManager = SurveyManager(surveyType: SurveyType.externalOffer(offerItem: offerItem))

    Router.shared.route(
        to: Route.surveyStart(surveyManager: surveyManager, screenType: .myFeed),
        from: self,
      presentationType: .modal(presentationStyle: .pageSheet, transitionStyle: .coverVertical)
    )
  case .internal:
    if offerItem.sampleRequestType == SampleRequestType.connectedSetUpDynata {
        callApiToGetDynataItems(.dynata) { (dynata, _) in
            if let data = dynata {
                Router.shared.route(
                    to: Route.connect(appType: .dynata, connectAppData: data, offerItem: offerItem),
                          from: self,
                          presentationType: .modal(presentationStyle: .pageSheet,
                                                   transitionStyle: .coverVertical))
            }
        }
        return
    }
    if offerItem.sampleRequestType == SampleRequestType.connectedSetUpPollfish {
        callApiToGetDynataItems(.pollfish) { (dynata, _) in
            if let data = dynata {
                Router.shared.route(
                    to: Route.connect(appType: .pollfish, connectAppData: data, offerItem: offerItem),
                          from: self,
                          presentationType: .modal(presentationStyle: .pageSheet,
                                                   transitionStyle: .coverVertical))
            }
        }
        return
    }
    if offerItem.sampleRequestType == SampleRequestType.kantarSetUp {
        callApiToGetDynataItems(.kantar) { (dynata, _) in
            if let data = dynata {
                Router.shared.route(
                    to: Route.connect(appType: .kantar, connectAppData: data, offerItem: offerItem),
                          from: self,
                          presentationType: .modal(presentationStyle: .pageSheet,
                                                   transitionStyle: .coverVertical))
            }
        }
        return
    }
    if offerItem.sampleRequestType == SampleRequestType.precisionSetUp {
        callApiToGetDynataItems(.precision) { (precision, _) in
            if let data = precision {
                Router.shared.route(
                    to: Route.connect(appType: .precision, connectAppData: data, offerItem: offerItem),
                          from: self,
                          presentationType: .modal(presentationStyle: .pageSheet,
                                                   transitionStyle: .coverVertical))
            }
        }
        return
    }
    guard let surveyType = InternalOfferURLParser.parse(offerItem: offerItem) else {
      os_log("Could not create survey type object from URL.", log: OSLog.feed, type: .error)
      let toaster = Toaster(view: self.view)
      toaster.toast(message: FeedViewText.urlError, title: FeedViewText.urlTitleError)
      return
    }

    let surveyManager = SurveyManager(surveyType: surveyType)

    Router.shared.route(
      to: Route.surveyStart(surveyManager: surveyManager, screenType: .myFeed),
      from: self,
      presentationType: .modal(presentationStyle: .pageSheet, transitionStyle: .coverVertical)
    )
  }
 }
}

func callApiToGetDynataItems(_ appType: ConnectedApp, completion: ((ConnectedAppData?, Error?) -> Void)? = nil) {
    if ConnectivityUtils.isConnectedToNetwork() == false {
        Helper.showNoNetworkAlert(controller: self)
        return
    }
    NetworkManager.shared.getDynataProfileItems(appType: appType) {(connectedData, error) in
        if error == nil {
            completion?(connectedData, nil)
        } else {
            completion?(nil, error)
        }
    }
  }
}

// MARK: ContentSectionControllerDelegate

extension FeedViewController: ContentItemSectionControllerDelegate {
func didSelectContentItem(_ item: ContentItem) {
  if item.contentType == ContentItem.ContentType.externalLink, let url = item.url {
  // bzzzz
  generator.impactOccurred()
  
  // pause feed refreshing until control is returned from the content modal
  pauseFeedRefresh = true

  // mark as opened if not already
  if !item.opened {
    item.opened = true
    
    markItemBackgroundTaskRunner = BackgroundTaskRunner(application: UIApplication.shared)
    markItemBackgroundTaskRunner.startTask {
      NetworkManager.shared.markContentItemsAsOpened(items: [item]) {
        [weak self] error in
        
        if let _ = error {
          os_log("markContentItemsAsOpened failed", log: OSLog.feed, type: .error)
        }
        
        self?.markItemBackgroundTaskRunner.endTask()
      }
    }
  }
  
  // open in safari
  let sfvc = SFSafariViewController(url: url)
  present(sfvc, animated: true, completion: nil)
 }
 }
}
// MARK: StorySectionControllerDelegate

extension FeedViewController: RoundedStoriesSectionControllerDelegate {
    func markStoryAsSeen(_ item: StoryItem) {
        // mark as seen if not already
        if !item.seen {
            item.seen = true
            
            markItemBackgroundTaskRunner = BackgroundTaskRunner(application: UIApplication.shared)
            markItemBackgroundTaskRunner.startTask {
                NetworkManager.shared.markStoryItemsAsSeen(items: [item]) {
                    [weak self] error in
                    
                    if let _ = error {
                        os_log("markStoryItemsAsSeen failed", log: OSLog.feed, type: .error)
                    }
                    
                    self?.markItemBackgroundTaskRunner.endTask()
                }
            }
        }
    }
    func markStoryAsOpened(_ item: StoryItem) {
        // mark as opened if not already
        if !item.opened {
            item.opened = true
            
            markItemBackgroundTaskRunner = BackgroundTaskRunner(application: UIApplication.shared)
            markItemBackgroundTaskRunner.startTask {
                NetworkManager.shared.markStoryItemsAsOpened(items: [item]) {
                    [weak self] error in
                    
                    if let _ = error {
                        os_log("markStoryItemsAsOpened failed", log: OSLog.feed, type: .error)
                    }
                    
                    self?.markItemBackgroundTaskRunner.endTask()
                }
            }
        }
    }
    func markStoryOfferItemAsSeen(_ item: Story, indexPath: Int) {
        markStoryAsSeen(item.item)
    }
    func didSelectStoryOfferItem(_ item: Story, indexPath: Int) {
        markStoryAsOpened(item.item)
        if self.selectedStoryIndex == indexPath  {
            debugPrint("Same item selected again")
            closeOffer()
            return
        }
        self.selectedStoryIndex = indexPath
        self.selectedStoryItem = item
        for (index, itemInfo) in self.storyItems.enumerated() {
            if index == indexPath {itemInfo.item?.isSelected = true} else {itemInfo.item?.isSelected = false}
            if index == self.selectedStoryIndex {itemInfo.item?.storySeened = true}
        }
        
        DispatchQueue.main.async {
            [weak self] in
            guard let this = self else {
                return
            }
            this.adapter.performUpdates(animated: false)
        }
        if item.itemType == "content-action-only" {
            if let link = item.item?.links?.first {
                self.didSelectStoryItemLink(link)
                closeOffer()
            }
        }
    }
}
// MARK: StorySectionControllerDelegate + Links
extension FeedViewController: StoryOfferItemSectionControllerDelegate {
    internal func navigateToExternalBrowser(url: URL?) {
        guard let webUrl = url else {return}
        let sfvc = SFSafariViewController(url: webUrl)
        present(sfvc, animated: true, completion: nil)
       }
    fileprivate func closeOffer() {
        _ = self.storyItems.map({($0.item?.isSelected = false)})
        for (index, itemInfo) in self.storyItems.enumerated() {
            if index == self.selectedStoryIndex {itemInfo.item?.storySeened = true}
        }
        self.selectedStoryIndex = -1
        self.selectedStoryItem = nil
        DispatchQueue.main.async {
            [weak self] in
            guard let this = self else {
                return
            }
            this.adapter.performUpdates(animated: false)
        }
    }
    func didSelectCloseOffer() {
        closeOffer()
    }
    
    func didSelectStoryItemLink(_ link: Link) {
        debugPrint("Feed VC selcted Link is", link)
        if link.action == "external-link" {
            if let url = link.linkURL {
                self.handleWebLinksOnSafari(URL(string: url) ?? nil)
            }
        } else if link.action == "internal-link" {
            if let url = link.linkURL {
               let finalUrl = URL(string:"\(Constants.baseContributorURLString)/" + url)
                self.handleWebLinks(finalUrl)
            }
        } else if link.action == "app-link" {
            if let url = link.linkURL {
                guard let finalUrl =  URL(string:"\(url)/") else {return}
                if finalUrl.scheme?.caseInsensitiveCompare("app") == .orderedSame {
                    if let _ = finalUrl.host?.caseInsensitiveCompare("offers") {
                        guard let offerId = Int(finalUrl.lastPathComponent) else { return }
                        NetworkManager.shared.getNotifOfferItem(offerId: offerId) { [weak self] (offer, _) in
                            guard let this = self else { return }
                            if let item = offer {
                                this.didSelectOfferItem(item)
                            }
                        }
                        debugPrint("Found result")
                        
                    }
                }
            }
        }

    }
   
    //Open Link on Safari
    func handleWebLinksOnSafari(_ url: URL?) {
        // open in safari
        guard let url = url else {
            return
        }
        let sfvc = SFSafariViewController(url: url)
        present(sfvc, animated: true, completion: nil)
        
    }
    // Open Web View
    func handleWebLinks(_ url: URL?) {
        guard let url = url else {
            return
        }
        let webContentViewController = WebContentViewController()
        webContentViewController.shouldHideBackButton = false
        webContentViewController.isFromFeedScreen = true
        webContentViewController.startURL = url
        let nav = UINavigationController(rootViewController: webContentViewController)
        nav.navigationBar.tintColor = .black
        nav.navigationItem.hidesBackButton = false
        show(nav, sender: self)
    }
}
extension FeedViewController: UIScrollViewDelegate {
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    if scrollView.contentOffset.y <= 0 && Defaults[.notifAppeared] {
        self.customView.removeFromSuperview()
    }
    if scrollView.contentOffset.y > 0 {
        removeReferViewWithAnimation()
    } else {
        if scrollView.contentOffset.y == 0 && !Defaults[.closeReferFriendView] {
            addReferView()
        }
    }
  }
    
  func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    if scrollView.contentOffset.y <= 0 && Defaults[.notifAppeared] {
        updateAdapterNotif()
    }
    if scrollView.contentOffset.y == 0 && !Defaults[.closeReferFriendView] {
        addReferView()
    }
  }
}

// MARK: UICollectionViewDelegate

extension FeedViewController: UICollectionViewDelegate {
func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
    
guard let user = UserManager.shared.user else {
  return
}

if !gotFetchError && user.isAcceptingOffers && onboardingFinished {
  switch indexPath.section {
  case 1:
    if indexPath.row >= offerItems.count {
      return
    }
    
    let offerItem = offerItems[indexPath.row]
    
    // mark as seen if not already
    if !offerItem.item.seen {
        offerItem.item.seen = true
      
      markItemBackgroundTaskRunner = BackgroundTaskRunner(application: UIApplication.shared)
      markItemBackgroundTaskRunner.startTask {
        NetworkManager.shared.markOfferItemsAsSeen(items: [offerItem.item]) {
          [weak self] error in
          
          if let _ = error {
            os_log("markOfferItemsAsSeen failed", log: OSLog.feed, type: .error)
          }
          
          self?.markItemBackgroundTaskRunner.endTask()
        }
      }
    }
  case 3:
    if indexPath.row >= contentItems.count {
      return
    }
    
    let contentItem = contentItems[indexPath.row]
    
    // mark as seen if not already
    if !contentItem.seen {
      contentItem.seen = true
      
      markItemBackgroundTaskRunner = BackgroundTaskRunner(application: UIApplication.shared)
      markItemBackgroundTaskRunner.startTask {
        NetworkManager.shared.markContentItemsAsSeen(items: [contentItem]) {
          [weak self] error in
          
          if let _ = error {
            os_log("markContentItemsAsSeen failed", log: OSLog.feed, type: .error)
          }
          
          self?.markItemBackgroundTaskRunner.endTask()
        }
      }
    }
  default:
    break
  }
 }
 }
}

// MARK: ErrorMessageSectionControllerDelegate

extension FeedViewController: ErrorMessageSectionControllerDelegate {
  func didTapActionButton() {
    NetworkManager.shared.reloadCurrentUser { _ in }
    self.apiCallIsInProgress = false
    Defaults[.notifAppeared] = false
    Defaults[.feedDidLoadRunBefore] = false
    fetchFeed()
  }
}

// MARK: Tabbables

extension FeedViewController: Tabbable {
  var tabName: String {
    return TabName.feed.localized()
  }
  
  var tabImage: Image {
    return Image.feedIcon
  }
  
  var tabHighlightedImage: Image {
    return Image.feedIcon
  }
}

extension FeedViewController: CustomSnackViewDelegate {
 func didTapSnackbar() {
  self.customView.removeFromSuperview()
  updateAdapterNotif()
}
    
func updateAdapterNotif() {
  Defaults[.notifAppeared] = false
  self.updateOtherUI()
  self.adapter.collectionView?.scrollToItem(at: IndexPath(item: 0, section: 0), at: .top, animated: true)
 }
}

extension FeedViewController: WebContentDelegate {
func didFinishNavigation(navigationAction: WKNavigationAction) {
    if let clickedUrl = navigationAction.request.url?.absoluteString,
        clickedUrl == Constants.maintananceRefreshButtonUrl {
        Helper.checkAppAvailabilityStatus(self) { [weak self] (isSuccess, measureAppStatus) in
            if isSuccess == false { return }
            guard let this = self else { return }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                NotificationCenter.default.post(name: NSNotification.Name.refreshWebview, object: nil, userInfo: nil)
            }
            if measureAppStatus == .available {
               if this.isMaintenanceScreenDisplayed == true {
                  this.isMaintenanceScreenDisplayed = false
               }
               this.dismissSelf()
               NetworkManager.shared.reloadCurrentUser { _ in }
               this.fetchFeed()
            }
         }
      }
   }
}
