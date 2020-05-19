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
  //  func getTimeRecordPublisher(for id: UUID) -> AnyPublisher<Int, Error> {
  //    let timeRecordObservation = ValueObservation.tracking { db in
  //      return try! TimeRecord.filter(Column("projectId") == id).fetchCount(db)
  //    }
  //
  //    return timeRecordObservation.publisher(in: dbQueue).eraseToAnyPublisher()
  //  }
  //
  //  func getAllProjectsPublisher() -> AnyPublisher<[Project], Error> {
  //    let observation = ValueObservation.tracking(value: Project.fetchAll)
  //    return observation.publisher(in: dbQueue).eraseToAnyPublisher()
  //  }
  //
  //  func getProjectInfoPublisher(for id: UUID) -> AnyPublisher<String, Error> {
  //    let timeRecordObservation = ValueObservation.tracking { db in
  //      return try! TimeRecord.filter(Column("projectId") == id).fetchCount(db)
  //    }
  //
  //    return timeRecordObservation.publisher(in: dbQueue)
  //      .map { String($0) }
  //      .eraseToAnyPublisher()
  //  }

  //  func getProjectViewModels(date: Date) -> AnyPublisher<[ProjectViewModel], Error> {
  //    let lastWeek = date.addingTimeInterval(-3600 * 24 * 7)
  //    let observation = ValueObservation.tracking { db -> [ProjectViewModel] in
  //      let projects = try Project.fetchAll(db)
  //      return try projects.map { project in
  //        let lastWeekTime = try Int.fetchOne(db, sql: """
  //            SELECT sum(strftime('%s', endTime) - strftime('%s', startTime))
  //            FROM timeRecord
  //            WHERE (projectId = ?) and (strftime('%s', endTime) > strftime('%s', ?))
  //          """,
  //
  //          arguments: [project.id, lastWeek])
  //        var statusMessage = ""
  //        if let lastWeekTime = lastWeekTime {
  //            statusMessage = "\(lastWeekTime) sec\nlast week"
  //        }
  //        return ProjectViewModel(project: project, statusMessage: statusMessage)
  //      }
  //    }
  //    return observation.publisher(in: dbQueue).eraseToAnyPublisher()
  //  }

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
        let lastWeekTime = try Int.fetchOne(
          db,
          sql: """
              SELECT sum(strftime('%s', endTime) - strftime('%s', startTime))
              FROM timeRecord
              WHERE (projectId = ?) and (strftime('%s', endTime) > strftime('%s', ?))
            """,

          arguments: [project.id, lastWeek])
        var statusMessage = ""
        if let lastWeekTime = lastWeekTime {
          statusMessage = "\(lastWeekTime) sec\nlast week"
        }
        return ProjectViewModel(project: project, statusMessage: statusMessage)
      }

      return (timerViewModel, projectViewModels)
    }
    return observation.publisher(in: dbQueue).eraseToAnyPublisher()

  }
  //
  //  func getRunningTimerPublisher() -> AnyPublisher<RunningTimerViewModel?, Error> {
  //    let currentlyRunningObservation = ValueObservation.tracking { db -> RunningTimerViewModel? in
  //      let request = RunningTimer.filter(Column("isActive") == true).including(
  //        required: RunningTimer.project)
  //      if let runningTimerInfo = try RunningTimerInfo.fetchOne(db, request) {
  //        return RunningTimerViewModel(runningTimerInfo: runningTimerInfo)
  //      } else {
  //        return nil
  //      }
  //    }
  //    return currentlyRunningObservation.publisher(in: dbQueue)
  //      .eraseToAnyPublisher()
  //  }

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
}
