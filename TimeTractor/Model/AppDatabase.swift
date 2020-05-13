import GRDB

/// A type responsible for initializing the application database.
///
/// See AppDelegate.setupDatabase()
struct AppDatabase {

  /// Creates a fully initialized database at path.
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

    migrator.registerMigration("createProject") { db in
      try db.create(
        table: "project",
        body: { t in
          t.column("id", .blob).primaryKey()
          t.column("name", .text).notNull()
        })
    }

    migrator.registerMigration("createTimeRecord") { db in
      // Create a table
      // See https://github.com/groue/GRDB.swift#create-tables

      try db.create(table: "timeRecord") { t in
        t.column("id", .blob).primaryKey()

        // Sort player names in a localized case insensitive fashion by default
        // See https://github.com/groue/GRDB.swift/blob/master/README.md#unicode
        t.column("taskName", .text)
        t.column("startTime", .datetime).notNull()
        t.column("endTime", .datetime).notNull()
        t.column("projectId", .blob).notNull()
        t.foreignKey(["projectId"], references: "project", columns: ["id"], onDelete: .cascade, onUpdate: .none, deferred: false)
      }
    }
    
    migrator.registerMigration("createRunningTimer") { db in
      try db.create(table: "runningTimer") { t in
        t.column("id", .blob).primaryKey()
        
        // Sort player names in a localized case insensitive fashion by default
        // See https://github.com/groue/GRDB.swift/blob/master/README.md#unicode
        t.column("taskName", .text)
        t.column("startTime", .datetime).notNull()
        t.column("isActive", .boolean).notNull()
        t.column("projectId", .blob).notNull()
        t.foreignKey(["projectId"], references: "project", columns: ["id"], onDelete: .cascade, onUpdate: .none, deferred: false)
      }
    }
    
    return migrator
  }
}
