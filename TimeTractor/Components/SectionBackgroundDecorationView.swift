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

// MARK: - Button Targets
extension SectionBackgroundDecorationView {
  @objc func buttonTouchUpInside(sender: UIButton) {
    buttonTouchUp(sender: sender)
  }

  @objc func buttonTouchUp(sender: UIButton) {
    UIView.animate(withDuration: 0.1) {
      Appearance.Card.applyUnpressed(on: self)
    }
  }

  @objc func buttonTouchDown(sender: UIButton) {
    UIView.animate(withDuration: 0.1) {

      Appearance.Card.applyPressed(
        on: self, darkMode: self.traitCollection.userInterfaceStyle == .dark)
    }
  }
}
// MARK: - Configuration
extension SectionBackgroundDecorationView {
  func configure() {
    Appearance.Card.apply(on: self)

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
