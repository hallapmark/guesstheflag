//
//  GameViewModel.swift
//  GuessTheFlag
//
//  Created by Mark Hallap on 2025-08-08.
//

import SwiftUI
import Combine

@MainActor
class GameViewModel: ObservableObject {
    let numberOfQuestions = 6
    
    let db = LocalDatabase.shared
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Published properties that affect the UI
    @Published var isLoadingSession = true
    
    // DB session - reset when starting new round
    @Published var session: GameSession?
    
    @Published var countries: [String] = ["Estonia", "France", "Germany", "Ireland", "Italy", "Nigeria", "Poland", "Spain", "UK", "Ukraine", "US"].shuffled()
    @Published var correctAnswer: Int = Int.random(in: 0...2)
    
    // Reset when starting new round --->
    @Published var score = 0
    @Published var questionsAsked = 0
    @Published var gameOver = false
    @Published var canTapFlag = true
    // <--- Reset when starting new round
    
    @Published var overlaySymbols = [String?](repeating: nil, count: 3)
    @Published var feedbackText = ""
    @Published var borderColors = [Color](repeating: .clear, count: 3)
    @Published var opacityAmount = [1.0, 1.0, 1.0]
    @Published var offsetAmount = [CGFloat](repeating: 0, count: 3)
    
    // MARK: - Published properties for DB
    @Published private(set) var flagGuesses: [FlagGuess] = []
    
    // MARK: - Public interface
    func flagTapped(_ number: Int) {
        guard !gameOver else { return }
        guard canTapFlag else { return } // Prevent multiple taps during animation
        canTapFlag = false
        
        let correct = number == correctAnswer
        if correct {
            score += 1
        }
        
        // Append guess with current session ID
        if let sessionId = session?.id {
            let guess = FlagGuess(
                id: nil,
                country: countries[number],
                wasCorrect: correct,
                gameSessionId: sessionId
            )
            flagGuesses.append(guess)
        } // We save to memory. We only save to the DB at the end of the round.
        // Information on incomplete rounds is abandoned.
        
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
                        self.handleGameOver()
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
        UINotificationFeedbackGenerator()
            .notificationOccurred(correct ? .success : .error)
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
    
    func handleGameOver() {
        self.gameOver = true
        guard var currentSession = session else { return }
        currentSession.score = score
        let guessesToSave = flagGuesses
        
        DispatchQueue.global(qos: .userInitiated).async {
            // self is kept strong here, we want to guarantee that the db save happens
            self.saveSessionAndGuesses(session: currentSession, flagGuesses: guessesToSave)
        }
    }
    
    func restartGame() {
        flagGuesses = []
        gameOver = false
        questionsAsked = 0
        score = 0
        createNewSession()
    }
    
    // Update session and save guesses to DB
    nonisolated func saveSessionAndGuesses(session: GameSession, flagGuesses: [FlagGuess]) {
        do {
            // Save updated session score
            try db.updateGameSession(session)
            // Save all guesses
            try db.saveFlagGuesses(flagGuesses)
            print("Saved session and guesses")
        } catch {
            print("Failed to save session: \(error)")
        }
    }
    
    func createNewSession() {
        // Creates a new DB session.
        isLoadingSession = true
        let newSession = GameSession(id: nil, date: Date(), score: 0)
        
        Just(newSession)
            .subscribe(on: DispatchQueue.global(qos: .userInitiated)) // background insert
            .tryMap { [db] session in
                return try db.saveGameSession(session) // returns GameSession with id
            }
            .receive(on: DispatchQueue.main) // back to UI
            .sink(receiveCompletion: { [weak self] completion in
                if case .failure(let error) = completion {
                    print("Error creating session: \(error)")
                }
                self?.isLoadingSession = false
            }, receiveValue: { [weak self] savedSession in
                self?.session = savedSession
                if let id = savedSession.id {
                    print("Session created with id: \(id)")
                }
                self?.askQuestion()
            })
            .store(in: &cancellables)
    }
}
