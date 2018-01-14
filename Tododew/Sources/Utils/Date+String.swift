import Foundation

extension Date {
  
  func toString(format: String = "yyyy.MM.dd HH:mm:ss") -> String {
    return DateFormatter().then {
      $0.dateFormat = format
      $0.locale = Locale.init(identifier: "ko_KR")
    }.string(from: self)
  }
}
