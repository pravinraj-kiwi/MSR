//
//  RadioBlockViewController.swift
//  Contributor
//
//  Created by arvindh on 30/10/18.
//  Copyright © 2018 Measure. All rights reserved.
//

import UIKit
import SnapKit

class RadioBlockViewController: BlockViewController, BlockValueContainable {
  typealias ValueType = RadioBlockResponse
  
  let tableView: FittingTableView = {
    let tableView = FittingTableView(frame: CGRect.zero, style: UITableView.Style.plain)
    tableView.rowHeight = UITableView.automaticDimension
    tableView.estimatedRowHeight = 50
    tableView.backgroundColor = .clear
    tableView.isScrollEnabled = false
    tableView.separatorStyle = .none
    tableView.register(RadioOptionTableViewCell.self, forCellReuseIdentifier: CellIdentifier.radioOptionCell.rawValue)
    return tableView
  }()
  
  var options: [SurveyBlock.Choice] = []
  
  override func viewDidLoad() {
    super.viewDidLoad()

    options = block.choices ?? []
    setupViews()
  }

  override func setupViews() {
    view.addSubview(tableView)
    tableView.snp.makeConstraints { (make) in
      make.edges.equalTo(view)
    }
    
    tableView.delegate = self
    tableView.dataSource = self
  }
}

extension RadioBlockViewController: UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return options.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.radioOptionCell.rawValue, for: indexPath) as? RadioOptionTableViewCell else {
      fatalError()
    }
    
    let option = options[indexPath.row]
    let selectedLanguage = AppLanguageManager.shared.getLanguage()
    if (selectedLanguage == "pt-BR") || (selectedLanguage == "pt") {
        if let optionValue = option.labelPt {
            cell.label.attributedText = optionValue.lineSpaced(1.2)
        } else {
            if let optionValue = option.label {
                cell.label.attributedText = optionValue.lineSpaced(1.2)
            }
        }
    } else {
        if let optionValue = option.label {
            cell.label.attributedText = optionValue.lineSpaced(1.2)
        }
    }
    let selectedChoice = typedValue?.value
    cell.setSelected((option.value == selectedChoice?.value))
    cell.selectionStyle = .none
    
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let option = options[indexPath.row]
    
    if let existingValue = typedValue, option == existingValue.value {
      updateValue(with: nil)
    } else {
      updateValue(with: option)
    }
    
    tableView.reloadData()
  }
  
  func updateValue(with option: SurveyBlock.Choice?) {
    if let option = option {
      let newValue = RadioBlockResponse()
      newValue.value = option
      value = newValue
    } else {
      value = nil
    }
  }
}
