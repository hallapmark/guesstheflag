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
    
    // Feedback (e.g. green border, green checkmark overlayed)
    let borderColor: Color
    let overlaySymbol: String? 
    
    // Ease-in, ease-out
    let offset: CGFloat
    let opacity: Double
    
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
                    .offset(x: offset)
                    .opacity(opacity)
                
                if let symbol = overlaySymbol {
                    Text(symbol)
                        .font(.system(size: 40))
                        .shadow(radius: 2)
                        .transition(.scale.combined(with: .opacity))
                        .animation(.easeInOut, value: symbol)
                }
            }
        }
    }
}
