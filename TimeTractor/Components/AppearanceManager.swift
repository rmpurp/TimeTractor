//
//  AppearanceManager.swift
//  TimeTractor
//
//  Created by Ryan Purpura on 5/21/20.
//  Copyright © 2020 Ryan Purpura. All rights reserved.
//

import Foundation
import UIKit

struct AppearanceManager {
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
  }
}
