//
//  TimeRecordInfo.swift
//  TimeTractor
//
//  Created by Ryan Purpura on 5/12/20.
//  Copyright © 2020 Ryan Purpura. All rights reserved.
//

import Foundation
import GRDB

struct TimeRecordInfo: FetchableRecord, Decodable {
  var timeRecord: TimeRecord
  var project: Project
}

extension TimeRecordInfo: Hashable { }
