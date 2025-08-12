//
//  LocalDatabase+Persistence.swift
//  GuessTheFlag
//
//  Created by Mark Hallap on 2025-08-08.
//

import Foundation
import GRDB

extension LocalDatabase {
    static let shared: LocalDatabase = {
        do {
            let fileManager = FileManager.default

            let folder = try fileManager.url(
                for: .applicationSupportDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: true
            ).appendingPathComponent("database", isDirectory: true)

            try fileManager.createDirectory(at: folder, withIntermediateDirectories: true)

            let databaseURL = folder.appendingPathComponent("db.sqlite")

            // Use DatabaseQueue for simplicity
            let writer = try DatabaseQueue(path: databaseURL.path)

            let db = try LocalDatabase(writer)
            return db
        } catch {
            fatalError("Failed to create LocalDatabase: \(error)")
        }
    }()
}
