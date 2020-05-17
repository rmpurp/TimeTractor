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

  @objc func buttonPressed(sender: UIButton) {
    delegate?.buttonWasPressed(in: self)
  }

  let label = UILabel()
  let subtitleLabel = UILabel()
  
  let button = UIButton(type: .system)
  let separatorView = UIView()
  let accessoryImageView = UIImageView()

  static let reuseIdentifier = "project-list-cell-reuse-identifier"

  override init(frame: CGRect) {
    super.init(frame: frame)
    configure()
  }

  required init?(coder: NSCoder) {
    fatalError()
  }
}

extension ProjectListCell {
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
    if arc4random() % 10 < 2 {
    subtitleLabel.text = "5:35\ntoday"
    }
    subtitleLabel.textColor = .secondaryLabel
    subtitleLabel.numberOfLines = 2
    subtitleLabel.font = .monospacedDigitSystemFont(ofSize: 12, weight: .regular)
    
//    subtitleLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
    contentView.addSubview(subtitleLabel)

//    button.setTitle("Start", for: .normal)
    button.setImage(UIImage(systemName: "play.circle.fill"), for: .normal)
    button.translatesAutoresizingMaskIntoConstraints = false
    button.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    button.contentEdgeInsets = UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)

    button.addTarget(self, action: #selector(buttonPressed(sender:)), for: .touchUpInside)
    contentView.addSubview(button)

    
    separatorView.translatesAutoresizingMaskIntoConstraints = false
    separatorView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
    contentView.addSubview(separatorView)
    
    let rtl = effectiveUserInterfaceLayoutDirection == .rightToLeft
    let chevronImageName = rtl ? "chevron.left" : "chevron.right"
    let chevronImage = UIImage(systemName: chevronImageName)
    
    accessoryImageView.translatesAutoresizingMaskIntoConstraints = false
    accessoryImageView.image = chevronImage
    accessoryImageView.tintColor = UIColor.lightGray.withAlphaComponent(0.7)
    accessoryImageView.isHidden = true
    contentView.addSubview(accessoryImageView)
    
    NSLayoutConstraint.activate([
      label.leadingAnchor.constraint(equalTo: button.trailingAnchor),
      label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
      label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),

      button.topAnchor.constraint(equalTo: contentView.topAnchor),
      button.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
      button.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),

      separatorView.leadingAnchor.constraint(equalTo: button.trailingAnchor, constant: 0),
      separatorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
      separatorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
      separatorView.heightAnchor.constraint(equalToConstant: 0.5),
      
      subtitleLabel.leadingAnchor.constraint(equalTo: label.trailingAnchor, constant: 10),
      subtitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
      subtitleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
      subtitleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),

//      accessoryImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
//      accessoryImageView.widthAnchor.constraint(equalToConstant: 13),
//      accessoryImageView.heightAnchor.constraint(equalToConstant: 20),
//      accessoryImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -inset),
    ])
  }

}
