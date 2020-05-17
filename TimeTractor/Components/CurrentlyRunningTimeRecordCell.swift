//
//  ProjectListCell.swift
//  TimeTractor
//
//  Created by Ryan Purpura on 5/7/20.
//  Copyright © 2020 Ryan Purpura. All rights reserved.
//

import Combine
import UIKit

@objc protocol CurrentlyRunningTimeRecordCellDelegate {
  func buttonWasPressed(inCurrentlyRunningTimeRecordCell: CurrentlyRunningTimeRecordCell)
}

class CurrentlyRunningTimeRecordCell: UICollectionViewCell {
  weak var delegate: CurrentlyRunningTimeRecordCellDelegate?
  var subscriptions = Set<AnyCancellable>()
  
  @objc func buttonPressed(sender: UIButton) {
    delegate?.buttonWasPressed(inCurrentlyRunningTimeRecordCell: self)
  }
  
  let label = UILabel()
  let button = UIButton(type: .system)
  static let reuseIdentifier = "currently-running-time-record-cell-reuse-identifier"
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    configure()
  }
  
  required init?(coder: NSCoder) {
    fatalError()
  }
}

extension CurrentlyRunningTimeRecordCell {
  func configure() {
    let inset = CGFloat(15)

    label.translatesAutoresizingMaskIntoConstraints = false
    label.adjustsFontForContentSizeCategory = true
    label.textAlignment = .left
    label.setContentHuggingPriority(.defaultLow, for: .horizontal)
    label.font = .monospacedDigitSystemFont(ofSize: 17, weight: .regular)
    contentView.addSubview(label)
    
    button.setImage(UIImage(systemName: "stop.circle.fill"), for: .normal)
    button.translatesAutoresizingMaskIntoConstraints = false
    button.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    button.contentEdgeInsets = UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
    button.addTarget(self, action: #selector(buttonPressed(sender:)), for: .touchUpInside)

    contentView.addSubview(button)
    
    NSLayoutConstraint.activate([
      label.leadingAnchor.constraint(equalTo: button.trailingAnchor),
      label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5),
      label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
      label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
      button.topAnchor.constraint(equalTo: contentView.topAnchor),
      button.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
      button.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
    ])
  }
  
}
