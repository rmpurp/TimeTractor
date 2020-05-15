//
//  SectionBackgroundDecorationView.swift
//  TimeTractor
//
//  Created by Ryan Purpura on 5/14/20.
//  Copyright © 2020 Ryan Purpura. All rights reserved.
//

import UIKit

class SectionBackgroundDecorationView: UICollectionReusableView {
  override init(frame: CGRect) {
    super.init(frame: frame)
    print("HI")
    configure()
  }
  required init?(coder: NSCoder) {
    fatalError("not implemented")
  }
}

extension SectionBackgroundDecorationView {
  func configure() {
    backgroundColor = .systemBackground
    layer.borderColor = UIColor.black.cgColor
    layer.cornerRadius = 12
  }
}
