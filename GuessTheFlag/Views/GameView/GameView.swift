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
            if viewModel.isLoadingNewSession {
                loadingView
            } else {
                GameContentView(viewModel: viewModel)
                    .disabled(viewModel.currentSession == nil)
            }
        }
        .onAppear {
            viewModel.createNewSession()
        }
    }
    
    private var loadingView: some View {
        ZStack {
            BackgroundGradient()
            
            ProgressView("Starting Game...")
                .font(.title2)
                .foregroundStyle(.white)
        }
    }
}

#Preview {
    GameView()
}
