//
//  AppDelegate.swift
//  tododew
//
//  Created by  BCNX-A06 on 2016. 10. 19..
//  Copyright © 2016년 hyungdew. All rights reserved.
//

import UIKit

import AMScrollingNavbar
import ManualLayout
import SnapKit
import Then

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?
  
  static var instance: AppDelegate? {
    return UIApplication.shared.delegate as? AppDelegate
  }

  func setupBadgeNumberPermissions() {
    let types: UIUserNotificationType = .badge
    let notificationSettings: UIUserNotificationSettings = UIUserNotificationSettings(types: types, categories: nil)
    UIApplication.shared.registerUserNotificationSettings(notificationSettings)
  }
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    let window = UIWindow(frame: UIScreen.main.bounds)
    window.backgroundColor = .white
    window.makeKeyAndVisible()
    window.rootViewController = SplashViewController()
    
    self.window = window
    self.setupBadgeNumberPermissions()
    
    return true
  }
  
  func presentMainScreen() {
    let transparentImage = UIImage()
    let navigationController = ScrollingNavigationController(rootViewController: TotalViewConroller())
    navigationController.navigationBar.setBackgroundImage(transparentImage, for: .default)
    navigationController.navigationBar.shadowImage = transparentImage
    navigationController.navigationBar.tintColor = .black
    
    navigationController.navigationBar.backIndicatorImage = transparentImage
    navigationController.navigationBar.backIndicatorTransitionMaskImage = transparentImage

    if let font = UIFont(name: "Quicksand-Bold", size: 18) {
      navigationController.navigationBar.titleTextAttributes = [NSFontAttributeName: font]
    }
    
    self.window?.rootViewController = navigationController
  }
  
  func applicationDidEnterBackground(_ application: UIApplication) {
//    application.applicationIconBadgeNumber = 20
  }
  
  func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
//    application.applicationIconBadgeNumber = 0
  }
}

