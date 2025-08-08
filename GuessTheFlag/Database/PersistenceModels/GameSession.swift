//
//  GameSession.swift
//  GuessTheFlag
//
//  Created by Mark Hallap on 2025-08-07.
//
import GRDB
import Foundation

// Entity model – 1-on-1 mapping to the SQL schema (see Migrator)
struct GameSession: Identifiable, Codable {
    var id: Int64? = nil
    var date: Date
    var score: Int
}

extension GameSession: FetchableRecord, PersistableRecord { }
