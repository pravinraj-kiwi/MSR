//
//  ChangeLanguageViewController.swift
//  Contributor
//
//  Created by Shashi Kumar on 24/06/21.
//  Copyright © 2021 Measure. All rights reserved.
//

import UIKit

class ChangeLanguageViewController: UIViewController {
    @IBOutlet weak var optionsTableView: UITableView!
    var languages = Languages.languages

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpData()
        setUpDataSource()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        FirebaseAnalyticsManager.shared.logFirebaseAnalytics(.changePasswordScreen)
    }
    func setUpData() {
       let currentLanguageCode = UserDefaults.standard.string(forKey: "AppLanguage")
        if let row = languages.firstIndex(where: {$0.languageCode == currentLanguageCode}) {
            self.languages[row].isSelected = true
        }
    }
    func registerNib() {
        optionsTableView.estimatedRowHeight = 80
    }
    
    func setUpDataSource() {
        registerNib()
        optionsTableView.dataSource = self
        optionsTableView.delegate = self
    }
    
}
extension ChangeLanguageViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
       return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return languages.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       let cell = tableView.dequeueReusableCell(with: LanguageViewCell.self, for: indexPath)
       updateSettingCell(cell, indexPath)
       return cell
    }
      
    func updateSettingCell(_ cell: LanguageViewCell, _ indexPath: IndexPath) {
        let language = languages[indexPath.row]
        cell.languageTitle.textColor = .black
        cell.languageTitle.text = language.description.localized()
        if language.isSelected {
            cell.selectedArrow.image = UIImage(named: "checkmark")
        } else {
            cell.selectedArrow.image = nil
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let language = languages[indexPath.row]
        _ = self.languages.map({($0.isSelected = false)})
        if let row = self.languages.firstIndex(where: {$0.languageCode == language.languageCode}) {
            self.languages[row].isSelected = true
        }
        AppLanguageManager.shared.setAppLanguage(language.languageCode)
        self.optionsTableView.reloadData()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                 appDelegate.navigateToRootView()
            }
        }
       
    }
}

