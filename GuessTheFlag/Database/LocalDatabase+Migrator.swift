//
//  LocalDatabase+Migrator.swift
//  GuessTheFlag
//
//  Created by Mark Hallap on 2025-08-08.
//

import GRDB

extension LocalDatabase {
    /// Defines all schema migrations for the database.
    var migrator: DatabaseMigrator {
        let GAME_SESSION = "gameSession"
        let FLAG_GUESS = "flagGuess"
        
        var migrator = DatabaseMigrator()

        #if DEBUG
        // During development, wipe and recreate the database if schema changes.
        migrator.eraseDatabaseOnSchemaChange = true
        #endif

        migrator.registerMigration("createGameSessionAndFlagGuess") { db in
            try db.create(table: GAME_SESSION) { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("date", .datetime).notNull()
                t.column("score", .integer).notNull()
                t.column("completed", .boolean).notNull().defaults(to: false)
            }

            try db.create(table: FLAG_GUESS) { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("country", .text).notNull()
                t.column("wasCorrect", .boolean).notNull()
                t.belongsTo(GAME_SESSION, onDelete: .cascade).notNull()
                // Automatically creates a foreign key, "gameSessionId"
            }
        }

        return migrator
    }
}
