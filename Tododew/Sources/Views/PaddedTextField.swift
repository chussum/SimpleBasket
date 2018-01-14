//
//  PaddedTextField.swift
//  tododew
//
//  Created by 권형주 on 2017. 6. 6..
//  Copyright © 2017년 hyungdew. All rights reserved.
//

import UIKit

class PaddedTextField: UITextField {
  override init(frame: CGRect) {
    super.init(frame: frame)
    self.autocapitalizationType = .none
    self.autocorrectionType = .no
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func textRect(forBounds bounds: CGRect) -> CGRect {
    return CGRect(x: bounds.origin.x + 10, y: bounds.origin.y, width: bounds.width, height: bounds.height)
  }

  override func editingRect(forBounds bounds: CGRect) -> CGRect {
    return CGRect(x: bounds.origin.x + 10, y: bounds.origin.y, width: bounds.width, height: bounds.height)
  }
}
