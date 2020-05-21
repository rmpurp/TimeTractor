//
//  ColorChangingButton.swift
//  TimeTractor
//
//  Created by Ryan Purpura on 5/21/20.
//  Copyright © 2020 Ryan Purpura. All rights reserved.
//

import UIKit

class ColorChangingButton: UIButton {

  override init(frame: CGRect) {
    super.init(frame: frame)
    backgroundColor = normalColor
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  var normalColor: UIColor = UIColor(displayP3Red: 0, green: 0, blue: 0, alpha: 0)
  var highlightColor: UIColor = UIColor(displayP3Red: 0, green: 0, blue: 0, alpha: 0.2)

  override open var isHighlighted: Bool {
    didSet {
      backgroundColor = isHighlighted ? highlightColor : normalColor
    }
  }

}
