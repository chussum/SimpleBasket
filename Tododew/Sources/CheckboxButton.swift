//
//  CheckboxButton.swift
//  tododew
//
//  Created by  BCNX-A06 on 2016. 10. 25..
//  Copyright © 2016년 hyungdew. All rights reserved.
//

import UIKit
import RealmSwift

final class CheckboxButton: UIButton {
  // MARK: Properties
  var didTap: (() -> Void)?
  var isChecked: Bool = false {
    didSet{
      if isChecked == true {
        self.setImage(checkedImage, for: .normal)
      } else {
        self.setImage(uncheckedImage, for: .normal)
      }
    }
  }

  // MARK:  Images
  let checkedImage = UIImage(named: "checkbox_on")! as UIImage
  let uncheckedImage = UIImage(named: "checkbox_off")! as UIImage
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    self.addTarget(self, action: #selector(self.buttonClicked), for: .touchUpInside)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func buttonClicked() {
    self.isChecked = !self.isChecked
    self.didTap?()
  }
}

