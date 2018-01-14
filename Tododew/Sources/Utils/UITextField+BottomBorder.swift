import UIKit

extension UITextField {
  
  func addBorderBottom(height: CGFloat, color: UIColor) {
    let border = UIView()
    border.frame = CGRect(x: 0, y: self.height - height, width: self.width, height: height)
    border.backgroundColor = color
    self.addSubview(border)
    
    border.snp.makeConstraints { make in
      make.left.right.width.equalTo(self)
      make.height.equalTo(height)
      make.bottom.equalTo(self.height).offset(-height)
    }
  }
}
