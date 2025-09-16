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
    func saveGameSession(_ session: GameSession) throws -> GameSession {
        try writer.write { db in
            return try session.inserted(db) // returns GameSession with the db-created id
        }
    }
    
    func updateGameSession(_ session: GameSession) throws {
        try writer.write { db in
            try session.update(db)
        }
    }

    func saveFlagGuess(_ guess: FlagGuess) throws {
        try writer.write { db in
            try guess.insert(db)
        }
    }
    
    /// Saves multiple guesses in a single transaction
    func saveFlagGuesses(_ guesses: [FlagGuess]) throws {
        guard !guesses.isEmpty else { return }
        try writer.write { db in
            for guess in guesses {
                try guess.insert(db)
            }
        }
    }
    
    // MARK: READ
    func readAllGameSessions() throws -> [GameSession] {
        try reader.read { db in
            try GameSession.fetchAll(db)
        }
    }

    func readFirstGameSession() throws -> GameSession? {
        try reader.read { db in
            try GameSession.fetchOne(db)
        }
    }
    
    func fetchPreviousGameSession(currentSessionId: Int64) throws -> GameSession? {
        try reader.read { db in
            try GameSession
                .filter(Column("id") < currentSessionId)
                .filter(Column("completed") == true)
                .order(Column("id").desc)
                .fetchOne(db)
        }
    }
    
    func readAllFlagGuesses() throws -> [FlagGuess] {
        try reader.read { db in
            try FlagGuess.fetchAll(db)
        }
    }
    
    // MARK: DELETE
    func deleteAllGameSessions() throws {
        let _ = try writer.write { db in
            try GameSession.deleteAll(db)
        }
    }

}
