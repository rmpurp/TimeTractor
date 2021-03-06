//
//  TimeRecordController.swift
//  TimeTractor
//
//  Created by Ryan Purpura on 5/11/20.
//  Copyright © 2020 Ryan Purpura. All rights reserved.
//

import Combine
import Foundation
import GRDB
import GRDBCombine

class TimeRecordController {
  /// Since one action may update multiple things at once, we don't want multiple redundant updates flying to the data source
  func getDataPublisher(date: Date) -> AnyPublisher<
    (RunningTimerViewModel?, [ProjectViewModel]), Error
  > {
    let observation = ValueObservation.tracking {
      db -> (RunningTimerViewModel?, [ProjectViewModel]) in
      let request = RunningTimer.filter(Column("isActive") == true).including(
        required: RunningTimer.project)

      var timerViewModel: RunningTimerViewModel? = nil
      if let runningTimerInfo = try RunningTimerInfo.fetchOne(db, request) {
        timerViewModel = RunningTimerViewModel(runningTimerInfo: runningTimerInfo)
      }

      let lastWeek = date.addingTimeInterval(-3600 * 24 * 7)

      let projects = try Project.fetchAll(db)
      let projectViewModels = try projects.map { project -> ProjectViewModel in
        
        let recentTimeRecords = try TimeRecord.fetchAll(db, sql: """
          SELECT *
          FROM timeRecord
          WHERE (projectId = ?) AND (strftime('%s', endTime) > strftime('%s', ?))
        """, arguments: [project.id, lastWeek])

        return ProjectViewModel(project: project, referenceDate: date, recentTimeRecords: recentTimeRecords)
      }
      return (timerViewModel, projectViewModels)
    }
    return observation.publisher(in: dbQueue).eraseToAnyPublisher()

  }

  func complete(runningTimerId: UUID, at date: Date) {
    try! dbQueue.write { db in
      guard let runningTimer = try RunningTimer.fetchOne(db, key: runningTimerId) else { return }

      var timeRecord = TimeRecord(
        taskName: runningTimer.taskName, startTime: runningTimer.startTime, endTime: date,
        projectId: runningTimer.projectId)
      try runningTimer.delete(db)
      try timeRecord.insert(db)
    }
  }
  
  func update(projectViewModel: ProjectViewModel) {
    try! dbQueue.write { db in
      try projectViewModel.project.update(db)
    }
  }
  
  func delete(projectViewModel: ProjectViewModel) {
    _ = try! dbQueue.write { db in
      try projectViewModel.project.delete(db)
    }
  }

  func cancel(runningTimerId: UUID) {
    try! dbQueue.write { db in
      guard let runningTimer = try RunningTimer.fetchOne(db, key: runningTimerId) else { return }
      try runningTimer.delete(db)
    }
  }
}
