//
//  SummaryView.swift
//  tododew
//
//  Created by 권형주 on 2017. 6. 1..
//  Copyright © 2017년 hyungdew. All rights reserved.
//

import UIKit
import RealmSwift

final class BasketHeaderCell: UICollectionViewCell {
  
  // MARK: Properties
  fileprivate struct Font {
    static let titleLabel = UIFont(name: "Quicksand-BoldItalic", size: 14)
  }
  
  // MARK: UI
  fileprivate let titleLabel = UITextField().then {
    $0.font = Font.titleLabel
    $0.textColor = Color.collectionViewHeaderColor
    $0.isEnabled = false
  }
  fileprivate let separateLine = UIView().then {
    $0.backgroundColor = Color.collectionViewSeparateColor
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    
    self.contentView.addSubview(self.titleLabel)
    self.contentView.addSubview(self.separateLine)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    self.titleLabel.sizeToFit()
    self.titleLabel.snp.makeConstraints { make in
      make.center.equalTo(self.contentView)
    }
    
    self.separateLine.snp.makeConstraints { make in
      make.bottom.equalTo(self.contentView.snp.bottom)
      make.width.equalTo(self.contentView.snp.width)
      make.height.equalTo(1 / UIScreen.main.scale)
    }
  }
  
  func configure(title: String) {
    self.backgroundColor = Color.collectionViewHeaderBackground
    self.titleLabel.text = title
    
    setNeedsLayout()
  }
  
  class func size(width: CGFloat) -> CGSize {
    return CGSize(width: width, height: 26)
  }
}

