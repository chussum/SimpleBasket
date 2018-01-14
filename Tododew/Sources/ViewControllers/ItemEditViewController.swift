//
//  ItemEditViewController.swift
//  PopupDialog
//
//  Created by Martin Wildfeuer on 11.07.16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//
import UIKit
import PopupDialog
import RealmSwift

class ItemEditViewController: UIViewController {
  fileprivate enum Font {
    static let textField = UIFont(name: "Quicksand-Bold", size: 16)
    static let addButton = UIFont(name: "Quicksand-Bold", size: 14)
    static let cancelButton = UIFont(name: "Quicksand-Bold", size: 14)
  }
  
  fileprivate enum Color {
    static let borderBottom = UIColor(hex: "#eeeeee", alpha: 1)
    static let cancelButtonBackground = UIColor(red: 198/255, green: 198/255, blue: 198/255, alpha: 1)
  }

  fileprivate let titleTextField = UITextField().then {
    $0.font = Font.textField
    $0.placeholder = "Item"
    $0.borderStyle = .none
    $0.addBorderBottom(height: 1, color: Color.borderBottom)
  }
  
  fileprivate let priceTextField = UITextField().then {
    $0.font = Font.textField
    $0.placeholder = "Price"
    $0.keyboardType = .numberPad
    $0.borderStyle = .none
    $0.addBorderBottom(height: 1, color: Color.borderBottom)
  }
  
  fileprivate let addButton = UIButton().then {
    $0.titleLabel?.font = Font.addButton
    $0.tintColor = .white
    $0.backgroundColor = .black
    $0.layer.cornerRadius = 2
    $0.setTitle("ADD", for: .normal)
  }
  
  fileprivate let cancelButton = UIButton().then {
    $0.titleLabel?.font = Font.cancelButton
    $0.tintColor = .white
    $0.backgroundColor = Color.cancelButtonBackground
    $0.layer.cornerRadius = 2
    $0.setTitle("CANCEL", for: .normal)
  }
  
  fileprivate let viewWidth: Int
  fileprivate var itemTitle: String {
    guard let titleText = self.titleTextField.text else { return "" }
    return titleText
  }
  fileprivate var itemPrice: String {
    guard let priceText = self.priceTextField.text else { return "0" }
    return priceText
  }
  
  var addButtonItemDidTap: () -> Void
  var dismissAction: (() -> Void)?
  var addDidAction: (() -> Void)?

  init(width: Int, addButtonItemDidTap: @escaping () -> Void) {
    self.viewWidth = width
    self.addButtonItemDidTap = addButtonItemDidTap
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.titleTextField.delegate = self
    self.priceTextField.delegate = self

    self.addButton.addTarget(self, action: #selector(addButtonDidTap), for: .touchUpInside)
    self.cancelButton.addTarget(self, action: #selector(cancelButtonDidTap), for: .touchUpInside)
    
    self.view.addSubview(titleTextField)
    self.view.addSubview(priceTextField)
    self.view.addSubview(cancelButton)
    self.view.addSubview(addButton)
    self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(endEditing)))
    
    self.view.snp.makeConstraints { make in
      make.width.equalTo(self.viewWidth)
      make.height.equalTo(200)
    }
    
    self.titleTextField.snp.makeConstraints { make in
      make.height.equalTo(40)
      make.top.left.equalTo(26)
      make.right.equalTo(-26)
    }
    
    self.priceTextField.snp.makeConstraints { make in
      make.height.equalTo(40)
      make.top.equalTo(self.titleTextField.snp.bottom).offset(10)
      make.left.right.equalTo(self.titleTextField)
    }
    
    let buttonWidth = self.viewWidth / 2 - 30
    self.cancelButton.snp.makeConstraints { make in
      make.height.equalTo(40)
      make.width.equalTo(buttonWidth)
      make.left.equalTo(26)
      make.top.equalTo(self.priceTextField.snp.bottom).offset(20)
    }

    self.addButton.snp.makeConstraints { make in
      make.height.equalTo(40)
      make.width.equalTo(buttonWidth)
      make.right.equalTo(-26)
      make.top.equalTo(self.priceTextField.snp.bottom).offset(20)
    }
  }

  func endEditing() {
    self.view.endEditing(true)
  }
  
  fileprivate func makeError(type: String) {
    switch (type) {
    case "title":
      self.shakeTextField(textField: self.titleTextField)
      break
    default:
      self.shakeTextField(textField: self.priceTextField)
      break
    }
  }
  
  func cancelButtonDidTap() {
    self.dismissAction?()
  }
  
  func addButtonDidTap() {
    guard self.itemTitle != "" else {
      self.makeError(type: "title")
      return
    }
    guard self.itemPrice != "" else {
      self.makeError(type: "price")
      return
    }
    
    let newItem = ToDoItem()
    newItem.id = ToDoItem.nextId()
    newItem.title = self.itemTitle
    newItem.price = self.itemPrice
    
    let realm = try! Realm()
    try! realm.write {
      realm.add(newItem)
    }
    
    NotificationCenter.default.post(name: Noti.refreshItems, object: nil)
    NotificationCenter.default.post(name: Noti.refreshSubItems, object: nil)
    NotificationCenter.default.post(name: Noti.refreshBadgeCount, object: nil)
    
    self.addDidAction?()
  }
  
  private func shakeTextField(textField: UITextField) {
    // TODO : refactor
    UIView.animate(
      withDuration: 0.1,
      animations: {
        textField.frame.origin.x += 2
      },
      completion: { _ in
        UIView.animate(
          withDuration: 0.1,
          animations: {
            textField.frame.origin.x -= 4
          },
          completion: { _ in
            UIView.animate(
              withDuration: 0.1,
              animations: {
                textField.frame.origin.x += 4
              },
              completion: { _ in
                UIView.animate(
                  withDuration: 0.1,
                  animations: {
                    textField.frame.origin.x -= 4
                  },
                  completion: { _ in
                    UIView.animate(
                      withDuration: 0.2,
                      animations: {
                        textField.frame.origin.x += 2
                      },
                      completion: { _ in
                      }
                    )
                  }
                )
              }
            )
          }
        )
      }
    )
  }
}

extension ItemEditViewController: UITextFieldDelegate {
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    endEditing()
    return true
  }
}
