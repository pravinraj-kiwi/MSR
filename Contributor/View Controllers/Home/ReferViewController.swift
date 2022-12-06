//
//  ReferFriendViewController.swift
//  Contributor
//
//  Created by KiwiTech on 10/26/20.
//  Copyright © 2020 Measure. All rights reserved.
//

import UIKit

class ReferViewController: UIViewController {
    
 @IBOutlet weak var referFriendTableView: UITableView!

 var inviteCode: String? = ""
 var referDatasource = ReferDatasource()

 override func viewDidLoad() {
   super.viewDidLoad()
   // Do any additional setup after loading the view.
   self.view.endEditing(false)
   setupNavbar()
   applyCommunityTheme()
   if #available(iOS 13.0, *) {
      isModalInPresentation = true
   }
   setUpDataSource()
 }
    
 override func viewDidAppear(_ animated: Bool) {
   super.viewDidAppear(animated)
   FirebaseAnalyticsManager.shared.logFirebaseAnalytics(.referFriend)
 }

 func registerNib() {
   referFriendTableView.rowHeight = 741
   referFriendTableView.estimatedRowHeight = 741
 }
    
 func setupNavbar() {
  if let _ = self.presentingViewController {
    navigationItem.leftBarButtonItem = UIBarButtonItem(title: Text.close.localized(),
                                                       style: UIBarButtonItem.Style.plain,
                                                       target: self, action: #selector(close))
    navigationItem.leftBarButtonItem?.setTitleTextAttributes(Font.regular.asTextAttributes(size: 16),
                                                             for: .normal)
    
    navigationItem.leftBarButtonItem?.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white],
                                                             for: .normal)

    let navigationBarAppearance = UINavigationBarAppearance()
    navigationBarAppearance.configureWithOpaqueBackground()
    navigationBarAppearance.backgroundColor = Constants.primaryColor
    navigationBarAppearance.shadowImage = nil
    navigationBarAppearance.shadowColor = .none
    navigationController!.navigationBar.scrollEdgeAppearance = navigationBarAppearance
    navigationController!.navigationBar.compactAppearance = navigationBarAppearance
    navigationController!.navigationBar.standardAppearance = navigationBarAppearance
    if #available(iOS 15.0, *) {
        navigationController!.navigationBar.compactScrollEdgeAppearance = navigationBarAppearance
    }

   }
 }
    
 @objc func close() {
    dismissSelf()
 }
       
 func setUpDataSource() {
   registerNib()
   referDatasource.delegate = self
   referDatasource.inviteCode = inviteCode
   referFriendTableView.dataSource = referDatasource
   referFriendTableView.delegate = referDatasource
   referFriendTableView.reloadData()
  }
}

extension ReferViewController: ReferDatasourceDelegate {
 func clickToShareCode(_ code: String) {
    let shareText = ReferFriendViewText.shareText
        + ReferFriendViewText.sharePreixText
        + " \(code) " + ReferFriendViewText.shareSuffixText
    let activityItems: [Any] = [
        shareText,
      URL(string: "\(Constants.baseContributorURLString)/i/\(code)")!
    ]
    let activityViewController = UIActivityViewController(activityItems: activityItems,
                                                          applicationActivities: nil)
    activityViewController.setValue(ReferFriendViewText.shareSubjectText.localized() , forKey: "subject")
    activityViewController.completionWithItemsHandler = {
      activityType, completed, returnedItems, error  in
      AnalyticsManager.shared.log(event: .friendReferred)
    }
    present(activityViewController, animated: true, completion: nil)
 }
    
 func showCopiedAlert() {
   let alerter = Alerter(viewController: self)
    alerter.alert(title: "", message: ReferFriendViewText.copiedAlert.localized(),
                      confirmButtonTitle: nil, cancelButtonTitle: Text.ok.localized(),
                      onConfirm: nil, onCancel: nil)
 }
    
 func didTapGesture(_ label: UILabel, gesture: UITapGestureRecognizer) {
    if let range = label.text?.range(of: ReferFriendViewText.terms.localized())?.nsRange {
      if gesture.didTapAttributedTextInLabel(label: label,
                                             inRange: range) {
        Helper.clickToOpenUrl(Constants.termsURL, controller: self, shouldPresent: true)
      }
    }
  }
}

extension ReferViewController: CommunityThemeConfigurable {
@objc func applyCommunityTheme() {
    guard let community = UserManager.shared.user?.selectedCommunity, let colors = community.colors else {
       return
     }
    self.navigationController?.navigationBar.barTintColor = colors.primary
  }
}
