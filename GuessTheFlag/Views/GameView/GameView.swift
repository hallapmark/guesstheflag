//
//  ContentView.swift
//  GuessTheFlag
//
//  Created by Mark Hallap on 2025-07-24.
//

import SwiftUI

struct GameView: View {
    @StateObject private var viewModel = GameViewModel()
    
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
                        )
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
        .alert("Game finished!", isPresented: $viewModel.gameOver) {
            Button("Restart game", action: viewModel.restartGame)
        } message: {
            Text("Your final score is: \(viewModel.score)/\(viewModel.questionsAsked).")
        }
    }
}

#Preview {
    GameView()
}
