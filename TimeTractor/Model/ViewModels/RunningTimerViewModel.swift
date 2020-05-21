//
//  RunningTimerViewModel.swift
//  TimeTractor
//
//  Created by Ryan Purpura on 5/17/20.
//  Copyright © 2020 Ryan Purpura. All rights reserved.
//

import Foundation

struct RunningTimerViewModel {
  private let runningTimerInfo: RunningTimerInfo
  var id: UUID { runningTimerInfo.runningTimer.id }
  var taskName: String { runningTimerInfo.runningTimer.taskName ?? "No task name" }
  var projectName: String { runningTimerInfo.project.name }

  func timeDisplay(at date: Date) -> String {
    return "\(date.timeIntervalSince(runningTimerInfo.runningTimer.startTime).asFormattedTime)"
  }

  init(runningTimerInfo: RunningTimerInfo) {
    self.runningTimerInfo = runningTimerInfo
  }
}

extension RunningTimerViewModel: Hashable {}
