//
//  FlagButtonView.swift
//  GuessTheFlag
//
//  Created by Mark Hallap on 2025-08-03.
//

import SwiftUI

struct FlagButtonView: View {
    let imageName: String
    let action: () -> Void
    let borderColor: Color
    
    // Keep these for later activation
    let rotation: Double
    let opacity: Double
    let scale: CGFloat
    
    var body: some View {
        Button(action: action) {
            Image(imageName)
                // Optional sizing (uncomment if needed for consistency)
                //.resizable()
                //.frame(width: 200, height: 100)
                
                .clipShape(Capsule())
                
                .overlay(alignment: .center) {
                    Capsule()
                        .stroke(borderColor, lineWidth: 4)
                        .opacity(borderColor == .clear ? 0 : 1)
                        .animation(.easeInOut(duration: 0.2), value: borderColor)
                }
                
                .shadow(radius: 5)
                
                // Optional effects for later testing
                //.rotation3DEffect(.degrees(rotation), axis: (x: 0, y: 1, z: 0))
                //.opacity(opacity)
                //.scaleEffect(scale)
        }
    }
}
