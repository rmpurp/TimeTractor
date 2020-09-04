//
//  ProjectViewModel.swift
//  TimeTractor
//
//  Created by Ryan Purpura on 5/27/20.
//  Copyright © 2020 Ryan Purpura. All rights reserved.
//

import Foundation
import GRDB
import Combine
import GRDBCombine

class TimeTractorViewModel: ObservableObject {
  private struct TimeTractorData {
    var runningTimer: RunningTimerViewModel?
    var projects: [ProjectViewModel]
    
    static let empty = TimeTractorData(runningTimer: nil, projects: [])
  }
  
  private var subscriptions: Set<AnyCancellable> = Set()
  @Published private var timeTractorData: TimeTractorData = .empty
  
  init() {
    createDataPublisher(date: Date())
      .catch { _ in Empty() }
      .sink { [unowned self] in self.timeTractorData = $0 }
      .store(in: &subscriptions)
  }
  
  private func createDataPublisher(date: Date) -> AnyPublisher<TimeTractorData, Error> {
    let observation = ValueObservation.tracking {
      db -> TimeTractorData in
      let request = RunningTimer.filter(Column("isActive") == true).including(
        required: RunningTimer.project)
      
      var timerViewModel: RunningTimerViewModel? = nil
      if let runningTimerInfo = try RunningTimerInfo.fetchOne(db, request) {
        timerViewModel = RunningTimerViewModel(runningTimerInfo: runningTimerInfo)
      }
      
      let yesterday = date.addingTimeInterval(-3600 * 24)
      let lastWeek = date.addingTimeInterval(-3600 * 24 * 7)
      
      let projects = try Project.fetchAll(db)
      let projectViewModels = try projects.map { project -> ProjectViewModel in
        var statusMessage = ""
        
        let yesterdayTime = try Int.fetchOne(
          db,
          sql: """
              SELECT sum(strftime('%s', endTime) - strftime('%s', startTime))
              FROM timeRecord
              WHERE (projectId = ?) and (strftime('%s', endTime) > strftime('%s', ?))
            """,
          arguments: [project.id, yesterday])
        
        if let yesterdayTime = yesterdayTime, yesterdayTime > 0 {
          statusMessage = "\(yesterdayTime.asFormattedTime) \ntoday"
        } else {
          let lastWeekTime = try Int.fetchOne(
            db,
            sql: """
                SELECT sum(strftime('%s', endTime) - strftime('%s', startTime))
                FROM timeRecord
                WHERE (projectId = ?) and (strftime('%s', endTime) > strftime('%s', ?))
              """,
            arguments: [project.id, lastWeek])
          if let lastWeekTime = lastWeekTime, lastWeekTime > 0 {
            statusMessage = "\(lastWeekTime.asFormattedTime) \nthis week"
          }
        }
        
        return ProjectViewModel(project: project, referenceDate: date, recentTimeRecords: [])
      }
      return TimeTractorData(runningTimer: timerViewModel, projects: projectViewModels)
    }
    return observation.publisher(in: dbQueue)
      .eraseToAnyPublisher()
    
  }
  
  var runningTimer: RunningTimerViewModel? { timeTractorData.runningTimer }
  var projects: [ProjectViewModel] { timeTractorData.projects }
}

// MARK: - Intents
extension TimeTractorViewModel {
  
  func start(project: ProjectViewModel) {
    try! dbQueue.write { db in
      try TimeRecord.filter(Column("currentlyRunning") == true).deleteAll(db)
      try RunningTimer.filter(Column("isActive") == true).updateAll(
        db, Column("isActive").set(to: false))
      var runningTimer = RunningTimer(startTime: Date(), isActive: true, projectId: project.id)
      try! runningTimer.insert(db)
    }    
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
