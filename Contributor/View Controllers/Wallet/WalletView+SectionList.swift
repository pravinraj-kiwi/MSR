//
//  WalletView+SectionList.swift
//  Contributor
//
//  Created by KiwiTech on 8/28/20.
//  Copyright © 2020 Measure. All rights reserved.
//

import UIKit
import AFDateHelper

private func parseDate(_ str: String) -> Date {
    let dateFormat = DateFormatter()
    dateFormat.dateFormat = DateFormatType.serverDateFormat.rawValue
    if let convertedDate = dateFormat.date(from: str) {
        debugPrint("Date: \(convertedDate)")
        return convertedDate
    }
    return Date()
}

private func filterByYear(date: Date) -> Date {
    let calendar = Calendar.current
    let components = calendar.dateComponents([.year],
                            from: date)
    if let dateYear = calendar.date(from: components) {
        return dateYear
    }
    return Date()
}

private func filterByMonth(date: Date) -> Date {
    let calendar = Calendar.current
    let components = calendar.dateComponents([.month, .year],
                            from: date)
    if let dateMonth = calendar.date(from: components) {
        return dateMonth
    }
    return Date()
}

enum DateType {
     case today, yesterday, previous
  }

extension Date {
    func get(_ components: Calendar.Component..., calendar: Calendar = Calendar.current) -> DateComponents {
        return calendar.dateComponents(Set(components), from: self)
    }
}
extension WalletListViewController {
    
func compareDate(first: Date, second: Date) -> DateType {
      let components1 = first.get(.day, .month, .year)
      let components2 = second.get(.day, .month, .year)
      if let day1 = components1.day, let month1 = components1.month,
         let year1 = components1.year, let day2 = components2.day,
         let month2 = components2.month, let year2 = components2.year {
         if year1 == year2 && month1 == month2 {
            if day1 == day2 {
               return DateType.today
            } else if day1 - day2 == 1 {
               return DateType.yesterday
            }
         }
      }
      return DateType.previous
}
    
func getFilterList(_ rows: [WalletTransaction], completion: @escaping (Bool?) -> Void) {
  resetValues()
  let todayObject = getTodayDateObjects(rows)
  let leftObject = Array(Set(rows).subtracting(todayObject))
  let yesterdayObject = getYesterDayObject(leftObject)
  let combineObject = todayObject + yesterdayObject
  let filterObject = Array(Set(rows).subtracting(combineObject))
  if !todayObject.isEmpty {
    let todayData = [GroupedSection.init(sectionItem: Date(), rows: todayObject)]
    transactionItem.append(contentsOf: todayData)
  }
  if !yesterdayObject.isEmpty {
    let yesterdayData = [GroupedSection.init(sectionItem: Date().adjust(.day, offset: -1), rows: yesterdayObject)]
    transactionItem.append(contentsOf: yesterdayData)
  }
  let thisMonthObject = getThisMonthObject(filterObject)
  let filterUpdatedObject = Array(Set(filterObject).subtracting(thisMonthObject))
  if !thisMonthObject.isEmpty {
    let thisMonthData = GroupedSection.updateData(rows: thisMonthObject, by: { filterByMonth(date: parseDate($0.updatedDate ?? ""))})
    transactionItem.append(contentsOf: thisMonthData)
  }
  fetchLeftTransactions(filterUpdatedObject) { (_) in
     completion(true)
  }
}
    
func getTodayDateObjects(_ rows: [WalletTransaction]) -> [WalletTransaction] {
  let rowArr = rows.sorted(by: {$0.transactionID! > $1.transactionID!})
  var todayArray = [WalletTransaction]()
  for date in rowArr.enumerated() {
    if let todayDateUpdate = date.element.date {
       let serverDate = Utilities.serverDateInUTC(isoDate: todayDateUpdate)
        if compareDate(first: Date(), second: serverDate) == .today {
         todayArray.append(date.element)
       }
    }
  }
  return todayArray
}

func getYesterDayObject(_ rows: [WalletTransaction]) -> [WalletTransaction] {
  let rowArr = rows.sorted(by: {$0.transactionID! > $1.transactionID!})
  var yesterdayArray = [WalletTransaction]()
  for date in rowArr.enumerated() {
    if let yesterdayDateUpdate = date.element.date {
      let serverDate = Utilities.serverDateInUTC(isoDate: yesterdayDateUpdate)
        if compareDate(first: Date(), second: serverDate) == .yesterday {
          yesterdayArray.append(date.element)
      }
    }
  }
  return yesterdayArray
}
    
func getThisMonthObject(_ rows: [WalletTransaction]) -> [WalletTransaction] {
  let rowArr = rows.sorted(by: {$0.transactionID! > $1.transactionID!})
  var thisMonthArray = [WalletTransaction]()
  for date in rowArr.enumerated() {
    if let monthDateUpdate = date.element.date {
        let serverDate = Utilities.serverDateInUTC(isoDate: monthDateUpdate)
        if serverDate.compare(.isThisMonth) {
            thisMonthArray.append(date.element)
        }
    }
  }
  return thisMonthArray
}

func updateCornersRadius(_ completion: @escaping (Bool?) -> Void) {
  if transactionItem.isEmpty == true {
    return
  }
  for rows in transactionItem {
    var initialIndex = 0
    while initialIndex < rows.rows.count {
      if rows.rows.count == 1 {
        rows.rows.first?.shouldShowTopCorners = true
        rows.rows.last?.shouldShowBottomCorners = true
      } else {
        if initialIndex == 0 {
            rows.rows.first?.shouldShowTopCorners = true
            rows.rows.first?.shouldShowBottomCorners = false
        }
        if initialIndex == rows.rows.count - 1 {
            rows.rows.last?.shouldShowTopCorners = false
            rows.rows.last?.shouldShowBottomCorners = true
          }
        }
      initialIndex+=1
    }
  }
  completion(true)
}

func fetchLeftTransactions(_ rows: [WalletTransaction], completion: @escaping (Bool?) -> Void) {
  let rowArr = rows.sorted(by: {$0.transactionID! > $1.transactionID!})
    let yearData = GroupedSection.updateData(rows: rowArr, by: { filterByYear(date: parseDate($0.updatedDate ?? ""))})
  transactionItem.append(contentsOf: yearData)
  transactionItem.sort { lhs, rhs in lhs.sectionItem > rhs.sectionItem }
    updateCornersRadius { (_) in
        completion(true)
    }
 }
}
