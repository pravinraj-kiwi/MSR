//
//  ReferDatasource.swift
//  Contributor
//
//  Created by KiwiTech on 10/26/20.
//  Copyright © 2020 Measure. All rights reserved.
//

import UIKit

protocol ReferDatasourceDelegate: class {
  func clickToShareCode(_ code: String)
  func showCopiedAlert()
  func didTapGesture(_ label: UILabel, gesture: UITapGestureRecognizer)
}

class ReferDatasource: NSObject, UITableViewDataSource, UITableViewDelegate {
 weak var delegate: ReferDatasourceDelegate?
 var inviteCode: String? = ""

 func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return ReferFriendList.noOfRows
 }
    
 func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
   let cell = tableView.dequeueReusableCell(with: ReferFriendTableViewCell.self, for: indexPath)
   if let code = inviteCode {
    cell.updateCellUI(code)
   }
   cell.referDelegate = self
   return cell
 }
  
 func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return ReferFriendList.heightForCell
 }
}

extension ReferDatasource: ReferFriendDelegate {
 func clickToShareCode(_ code: String) {
    delegate?.clickToShareCode(code)
 }
    
 func showCopiedAlert() {
    delegate?.showCopiedAlert()
 }
    
 func didTapGesture(_ label: UILabel, gesture: UITapGestureRecognizer) {
    delegate?.didTapGesture(label, gesture: gesture)
 }
}
