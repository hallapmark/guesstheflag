//
//  GameOverStatsView.swift
//  GuessTheFlag
//
//  Created by Mark Hallap on 2025-08-11.
//
import SwiftUI

struct GameOverStatsView: View {
    let currentScore: Int
    let questionsAsked: Int
    let previousScore: Int?
    let onRestart: () -> Void
    
    @State private var showConfetti = false
    
    var scoreDiff: Int? {
        guard let previous = previousScore else { return nil }
        return currentScore - previous
    }
    
    var body: some View {
        VStack(spacing: 25) {
            Text("Game Finished!")
                .font(.largeTitle.bold())
            
            Text("You guessed \(currentScore)/\(questionsAsked) flags!")
                .font(.title2)
            
            if let diff = scoreDiff {
                if diff > 0 {
                    Text("🎉 That's \(diff) more than your previous session!")
                        .foregroundColor(.green)
                        .onAppear {
                            withAnimation(Animation.easeInOut(duration: 1).repeatForever(autoreverses: true)) {
                                showConfetti = true
                            }
                        }
                } else if diff < 0 {
                    Text("😌 That's \(abs(diff)) less than last time, but keep going!")
                        .foregroundColor(.orange)
                } else {
                    Text("Same score as your last session.")
                        .foregroundColor(.blue)
                }
            } else {
                Text("This is your first recorded session. Keep guessing!")
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button("Restart Game", action: onRestart)
                .buttonStyle(.borderedProminent)
                .font(.title3.bold())
                .padding(.horizontal, 30)
                .padding(.vertical, 10)
            
            Spacer()
        }
        .padding()
        .background(.regularMaterial)
        .cornerRadius(20)
        .padding()
        .overlay(
            Group {
                if showConfetti {
                    ConfettiView()
                        .transition(.scale)
                }
            }
        )
    }
}

struct ConfettiView: View {
    // Simple confetti placeholder: colorful circles falling
    @State private var animate = false
    
    var body: some View {
        GeometryReader { geo in
            ForEach(0..<30, id: \.self) { i in
                Circle()
                    .fill(colors[i % colors.count])
                    .frame(width: 8, height: 8)
                    .position(x: CGFloat.random(in: 0...geo.size.width),
                              y: animate ? geo.size.height + 20 : -20)
                    .animation(
                        Animation.linear(duration: Double.random(in: 2...4))
                            .repeatForever(autoreverses: false)
                            .delay(Double(i) * 0.1),
                        value: animate
                    )
            }
            .onAppear {
                animate = true
            }
        }
        .allowsHitTesting(false)
    }
    
    let colors: [Color] = [.red, .blue, .green, .yellow, .purple, .orange]
}
