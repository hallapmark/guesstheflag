//
//  GuessTheFlagApp.swift
//  GuessTheFlag
//
//  Created by Mark Hallap on 2025-07-24.

// ---- Built following Paul Hudson's 100 Days of SwiftUI, with some enhancements. ----
// https://www.hackingwithswift.com/books/ios-swiftui/guess-the-flag-introduction
//

import SwiftUI

@main
struct GuessTheFlagApp: App {
    var body: some Scene {
        WindowGroup {
            GameView()
        }
    }
}
