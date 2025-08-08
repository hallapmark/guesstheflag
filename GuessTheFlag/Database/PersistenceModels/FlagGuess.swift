//
//  FlagGuess.swift
//  GuessTheFlag
//
//  Created by Mark Hallap on 2025-08-07.
//
import GRDB

// Entity model – 1-on-1 mapping to SQL schema (see Migrator)
struct FlagGuess: Identifiable, Codable {
    var id: Int64? = nil
    var country: String
    var wasCorrect: Bool
    var gameSessionId: Int64 // links to GameSession
}

extension FlagGuess: FetchableRecord, PersistableRecord { }
