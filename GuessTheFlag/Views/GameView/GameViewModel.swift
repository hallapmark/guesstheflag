//
//  GameViewModel.swift
//  GuessTheFlag
//
//  Created by Mark Hallap on 2025-08-08.
//

import SwiftUI
import Combine

let COUNTRIES = ["Estonia", "France", "Germany", "Ireland", "Italy", "Nigeria", "Poland", "Spain", "UK", "Ukraine", "US"]

struct GameDBError: Error {
    let message: String
}

// In-memory guess model for the current round
struct InMemoryFlagGuess {
    let country: String
    let wasCorrect: Bool
}

@MainActor
class GameViewModel: ObservableObject {
    
    let numberOfQuestions = 7
    
    private var cancellables = Set<AnyCancellable>()
    private let haptics = UINotificationFeedbackGenerator()
    
    // MARK: - Published properties that affect the UI
    @Published var countries: [String] = COUNTRIES.shuffled()
    @Published var correctAnswer: Int = Int.random(in: 0...2)
    
    // Reset when starting new round --->
    @Published var questionsAsked = 0
    @Published var score = 0
    @Published var gameOver = false
    @Published var showStatsModal = false
    // In-memory guesses for the current game session (saved to db at game over)
    private(set) var flagGuesses: [InMemoryFlagGuess] = []
    // <--- Reset when starting new round
    
    @Published var canTapFlag = true
    
    @Published var overlaySymbols = [String?](repeating: nil, count: 3)
    @Published var feedbackText = ""
    @Published var borderColors = [Color](repeating: .clear, count: 3)
    @Published var opacityAmount = [1.0, 1.0, 1.0]
    @Published var offsetAmount = [CGFloat](repeating: 0, count: 3)
    
    @Published var previousSessionScore: Int? = nil
    
    func prepareHaptics() {
        haptics.prepare()
    }
    
    func flagTapped(_ number: Int) {
        guard !gameOver else { return }
        guard canTapFlag else { return } // Prevent multiple taps during animation
        canTapFlag = false
        
        let correct = number == correctAnswer
        if correct {
            score += 1
        }
        // Save guess in memory (no sessionId yet)
        let guess = InMemoryFlagGuess(
            country: countries[number],
            wasCorrect: correct
        )
        flagGuesses.append(guess)
        
        provideFeedbackForTapped(number: number, correct: correct)
        
        // Delay flag fly-out to allow symbol animation to complete
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            self.borderColors = [Color](repeating: .clear, count: 3)
            self.overlaySymbols = [String?](repeating: nil, count: 3)
            withAnimation(.easeIn(duration: 0.7)) {
                for i in 0..<3 {
                    self.offsetAmount[i] = -300 // flags fly away, left
                    self.opacityAmount[i] = 0.0
                }
            } completion: {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    // self is strong here to guarantee that handleGameOver()
                    // runs when needed.
                    self.questionsAsked += 1
                    if self.questionsAsked == self.numberOfQuestions {
                        self.gameOver = true
                        Task { await self.handleGameOver() }
                    } else {
                        self.askQuestion()
                    }
                }
            }
        }
    }
    
    func provideFeedbackForTapped(number: Int, correct: Bool) {
        startFeedbackAnimationForTapped(number: number, correct: correct)
        setFeedbackTextForTapped(number: number, correct: correct)
        giveHapticFeedback(correct: correct)
    }
    
    func startFeedbackAnimationForTapped(number i: Int, correct: Bool) {
        borderColors[i] = correct ? .green : .red
        overlaySymbols[i] = correct ? "✅" : "❌"
    }
    
    func setFeedbackTextForTapped(number i: Int, correct: Bool) {
        feedbackText = correct ? "✅ Correct!" : "🫩 Wrong!"
    }
    
    func giveHapticFeedback(correct: Bool) {
        haptics.notificationOccurred(correct ? .success : .error)
    }
    
    func askQuestion() {
        feedbackText = ""
        countries.shuffle()
        correctAnswer = Int.random(in: 0...2)
        // Reset offsets and fade in
        for i in 0..<3 {
            offsetAmount[i] = 0
        }
        withAnimation(.easeIn(duration: 0.9)) {
            for i in 0..<3 {
                opacityAmount[i] = 1.0
            }
        }
        canTapFlag = true // Allow taps again
    }
    
    func handleGameOver() async {
        let session = GameSession(id: nil, date: Date(), score: score, completed: true)
        let db = await LocalDatabase.shared
        
        Just(session)
            .subscribe(on: DispatchQueue.global(qos: .userInitiated))
            .tryMap { [self] session -> Int64 in // strong self to guarantee db save
                // Save game session and guesses to the database
                let savedSession = try db.saveGameSession(session)
                guard let savedSessionId = savedSession.id else {
                    throw GameDBError(message: "Failed to get saved session id")
                }
                // Save in-memory guesses to the DB (id created upon insert)
                let guessesToSave = flagGuesses.map { guess in
                    FlagGuess(id: nil, country: guess.country, wasCorrect: guess.wasCorrect, gameSessionId: savedSessionId)
                }
                try db.saveFlagGuesses(guessesToSave)
                return savedSessionId
            }
            .flatMap { [weak self] (savedSessionId: Int64) in
                // Switching to weak self from here on
                // for UI updates (i.e. check that we still have the view)
                guard self != nil else {
                    return Empty<Int?, Error>(completeImmediately: true).eraseToAnyPublisher()
                }
                return Future<Int?, Error> { promise in
                    do {
                        let previous = try db.fetchPreviousGameSession(currentSessionId: savedSessionId)
                        promise(.success(previous?.score))
                    } catch {
                        promise(.failure(error))
                    }
                }
                .eraseToAnyPublisher()            }
            .receive(on: DispatchQueue.main) // UI
            .sink(receiveCompletion: { [weak self] completion in
                guard let self else {
                    return
                }
                if case .failure(let error) = completion {
                    print("Failed to save session or guesses: \(error)")
                }
                // Current session saved, previous session fetched. Show comparison stats modal
                self.showStatsModal = true
            }, receiveValue: { [weak self] previousScore in
                self?.previousSessionScore = previousScore
            })
            .store(in: &cancellables)
    }
    
    func restartGame() {
        // reset progress and state
        questionsAsked = 0
        score = 0
        gameOver = false
        showStatsModal = false
        flagGuesses = []
        
        overlaySymbols = [String?](repeating: nil, count: 3)
        borderColors = [Color](repeating: .clear, count: 3)
        
        askQuestion()
    }
}
