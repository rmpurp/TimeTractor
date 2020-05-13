//
//  TimeRecordController.swift
//  TimeTractor
//
//  Created by Ryan Purpura on 5/11/20.
//  Copyright © 2020 Ryan Purpura. All rights reserved.
//

import Foundation
import Combine
import GRDB
import GRDBCombine

class TimeRecordController {
  func getTimeRecordPublisher(for id: UUID) -> AnyPublisher<Int, Error> {
    let timeRecordObservation = ValueObservation.tracking { db in
      return try! TimeRecord.filter(Column("projectId") == id).fetchCount(db)
    }
    
    return timeRecordObservation.publisher(in: dbQueue).eraseToAnyPublisher()
  }
  
  func getAllProjectsPublisher() -> AnyPublisher<[Project], Error> {
    let observation = ValueObservation.tracking(value: Project.fetchAll)
    return observation.publisher(in: dbQueue).eraseToAnyPublisher()
  }
  
  func getProjectInfoPublisher(for id: UUID) -> AnyPublisher<String, Error> {
    let timeRecordObservation = ValueObservation.tracking { db in
      return try! TimeRecord.filter(Column("projectId") == id).fetchCount(db)
    }
    
    return timeRecordObservation.publisher(in: dbQueue)
      .map { String($0) }
      .eraseToAnyPublisher()
  }
  
  func getRunningTimerPublisher() -> AnyPublisher<RunningTimerInfo?, Error> {
    let currentlyRunningObservation = ValueObservation.tracking { db -> RunningTimerInfo? in
      let request = RunningTimer.filter(Column("isActive") == true).including(required: RunningTimer.project)
      return try RunningTimerInfo.fetchOne(db, request)
    }
    return currentlyRunningObservation.publisher(in: dbQueue)
      .eraseToAnyPublisher()
  }
  
  func complete(runningTimer: RunningTimer, at date: Date) {
    try! dbQueue.write { db in
        var timeRecord = TimeRecord(taskName: runningTimer.taskName, startTime: runningTimer.startTime, endTime: date, projectId: runningTimer.projectId)
        try runningTimer.delete(db)
        try timeRecord.insert(db)
    }
  }
}


