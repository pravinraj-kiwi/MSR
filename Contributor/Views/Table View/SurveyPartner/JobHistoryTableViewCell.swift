//
//  JobHistoryTableViewCell.swift
//  Contributor
//
//  Created by KiwiTech on 5/7/20.
//  Copyright © 2020 Measure. All rights reserved.
//

import UIKit

protocol JobHistoryCellDelegate: class {
    func getTheJobHistoryDetail(_ appType: ConnectedApp, _ transaction: WalletTransaction)
}

class JobHistoryTableViewCell: UITableViewCell {

@IBOutlet weak var earningTableView: UITableView!
@IBOutlet weak var title: EdgeInsetLabel!
@IBOutlet weak var subTitle: UILabel!
@IBOutlet weak var totalEarned: EdgeInsetLabel!
@IBOutlet weak var totalEarnedAmount: EdgeInsetLabel!
@IBOutlet weak var totalEarnedView: UIView!
@IBOutlet weak var earningTableViewHeightConstraint: NSLayoutConstraint!
@IBOutlet weak var earningViewHeight: NSLayoutConstraint!
    
weak var jobHistoryDelegate: JobHistoryCellDelegate?
var jobEarnings: DynataJobDetail?
var appType: ConnectedApp?

override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
}

override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    // Configure the view for the selected state
}

func updateDynataEarnings(_ connectApp: ConnectedAppData?) {
  earningViewHeight.constant = 0
    title.text = DynataDetail.history.localized()
  subTitle.isHidden = true
  getUpdatedJobs()
  earningTableView.dataSource = self
  earningTableView.delegate = self
  earningTableView.reloadData()
}
    
func getUpdatedJobs() {
  if jobEarnings?.jobs?.count == 1 {
   _ = jobEarnings?.jobs?.map({$0.shouldShowTopCorners == true})
   _ = jobEarnings?.jobs?.map({$0.shouldShowBottomCorners == true})
  }
  _ = jobEarnings?.jobs.map({$0.first.map({$0.shouldShowTopCorners = true})})
  _ = jobEarnings?.jobs.map({$0.last.map({$0.shouldShowBottomCorners = true})})
}
    
override func layoutIfNeeded() {
  if super.window != nil {
     super.layoutIfNeeded()
    }
    if let data = jobEarnings?.jobs, !data.isEmpty {
      earningTableViewHeightConstraint.constant = CGFloat(data.count * Constants.jobHistoryCellHeight)
    } else {
      earningTableViewHeightConstraint.constant = CGFloat(1 * Constants.jobHistoryCellHeight)
    }
  }
}

extension JobHistoryTableViewCell: UITableViewDelegate, UITableViewDataSource {
    
func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if let data = jobEarnings?.jobs, !data.isEmpty {
        return data.count
    }
    return 1
}

func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
  let cell = tableView.dequeueReusableCell(with: DynataJobCell.self, for: indexPath)
  if let data = jobEarnings?.jobs, !data.isEmpty {
    let earning = data[indexPath.row]
    cell.jobTransaction = earning
    cell.updateUIForJobs(earning)
  } else {
    cell.imgArrow?.isHidden = true
    cell.transactionTitle.text = DynataDetail.noJobCompleted.localized()
  }
  return cell
}

func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return CGFloat(Constants.jobHistoryCellHeight)
}
    
func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if let data = jobEarnings?.jobs, !data.isEmpty {
      let transaction = data[indexPath.row]
        if let app = appType {
            jobHistoryDelegate?.getTheJobHistoryDetail(app, transaction)
        }
     }
  }
}

class DynataJobCell: UITableViewCell {
    
@IBOutlet weak var transactionTitle: UILabel!
@IBOutlet weak var transactionPrice: UILabel!
@IBOutlet weak var transactionDescription: UILabel!
@IBOutlet weak var imgArrow: UIImageView!
@IBOutlet weak var divider: UIView!
@IBOutlet weak var transactionStack: UIView!
    
var jobTransaction: WalletTransaction?

override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
    transactionStack.backgroundColor = getRgbColor(116.0, 116.0, 128.0, 0.08)
}
    
func getRgbColor(_ red: CGFloat, _ green: CGFloat, _ blue: CGFloat, _ alpha: CGFloat = 1.0) -> UIColor {
   return UIColor.init(displayP3Red: red/255.0, green: green/255.0, blue: blue/255.0, alpha: alpha)
}
    
override func draw(_ rect: CGRect) {
  super.draw(rect)
  updateCorners()
}

func updateUIForJobs(_ transaction: WalletTransaction) {
  transactionTitle.text = transaction.title
  if let desc = transaction.transactionDescription {
    transactionDescription.text = desc
  } else {
    transactionDescription.text = ""
  }
  if let amount = transaction.amountMSR {
    transactionPrice.text = "\(amount.stringWithCommas) MSR"
  } else {
    transactionPrice.text = ""
  }
  if transaction.descriptionStyle == TransactionListDisplay.danger.display {
    transactionDescription.textColor = getRgbColor(215.0, 87.0, 102.0)
  } else {
    transactionDescription.textColor = .black
  }
  imgArrow.isHidden = false
  updateCorners()
  applyCommunityTheme()
}
    
func updateCorners() {
  if jobTransaction == nil {
    transactionStack.roundCorners(corners: [.allCorners], radius: 12.0)
    divider.backgroundColor = .clear
    return
  }

  if let topCorner = jobTransaction?.shouldShowTopCorners, topCorner == true {
    transactionStack.roundCorners(corners: [.topLeft, .topRight], radius: 12.0)
    divider.backgroundColor = getRgbColor(228.0, 228.0, 228.0)
  }
  if let bottomCorner = jobTransaction?.shouldShowBottomCorners, bottomCorner == true {
    transactionStack.roundCorners(corners: [.bottomLeft, .bottomRight], radius: 12.0)
    divider.backgroundColor = .clear
  }
  if let topCorner = jobTransaction?.shouldShowTopCorners, topCorner == true,
    let bottomCorner = jobTransaction?.shouldShowBottomCorners, bottomCorner == true {
    transactionStack.roundCorners(corners: [.allCorners], radius: 12.0)
    divider.backgroundColor = .clear
  }
  if let topCorner = jobTransaction?.shouldShowTopCorners, topCorner == false,
    let bottomCorner = jobTransaction?.shouldShowBottomCorners, bottomCorner == false {
    transactionStack.layer.mask = nil
    divider.backgroundColor = getRgbColor(228.0, 228.0, 228.0)
  }
 }
}

extension DynataJobCell: CommunityThemeConfigurable {
  @objc func applyCommunityTheme() {
   guard let community = UserManager.shared.user?.selectedCommunity, let colors = community.colors else {
      return
    }
    switch jobTransaction?.titleStyle {
    case TransactionListDisplay.primary.display:
        transactionTitle.textColor = colors.primary
        transactionPrice.textColor = colors.primary
    default:
        transactionTitle.textColor = .black
        transactionPrice.textColor = getRgbColor(44.0, 44.0, 44.0)
    }
  }
}

class DataSharingCell: UITableViewCell {
    
    @IBOutlet weak var dynataTitle: UILabel!
    @IBOutlet weak var dynataSubTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
        
func updateSharingUI(_ connectApp: ConnectedAppData?) {
    if let selectedAppData = connectApp, let app = selectedAppData.type,
          let type = ConnectedApp(rawValue: app) {
         dynataTitle.text = DynataJobHistoryCell.sharingTitleText.localized()
        switch type {
        case .dynata:
           dynataSubTitle.text = DynataJobHistoryCell.dynataSubTitleText.localized()
        case .pollfish:
           dynataSubTitle.text = DynataJobHistoryCell.pollfishSubTitleText.localized()
        case .kantar:
           dynataSubTitle.text = DynataJobHistoryCell.kantarSubTitleText.localized()
        case .precision:
            dynataSubTitle.text = DynataJobHistoryCell.precisionSubTitleText.localized()
        default:
            break
        }
    }
  }
}
