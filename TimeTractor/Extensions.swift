//
//  Extensions.swift
//  TimeTractor
//
//  Created by Ryan Purpura on 5/14/20.
//  Copyright © 2020 Ryan Purpura. All rights reserved.
//

import Foundation

extension Sequence {
  func sorted<T: Comparable>(by keyPath: KeyPath<Element, T>) -> [Element] {
    return sorted { a, b in
      return a[keyPath: keyPath] < b[keyPath: keyPath]
    }
  }
}
