//
//  ProjectViewModel.swift
//  TimeTractor
//
//  Created by Ryan Purpura on 5/17/20.
//  Copyright © 2020 Ryan Purpura. All rights reserved.
//

import Foundation

struct ProjectViewModel: Identifiable {
  private(set) var project: Project
  //  private var seconds: Double
  
  var statusMessage: String = ""
  
  var referenceDate: Date {
    didSet {
      statusMessage = getStatusMessage()
    }
  }
  
  private func getStatusMessage() -> String {
    let yesterday = self.referenceDate.addingTimeInterval(-3600 * 24)
    let yesterdayAmount = self.recentTimeRecords.filter {$0.startTime >= yesterday}
      .reduce(0) { $0 + $1.endTime.timeIntervalSince(max($1.startTime, yesterday))}
    if yesterdayAmount > 0 {
      return "\(yesterdayAmount.asFormattedTime)\ntoday"
    }
    let lastWeekAmount = self.recentTimeRecords.reduce(0) { $0 + $1.endTime.timeIntervalSince($1.startTime)}
    if lastWeekAmount > 0 {
      return "\(lastWeekAmount.asFormattedTime)\nthis week"
    }
    
    return ""
  }
  
  private var recentTimeRecords: [TimeRecord]
  
  var name: String {
    get {
      project.name
    } set(newValue) {
      project.name = newValue
    }
  }
  var id: UUID { project.id }
  
  init(project: Project, referenceDate: Date, recentTimeRecords: [TimeRecord]) {
    self.project = project
    self.referenceDate = referenceDate
    self.recentTimeRecords = recentTimeRecords
    self.statusMessage = getStatusMessage()
  }
}

extension ProjectViewModel: Hashable {
  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
  
  static func == (lhs: ProjectViewModel, rhs: ProjectViewModel) -> Bool {
    return lhs.id == rhs.id
  }
}
