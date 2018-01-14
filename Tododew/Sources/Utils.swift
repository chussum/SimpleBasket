//
//  Utils.swift
//  tododew
//
//  Created by 권형주 on 2016. 12. 24..
//  Copyright © 2016년 hyungdew. All rights reserved.
//

import UIKit

typealias BasketTotal = (year: String, title: String, total: Int)
typealias BasketTotals = [(key: String, value: BasketTotal)]

let yearFormatter = DateFormatter().then {
  $0.dateFormat = "yyyy"
  $0.locale = Locale.init(identifier: "ko_KR")
}
let keyFormatter = DateFormatter().then {
  $0.dateFormat = "yyyyMM"
  $0.locale = Locale.init(identifier: "ko_KR")
}
let titleFormatter = DateFormatter().then {
  $0.dateFormat = "MMM yyyy"
  $0.locale = Locale.init(identifier: "en")
}

enum Color {
  static let collectionViewHeaderBackground = UIColor(red: 246/255, green: 246/255, blue: 246/255, alpha: 1)
  static let collectionViewHeaderColor = UIColor(red: 159/255, green: 159/255, blue: 159/255, alpha: 1)
  static let collectionViewSeparateColor = UIColor(red: 238/255, green: 238/255, blue: 238/255, alpha: 1)
  
  static let lightGray = UIColor(red: 198/255, green: 198/255, blue: 198/255, alpha: 1)
}

enum Noti {
  static let refreshItems = Notification.Name("refreshItems")
  static let refreshSubItems = Notification.Name("refreshSubItems")
  static let refreshBadgeCount = Notification.Name("refreshBadgeCount")
}

func toNumberFormat(string: String?) -> String {
    guard let string = string else { return "" }
    guard let price = Int(string) else { return "0" }
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    formatter.locale = Locale(identifier: "ko_KR")
  
    guard let convertString = formatter.string(from: price as NSNumber) else { return "" }
    return convertString
}

