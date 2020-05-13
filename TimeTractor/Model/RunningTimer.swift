//
//  TimeRecord.swift
//  TimeTractor
//
//  Created by Ryan Purpura on 5/7/20.
//  Copyright © 2020 Ryan Purpura. All rights reserved.
//

import Foundation
import GRDB

struct RunningTimer {
  var id: UUID = UUID()
  var taskName: String?
  var startTime: Date
  var isActive: Bool
  var projectId: UUID
}

extension RunningTimer: Hashable {}

// Turn Player into a Codable Record.
// See https://github.com/groue/GRDB.swift/blob/master/README.md#records
extension RunningTimer: Codable, FetchableRecord, MutablePersistableRecord {
  // Define database columns from CodingKeys
  private enum Columns {
    static let id = Column(CodingKeys.id)
    static let name = Column(CodingKeys.taskName)
    static let endTime = Column(CodingKeys.startTime)
    static let projectId = Column(CodingKeys.projectId)
    static let isActive = Column(CodingKeys.isActive)
  }
}

extension RunningTimer {
  static let project = belongsTo(Project.self)
  
  var project: QueryInterfaceRequest<Project> {
    request(for: RunningTimer.project)
  }
}
