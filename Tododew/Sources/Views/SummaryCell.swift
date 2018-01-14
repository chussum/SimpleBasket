//
//  SummaryView.swift
//  tododew
//
//  Created by 권형주 on 2017. 6. 1..
//  Copyright © 2017년 hyungdew. All rights reserved.
//

import UIKit

final class SummaryCell: UICollectionViewCell {
  
  fileprivate struct Font {
    static let titleLabel = UIFont(name: "Quicksand-Bold", size: 19)
    static let priceLabel = UIFont(name: "Quicksand-Regular", size: 36)
    static let unitLabel = UIFont(name: "Quicksand-Regular", size: 20)
  }
  
  fileprivate var canEdit = false
  fileprivate let titleLabel = UILabel().then {
    $0.layer.cornerRadius = 15
    $0.layer.backgroundColor = UIColor.black.cgColor
    $0.font = Font.titleLabel
    $0.textAlignment = .center
    $0.textColor = .white
    $0.text = "### ####"
    $0.sizeToFit()
  }
  fileprivate let priceLabel = UILabel().then {
    $0.font = Font.priceLabel
  }
  fileprivate let unitLabel = UILabel().then {
    $0.font = Font.unitLabel
    $0.text = "₩"
    $0.sizeToFit()
  }
  fileprivate let separateLine = UIView().then {
    $0.backgroundColor = Color.collectionViewSeparateColor
  }
  
  fileprivate let tapRecognizer = UITapGestureRecognizer()
  var didTap: (() -> Void)?
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    self.contentView.addSubview(self.titleLabel)
    self.contentView.addSubview(self.priceLabel)
    self.contentView.addSubview(self.unitLabel)
    
    if self.contentView.frame.height < self.contentView.frame.width {
      self.contentView.addSubview(self.separateLine)
    }
    
    self.tapRecognizer.addTarget(self, action: #selector(viewDidTap))
    self.contentView.addGestureRecognizer(self.tapRecognizer)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    self.titleLabel.snp.makeConstraints { make in
      make.width.equalTo(110)
      make.height.equalTo(28.5)
      make.centerX.equalTo(self.contentView)
      make.centerY.equalTo(self.contentView).offset(-30)
    }
    
    self.priceLabel.sizeToFit()
    self.priceLabel.snp.makeConstraints { make in
      make.centerX.equalTo(self.contentView).offset(-(self.unitLabel.frame.size.width/2))
      make.top.equalTo(self.titleLabel.snp.bottom).offset(14)
    }

    self.unitLabel.snp.makeConstraints { make in
      make.top.equalTo(self.priceLabel.snp.top).offset(14)
      make.left.equalTo(self.priceLabel.snp.right)
    }
    
    if self.contentView.frame.height < self.contentView.frame.width {
      self.separateLine.snp.makeConstraints { make in
        make.bottom.equalTo(self.contentView.snp.bottom)
        make.width.equalTo(self.contentView.snp.width)
        make.height.equalTo(1 / UIScreen.main.scale)
      }
    }
  }
  
  func configure(item: BasketTotal) {
    self.backgroundColor = .white
    self.titleLabel.text = item.title
    self.priceLabel.text = toNumberFormat(string: String(item.total))
    
    setNeedsLayout()
  }
  
  class func size(width: CGFloat, height: CGFloat) -> CGSize {
    return CGSize(width: width, height: height)
  }
  
  // MARK: Actions
  func viewDidTap() {
    self.didTap?()
  }
}
