/*
 See LICENSE folder for this sample’s licensing information.
 
 Abstract:
 Simple example of a self-sizing supplementary title view
 */

import UIKit

class TitleSupplementaryView: UICollectionReusableView {
  let label = UILabel()
  static let reuseIdentifier = "title-supplementary-reuse-identifier"
  let accessoryImageView = UIImageView()

  override init(frame: CGRect) {
    super.init(frame: frame)
    configure()
  }
  required init?(coder: NSCoder) {
    fatalError()
  }
}

extension TitleSupplementaryView {
  func configure() {
    isUserInteractionEnabled = false
    addSubview(label)

    label.translatesAutoresizingMaskIntoConstraints = false
    label.adjustsFontForContentSizeCategory = true
    label.font = UIFont.systemFont(ofSize: 24, weight: .bold)

    let rtl = effectiveUserInterfaceLayoutDirection == .rightToLeft
    let chevronImageName = rtl ? "chevron.left" : "chevron.right"
    let chevronImage = UIImage(systemName: chevronImageName)

    accessoryImageView.translatesAutoresizingMaskIntoConstraints = false
    accessoryImageView.image = chevronImage
    accessoryImageView.tintColor = UIColor.lightGray.withAlphaComponent(0.7)
    addSubview(accessoryImageView)

    let inset = CGFloat(15)
    let bottomInset = CGFloat(5)

    NSLayoutConstraint.activate([
      label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: inset),
      label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -inset),
      label.topAnchor.constraint(equalTo: topAnchor, constant: inset),
      label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -bottomInset),

      accessoryImageView.centerYAnchor.constraint(equalTo: label.centerYAnchor),
      accessoryImageView.widthAnchor.constraint(equalToConstant: 13),
      accessoryImageView.heightAnchor.constraint(equalToConstant: 20),
      accessoryImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -inset),
    ])
  }
}
