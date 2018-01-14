//
//  UIFont+CustomFont.swift
//  tododew
//
//  Created by 권형주 on 2017. 6. 10..
//  Copyright © 2017년 hyungdew. All rights reserved.
//

import UIKit

extension UIFont {
  class func loadCustomFonts() {
    registerCustomFonts()
  }
  
  private static func registerCustomFonts() {
    // Load bundle which hosts the font files. Bundle has various ways of locating bundles.
    // This one uses the bundle's identifier
    guard let bundle = Bundle(identifier: "com.hyungdew.simplewallet")
    else { return }

    // List the fonts by name and extension, relative to the bundle
    let fonts = [
        bundle.url(forResource: "Quicksand-Bold", withExtension: "otf"),
        bundle.url(forResource: "Quicksand-BoldItalic", withExtension: "otf"),
        bundle.url(forResource: "Quicksand-Italic", withExtension: "otf"),
        bundle.url(forResource: "Quicksand-Light", withExtension: "otf"),
        bundle.url(forResource: "Quicksand-LightItalic", withExtension: "otf"),
        bundle.url(forResource: "Quicksand-Regular", withExtension: "otf"),
    ]

    // Iterate over the resulting urls, filtering out nil-values with .flatMap()]
    fonts
      .flatMap { $0 }
      .flatMap { CGDataProvider(url: $0 as CFURL) }
      .map(CGFont.init)
      .forEach { CTFontManagerRegisterGraphicsFont($0, nil) }
  }
}
