//
//  LocalDatabase.swift
//  GuessTheFlag
//
//  Created by Mark Hallap on 2025-08-08.
//

import Foundation
import GRDB

struct LocalDatabase {
    // MARK: PROPERTIES
    private let writer: DatabaseWriter

    var reader: DatabaseReader {
        writer
    }
    
    // MARK: INIT
    // Initialize the database and run migrations.
    init(_ writer: DatabaseWriter) throws {
        self.writer = writer
        try migrator.migrate(writer)
    }
    
    // MARK: WRITE
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
    
    // MARK: READ
    func readAllGameSessions() throws -> [GameSession] {
        try writer.read { db in
            try GameSession.fetchAll(db)
        }
    }
    
    func readAllFlagGuesses() throws -> [FlagGuess] {
        try writer.read { db in
            try FlagGuess.fetchAll(db)
        }
    }

    func readFirstGameSession() throws -> GameSession? {
        try writer.read { db in
            try GameSession.fetchOne(db)
        }
    }
    
    // MARK: DELETE
    func deleteAllGameSessions() throws {
        let _ = try writer.write { db in
            try GameSession.deleteAll(db)
        }
    }

}
