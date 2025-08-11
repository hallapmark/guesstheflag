//
//  GameSession.swift
//  GuessTheFlag
//
//  Created by Mark Hallap on 2025-08-07.
//
import GRDB
import Foundation

// See https://swiftpackageindex.com/groue/GRDB.swift/v7.6.1/documentation/grdb/recordrecommendedpractices
// esp. for autoincremented keys.

// Entity model – 1-on-1 mapping to the SQL schema (see Migrator)
struct GameSession: Codable {
    var id: Int64? = nil
    var date: Date
    var score: Int
}

extension GameSession: FetchableRecord, MutablePersistableRecord {
    // Update auto-incremented id upon successful insertion
    mutating func didInsert(_ inserted: InsertionSuccess) {
        id = inserted.rowID
    }
}

// enable Swift-language db queries
extension GameSession: TableRecord {
    static let flagGuesses = hasMany(FlagGuess.self)
    
    var flagGuesses: QueryInterfaceRequest<FlagGuess> {
        request(for: GameSession.flagGuesses)
    }
}


