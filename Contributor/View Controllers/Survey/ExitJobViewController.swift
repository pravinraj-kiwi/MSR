//
//  ExitJobViewController.swift
//  Contributor
//
//  Created by KiwiTech on 11/23/20.
//  Copyright © 2020 Measure. All rights reserved.
//

import UIKit
import SwiftyUserDefaults

class ExitJobViewController: UIViewController {
    
@IBOutlet weak var collection: UICollectionView!
private var jobResponseArray = [JobReasonModel]()
var types: OfferTypes?
var exitJobDatasource = ExitJobDatasource()
var themeColor: UIColor = Constants.primaryColor
var requestModel: ExitRequestModel?
    
override func viewDidLoad() {
  super.viewDidLoad()
  // Do any additional setup after loading the view.
  setupNavbar()
  applyCommunityTheme()
  initialSetUp()
}
    
override func viewDidAppear(_ animated: Bool) {
  super.viewDidAppear(animated)
  FirebaseAnalyticsManager.shared.logFirebaseAnalytics(.exitJobScreen)
}

func setupNavbar() {
 isModalInPresentation = true
 if let _ = self.presentingViewController {
    self.navigationController?.navigationBar.barTintColor = Utilities.getRgbColor(247, 247, 247)
    navigationItem.leftBarButtonItem = backBarButtonItem(backArrowImage: Image.crossWhite.value)
    navigationItem.leftBarButtonItem?.tintColor = .black
    navigationItem.leftBarButtonItem?.imageInsets = UIEdgeInsets(top: 0, left: 22, bottom: 0, right: 0)
  }
}
    
override func goBack() {
  dismissSelf()
}
    
func getExitJobReasonJson(filename fileName: String) -> ExitJobReasonModel? {
  let extensionName = Constants.jsonFileExtension
  if let url = Bundle.main.url(forResource: fileName, withExtension: extensionName) {
    do {
      let data = try Data(contentsOf: url)
      let decoder = JSONDecoder()
      let reasonModel = try decoder.decode(ExitJobReasonModel.self, from: data)
      return reasonModel
     } catch {
        debugPrint("error:\(error)")
     }
   }
  return nil
}
    
func initialSetUp() {
 collection.delegate = exitJobDatasource
 collection.dataSource = exitJobDatasource
 exitJobDatasource.delegate = self
 let jobReasonFile = Constants.exitJobReason
  if let reasonData = getExitJobReasonJson(filename: jobReasonFile) {
    jobResponseArray.append(contentsOf: reasonData.reasons)
    exitJobDatasource.jobResponseData = jobResponseArray
    collection.reloadData()
  }
 }
}

extension ExitJobViewController: ExitDatasourceDelegate {
 func clickOtherReason() {
    collection.reloadSections(IndexSet(integer: 1))
    if let footerCell = collection.cellForItem(at: IndexPath(item: 0, section: 2)) as? FooterViewCell {
      if footerCell.OtherReasonTextView.text.isEmpty == false {
        footerCell.exitButton.alpha = 1.0
        footerCell.exitButton.isUserInteractionEnabled = true
        requestModel = ExitRequestModel(type: "other",
                                        reason: footerCell.OtherReasonTextView.text,
                                        videoSize: Defaults[.retroVideoFileSize] ?? "",
                                        approxUploadSpeed: Defaults[.retroVideoApproxUploadSpeed] ?? "")
      }
    }
 }
    
 func clickToExit() {
   if ConnectivityUtils.isConnectedToNetwork() == false {
    if let footerCell = collection.cellForItem(at: IndexPath(item: 0, section: 2)) as? FooterViewCell {
        footerCell.OtherReasonTextView.resignFirstResponder()
    }
     Helper.showNoNetworkAlert(controller: self)
     return
   }
   dismissSelf()
   if types == .externalOffer {
    NotificationCenter.default.post(name: NSNotification.Name.exitExternalSurvey, object: requestModel)
   } else {
    NotificationCenter.default.post(name: NSNotification.Name.exitJobFeed, object: requestModel)
   }
   let userTerminated = JobCompletionStaus.userTerminated
   FirebaseAnalyticsManager.shared.logFirebaseAnalytics(.jobStatusScreen(status: userTerminated))
 }
    
 func clickToSelectReason(_ model: JobReasonModel) {
    requestModel = ExitRequestModel(type: model.reasonType,
                                    reason: "",
                                    videoSize: Defaults[.retroVideoFileSize] ?? "",
                                    approxUploadSpeed: Defaults[.retroVideoApproxUploadSpeed] ?? "")
    if let footerCell = collection.cellForItem(at: IndexPath(item: 0, section: 2)) as? FooterViewCell {
        footerCell.exitButton.alpha = 1.0
        footerCell.exitButton.isUserInteractionEnabled = true
    }
  }
}

extension ExitJobViewController: CommunityThemeConfigurable {
  @objc func applyCommunityTheme() {
   guard let community = UserManager.shared.user?.selectedCommunity,
         let colors = community.colors else {
      return
    }
    themeColor = colors.primary
  }
}
