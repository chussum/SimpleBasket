//
//  Navigation+Modal.swift
//  tododew
//
//  Created by 권형주 on 2017. 6. 8..
//  Copyright © 2017년 hyungdew. All rights reserved.
//

import UIKit
import PopupDialog
import RealmSwift

extension UINavigationController {
  fileprivate struct Font {
    static let addButton = UIFont(name: "Quicksand-Bold", size: 14)
    static let cancelButton = UIFont(name: "Quicksand-Bold", size: 14)
  }
  
  func showAddDialog(addButtonItemDidTap: @escaping () -> Void) {
    let itemEditContoller = ItemEditViewController(width: 300, addButtonItemDidTap: addButtonItemDidTap)
    let popup = PopupDialog(
      viewController: itemEditContoller,
      buttonAlignment: .horizontal,
      transitionStyle: .bounceDown,
      gestureDismissal: true
    )
    
    let view = popup.view.subviews[0].subviews[0]
    view.layer.cornerRadius = 2
    
    itemEditContoller.dismissAction = {
      popup.dismiss()
    }
    itemEditContoller.addDidAction = { [weak self] in
      popup.dismiss()
      
      if self?.viewControllers.last is TotalViewConroller {
        let currentDate = Date()
        let currentMonth = keyFormatter.string(from: currentDate)
        let title = titleFormatter.string(from: currentDate)
        
        self?.pushBasketController(month: currentMonth, title: title, addButtonItemDidTap: addButtonItemDidTap)
      }
    }
    
    self.present(popup, animated: true, completion: nil)
  }
  
  func pushBasketController(month: String, title: String, addButtonItemDidTap: @escaping () -> Void) {
    let basketViewConroller = BasketViewConroller(month: month, title: title)
    basketViewConroller.addButtonDidTap = addButtonItemDidTap
    
    self.pushViewController(basketViewConroller, animated: true)
  }
}
