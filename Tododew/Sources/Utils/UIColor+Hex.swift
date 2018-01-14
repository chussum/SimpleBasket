import UIKit

extension UIColor {
  convenience init(hex: String, alpha: Float = 1) {
    var hex = hex
    
    if hex.hasPrefix("#") {
			hex = hex.substring(from: hex.index(hex.startIndex, offsetBy: 1))
		}
    
    guard let hexVal = Int(hex, radix: 16) else {
			self.init()
      return
		}
    
    let red = CGFloat((hexVal & 0xFF0000) >> 16) / 256.0
    let green = CGFloat((hexVal & 0xFF00) >> 8) / 256.0
    let blue = CGFloat(hexVal & 0xFF) / 256.0
    
    switch hex.characters.count {
		case 6:
			self.init(red: red, green: green, blue: blue, alpha: CGFloat(alpha))
		default:
			self.init()
		}
  }
}
