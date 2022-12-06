//
//  ExitJobDatasource.swift
//  Contributor
//
//  Created by KiwiTech on 11/23/20.
//  Copyright © 2020 Measure. All rights reserved.
//

import UIKit

protocol ExitDatasourceDelegate: class {
  func clickToSelectReason(_ model: JobReasonModel)
  func clickOtherReason()
  func clickToExit()
}

class ExitJobDatasource: NSObject, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
 var jobResponseData = [JobReasonModel]()
 weak var delegate: ExitDatasourceDelegate?
 var shouldExpand = false
 var selectedIndex: Int?
    
 func numberOfSections(in collectionView: UICollectionView) -> Int {
   return 3
 }
    
 func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    if section == 0 {
      return 1
    }
    if section == 1 {
     return jobResponseData.count
    }
    return 1
 }
  
 func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    if indexPath.section == 0 {
        let cellIdentifier = CellIdentifier.headerCollectionCell.rawValue
        guard let headerCell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier,
                                                              for: indexPath) as? HeaderCollectionCell else {
          fatalError()
        }
        return headerCell
    }
    if indexPath.section == 1 {
        let cellIdentifier = CellIdentifier.reasonViewCell.rawValue
        guard let reasonCell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier,
                                                              for: indexPath) as? ReasonViewCell else {
          fatalError()
        }
        let model = jobResponseData[indexPath.item]
        let color = Utilities.getRgbColor(0, 0, 0, 0.12)
        cellShadow(color: color, view: reasonCell.baseView)
        reasonCell.updateReasonCell(model)
        return reasonCell
    }
    if indexPath.section == 2 {
        let cellIdentifier = CellIdentifier.footerViewCell.rawValue
        guard let footerCell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier,
                                                              for: indexPath) as? FooterViewCell else {
          fatalError()
        }
        let color = Utilities.getRgbColor(0, 0, 0, 0.12)
        cellShadow(color: color, view: footerCell.OtherButton)
        footerCell.updateFooterCell()
        footerCell.delegate = self
        return footerCell
    }
   return UICollectionViewCell()
 }
  
 func collectionView(_ collectionView: UICollectionView,
                     layout collectionViewLayout: UICollectionViewLayout,
                     sizeForItemAt indexPath: IndexPath) -> CGSize {
    if indexPath.section == 0 {
        return CGSize(width: collectionView.frame.size.width - 22, height: 80)
    }
    if indexPath.section == 1 {
        let leftPadding = 22
        let rightPadding = 22
        let spaceBtwCell = 10
        let combinedSpacing: CGFloat = CGFloat(leftPadding + rightPadding + spaceBtwCell)
        let cellSize = CGSize(width: (collectionView.bounds.width - combinedSpacing)/2, height: 100)
        return cellSize
    }
    return CGSize(width: collectionView.frame.size.width, height: 230)
}
    
func collectionView(_ collectionView: UICollectionView,
                    layout collectionViewLayout: UICollectionViewLayout,
                    minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    if section == 1 {
      return 10
    }
    return 0
}

func collectionView(_ collectionView: UICollectionView,
                    layout collectionViewLayout: UICollectionViewLayout,
                    insetForSectionAt section: Int) -> UIEdgeInsets {
    if section == 0 {
        return UIEdgeInsets(top: 0, left: 22, bottom: 30, right: 22)
    }
    if section == 1 {
      return UIEdgeInsets(top: 0, left: 22, bottom: 16, right: 22)
    }
    return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
}

func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    if indexPath.section == 0 {
        return
    }
    if indexPath.section == 1 {
      updateReasonListSection(collectionView, indexPath)
   }
}
    
func updateReasonListSection(_ collectionView: UICollectionView, _ indexPath: IndexPath) {
  if let footerCell = collectionView.cellForItem(at: IndexPath(item: 0, section: 2)) as? FooterViewCell {
   footerCell.hideOtherView()
   let model = jobResponseData[indexPath.item]
    if collectionView.cellForItem(at: indexPath)?.isSelected == true
        && model.selection == false {
                                                                
    let filterModel = jobResponseData.filter({$0.selection == true})
    if filterModel.isEmpty == false {
      _ = filterModel.map({$0.selection = false})
    }
    model.selection = true
    footerCell.exitButton.alpha = 1.0
    footerCell.exitButton.isUserInteractionEnabled = true
    delegate?.clickToSelectReason(model)
  } else {
    footerCell.exitButton.alpha = 0.5
    footerCell.exitButton.isUserInteractionEnabled = false
    model.selection = false
  }
  jobResponseData[indexPath.item] = model
  collectionView.reloadSections(IndexSet(integer: 1))
  }
}
    
func cellShadow(color: UIColor, view: UIView) {
  view.layer.masksToBounds = false
  view.layer.cornerRadius = 8.0
  view.layer.backgroundColor = UIColor.white.cgColor
  view.layer.borderColor = UIColor.clear.cgColor
  view.layer.shadowColor = color.cgColor
  view.layer.shadowOffset = CGSize.zero
  view.layer.shadowOpacity = 0.08
  view.layer.shadowRadius = 5
  }
}

extension ExitJobDatasource: FooterViewDelegate {
  func clickOtherReason() {
    let filterModel = jobResponseData.filter({$0.selection == true})
    if filterModel.isEmpty == false {
      _ = filterModel.map({$0.selection = false})
    }
    delegate?.clickOtherReason()
  }
    
  func clickToExit() {
    delegate?.clickToExit()
  }
}
