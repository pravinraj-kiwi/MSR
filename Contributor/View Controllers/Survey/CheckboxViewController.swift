//
//  CheckboxViewController.swift
//  Contributor
//
//  Created by arvindh on 01/01/19.
//  Copyright © 2019 Measure. All rights reserved.
//

import UIKit

class CheckboxBlockViewController: BlockViewController, BlockValueContainable {
  typealias ValueType = CheckboxBlockResponse
  
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

extension CheckboxBlockViewController: UITableViewDelegate, UITableViewDataSource {
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
    let selectedChoices = typedValue?.value
    let selectedChoiceValues = selectedChoices?.map({ (choice) -> String in
        return (choice.value ?? "")
    })
    
    if let option = option.value, let values = selectedChoiceValues, values.contains(option) {
      cell.setSelected(true)
    }
    else {
      cell.setSelected(false)
    }
    
    cell.selectionIndicator.selectionType = .checkbox
    cell.selectionStyle = .none
    
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let option = options[indexPath.row]
    updateValue(with: option)
    tableView.reloadData()
  }
  
  func updateValue(with option: SurveyBlock.Choice) {
    let response = typedValue ?? CheckboxBlockResponse()
    var selectedChoices = response.value ?? Set<SurveyBlock.Choice>()
    
    let optionToRemove = selectedChoices.filter { (choice) -> Bool in
      return choice.value == option.value
    }.first
    
    if let optionToRemove = optionToRemove {
      selectedChoices.remove(optionToRemove)
    }
    else {
      selectedChoices.insert(option)
    }
    
    if selectedChoices.isEmpty {
      value = nil
    }
    else {
      response.value = selectedChoices
      value = response
    }
  }
}
