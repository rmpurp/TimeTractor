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
    
    label.layer.borderWidth = 1.0
    label.backgroundColor = .secondarySystemBackground
    label.translatesAutoresizingMaskIntoConstraints = false
    label.adjustsFontForContentSizeCategory = true
    label.textAlignment = .center
    label.setContentHuggingPriority(.defaultLow, for: .horizontal)
    contentView.addSubview(label)
    
    button.setTitle("Stop", for: .normal)
    button.translatesAutoresizingMaskIntoConstraints = false
    button.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    button.backgroundColor = .secondarySystemBackground
    button.layer.borderWidth = 1.0
    button.addTarget(self, action: #selector(buttonPressed(sender:)), for: .touchUpInside)
    contentView.addSubview(button)
    
    NSLayoutConstraint.activate([
      label.leadingAnchor.constraint(equalTo: button.trailingAnchor, constant: 5),
      label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5),
      label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
      label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
      button.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
      button.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
      button.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5),
    ])
  }
  
}
