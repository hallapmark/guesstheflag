//
//  BlinkViewModifier.swift
//  GuessTheFlag
//
//  Created by Mark Hallap on 2025-08-03.
//

import SwiftUI

struct BlinkViewModifier: ViewModifier {
    // From Priyanka Saroha
    // https://medium.com/swiftable/swiftui-skeletons-e7944085567e
    let duration: Double
    @State private var blinking: Bool = false

    func body(content: Content) -> some View {
        content
            .opacity(blinking ? 0.3 : 1)
            .animation(.easeInOut(duration: duration).repeatForever(), value: blinking)
            .onAppear {
                // Animation will only start when blinking value changes
                blinking.toggle()
            }
    }
}

extension View {
    func blinking(duration: Double = 1) -> some View {
        modifier(BlinkViewModifier(duration: duration))
    }
}
