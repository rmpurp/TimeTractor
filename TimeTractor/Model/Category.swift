//
//  Category.swift
//  TimeTractor
//
//  Created by Ryan Purpura on 5/7/20.
//  Copyright © 2020 Ryan Purpura. All rights reserved.
//

import Foundation
import GRDB

struct Category {
    var id: Int64?
    var name: String
    
    static let timeRecords = hasMany(TimeRecord.self)
}

extension Category: Hashable { }


// Turn Player into a Codable Record.
// See https://github.com/groue/GRDB.swift/blob/master/README.md#records
extension Category: Codable, FetchableRecord, MutablePersistableRecord {
    // Define database columns from CodingKeys
    private enum Columns {
        static let id = Column(CodingKeys.id)
        static let name = Column(CodingKeys.name)
    }
    
    // Update a player id after it has been inserted in the database.
    mutating func didInsert(with rowID: Int64, for column: String?) {
        id = rowID
    }
    
    
}

