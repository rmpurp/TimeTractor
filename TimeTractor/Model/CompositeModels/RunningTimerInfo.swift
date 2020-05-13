//
//  RunningTimerInfo.swift
//  TimeTractor
//
//  Created by Ryan Purpura on 5/12/20.
//  Copyright © 2020 Ryan Purpura. All rights reserved.
//

import Foundation
import GRDB

struct RunningTimerInfo: FetchableRecord, Decodable {
  var runningTimer: RunningTimer
  var project: Project
}

extension RunningTimerInfo: Hashable { }
