//
//  GameContentView.swift
//  GuessTheFlag
//
//  Created by Mark Hallap on 2025-08-10.
//

import SwiftUI

struct GameContentView: View {
    @ObservedObject var viewModel: GameViewModel
    
    var body: some View {
        ZStack {
            BackgroundGradient()
            
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
                        
                        Text(viewModel.countries[viewModel.correctAnswer])
                            .font(.largeTitle.weight(.semibold))
                    }
                    
                    ForEach(0..<3, id: \.self) { number in
                        FlagButtonView(
                            imageName: viewModel.countries[number],
                            action: { viewModel.flagTapped(number) },
                            borderColor: viewModel.borderColors[number],
                            overlaySymbol: viewModel.overlaySymbols[number],
                            offset: viewModel.offsetAmount[number],
                            opacity: viewModel.opacityAmount[number]
                        ).disabled(!viewModel.canTapFlag)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .background(.regularMaterial)
                .clipShape(.rect(cornerRadius: 20))
                
                Spacer()
                
                if viewModel.questionsAsked == 0 {
                    Text("Click the flag to start")
                        .font(.title.bold())
                        .foregroundStyle(.white)
                        .blinking()
                } else {
                    Text(viewModel.feedbackText)
                        .foregroundStyle(.white)
                        .font(.headline)
                        .padding(.top, 10)
                }
                
                Spacer()
                
                Text("Score: \(viewModel.score)")
                    .foregroundStyle(.white)
                    .font(.title.bold())
                
                Spacer()
            }
            .padding()
        }
        .sheet(isPresented: $viewModel.showStatsModal) {
            GameOverStatsView(
                currentScore: viewModel.score,
                questionsAsked: viewModel.questionsAsked,
                previousScore: viewModel.previousSessionScore,
                onRestart: viewModel.restartGame
            )
        }
    }
}

#Preview {
    GameContentView(viewModel: GameViewModel())
}
