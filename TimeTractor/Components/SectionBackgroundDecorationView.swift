//
//  SectionBackgroundDecorationView.swift
//  TimeTractor
//
//  Created by Ryan Purpura on 5/14/20.
//  Copyright © 2020 Ryan Purpura. All rights reserved.
//

import UIKit

class SectionBackgroundDecorationView: UICollectionReusableView {
  let button = UIButton()

  override init(frame: CGRect) {
    super.init(frame: frame)
    configure()
  }
  required init?(coder: NSCoder) {
    fatalError("not implemented")
  }
}

extension SectionBackgroundDecorationView {
  @objc func buttonTouchUpInside(sender: UIButton) {
    buttonTouchUp(sender: sender)

  }

  @objc func buttonTouchUp(sender: UIButton) {
    UIView.animate(withDuration: 0.1) {
      self.backgroundColor = .secondarySystemGroupedBackground
    }
  }

  @objc func buttonTouchDown(sender: UIButton) {
    UIView.animate(withDuration: 0.1) {
      self.backgroundColor = UIColor.secondarySystemGroupedBackground.modify(
        by: 0.2, isDarkMode: self.traitCollection.userInterfaceStyle == .dark)
    }
  }

  func configure() {
    backgroundColor = .secondarySystemGroupedBackground
    layer.borderColor = UIColor.black.cgColor
    layer.cornerRadius = 12

    addSubview(button)
    button.translatesAutoresizingMaskIntoConstraints = false
    button.addTarget(self, action: #selector(buttonTouchUpInside(sender:)), for: .touchUpInside)
    button.addTarget(self, action: #selector(buttonTouchDown(sender:)), for: .touchDown)
    button.addTarget(self, action: #selector(buttonTouchUp(sender:)), for: .touchUpOutside)
    button.addTarget(self, action: #selector(buttonTouchUp(sender:)), for: .touchCancel)
    NSLayoutConstraint.activate([
      button.topAnchor.constraint(equalTo: topAnchor),
      button.bottomAnchor.constraint(equalTo: bottomAnchor),
      button.leadingAnchor.constraint(equalTo: leadingAnchor),
      button.trailingAnchor.constraint(equalTo: trailingAnchor),
    ])
  }
}
