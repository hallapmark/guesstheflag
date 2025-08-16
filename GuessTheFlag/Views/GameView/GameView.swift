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
        GameContentView(viewModel: viewModel)
            .onAppear {
                viewModel.askQuestion()
            }
    }
}

#Preview {
    GameView()
}
