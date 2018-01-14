//
//  Date+Pick.swift
//  tododew
//
//  Created by 권형주 on 2017. 6. 10..
//  Copyright © 2017년 hyungdew. All rights reserved.
//

import Foundation

extension Date {
  func startOfMonth() -> Date {
    return Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Calendar.current.startOfDay(for: self)))!
  }
  
  func endOfMonth() -> Date {
    return Calendar.current.date(byAdding: DateComponents(month: 1, day: 0), to: self.startOfMonth())!
  }
}
