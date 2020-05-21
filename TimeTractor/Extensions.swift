//
//  Extensions.swift
//  TimeTractor
//
//  Created by Ryan Purpura on 5/14/20.
//  Copyright © 2020 Ryan Purpura. All rights reserved.
//

import Foundation
import UIKit

extension Sequence {
  func sorted<T: Comparable>(by keyPath: KeyPath<Element, T>) -> [Element] {
    return sorted { a, b in
      return a[keyPath: keyPath] < b[keyPath: keyPath]
    }
  }
}

extension UIColor {
  func desaturate(by: CGFloat) -> UIColor {
    var h: CGFloat = 0
    var s: CGFloat = 0
    var b: CGFloat = 0
    var a: CGFloat = 0
    self.getHue(&h, saturation: &s, brightness: &b, alpha: &a)

    return UIColor(hue: h, saturation: s * (1 - by), brightness: b, alpha: a)
  }

  func darken(by: CGFloat) -> UIColor {
    var h: CGFloat = 0
    var s: CGFloat = 0
    var b: CGFloat = 0
    var a: CGFloat = 0
    self.getHue(&h, saturation: &s, brightness: &b, alpha: &a)

    return UIColor(hue: h, saturation: s, brightness: b * (1 - by), alpha: a)
  }

  func lighten(by: CGFloat) -> UIColor {
    var h: CGFloat = 0
    var s: CGFloat = 0
    var b: CGFloat = 0
    var a: CGFloat = 0
    self.getHue(&h, saturation: &s, brightness: &b, alpha: &a)

    return UIColor(hue: h, saturation: s, brightness: b * (1 + by), alpha: a)
  }

  func modify(by amount: CGFloat, isDarkMode: Bool) -> UIColor {
    return isDarkMode ? lighter! : darker!
  }

}

extension UIColor {
  convenience init(hue: CGFloat, saturation: CGFloat, lightness: CGFloat, alpha: CGFloat = 1) {
    let offset = saturation * (lightness < 0.5 ? lightness : 1 - lightness)
    let brightness = lightness + offset
    let saturation = lightness > 0 ? 2 * offset / brightness : 0
    self.init(hue: hue, saturation: saturation, brightness: brightness, alpha: alpha)
  }

  var lighter: UIColor? {
    return applying(lightness: 1.25)
  }

  var darker: UIColor? {
    return applying(lightness: 0.9)
  }

  func applying(lightness value: CGFloat) -> UIColor? {
    guard let hsl = hsl else { return nil }
    return UIColor(
      hue: hsl.hue, saturation: hsl.saturation, lightness: hsl.lightness * value, alpha: hsl.alpha)
  }
  var hsl: (hue: CGFloat, saturation: CGFloat, lightness: CGFloat, alpha: CGFloat)? {
    var red: CGFloat = 0
    var green: CGFloat = 0
    var blue: CGFloat = 0
    var alpha: CGFloat = 0
    var hue: CGFloat = 0
    guard
      getRed(&red, green: &green, blue: &blue, alpha: &alpha),
      getHue(&hue, saturation: nil, brightness: nil, alpha: nil)
    else { return nil }
    let upper = max(red, green, blue)
    let lower = min(red, green, blue)
    let range = upper - lower
    let lightness = (upper + lower) / 2
    let saturation = range == 0 ? 0 : range / (lightness < 0.5 ? lightness * 2 : 2 - lightness * 2)
    return (hue, saturation, lightness, alpha)
  }
}
