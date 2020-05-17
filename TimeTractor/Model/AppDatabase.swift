import Foundation
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

    //    #if DEBUG
    //    migrator.registerMigration("dropTables") { db in
    //      try db.execute(sql: "DROP TABLE IF EXISTS project")
    //      try db.execute(sql: "DROP TABLE IF EXISTS timeRecord")
    //      try db.execute(sql: "DROP TABLE IF EXISTS runningTimer")
    //    }
    //    #endif

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
        t.foreignKey(
          ["projectId"], references: "project", columns: ["id"], onDelete: .cascade,
          onUpdate: .none, deferred: false)
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
        t.foreignKey(
          ["projectId"], references: "project", columns: ["id"], onDelete: .cascade,
          onUpdate: .none, deferred: false)
      }
    }

    #if DEBUG
      migrator.registerMigration("debugCreateCategories") { db in
        NSLog("Creating debug categories...")
        var cat1 = Project(name: "Cook")
        var cat2 = Project(name: "Sleep")
        var cat3 = Project(name: "CS 195")
        var cat4 = Project(name: "CS 189")
        var cat5 = Project(name: "EE 120")

        try cat1.insert(db)
        try cat2.insert(db)
        try cat3.insert(db)
        try cat4.insert(db)
        try cat5.insert(db)
      }
    #endif

    return migrator
  }
}
