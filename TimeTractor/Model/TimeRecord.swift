//
//  TimeRecord.swift
//  TimeTractor
//
//  Created by Ryan Purpura on 5/7/20.
//  Copyright © 2020 Ryan Purpura. All rights reserved.
//

import Foundation
import GRDB

struct TimeRecord {
  var id: UUID = UUID()
  var taskName: String?
  var startTime: Date
  var endTime: Date?
  var projectId: UUID
}

extension TimeRecord: Hashable {}

// Turn Player into a Codable Record.
// See https://github.com/groue/GRDB.swift/blob/master/README.md#records
extension TimeRecord: Codable, FetchableRecord, MutablePersistableRecord {
  // Define database columns from CodingKeys
  private enum Columns {
    static let id = Column(CodingKeys.id)
    static let name = Column(CodingKeys.taskName)
    static let endTime = Column(CodingKeys.startTime)
    static let startTime = Column(CodingKeys.endTime)
    static let projectId = Column(CodingKeys.projectId)
  }
}

extension TimeRecord {
  static let project = hasOne(Project.self)
  var project: QueryInterfaceRequest<Project> {
    request(for: TimeRecord.project)
  }
}
