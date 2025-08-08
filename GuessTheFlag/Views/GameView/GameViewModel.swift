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
    let numberOfQuestions = 8
    
    // MARK: - Published properties that affect the UI
    @Published var countries: [String] = ["Estonia", "France", "Germany", "Ireland", "Italy", "Nigeria", "Poland", "Spain", "UK", "Ukraine", "US"].shuffled()
    @Published var correctAnswer: Int = Int.random(in: 0...2)
    
    @Published var score = 0
    @Published var questionsAsked = 0
    @Published var gameOver = false
    
    @Published var overlaySymbols = [String?](repeating: nil, count: 3)
    @Published var feedbackText = ""
    
    @Published var borderColors = [Color](repeating: .clear, count: 3)
    
    @Published var opacityAmount = [1.0, 1.0, 1.0]
    @Published var offsetAmount = [CGFloat](repeating: 0, count: 3)
    
    // MARK: - Public interface
    
    func flagTapped(_ number: Int) {
        let correct = number == correctAnswer
        if correct {
            score += 1
        }
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
                    self.questionsAsked += 1
                    if self.questionsAsked == self.numberOfQuestions {
                        self.gameOver = true
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
    }
    
    func restartGame() {
        gameOver = false
        questionsAsked = 0
        score = 0
        askQuestion()
    }
    
    func giveHapticFeedback(correct: Bool) {
        UINotificationFeedbackGenerator()
            .notificationOccurred(correct ? .success : .error)
    }
}
