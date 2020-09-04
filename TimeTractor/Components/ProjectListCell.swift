//
//  ProjectListCell.swift
//  TimeTractor
//
//  Created by Ryan Purpura on 5/7/20.
//  Copyright © 2020 Ryan Purpura. All rights reserved.
//

import Combine
import UIKit

@objc protocol ProjectListCellDelegate {
  func buttonWasPressed(in projectListCell: ProjectListCell)
}

class ProjectListCell: UICollectionViewCell {
  weak var delegate: ProjectListCellDelegate?
  var subscriptions = Set<AnyCancellable>()
  
  var accessoryButtonPressed: (() -> Void)?

  @objc func buttonPressed(_ sender: Any) {
//    delegate?.buttonWasPressed(in: self)
    accessoryButtonPressed?()
  }

  let label = UILabel()
  let subtitleLabel = UILabel()

  let accessoryButton = UIButton(type: .system)
  let invisibleSelectionButton = UIButton()

  let separatorView = UIView()
  let leadingView = UIView()

  static let reuseIdentifier = "project-list-cell-reuse-identifier"

  override init(frame: CGRect) {
    super.init(frame: frame)
    configureAccessoryButton()
    configure()
    configureInvisibleSelectionButton()
    contentView.bringSubviewToFront(accessoryButton)
  }

  required init?(coder: NSCoder) {
    fatalError()
  }
}

extension ProjectListCell {
  @objc func invisibleSelectionButtonTouchUpInside(_ sender: Any) {
    invisibleSelectionButtonTouchCancelled(sender)
    delegate?.buttonWasPressed(in: self)
  }

  @objc func invisibleSelectionButtonTouchCancelled(_ sender: Any) {
    UIView.animate(withDuration: 0.1) {
      Appearance.CardCell.applyUnpressed(on: self.contentView)
    }
  }

  @objc func invisibleSelectionButtonTouchDown(_ sender: Any) {
    UIView.animate(withDuration: 0.1) {
      Appearance.CardCell.applyPressed(
        on: self.contentView, darkMode: self.traitCollection.userInterfaceStyle == .dark)
    }
  }

}

extension ProjectListCell {
  func configureInvisibleSelectionButton() {
    contentView.addSubview(invisibleSelectionButton)
    invisibleSelectionButton.translatesAutoresizingMaskIntoConstraints = false
    invisibleSelectionButton.addTarget(
      self, action: #selector(invisibleSelectionButtonTouchUpInside(_:)), for: .touchUpInside)

    invisibleSelectionButton.addTarget(
      self, action: #selector(invisibleSelectionButtonTouchCancelled(_:)),
      for: [.touchUpOutside, .touchDragOutside, .touchCancel])

    invisibleSelectionButton.addTarget(
      self, action: #selector(invisibleSelectionButtonTouchDown(_:)),
      for: [.touchDown, .touchDragEnter])

    NSLayoutConstraint.activate([
      invisibleSelectionButton.leadingAnchor.constraint(equalTo: label.leadingAnchor),
      invisibleSelectionButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
      invisibleSelectionButton.topAnchor.constraint(equalTo: contentView.topAnchor),
      invisibleSelectionButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
    ])
  }
  
  func configureAccessoryButton() {
    let inset: CGFloat = 15

    let image = UIImage(
      systemName: "ellipsis.circle.fill")
    accessoryButton.setImage(image, for: .normal)
    accessoryButton.translatesAutoresizingMaskIntoConstraints = false
    accessoryButton.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    accessoryButton.contentEdgeInsets = UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
    accessoryButton.addTarget(self, action: #selector(buttonPressed(_:)), for: .touchUpInside)
    contentView.addSubview(accessoryButton)
    
    NSLayoutConstraint.activate([
      accessoryButton.topAnchor.constraint(equalTo: contentView.topAnchor),
      accessoryButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
      accessoryButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
])
    
  }

  func configure() {
    let inset: CGFloat = 15

    label.translatesAutoresizingMaskIntoConstraints = false
    label.adjustsFontForContentSizeCategory = true
    label.textAlignment = .left
    label.setContentHuggingPriority(.defaultLow, for: .horizontal)
    contentView.addSubview(label)

    subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
    subtitleLabel.adjustsFontForContentSizeCategory = true
    subtitleLabel.textAlignment = .right
    subtitleLabel.textColor = .secondaryLabel
    subtitleLabel.numberOfLines = 2
    subtitleLabel.font = .monospacedDigitSystemFont(ofSize: 12, weight: .regular)

    contentView.addSubview(subtitleLabel)

    separatorView.translatesAutoresizingMaskIntoConstraints = false
    separatorView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
    contentView.addSubview(separatorView)

    leadingView.translatesAutoresizingMaskIntoConstraints = false
    leadingView.backgroundColor = .systemBlue
    contentView.addSubview(leadingView)

    NSLayoutConstraint.activate([
      label.leadingAnchor.constraint(equalTo: leadingView.trailingAnchor, constant: inset),
      label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
      label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),

      separatorView.leadingAnchor.constraint(
        equalTo: label.leadingAnchor, constant: inset),
      separatorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
      separatorView.trailingAnchor.constraint(
        equalTo: accessoryButton.leadingAnchor, constant: 0),
      separatorView.heightAnchor.constraint(equalToConstant: 0.5),

      leadingView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: inset / 2),
      leadingView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -inset / 2),
      leadingView.widthAnchor.constraint(equalToConstant: 2),
      leadingView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: inset),

      subtitleLabel.leadingAnchor.constraint(equalTo: label.trailingAnchor, constant: 10),
      subtitleLabel.trailingAnchor.constraint(equalTo: accessoryButton.leadingAnchor),
      subtitleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
      subtitleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
    ])
  }

}
