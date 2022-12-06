//
//  MyAttributeController.swift
//  Contributor
//
//  Created by KiwiTech on 11/6/20.
//  Copyright © 2020 Measure. All rights reserved.
//

import UIKit

class MyAttributeController: UIViewController {
    
 @IBOutlet weak var tableView: UITableView!
 @IBOutlet weak var headerView: UIView!
 @IBOutlet weak var collection: UICollectionView!
 @IBOutlet weak var headerText: UILabel!
 @IBOutlet weak var searchBar: UITextField!
 @IBOutlet weak var searchView: UIView!
 @IBOutlet weak var searchButton: UIButton!
 @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
 @IBOutlet weak var headerTopConstraint: NSLayoutConstraint!
 @IBOutlet weak var collectionTopConstriant: NSLayoutConstraint!
 @IBOutlet weak var searchConstraint: NSLayoutConstraint!
 var themeColor: UIColor? = Constants.primaryColor
 var attributeDatasource = AtributeDatasource()
 var colllectionModel: [AttributeCollectionModel] = []
    
override func viewDidLoad() {
   super.viewDidLoad()
   // Do any additional setup after loading the view.
    setupNavbar()
    applyCommunityTheme()
    activityIndicator.updateIndicatorView(self, hidden: false)
    setUpDataSource()
    createAttributedList()
}
    
override func viewDidAppear(_ animated: Bool) {
  super.viewDidAppear(animated)
  FirebaseAnalyticsManager.shared.logFirebaseAnalytics(.myAttributeDetailScreen)
}
    
func setupNavbar() {
 isModalInPresentation = true
 if let _ = self.presentingViewController {
    navigationItem.leftBarButtonItem = backBarButtonItem(backArrowImage: Image.crossWhite.value)
    navigationItem.leftBarButtonItem?.tintColor = .white
   
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

@objc override func goBack() {
   dismissSelf()
}
    
func setUpDataSource() {
   let nib = UINib(nibName: Constants.sectionViewNib, bundle: nil)
   tableView.register(nib, forHeaderFooterViewReuseIdentifier: Constants.sectionViewNib)
   tableView.rowHeight = UITableView.automaticDimension
   tableView.estimatedRowHeight = UITableView.automaticDimension
   tableView.dataSource = attributeDatasource
   tableView.delegate = attributeDatasource
   if let layout = collection.collectionViewLayout as? UICollectionViewFlowLayout {
     layout.itemSize = CGSize(width: 68, height: 93)
   }
    initialSetUp()
}
    
func initialSetUp() {
  searchBar.addTarget(self, action: #selector(searchTextChanged(_:)), for: .editingChanged)
  searchBar.setLeftPaddingPoints(9)
  searchBar.attributedPlaceholder = NSAttributedString(string: ProfileAttributeText.placeholderText.localized(),
                                                          attributes: [NSAttributedString.Key.foregroundColor: Utilities.getRgbColor(102, 102, 102), NSAttributedString.Key.font: Font.regular.of(size: 16)])
  searchBar.delegate = self
  collection.delegate = self
  collection.dataSource = self
}
  
func callAttributeListApi(completion: (([ProfileAttributeModel]?, Bool) -> Void)? = nil) {
  if ConnectivityUtils.isConnectedToNetwork() == false {
    Helper.showNoNetworkAlert(controller: self)
    return
  }
  NetworkManager.shared.getProfileAttributeList { (attributeListModel, error) in
    if error != nil {
      completion?(nil, false)
    } else {
      completion?(attributeListModel, true)
     }
   }
  }
}

extension MyAttributeController: CommunityThemeConfigurable {
@objc func applyCommunityTheme() {
    guard let community = UserManager.shared.user?.selectedCommunity,
          let colors = community.colors else {
       return
     }
    headerView.backgroundColor = colors.primary
    self.navigationController?.navigationBar.barTintColor = colors.primary
    themeColor = colors.primary
    collection.backgroundColor = colors.primary
    self.headerText.text = ProfileAttributeText.myAttributesText.localized()
  }
}

extension MyAttributeController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
   return colllectionModel.count
}
  
func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
  let cellIdentifier = CellIdentifier.attributeCollectionCell.rawValue
  guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier,
                                                        for: indexPath) as? ProfileAttributeCollectionCell else {
    fatalError()
  }
  let model = colllectionModel[indexPath.item]
  cell.detailType.text = model.collectionLabel
  cell.detailCount.text = model.collectionCount
  return cell
  }
}
