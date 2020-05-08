//
//  Project.swift
//  TimeTractor
//
//  Created by Ryan Purpura on 5/7/20.
//  Copyright © 2020 Ryan Purpura. All rights reserved.
//

import Foundation
import GRDB

struct Project {
  var id: UUID = UUID()
  var name: String

  static let timeRecords = hasMany(TimeRecord.self)
}

extension Project: Hashable {}

// Turn Player into a Codable Record.
// See https://github.com/groue/GRDB.swift/blob/master/README.md#records
extension Project: Codable, FetchableRecord, MutablePersistableRecord {
  // Define database columns from CodingKeys
  private enum Columns {
    static let id = Column(CodingKeys.id)
    static let name = Column(CodingKeys.name)
  }
}
