//
//  SplashViewController.swift
//  Graygram
//
//  Created by 권형주 on 2017. 6. 14..
//  Copyright © 2017년 Hyungjoo Kwon. All rights reserved.
//

import UIKit

final class SplashViewController: UIViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
    UIFont.loadCustomFonts()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    AppDelegate.instance?.presentMainScreen()
  }
}
