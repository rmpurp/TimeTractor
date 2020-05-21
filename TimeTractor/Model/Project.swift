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
}

extension Project: Hashable {}

extension Project: Codable, FetchableRecord, MutablePersistableRecord {
  private enum Columns {
    static let id = Column(CodingKeys.id)
    static let name = Column(CodingKeys.name)
  }
}

extension Project {
  static let timeRecords = hasMany(TimeRecord.self)

  var timeRecords: QueryInterfaceRequest<TimeRecord> {
    request(for: Project.timeRecords)
  }

}
