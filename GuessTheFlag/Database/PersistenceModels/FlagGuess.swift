//
//  FlagGuess.swift
//  GuessTheFlag
//
//  Created by Mark Hallap on 2025-08-07.
//
import GRDB

// Entity model – 1-on-1 mapping to SQL schema (see Migrator)
struct FlagGuess: Codable {
    var id: Int64? = nil
    // Quirk of GRDB – this is not really optional to have, but the entity
    // only receives the auto-incremented id upon insertion to the db
    // which then gets written back to the struct
    
    var country: String
    var wasCorrect: Bool
    var gameSessionId: Int64 // links to GameSession
}

extension FlagGuess: FetchableRecord, PersistableRecord { }

extension FlagGuess: TableRecord { // enable Swift-language db queries with protocol conformance
    // now enable relationship-based queries
    static let gameSession = belongsTo(GameSession.self)
    var gameSession: QueryInterfaceRequest<GameSession> {
        request(for: FlagGuess.gameSession)
    }
}
