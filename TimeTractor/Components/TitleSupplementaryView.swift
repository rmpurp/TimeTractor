/*
 See LICENSE folder for this sample’s licensing information.
 
 Abstract:
 Simple example of a self-sizing supplementary title view
 */

import UIKit

class TitleSupplementaryView: UICollectionReusableView {
  static let reuseIdentifier = "title-supplementary-reuse-identifier"

  let label = UILabel()
  let accessory = UIImageView()

  override init(frame: CGRect) {
    super.init(frame: frame)

    isUserInteractionEnabled = false
    configureLabel()
    configureAccessoryImageView()
  }

  required init?(coder: NSCoder) {
    fatalError()
  }
}

// MARK: - Configuration
extension TitleSupplementaryView {
  func configureLabel() {
    addSubview(label)
    label.translatesAutoresizingMaskIntoConstraints = false
    label.adjustsFontForContentSizeCategory = true
    label.font = UIFont.systemFont(ofSize: 24, weight: .bold)

    NSLayoutConstraint.activate([
      label.leadingAnchor.constraint(
        equalTo: leadingAnchor, constant: Appearance.CardTitle.leadingInset),
      label.trailingAnchor.constraint(
        equalTo: trailingAnchor, constant: Appearance.CardTitle.trailingInset),
      label.topAnchor.constraint(equalTo: topAnchor, constant: Appearance.CardTitle.topInset),
      label.bottomAnchor.constraint(
        equalTo: bottomAnchor, constant: Appearance.CardTitle.bottomInset),
    ])
  }

  func configureAccessoryImageView() {
    let rtl = effectiveUserInterfaceLayoutDirection == .rightToLeft
    let chevronImageName = rtl ? "chevron.left" : "chevron.right"
    let chevronImage = UIImage(systemName: chevronImageName)

    accessory.translatesAutoresizingMaskIntoConstraints = false
    accessory.image = chevronImage
    accessory.tintColor = Appearance.Cheveron.tintColor
    addSubview(accessory)

    NSLayoutConstraint.activate([
      accessory.centerYAnchor.constraint(equalTo: label.centerYAnchor),
      accessory.widthAnchor.constraint(equalToConstant: Appearance.Cheveron.width),
      accessory.heightAnchor.constraint(equalToConstant: Appearance.Cheveron.height),
      accessory.trailingAnchor.constraint(
        equalTo: trailingAnchor, constant: Appearance.CardTitle.trailingInset),
    ])
  }
}
