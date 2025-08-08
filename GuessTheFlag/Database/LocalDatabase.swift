//
//  LocalDatabase.swift
//  GuessTheFlag
//
//  Created by Mark Hallap on 2025-08-08.
//

import Foundation
import GRDB

struct LocalDatabase {
    private let writer: DatabaseWriter

    var reader: DatabaseReader {
        writer
    }

    // Initialize the database and run migrations.
    init(_ writer: DatabaseWriter) throws {
        self.writer = writer
        try migrator.migrate(writer)
    }
    
    // Write operations
    func saveGameSession(_ session: GameSession) throws {
        try writer.write { db in
            try session.insert(db)
        }
    }
    
    func saveFlagGuess(_ guess: FlagGuess) throws {
        try writer.write { db in
            try guess.insert(db)
        }
    }
}
