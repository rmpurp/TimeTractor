//
//  AppearanceManager.swift
//  TimeTractor
//
//  Created by Ryan Purpura on 5/21/20.
//  Copyright © 2020 Ryan Purpura. All rights reserved.
//

import Foundation
import UIKit

struct Appearance {
  struct CardCell {
    static let backgroundColor = UIColor.black.withAlphaComponent(0)

    static func applyPressed(on view: UIView, darkMode: Bool) {
      view.backgroundColor = UIColor.secondarySystemGroupedBackground.modify(
        by: 0.2, isDarkMode: darkMode)
    }

    static func applyUnpressed(on view: UIView) {
      view.backgroundColor = backgroundColor
    }
  }

  struct Card {
    static let cornerRadius = CGFloat(12)
    static let shadowRadius = CGFloat(5)
    static let shadowOpacity = Float(0.1)
    static let shadowColor = UIColor.black.cgColor
    static let shadowOffset = CGSize.zero
    static let backgroundColor = UIColor.secondarySystemGroupedBackground

    static func apply(on view: UIView) {
      view.layer.cornerRadius = cornerRadius
      view.layer.shadowColor = shadowColor
      view.layer.shadowRadius = shadowRadius
      view.layer.shadowOpacity = shadowOpacity
      view.layer.shadowOffset = shadowOffset
      view.backgroundColor = backgroundColor
    }

    static func applyPressed(on view: UIView, darkMode: Bool) {
      view.layer.shadowRadius = 0
      view.backgroundColor = UIColor.secondarySystemGroupedBackground.modify(
        by: 0.2, isDarkMode: darkMode)
    }

    static func applyUnpressed(on view: UIView) {
      view.backgroundColor = backgroundColor
      view.layer.shadowRadius = shadowRadius
    }
  }

  struct CardTitle {
    static let font = UIFont.systemFont(ofSize: 24, weight: .bold)
    static let topInset = CGFloat(15)
    static let leadingInset = CGFloat(15)
    static let trailingInset = -CGFloat(15)
    static let bottomInset = -CGFloat(5)

  }

  struct Cheveron {
    static let width = CGFloat(13)
    static let height = CGFloat(20)
    static let tintColor = UIColor.lightGray.withAlphaComponent(0.7)
  }
}
