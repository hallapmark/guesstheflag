//
//  LocalDatabase+Persistence.swift
//  GuessTheFlag
//
//  Created by Mark Hallap on 2025-08-08.
//

import Foundation
import GRDB

extension LocalDatabase {
    // Public async accessor
    static var shared: LocalDatabase {
        get async {
            return await sharedTask.value // cached after first use
        }
    }

    // Internal cached Task (initialized once)
    private static let sharedTask: Task<LocalDatabase, Never> = Task.detached {
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
            let writer = try DatabaseQueue(path: databaseURL.path)
            return try LocalDatabase(writer)
        } catch {
            fatalError("Failed to create LocalDatabase: \(error)")
        }
    }
}
