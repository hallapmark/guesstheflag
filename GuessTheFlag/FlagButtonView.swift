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
    let overlaySymbol: String? 
    
    // Keep these for later activation
    let rotation: Double
    let opacity: Double
    let scale: CGFloat
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Image(imageName)
                    .clipShape(Capsule())
                    .overlay(alignment: .center) {
                        Capsule()
                            .stroke(borderColor, lineWidth: 4)
                            .opacity(borderColor == .clear ? 0 : 1)
                            .animation(.easeInOut(duration: 0.2), value: borderColor)
                    }
                    .shadow(radius: 5)
                
                if let symbol = overlaySymbol {
                    Text(symbol)
                        .font(.system(size: 40))
                        .shadow(radius: 2)
                        .transition(.scale.combined(with: .opacity))
                        .animation(.easeInOut, value: symbol)
                }
            }
            // Optional effects for later testing
            //.rotation3DEffect(.degrees(rotation), axis: (x: 0, y: 1, z: 0))
            //.opacity(opacity)
            //.scaleEffect(scale)
        }
    }
}
