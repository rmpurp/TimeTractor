import GRDB

/// A type responsible for initializing the application database.
///
/// See AppDelegate.setupDatabase()
struct AppDatabase {
    
    /// Creates a fully initialized database at path
    static func openDatabase(atPath path: String) throws -> DatabaseQueue {
        let dbQueue = try DatabaseQueue(path: path)
        try migrator.migrate(dbQueue)
        return dbQueue
    }
    
    /// The DatabaseMigrator that defines the database schema.
    ///
    /// See https://github.com/groue/GRDB.swift/blob/master/Documentation/Migrations.md
    static var migrator: DatabaseMigrator {
        var migrator = DatabaseMigrator()
        
        migrator.registerMigration("createCategory") { db in
            try db.create(table: "category", body: { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("name")
            })
        }
        
        migrator.registerMigration("createTimeRecord") { db in
            // Create a table
            // See https://github.com/groue/GRDB.swift#create-tables
            
            try db.create(table: "timeRecord") { t in
                t.autoIncrementedPrimaryKey("id")
                
                // Sort player names in a localized case insensitive fashion by default
                // See https://github.com/groue/GRDB.swift/blob/master/README.md#unicode
                t.column("taskName", .text)
                t.column("startTime", .datetime)
                t.column("endTime", .datetime)
                t.column("categoryId", .integer).references(
                    "category",
                    column: "id",
                    onDelete: .cascade,
                    onUpdate: .none,
                    deferred: false)
            }
        }
        
        migrator.registerMigration("fixtures") { db in
            // Populate the players table with random data
//            for _ in 0..<8 {
//                var player = Player(id: nil, name: Player.randomName(), score: Player.randomScore())
//                try player.insert(db)
//            }
        }
        
//        // Migrations for future application versions will be inserted here:
//        migrator.registerMigration(...) { db in
//            ...
//        }
        
        return migrator
    }
}

