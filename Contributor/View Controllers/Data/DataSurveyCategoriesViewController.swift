//
//  DataSurveyCategoriesViewController.swift
//  Contributor
//
//  Created by arvindh on 18/12/18.
//  Copyright © 2018 Measure. All rights reserved.
//

import UIKit
import Kingfisher

protocol DataSurveyCategoriesDataSource: class {
  func categories() -> Category?
  func getFilterCategory() -> [SurveyCategory]?
  func moveToSurvey(surveyManager: SurveyManager)
}

class DataSurveyCategoriesViewController: UIViewController {
  struct Layout {
    static let collectionViewHeight: CGFloat = 150
    static let collectionViewCellWidth: CGFloat = 100
    static let collectionViewInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
    static let borderHeight: CGFloat = 1
  }
  
  weak var dataSource: DataSurveyCategoriesDataSource?
  let generator = UIImpactFeedbackGenerator(style: .light)
  var dataSourceArray: [SurveyCategory]? = []
    
  let border: UIView = {
     let view = UIView()
     view.backgroundColor = Color.lightBorder.value
     return view
  }()
    
  let profileSurveyLabel: UILabel = {
     let label = UILabel()
    label.text = SurveyText.profileSurvey.localized()
     label.textColor = .black
     label.font = Font.bold.of(size: 24)
     label.numberOfLines = 0
     return label
  }()
    
  let profileSurveyCount: UILabel = {
     let label = UILabel()
     label.textColor = .black
     label.font = Font.bold.of(size: 16)
     label.numberOfLines = 0
     return label
  }()
    
  let dataProfileLabel: UILabel = {
     let label = UILabel()
    label.text = SurveyText.profileSurveyMessge.localized()
     label.textColor = .black
     label.font = Font.regular.of(size: 16)
     label.numberOfLines = 0
     return label
  }()
    
  let collectionView: UICollectionView = {
    let layout = UICollectionViewFlowLayout()
    layout.minimumInteritemSpacing = 14
    layout.minimumLineSpacing = 10
    layout.scrollDirection = .horizontal
    layout.sectionInset = Layout.collectionViewInset
    
    let cv = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
    cv.register(DataCategoryCollectionViewCell.self,
                forCellWithReuseIdentifier: CellIdentifier.dataCategory.rawValue)
    cv.backgroundColor = Constants.backgroundColor
    cv.showsHorizontalScrollIndicator = false
    cv.alwaysBounceHorizontal = true
    return cv
  }()
  
override func viewDidLoad() {
    super.viewDidLoad()
    setupViews()
    addObserver()
}
    
func addObserver() {
   NotificationCenter.default.addObserver(self, selector: #selector(updateCategoryWithAnimation(_:)),
                                          name: NSNotification.Name.animateCategory, object: nil)
   NotificationCenter.default.addObserver(self, selector: #selector(updateCollectionViewUI),
                                          name: NSNotification.Name.updateCollectionViewUI, object: nil)
}
  
override func setupViews() {
    view.setContentHuggingPriority(UILayoutPriority.required,
                                   for: NSLayoutConstraint.Axis.vertical)
    view.addSubview(border)
    view.addSubview(profileSurveyLabel)
    view.addSubview(profileSurveyCount)
    view.addSubview(dataProfileLabel)
    view.addSubview(collectionView)
    let contentWidth = view.frame.width - Layout.collectionViewInset.left - Layout.collectionViewInset.right

    border.snp.makeConstraints { (make) in
      make.top.equalTo(view)
      make.height.equalTo(Layout.borderHeight)
      make.width.equalTo(contentWidth)
    }
    
    profileSurveyLabel.snp.makeConstraints { (make) in
        make.top.equalTo(border.snp.bottom).offset(10)
        make.leading.equalTo(view)
    }
    
    profileSurveyCount.snp.makeConstraints { (make) in
        make.top.equalTo(border.snp.bottom).offset(15)
        make.centerX.equalTo(profileSurveyLabel)
        make.trailing.equalTo(view)
    }
    
    dataProfileLabel.snp.makeConstraints { (make) in
        make.top.equalTo(profileSurveyLabel.snp.bottom).offset(5)
    }
    
    collectionView.snp.makeConstraints { (make) in
      make.top.equalTo(dataProfileLabel.snp.bottom).offset(15)
      make.bottom.equalTo(view).offset(-10).priority(999)
      make.height.equalTo(Layout.collectionViewHeight)
      
      // set the width to nudge up against the edge of the device
      make.left.equalTo(view).offset(-Layout.collectionViewInset.left)
      make.right.equalTo(view).offset(Layout.collectionViewInset.right)
    }
    
    collectionView.dataSource = self
    collectionView.delegate = self
    if let totalCount = dataSource?.categories()?.totalCount,
        let completedCount = dataSource?.categories()?.completedCount {
        profileSurveyCount.text = "\(completedCount) / \(totalCount)"
    }
    dataSourceArray = dataSource?.getFilterCategory()
}
    
@objc func updateCategoryWithAnimation(_ notification: Notification) {
    let object = notification.object as? SurveyCategory
    if animationRequired(object, dataSource?.getFilterCategory()) == false {
        return
    }
    if let userId = UserManager.shared.user?.userID,
        let alreadyCompletedSurvey = UserDefaults.standard.value(forKey: "alreadyCompleted-\(userId)") as? String {
        if object?.ref == alreadyCompletedSurvey && object?.ref != Constants.basic {
            return
        }
    }
    if let index = dataSource?.getFilterCategory()?.firstIndex(where: { $0.categoryID == object?.categoryID }) {
        guard let cell = collectionView.cellForItem(at: IndexPath(item: index, section: 0)) as? DataCategoryCollectionViewCell else { return }
        flipAnimation(cell, row: index, object)
   }
}
    
func animationRequired(_ category: SurveyCategory?, _ surveyCategory: [SurveyCategory]?) -> Bool {
    if let isCompletedSurvey = surveyCategory?.filter({$0.isCompleted == true && $0.ref == Constants.basic}) {
        if isCompletedSurvey.count == 1 && category?.ref != Constants.basic {
          return true
    }
    if let isCompletedSurvey = surveyCategory?.filter({$0.isCompleted == true && $0.ref == category?.ref}),
        isCompletedSurvey.isEmpty == false {
       return false
     }
   }
   return true
}
    
func flipAnimation(_ cell: DataCategoryCollectionViewCell, row: Int, _ category: SurveyCategory?) {
    UIView.animate(withDuration: 1, delay: 0.3, options: [], animations: {
     let flipSide: UIView.AnimationOptions = .transitionFlipFromRight
     UIView.transition(with: cell.baseView, duration: 0.2, options: flipSide,
                       animations: { () -> Void in
        cell.plusView.isHidden = !cell.plusView.isHidden
        cell.imageContainerView.isHidden = !cell.imageContainerView.isHidden
      }, completion: { (_) in
        if category?.ref == Constants.basic {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
               NotificationCenter.default.post(name: NSNotification.Name.updateCategory, object: nil)
            }
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.dataSourceArray?.remove(at: row)
                self.collectionView.deleteItems(at: [IndexPath(item: row, section: 0)])
                NotificationCenter.default.post(name: NSNotification.Name.updateCategory, object: nil)
            }
          }
      })
   })
}

@objc func updateCollectionViewUI() {
    if let totalCount = self.dataSource?.categories()?.totalCount,
        let completedCount = self.dataSource?.categories()?.completedCount {
        self.profileSurveyCount.text = "\(completedCount) / \(totalCount)"
    }
    dataSourceArray = dataSource?.getFilterCategory()
    self.reloadData()
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
        NotificationCenter.default.post(name: NSNotification.Name.updateStats, object: self.dataSource?.categories()?.statTiles)
    }
}

func reloadData() {
    collectionView.reloadData()
    collectionView.performBatchUpdates(nil, completion: nil)
  }
}

extension DataSurveyCategoriesViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    let categories = dataSourceArray ?? []
    return categories.count
}
  
func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifier.dataCategory.rawValue, for: indexPath) as? DataCategoryCollectionViewCell else {
      fatalError()
    }
    let categories = dataSourceArray ?? []
    let category = categories[indexPath.item]
    cell.updateCellContent(category, indexPath: indexPath)
    return cell
}
  
func collectionView(_ collectionView: UICollectionView,
                    layout collectionViewLayout: UICollectionViewLayout,
                    sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: Layout.collectionViewCellWidth, height: collectionView.frame.size.height)
}
  
func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let categories = dataSourceArray ?? []
    generator.impactOccurred()
    let category = categories[indexPath.item]
    if category.isCompleted, let userId = UserManager.shared.user?.userID {
        UserDefaults.standard.set(category.ref, forKey: "alreadyCompleted-\(userId)")
    }
    let surveyManager = SurveyManager(surveyType: SurveyType.category(category: category))
    dataSource?.moveToSurvey(surveyManager: surveyManager)
  }
}
