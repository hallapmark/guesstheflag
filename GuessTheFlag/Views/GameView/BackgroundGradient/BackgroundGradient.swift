//
//  BackgroundGradient.swift
//  GuessTheFlag
//
//  Created by Mark Hallap on 2025-08-10.
//


import SwiftUI

struct BackgroundGradient: View {
    var body: some View {
        RadialGradient(stops: [
            .init(color: Color(.backgroundBlue), location: 0.3),
            .init(color: Color(.backgroundRed), location: 0.3)
        ], center: .top, startRadius: 200, endRadius: 700)
        .ignoresSafeArea()
    }
}
