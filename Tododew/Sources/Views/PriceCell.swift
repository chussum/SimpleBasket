//
//  SummaryView.swift
//  tododew
//
//  Created by 권형주 on 2017. 6. 1..
//  Copyright © 2017년 hyungdew. All rights reserved.
//

import UIKit
import SwipeCellKit
import RealmSwift

final class PriceCell: SwipeTableViewCell { //UICollectionViewCell {
  
  // MARK: Properties
  fileprivate struct Font {
    static let boldLabel = UIFont(name: "Quicksand-Bold", size: 18)
    static let regularLabel = UIFont(name: "Quicksand-Regular", size: 18)
    static let unitLabel = UIFont(name: "Quicksand-Regular", size: 14)
  }
  fileprivate var todoItem: ToDoItem? {
    didSet {
      self.titleLabel.text = todoItem?.title ?? ""
      self.priceLabel.text = toNumberFormat(string: todoItem?.price)
      self.checkBoxButton.isChecked = todoItem?.done ?? false
    }
  }
  
  // MARK: UI
  fileprivate var canEdit = false
  fileprivate let titleLabel = UITextField().then {
    $0.font = Font.boldLabel
    $0.isEnabled = false
  }
  fileprivate let priceLabel = UITextField().then {
    $0.font = Font.regularLabel
    $0.textAlignment = .right
    $0.keyboardType = .numberPad
    $0.isEnabled = false
  }
  fileprivate let unitLabel = UILabel().then {
    $0.font = Font.unitLabel
    $0.textAlignment = .center
    $0.text = "₩"
    $0.sizeToFit()
  }
  fileprivate let checkBoxButton = CheckboxButton()
  fileprivate let separateLine = UIView().then {
    $0.backgroundColor = Color.collectionViewSeparateColor
  }

  // MARK: Event
  fileprivate let realm = try! Realm()
  fileprivate let tapRecognizer = UITapGestureRecognizer()
  var didTap: (() -> Void)?
  var willEdit: (() -> Void)?
  var didEdit: (() -> Void)?
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    self.titleLabel.delegate = self
    self.priceLabel.delegate = self
    
    self.contentView.addSubview(self.unitLabel)
    self.contentView.addSubview(self.priceLabel)
    self.contentView.addSubview(self.titleLabel)
    self.contentView.addSubview(self.separateLine)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    if self.canEdit {
      self.checkBoxButton.snp.makeConstraints { make in
        make.width.height.equalTo(24)
        make.centerY.equalTo(self.contentView)
        make.right.equalTo(-18)
      }
    }
    
    self.unitLabel.snp.makeConstraints { make in
      make.centerY.equalTo(self.contentView)
      make.width.equalTo(16)
      if self.canEdit {
        make.right.equalTo(self.checkBoxButton.snp.left).offset(-6)
      } else {
        make.right.equalTo(-20)
      }
    }

    self.priceLabel.snp.makeConstraints { make in
      make.width.equalTo(100)
      make.centerY.equalTo(self.contentView)
      make.right.equalTo(self.unitLabel.snp.left)
    }
 
    self.titleLabel.snp.makeConstraints { make in
      make.centerY.equalTo(self.contentView)
      make.left.equalTo(20)
      make.right.equalTo(self.priceLabel.snp.left).offset(-6)
    }
    
    self.separateLine.snp.makeConstraints { make in
      make.bottom.equalTo(self.contentView.snp.bottom)
      make.width.equalTo(self.contentView.snp.width)
      make.height.equalTo(1 / UIScreen.main.scale)
    }
  }
  
  func configure(item: BasketTotal) {
    self.tapRecognizer.addTarget(self, action: #selector(viewDidTap))
    self.contentView.addGestureRecognizer(self.tapRecognizer)
    
    self.backgroundColor = .white
    self.titleLabel.text = item.title.substring(to: item.title.index(item.title.endIndex, offsetBy: -4))
    self.priceLabel.text = toNumberFormat(string: String(item.total))
    
    setNeedsLayout()
  }
  
  func configure(item: ToDoItem) {
    self.contentView.addSubview(self.checkBoxButton)
    self.todoItem = item
    
    self.checkBoxButton.didTap = { [weak self] in
      guard let `self` = self else { return }
      self.contentView.endEditing(true)
      
      guard let todoItem = self.todoItem else { return }
      DispatchQueue.main.async {
        let realm = try! Realm()
        try! realm.write {
          todoItem.done = !todoItem.done
        }
        
        NotificationCenter.default.post(name: Noti.refreshSubItems, object: nil)
        NotificationCenter.default.post(name: Noti.refreshBadgeCount, object: nil)
      }
    }
 
    self.backgroundColor = .white
    self.canEdit = true
    self.titleLabel.font = UIFont.systemFont(ofSize: 18)
    self.titleLabel.isEnabled = true
    self.priceLabel.isEnabled = true
    self.redrawCell()
    
    setNeedsLayout()
  }
  
  func redrawCell() {
    if self.todoItem?.done ?? false {
      self.titleLabel.textColor = .lightGray
      self.priceLabel.textColor = .lightGray
      self.unitLabel.textColor = .lightGray
    } else {
      self.titleLabel.textColor = .black
      self.priceLabel.textColor = .black
      self.unitLabel.textColor = .black
    }
  }
  
  class func size(width: CGFloat) -> CGSize {
    return CGSize(width: width, height: 60)
  }
  
  // MARK: Actions
  func viewDidTap() {
    self.didTap?()
  }
}

extension PriceCell: UITextFieldDelegate {
  func textFieldDidBeginEditing(_ textField: UITextField) {
    self.willEdit?()
  }
  
  func textFieldDidEndEditing(_ textField: UITextField) {
    self.didEdit?()
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    if textField.isEqual(self.titleLabel) {
      self.priceLabel.becomeFirstResponder()
    } else {
      self.titleLabel.resignFirstResponder()
    }
    return true
  }
  
  func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
    if textField.isEqual(self.priceLabel) {
        self.priceLabel.text = self.todoItem?.price ?? ""
    }
    return true
  }
  
  func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
    guard let todoItem = self.todoItem else { return false }
  
    try! realm.write {
      switch textField {
        case self.titleLabel: todoItem.title = textField.text!
        case self.priceLabel:
            todoItem.price = textField.text!
            textField.text = toNumberFormat(string: todoItem.price)
        default: break
      }
      todoItem.title = self.titleLabel.text!
      todoItem.updateAt = Date()
    }
    return true
  }
}
