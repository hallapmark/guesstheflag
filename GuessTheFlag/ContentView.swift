//
//  ContentView.swift
//  GuessTheFlag
//
//  Created by Mark Hallap on 2025-07-24.
//

import SwiftUI
import UIKit

struct ContentView: View {
    private let numberOfQuestions = 8
    
    @State private var countries = ["Estonia", "France", "Germany", "Ireland", "Italy", "Nigeria", "Poland", "Spain", "UK", "Ukraine", "US"].shuffled()
    @State private var correctAnswer = Int.random(in: 0...2)
    
    @State private var score = 0
    @State private var questionsAsked = 0
    @State private var gameOver = false
    
    @State private var overlaySymbols = [String?](repeating: nil, count: 3)
    @State private var feedbackText: String = ""
    
    @State private var borderColors = [Color](repeating: .clear, count: 3)
    
    @State private var opacityAmount = [1.0, 1.0, 1.0]
    @State private var offsetAmount = [CGFloat](repeating: 0, count: 3)
    
    var body: some View {
        ZStack {
            RadialGradient(stops: [
                .init(color: Color(red: 0.1, green: 0.2, blue: 0.45), location: 0.3),
                .init(color: Color(red: 0.76, green: 0.15, blue: 0.26), location: 0.3)
            ], center: .top, startRadius: 200, endRadius: 700)
            .ignoresSafeArea()
            
            VStack {
                Spacer()
                
                Text("Guess the Flag")
                    .font(.largeTitle.bold())
                    .foregroundStyle(.white)
                
                VStack(spacing: 15) {
                    VStack {
                        Text("Tap the flag of")
                            .foregroundStyle(.secondary)
                            .font(.subheadline.weight(.heavy))
                        
                        Text(countries[correctAnswer])
                            .font(.largeTitle.weight(.semibold))
                    }
                    
                    ForEach(0..<3, id: \.self) { number in
                        FlagButtonView(
                            imageName: countries[number],
                            action: { flagTapped(number) },
                            borderColor: borderColors[number],
                            overlaySymbol: overlaySymbols[number],
                            offset: offsetAmount[number],
                            opacity: opacityAmount[number]
                        )
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .background(.regularMaterial)
                .clipShape(.rect(cornerRadius: 20))
                
                Spacer()
                if questionsAsked == 0 {
                    Text("Click the flag to start")
                        .font(.title.bold())
                        .foregroundStyle(.white)
                        .blinking()
                } else {
                    Text(feedbackText)
                        .foregroundStyle(.white)
                        .font(.headline)
                        .padding(.top, 10)
                }
                Spacer()
                
                Text("Score: \(score)")
                    .foregroundStyle(.white)
                    .font(.title.bold())
                Spacer()
            }.padding()
        }
        .alert("Game finished!", isPresented: $gameOver) {
            Button("Restart game", action: restartGame)
        } message: {
            Text("Your final score is: \(score)/\(questionsAsked).")
        }
    }
    
    private func flagTapped(_ number: Int) {
        let correct = number == correctAnswer
        if correct {
            score += 1
        }
        provideFeedbackForTapped(number: number, correct: correct)
        
        // Delay flag fly-out to allow symbol animation to complete
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            borderColors = [Color](repeating: .clear, count: 3)
            overlaySymbols = [String?](repeating: nil, count: 3)
            withAnimation(.easeIn(duration: 0.7)) {
                for i in 0..<3 {
                    offsetAmount[i] = -300 // flags fly away, left
                    opacityAmount[i] = 0.0
                }
            } completion: { // ease in new question
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    questionsAsked += 1
                    if questionsAsked == numberOfQuestions {
                        gameOver = true
                    } else {
                        askQuestion()
                    }
                }
            }
        }
    }
    
    private func provideFeedbackForTapped(number: Int, correct: Bool) {
        startFeedbackAnimationForTapped(number: number, correct: correct)
        setFeedbackTextForTapped(number: number, correct: correct)
        giveHapticFeedback(correct: correct)
    }
    
    private func startFeedbackAnimationForTapped(number i: Int, correct: Bool) {
        borderColors[i] = correct ? .green : .red
        overlaySymbols[i] = correct ? "✅" : "❌"
    }
    
    private func setFeedbackTextForTapped(number i: Int, correct: Bool) {
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
        self.gameOver = false
        self.questionsAsked = 0
        self.score = 0
        self.askQuestion()
    }
    
    func giveHapticFeedback(correct: Bool) {
        UINotificationFeedbackGenerator()
            .notificationOccurred(correct ? .success : .error)
    }
}

#Preview {
    ContentView()
}
