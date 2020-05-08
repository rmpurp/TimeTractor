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
    var id: Int64?
    var taskName: String?
    var startTime: Date
    var endTime: Date?
    var categoryId: Int64?
    
}

extension TimeRecord: Hashable { }


// Turn Player into a Codable Record.
// See https://github.com/groue/GRDB.swift/blob/master/README.md#records
extension TimeRecord: Codable, FetchableRecord, MutablePersistableRecord {
    // Define database columns from CodingKeys
    private enum Columns {
        static let id = Column(CodingKeys.id)
        static let name = Column(CodingKeys.taskName)
        static let endTime = Column(CodingKeys.startTime)
        static let startTime = Column(CodingKeys.endTime)
        static let categoryId = Column(CodingKeys.categoryId)
    }
    
    // Update a player id after it has been inserted in the database.
    mutating func didInsert(with rowID: Int64, for column: String?) {
        id = rowID
    }
}

extension TimeRecord {
    static let category = hasOne(Category.self)
    var category: QueryInterfaceRequest<Category> {
        request(for: TimeRecord.category)
    }
}

