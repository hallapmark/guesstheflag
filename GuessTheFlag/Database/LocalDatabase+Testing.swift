//
//  LocalDatabase+Test.swift
//  GuessTheFlag
//
//  Created by Mark Hallap on 2025-08-08.
//

import Foundation
import GRDB

extension LocalDatabase {
    static func makeTestDatabase() -> LocalDatabase {
        do {
            let writer = try DatabaseQueue() // in-memory db
            return try LocalDatabase(writer)
        } catch {
            fatalError("Failed to create test database: \(error)")
        }
    }
}
