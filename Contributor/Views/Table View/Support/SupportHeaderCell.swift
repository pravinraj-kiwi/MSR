//
//  SupportHeaderCell.swift
//  Contributor
//
//  Created by KiwiTech on 10/12/20.
//  Copyright © 2020 Measure. All rights reserved.
//

import UIKit

protocol SupportHeaderDelegate: class {
    func clickToOpenSupportURL(_ url: URL)
}

class SupportHeaderCell: UITableViewCell {
    @IBOutlet weak var supportHelpLabel: UILabel!
 @IBOutlet weak var supportCollectionView: UICollectionView!
 private var supportArray = [SupportModel]()
 let itemWidth = SupportList.collectionItemWidth
 let itemHeight = SupportList.collectionItemHeight
 let itemLineSpacing = SupportList.collectionLineSpacing
 let supportCell = SupportList.supportCell

 weak var supportDelegate: SupportHeaderDelegate?
    
 override func awakeFromNib() {
   super.awakeFromNib()
   // Initialization code
    let helloTxt = SupportList.feedbackHeaderHelloTitle.localized()
    let helloSubTxt = SupportList.feedbackHeaderHelloSubTitle.localized()
    supportHelpLabel.text = helloTxt + "\n" + helloSubTxt
    updateInitialCollection()
    let fileName = Constants.supportJsonFile
    if let supportData = getSupportJson(filename: fileName) {
        supportArray.append(contentsOf: supportData.support)
        supportCollectionView.reloadData()
    }
}

func updateInitialCollection() {
  let cellNib = UINib(nibName: supportCell, bundle: nil)
  supportCollectionView.register(cellNib, forCellWithReuseIdentifier: supportCell)
  supportCollectionView.dataSource = self
  supportCollectionView.delegate = self
  let flowLayout = UICollectionViewFlowLayout()
  flowLayout.scrollDirection = .horizontal
  flowLayout.itemSize = CGSize(width: itemWidth, height: itemHeight)
  flowLayout.minimumLineSpacing = CGFloat(itemLineSpacing)
  supportCollectionView.collectionViewLayout = flowLayout
}

func getSupportJson(filename fileName: String) -> ResponseData? {
  let extensionName = Constants.jsonFileExtension
  if let url = Bundle.main.url(forResource: fileName, withExtension: extensionName) {
    do {
      let data = try Data(contentsOf: url)
      let decoder = JSONDecoder()
      let supportModel = try decoder.decode(ResponseData.self, from: data)
      return supportModel
     } catch {
        debugPrint("error:\(error)")
     }
   }
  return nil
}

 override func setSelected(_ selected: Bool, animated: Bool) {
   super.setSelected(selected, animated: animated)
   // Configure the view for the selected state
 }
}

extension SupportHeaderCell: UICollectionViewDataSource, UICollectionViewDelegate {
 func collectionView(_ collectionView: UICollectionView,
                     numberOfItemsInSection section: Int) -> Int {
    return supportArray.count
 }
    
 func collectionView(_ collectionView: UICollectionView,
                     cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: supportCell,
                                                     for: indexPath) as? SupportCollectionCell {
       let model = supportArray[indexPath.item]
       cell.updateSupportCell(model)
       return cell
    }
    return UICollectionViewCell()
}
    
func collectionView(_ collectionView: UICollectionView,
                    didSelectItemAt indexPath: IndexPath) {
   let model = supportArray[indexPath.item]
   if let linkingURL =  URL(string: "\(Constants.baseContributorURLString)/\(model.supportURL)") {
      supportDelegate?.clickToOpenSupportURL(linkingURL)
    }
  }
}
