//
//  LocalDatabaseTests.swift
//  GuessTheFlag
//
//  Created by Mark Hallap on 2025-08-08.
//

import XCTest
@testable import GuessTheFlag

final class LocalDatabaseTests: XCTestCase {
    var db: LocalDatabase!

    override func setUpWithError() throws {
        db = LocalDatabase.makeTestDatabase()
    }

    func testSaveAndFetchGameSession() throws {
        let session = GameSession(date: Date(), score: 7)
        try db.saveGameSession(session)

        let saved = try db.readAllGameSessions()

        XCTAssertEqual(saved.count, 1)
        XCTAssertEqual(saved[0].score, 7)
    }

    func testDateFieldStoresCorrectly() throws {
        let now = Date()
        try db.saveGameSession(GameSession(date: now, score: 3))

        guard let saved = try db.readFirstGameSession() else {
            XCTFail("Failed to fetch saved session")
            return
        }

        XCTAssertEqual(saved.date.timeIntervalSince1970, now.timeIntervalSince1970, accuracy: 0.01)
    }

    func testCascadeDeleteFlagGuesses() throws {
        try db.saveGameSession(GameSession(date: Date(), score: 5))

        guard let sessionId = try db.readFirstGameSession()?.id else {
            XCTFail("No session found")
            return
        }

        try db.saveFlagGuess(
            FlagGuess(country: "France", wasCorrect: true, gameSessionId: sessionId)
        )

        try db.deleteAllGameSessions()

        let guessesLeft = try db.readAllFlagGuesses()
        XCTAssertEqual(guessesLeft.count, 0, "Cascade delete should remove associated FlagGuesses")
    }

}
